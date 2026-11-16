--!nocheck
--[[
	Proximity · Widgets/Loader
	The planet intro.

	1. The screen dims. About 1500 points fly in along soft arcs and land on a
	   planet with a tilted ring that is already turning on its own axis.
	2. The planet is really built from them: a ViewportFrame holds a 3D model
	   made of ~500 surface tiles and ~290 ring segments. A build front sweeps
	   over the planet in its own space; where it passes, the points flash and
	   fuse, and the tiles under them appear (white first, then their colour).
	   Back points show through the unfinished shell and vanish as the front
	   side closes. The ring is laid down segment by segment around its circle.
	3. Points and model share one geometry, camera, tilt and spin, so the
	   points turn into the model in place - nothing is swapped for a picture.
	4. When it is whole: a lit crescent, a pulsing flare with a streak, a soft
	   halo; it keeps spinning while the bar shows real progress and time left.
	5. When everything is ready the model breaks back into points that burst
	   outward with a flash and a shock wave, and the window grows out of it.
]]

local Util = require("../Core/Util")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")
local Theme = require("../Theme")
local Locale = require("../Locale")
local Shared = require("../Shared")

local RunService = Env.Service("RunService")
local UserInputService = Env.Service("UserInputService")

local Loader = {}
Loader.__index = Loader

local PHONE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
-- geometry shared by the point cloud and the 3D model (studs = pixels / RADIUS)
local SPHERE, RING = PHONE and 560 or 900, PHONE and 380 or 600
local TILES = PHONE and 330 or 520
local RADIUS = 92 -- planet radius on screen, px
local RING_IN, RING_OUT = 1.36, 2.02 -- ring radii in planet radii
local STAGE = 420 -- stage and viewport size, px
local FOV = 30
local DIST = (STAGE / 2) / (RADIUS * math.tan(math.rad(FOV / 2))) -- camera distance for that radius
local TILT_Z, TILT_X = math.rad(17), math.rad(15) -- ring seen almost edge on, rising to the right
local FRAME = CFrame.Angles(0, 0, TILT_Z) * CFrame.Angles(TILT_X, 0, 0) -- planet axis = ring normal
local LIGHT = Vector3.new(0.72, 0.55, 0.42).Unit
local SPIN = 0.3 -- rad / s, turns in place around its axis
local BUILD_AT, BUILD_FOR = 1.45, 1.9 -- when the surface starts forming, and for how long
local TAU = math.pi * 2

local SHADES = {}
for i = 0, 11 do
	local v = i / 11
	SHADES[i] = Color3.new(v, v, v)
end
local WHITE = Color3.new(1, 1, 1)

local function rotY(v, a)
	local c, s = math.cos(a), math.sin(a)
	return Vector3.new(v.X * c + v.Z * s, v.Y, -v.X * s + v.Z * c)
end
local function rotX(v, a)
	local c, s = math.cos(a), math.sin(a)
	return Vector3.new(v.X, v.Y * c - v.Z * s, v.Y * s + v.Z * c)
end
local function rotZ(v, a)
	local c, s = math.cos(a), math.sin(a)
	return Vector3.new(v.X * c - v.Y * s, v.X * s + v.Y * c, v.Z)
end
-- planet space -> what the camera sees (matches FRAME * CFrame.Angles(0, spin, 0))
local function toView(v, spin)
	return rotZ(rotX(rotY(v, spin), TILT_X), TILT_Z)
end
local function toObject(v, spin)
	return rotY(rotX(rotZ(v, -TILT_Z), -TILT_X), -spin)
end

local function smooth(x)
	x = math.clamp(x, 0, 1)
	return x * x * (3 - 2 * x)
end

-- the order in which the surface forms, in planet space (same as the website)
local function thrSphere(o)
	return math.clamp(0.5 + 0.24 * math.sin(3.7 * o.X + 1.3 + 2.0 * o.Y) + 0.2 * math.sin(3.1 * o.Y + 2.1) * math.cos(2.9 * o.Z - 0.6) + 0.14 * math.sin(5.3 * o.Z + 1.7 * o.X + 0.4), 0.02, 0.98)
end
local function thrRing(theta, r)
	return math.clamp(0.08 + 0.8 * (theta % TAU) / TAU + 0.12 * (r - RING_IN) / 0.6, 0, 1)
end

-- how far the front of the planet at view position (x, y) is already solid
local function coverAt(x, y, spin, b)
	local z = math.sqrt(math.max(0, 1 - x * x - y * y))
	local o = toObject(Vector3.new(x, y, z), spin)
	return math.clamp((b - thrSphere(o)) / 0.05, 0, 1)
end

-- ─── the 3D model ─────────────────────────────────────────────────────────
local function part(props)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	for k, v in props do
		p[k] = v
	end
	return p
end

-- surface colour: soft bands bent by turbulence plus a few storms, so the
-- turning reads clearly on the lit side while the planet stays near black
local STORMS = {}
do
	local rng = Random.new(11)
	for _ = 1, 6 do
		table.insert(STORMS, { Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-0.6, 0.6), rng:NextNumber(-1, 1)).Unit, rng:NextNumber(0.14, 0.3) })
	end
end
local function surfaceColor(o)
	local turb = math.sin(3.1 * o.X + 1.7 * o.Z) * 0.5 + math.sin(4.3 * o.Z - 2.1 * o.Y) * 0.3 + math.sin(5.7 * o.X + 3.3 * o.Y) * 0.2
	local bands = 0.5 + 0.5 * math.sin(o.Y * 15 + turb * 3)
	local storm = 0
	for _, st in STORMS do
		local d = (o - st[1]).Magnitude
		storm = math.max(storm, math.exp(-(d / st[2]) ^ 2))
	end
	local v = 10 + bands * 14 * (0.7 + 0.3 * turb) + storm * 34
	return Color3.fromRGB(v, v, v + 3)
end

local function buildModel(viewport)
	local rng = Random.new(7)
	local camera = Instance.new("Camera")
	camera.FieldOfView = FOV
	camera.CFrame = CFrame.new(0, 0, DIST)
	camera.Parent = viewport
	viewport.CurrentCamera = camera

	local model = Instance.new("Model")
	model.Name = "Planet"
	local body = part({ Name = "Body", Shape = Enum.PartType.Ball, Size = Vector3.one * 1.985, Color = Color3.fromRGB(9, 9, 11), Transparency = 1 })
	body.Parent = model
	model.PrimaryPart = body

	-- surface tiles on a Fibonacci sphere, overlapping a little
	local tiles = {}
	local golden = math.pi * (3 - math.sqrt(5))
	local size = 0.235 * math.sqrt(520 / TILES)
	for i = 0, TILES - 1 do
		local y = 1 - (i / (TILES - 1)) * 2
		local r = math.sqrt(1 - y * y)
		local th = golden * i
		local dir = Vector3.new(math.cos(th) * r, y, math.sin(th) * r)
		local color = surfaceColor(dir)
		local tile = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.02, size, size), Color = color, Transparency = 1 })
		tile.CFrame = CFrame.lookAt(dir * 0.993, dir * 2) * CFrame.Angles(0, math.rad(90), 0)
		tile.Parent = model
		table.insert(tiles, { Part = tile, Thr = thrSphere(dir), Color = color, M = -1 })
	end

	-- the ring: dusty neon segments in four bands
	local segs = {}
	local bands = { { 1.40, 0.16, 0.55 }, { 1.60, 0.20, 0.35 }, { 1.80, 0.12, 0.6 }, { 1.95, 0.08, 0.75 } }
	local count = 72
	for _, band in bands do
		local r, width, base = band[1], band[2], band[3]
		local length = (TAU * r) / count * 1.08
		for i = 0, count - 1 do
			local a = (i / count) * TAU
			local dust = 0.5 + 0.25 * math.sin(a * 3 + r * 4) + 0.15 * math.sin(a * 7 + r) + rng:NextNumber(-0.12, 0.12)
			local seg = part({
				Size = Vector3.new(width, 0.004, length),
				Color = Color3.fromRGB(235, 235, 240),
				Material = Enum.Material.Neon,
				Transparency = 1,
			})
			seg.CFrame = CFrame.new(math.cos(a) * r, 0, math.sin(a) * r) * CFrame.Angles(0, -a, 0)
			seg.Parent = model
			-- a segment at angle a sits where a ring point with theta = a does
			table.insert(segs, { Part = seg, Thr = thrRing(a, r), Base = math.clamp(base + (1 - dust) * 0.4, 0.25, 0.97), M = -1 })
		end
	end
	model.Parent = viewport
	return model, body, tiles, segs
end

-- ─── loader ───────────────────────────────────────────────────────────────
function Loader.new(window, options)
	options = options or {}
	local self = setmetatable({}, Loader)
	self.Window = window
	self.Started = os.clock()
	self.Points = {}
	self.Angle = 0
	self.Display = 0
	self.Samples = {}
	self.Solid = 1
	self.Build = 0

	local root = Util.New("Frame", { Name = "ProximityLoader", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 300, Parent = Shared.Gui.Root })
	self.Root = root
	local dim = Util.New("Frame", { BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 300, Parent = root })
	Util.Gradient(dim, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 0.2) }), 90)
	Tween.Play(dim, { BackgroundTransparency = options.Dim or 0.22 }, 0.7, Enum.EasingStyle.Sine)
	self.Dim = dim

	local stage = Util.New("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.46), Size = UDim2.fromOffset(STAGE, STAGE), ZIndex = 301, Parent = root })
	local view = workspace.CurrentCamera.ViewportSize
	local scale = Util.New("UIScale", { Scale = math.clamp(math.min(view.X, view.Y) / 820, 0.55, 1.2), Parent = stage })
	self.Stage, self.Scale = stage, scale
	self.Center = Vector2.new(STAGE / 2, STAGE / 2)
	local c = self.Center

	-- halo behind everything
	local halo = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(c.X, c.Y), Size = UDim2.fromOffset(RADIUS * 3.6, RADIUS * 3.6), BackgroundColor3 = WHITE, BackgroundTransparency = 1, ZIndex = 301, Parent = stage })
	Util.Round(halo)
	Util.Gradient(halo, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.6, 0.995), NumberSequenceKeypoint.new(0.85, 0.975), NumberSequenceKeypoint.new(1, 0.96) }), -45)
	self.Halo = halo

	-- the bright crescent: a white disc just behind the model, nudged towards
	-- the light, so only a thin lit limb peeks out around the planet
	local crescent = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(c.X + 1.6, c.Y - 1.4), Size = UDim2.fromOffset(RADIUS * 2 + 3, RADIUS * 2 + 3), BackgroundColor3 = WHITE, BackgroundTransparency = 1, ZIndex = 302, Parent = stage })
	Util.Round(crescent)
	Util.Gradient(crescent, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.6, 1), NumberSequenceKeypoint.new(0.85, 0.3), NumberSequenceKeypoint.new(1, 0) }), -40)
	self.Crescent = crescent

	-- the model
	local viewport = Util.New("ViewportFrame", {
		Name = "Model",
		BackgroundTransparency = 1,
		ImageTransparency = 0,
		Size = UDim2.fromOffset(STAGE, STAGE),
		Ambient = Color3.fromRGB(14, 14, 18),
		LightColor = Color3.fromRGB(165, 165, 175),
		LightDirection = -LIGHT,
		ZIndex = 303,
		Parent = stage,
	})
	self.Viewport = viewport
	Util.New("UIGradient", {
		Rotation = -28,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 150, 156)),
			ColorSequenceKeypoint.new(0.45, Color3.fromRGB(205, 205, 210)),
			ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
		}),
		Parent = viewport,
	})
	local ok, planet, body, tiles, segs = pcall(buildModel, viewport)
	if ok then
		self.Planet, self.Body, self.Tiles, self.Segs = planet, body, tiles, segs
	end

	-- soft rim light over the model
	local rim = Util.New("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(c.X, c.Y), Size = UDim2.fromOffset(RADIUS * 2 + 2, RADIUS * 2 + 2), ZIndex = 304, Parent = stage })
	Util.Round(rim)
	local rimStroke = Util.Stroke(rim, WHITE, 1.6, 1)
	Util.Gradient(rimStroke, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.6, 1), NumberSequenceKeypoint.new(0.82, 0.35), NumberSequenceKeypoint.new(0.93, 0), NumberSequenceKeypoint.new(1, 0.3) }), -40)
	self.RimStroke = rimStroke

	-- points (same geometry as the model, in planet space)
	local rng = Random.new(42)
	local golden = math.pi * (3 - math.sqrt(5))
	for i = 0, SPHERE - 1 do
		local y = 1 - (i / (SPHERE - 1)) * 2
		local r = math.sqrt(1 - y * y)
		local theta = golden * i
		local base = Vector3.new(math.cos(theta) * r, y, math.sin(theta) * r)
		table.insert(self.Points, { Base = base, Kind = "Sphere", Thr = thrSphere(base) })
	end
	for _ = 1, RING do
		local t = rng:NextNumber() * TAU
		local rr = RING_IN + (RING_OUT - RING_IN) * (rng:NextNumber() ^ 1.4)
		table.insert(self.Points, { Base = Vector3.new(math.cos(t) * rr, 0, math.sin(t) * rr), Kind = "Ring", Thr = thrRing(t, rr), Glint = rng:NextNumber() < 0.06 })
	end
	for _, p in self.Points do
		local size = (p.Kind == "Ring" and p.Glint) and 3 or 2
		p.Frame = Util.New("Frame", { BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(size, size), BackgroundColor3 = WHITE, BackgroundTransparency = 1, ZIndex = 305, Parent = stage })
		p.Curl = (rng:NextNumber() < 0.5 and -1 or 1) * (2.2 + rng:NextNumber() * 1.6)
		p.Grow = 1.6 + rng:NextNumber() * 2.2
		p.Lift = (rng:NextNumber() - 0.5) * 1.8
		local tone = rng:NextNumber()
		p.Tone = tone < 0.45 and 1 or tone < 0.75 and 0.62 or 0.36
		p.Delay = p.Thr * 0.6 + rng:NextNumber() * 0.3
		p.Seed = rng:NextNumber() * 10
	end

	-- flare + streaks
	local flare = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(10, 10), BackgroundColor3 = WHITE, BackgroundTransparency = 1, ZIndex = 307, Parent = stage })
	Util.Round(flare)
	local flareGlow = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(24, 24), BackgroundColor3 = WHITE, BackgroundTransparency = 1, ZIndex = 306, Parent = flare })
	Util.Round(flareGlow)
	local streak = Util.New("Frame", { AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(190, 1), BorderSizePixel = 0, BackgroundColor3 = WHITE, BackgroundTransparency = 1, ZIndex = 307, Parent = stage })
	Util.Gradient(streak, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }))
	local streak2 = streak:Clone()
	streak2.AnchorPoint = Vector2.new(1, 0.5)
	streak2.Size = UDim2.fromOffset(70, 1)
	streak2.Parent = stage
	streak2:FindFirstChildOfClass("UIGradient").Rotation = 180
	self.Flare, self.FlareGlow, self.Streak, self.Streak2 = flare, flareGlow, streak, streak2

	self:_buildProgress(root, scale.Scale)
	self.Conn = RunService.RenderStepped:Connect(function(dt)
		self:_step(dt)
	end)
	return self
end

function Loader:_buildProgress(root, s)
	local info = Util.New("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.46, (STAGE / 2) * s * 0.88), Size = UDim2.fromOffset(300, 64), ZIndex = 301, Parent = root })
	local function label(props)
		local l = Util.Label(props)
		l.TextTransparency = 1
		l.ZIndex = 301
		l.Parent = info
		return l
	end
	local title = label({ Text = self.Window.Title, FontFace = Theme.Fonts.SemiBold, TextSize = 14, Size = UDim2.new(1, -60, 0, 18) })
	title.TextColor3 = WHITE
	local pct = label({ Text = "0%", FontFace = Theme.Fonts.MonoBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, 0, 0, 18) })
	pct.TextColor3 = WHITE
	local track = Util.New("Frame", { Size = UDim2.new(1, 0, 0, 3), Position = UDim2.fromOffset(0, 25), BackgroundColor3 = WHITE, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 301, Parent = info })
	Util.Round(track)
	local fill = Util.New("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 302, Parent = track })
	Util.Round(fill)
	local glow = Util.New("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(18, 8), BackgroundColor3 = WHITE, BackgroundTransparency = 0.55, BorderSizePixel = 0, ZIndex = 302, Parent = fill })
	Util.Round(glow)
	local status = label({ Text = Locale.T("Preparing"), FontFace = Theme.Fonts.Regular, TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -70, 0, 16), Position = UDim2.fromOffset(0, 36) })
	status.TextColor3 = Color3.fromRGB(170, 170, 178)
	local eta = label({ Text = "", FontFace = Theme.Fonts.Mono, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, 0, 0, 16), Position = UDim2.fromOffset(0, 36) })
	eta.TextColor3 = Color3.fromRGB(120, 120, 128)
	self.Info, self.Pct, self.Fill, self.Track, self.Status, self.Eta, self.TitleLabel = info, pct, fill, track, status, eta, title
	task.delay(0.5, function()
		if self.Root then
			for _, l in { title, pct, status, eta } do
				Tween.Play(l, { TextTransparency = 0 }, 0.6)
			end
			Tween.Play(track, { BackgroundTransparency = 0.86 }, 0.6)
		end
	end)
end

function Loader:_step(dt)
	local t = os.clock() - self.Started
	if t > BUILD_AT then
		self.Build = math.min(1, self.Build + dt / BUILD_FOR * (self.Hurry and 2.5 or 1))
	end
	local b = -0.08 + 1.16 * smooth(self.Build)
	if self.Exploding then
		self.Solid = math.max(0, self.Solid - dt / 0.12)
	end
	self.Angle += dt * (self.Exploding and 0.15 or SPIN)
	local spin = self.Angle
	local c = self.Center
	local settle = self.Exploding and 0 or smooth((b - 0.7) / 0.35)

	-- model: tiles and ring segments appear behind the build front
	if self.Planet then
		self.Planet:PivotTo(FRAME * CFrame.Angles(0, spin, 0))
		self.Viewport.ImageTransparency = 1 - self.Solid
		if not self.Built then
			for _, tile in self.Tiles do
				local m = math.floor(math.clamp((b - tile.Thr) / 0.07, 0, 1) * 10 + 0.5) / 10
				if m ~= tile.M then
					tile.M = m
					tile.Part.Transparency = 1 - m
					tile.Part.Color = WHITE:Lerp(tile.Color, 0.25 + 0.75 * m)
				end
			end
			for _, seg in self.Segs do
				local m = math.floor(math.clamp((b - seg.Thr) / 0.05, 0, 1) * 10 + 0.5) / 10
				if m ~= seg.M then
					seg.M = m
					seg.Part.Transparency = 1 - (1 - seg.Base) * m
				end
			end
			self.Body.Transparency = 1 - smooth((b - 0.75) / 0.3)
			if b >= 1.07 then
				self.Built = true
			end
		end
		if not self.Exploding then
			self.Crescent.BackgroundTransparency = 1 - settle * 0.95
			self.RimStroke.Transparency = 1 - settle * 0.9
			self.Halo.BackgroundTransparency = 1 - settle * (0.5 + 0.08 * math.sin(t * 1.3))
		end
	end

	-- points: fly in, sit on the turning planet, flash and fuse as the front passes
	if not self.PointsGone or self.Exploding then
		local any = false
		local et = self.Exploding and (os.clock() - self.ExplodeAt) or 0
		for _, p in self.Points do
			local v = toView(p.Base, spin)
			local s = DIST / (DIST - v.Z)
			local screen = c + Vector2.new(v.X, -v.Y) * RADIUS * s
			local op, shade
			if p.Kind == "Sphere" then
				if v.Z >= -0.02 then
					local diffuse = math.max(0, v:Dot(LIGHT))
					local rim = (1 - math.abs(v.Z)) ^ 2.2
					local light = math.clamp(diffuse ^ 1.2 * 0.4 + rim * diffuse * 1.6, 0, 1)
					local e = (b - p.Thr) / 0.035
					local flash = math.exp(-e * e)
					shade = math.floor(math.clamp(0.3 + light * 0.7 + flash, 0, 1) * 11)
					op = (0.4 + light * 0.5 + flash * 0.4) * (1 - math.clamp((b - p.Thr - 0.02) / 0.06, 0, 1))
				else
					-- the far side, seen through the unfinished shell
					shade = 5
					op = 0.28 * (1 - coverAt(v.X, v.Y, spin, b))
				end
			else
				local lit = math.clamp(0.35 + (v.X / RING_OUT) * 0.45 + (v.Z / RING_OUT) * 0.2, 0, 1)
				local e = (b - p.Thr) / 0.03
				local flash = math.exp(-e * e)
				shade = math.floor(math.clamp(0.35 + lit * 0.65 + (p.Glint and 0.3 or 0) + flash, 0, 1) * 11)
				op = (0.3 + lit * 0.5 + (p.Glint and 0.2 or 0) + flash * 0.3) * (1 - math.clamp((b - p.Thr - 0.02) / 0.05, 0, 1))
				if v.Z < 0 and (v.X * v.X + v.Y * v.Y) < 1 then
					op *= 1 - coverAt(v.X, v.Y, spin, b)
				end
			end
			-- spiral in around the planet's own axis, roughly in the order the
			-- surface forms, tightening onto the exact spot
			local k = math.clamp((t - p.Delay) / 1.2, 0, 1)
			local e = 1 - (1 - k) ^ 4
			local pos = screen
			if e < 1 then
				local left = 1 - e
				local fly = rotY(p.Base, p.Curl * left) * (1 + left * left * p.Grow) + Vector3.new(0, p.Lift * left, 0)
				local fv = toView(fly, spin)
				local fs = math.clamp(DIST / math.max(DIST - fv.Z, 0.5), 0.5, 2)
				pos = c + Vector2.new(fv.X, -fv.Y) * RADIUS * fs
			end
			op = math.min(op, 1) * math.min(1, k * 3)
			-- white, grey and near-black points; the fusing flash stays bright
			if shade < 11 or p.Tone < 1 then
				shade = math.max(2, math.floor(shade * (shade >= 10 and math.max(p.Tone, 0.8) or p.Tone) + 0.5))
			end
			if self.Exploding then
				if not p.Dir then
					local away = screen - c
					p.Dir = (away.Magnitude > 1 and away.Unit or Vector2.new(1, 0)) * (190 + p.Seed * 75) + Vector2.new((p.Seed - 5) * 9, (p.Seed % 3 - 1.5) * 12)
				end
				pos = screen + p.Dir * (1 - (1 - math.min(et / 0.95, 1)) ^ 3) * 1.6
				op = (v.Z >= -0.02 or p.Kind == "Ring") and math.clamp(0.75 - et / 0.9, 0, 1) or 0
				shade = math.max(shade, 7)
			end
			local f = p.Frame
			if op > 0.01 then
				any = true
				f.Position = UDim2.fromOffset(pos.X, pos.Y)
				f.BackgroundTransparency = 1 - op
				f.BackgroundColor3 = SHADES[shade]
				p.Shown = true
			elseif p.Shown then
				p.Shown = false
				f.BackgroundTransparency = 1
			end
		end
		if not any and self.Built and not self.Exploding then
			self.PointsGone = true
		end
	end

	-- flare on the lit limb
	if not self.Exploding then
		local dir = Vector2.new(LIGHT.X, -LIGHT.Y).Unit
		local fp = c + dir * RADIUS * 0.99
		self.Flare.Position = UDim2.fromOffset(fp.X, fp.Y)
		self.Streak.Position = UDim2.fromOffset(fp.X, fp.Y)
		self.Streak2.Position = UDim2.fromOffset(fp.X, fp.Y)
		local pulse = 0.2 + 0.15 * math.sin(t * 2.3)
		local hide = 1 - settle
		self.Flare.BackgroundTransparency = math.min(1, pulse + hide)
		self.FlareGlow.BackgroundTransparency = math.min(1, 0.8 + pulse * 0.3 + hide)
		self.Streak.BackgroundTransparency = math.min(1, 0.15 + pulse + hide)
		self.Streak2.BackgroundTransparency = math.min(1, 0.4 + pulse + hide)
	end
	self:_progress(t)
end

function Loader:_progress(t)
	if self.Exploding then
		return
	end
	local window = self.Window
	local actual = window:GetLoadProgress()
	if window.State ~= "Loading" then
		actual = math.max(actual, 0.98)
	end
	self.Display = math.max(self.Display, math.min(actual, 0.99))
	local shown = self._shown or 0
	shown += (self.Display - shown) * 0.12
	self._shown = shown
	self.Fill.Size = UDim2.fromScale(shown, 1)
	self.Pct.Text = math.floor(shown * 100 + 0.5) .. "%"
	table.insert(self.Samples, { t, self.Display })
	while #self.Samples > 2 and self.Samples[1][1] < t - 1.5 do
		table.remove(self.Samples, 1)
	end
	local first = self.Samples[1]
	local rate = (self.Display - first[2]) / math.max(t - first[1], 0.05)
	if rate > 0.002 and self.Display < 0.98 then
		local left = (1 - self.Display) / rate
		self.Eta.Text = left < 1 and "<1 s" or ("~" .. math.ceil(left) .. " s")
	else
		self.Eta.Text = string.format("%.1f s", t)
	end
end

function Loader:SetStage(text)
	if self.Status and text then
		self.Status.Text = text
	end
end

-- Breaks the model back into points, bursts them, and calls onOpen while
-- the burst is still flying so the window grows out of it.
function Loader:Finish(onOpen)
	if self.Exploding or self.Finishing then
		return
	end
	self.Finishing = true
	local function burst()
		if not self.Root then
			return
		end
		self.Exploding = true
		self.ExplodeAt = os.clock()
		self.Fill.Size = UDim2.fromScale(1, 1)
		self.Pct.Text = "100%"
		self.Status.Text = Locale.T("Ready")
		self.Eta.Text = ""
		local stage = self.Stage
		local flash = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(self.Center.X, self.Center.Y), Size = UDim2.fromOffset(RADIUS * 2.2, RADIUS * 2.2), BackgroundColor3 = WHITE, BackgroundTransparency = 0.05, ZIndex = 308, Parent = stage })
		Util.Round(flash)
		Tween.Play(flash, { Size = UDim2.fromOffset(30, 30), BackgroundTransparency = 1 }, 0.5)
		for i, size in { 1300, 900 } do
			local wave = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(self.Center.X, self.Center.Y), Size = UDim2.fromOffset(RADIUS * 2, RADIUS * 2), BackgroundTransparency = 1, ZIndex = 308, Parent = stage })
			Util.Round(wave)
			local ws = Util.Stroke(wave, WHITE, i == 1 and 2 or 1, i == 1 and 0 or 0.4)
			Tween.Play(wave, { Size = UDim2.fromOffset(size, size) }, 0.9 + i * 0.15, Enum.EasingStyle.Quart)
			Tween.Play(ws, { Transparency = 1, Thickness = 0.5 }, 0.9 + i * 0.15)
		end
		for _, o in { self.Flare, self.FlareGlow, self.Streak, self.Streak2, self.Crescent } do
			Tween.Play(o, { BackgroundTransparency = 1 }, 0.2)
		end
		Tween.Play(self.Halo, { BackgroundTransparency = 1 }, 0.4)
		Tween.Play(self.RimStroke, { Transparency = 1 }, 0.15)
		for _, l in { self.TitleLabel, self.Pct, self.Status, self.Eta } do
			Tween.Play(l, { TextTransparency = 1 }, 0.35)
		end
		Tween.Play(self.Track, { BackgroundTransparency = 1 }, 0.35)
		Tween.Play(self.Fill, { BackgroundTransparency = 1 }, 0.35)
		Tween.Play(self.Dim, { BackgroundTransparency = 1 }, 0.95, Enum.EasingStyle.Sine)
		task.delay(0.24, function()
			if onOpen then
				onOpen(stage.AbsolutePosition + stage.AbsoluteSize / 2 - Shared.Gui.Root.AbsolutePosition)
			end
		end)
		task.delay(1.2, function()
			self:Destroy()
		end)
	end
	task.spawn(function()
		local start = os.clock()
		-- let the planet finish forming (sped up) before it bursts
		self.Hurry = true
		while self.Root and ((self._shown or 0) < 0.97 or self.Build < 1) and os.clock() - start < 2.5 do
			self.Display = 1
			RunService.RenderStepped:Wait()
		end
		burst()
	end)
end

function Loader:Destroy()
	if self.Conn then
		self.Conn:Disconnect()
		self.Conn = nil
	end
	if self.Root then
		self.Root:Destroy()
		self.Root = nil
	end
end

return Loader
