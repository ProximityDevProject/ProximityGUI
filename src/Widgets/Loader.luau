--!nocheck
--[[
	Proximity · Widgets/Loader
	The planet intro.

	1. The screen dims. Hundreds of white, grey and black points fly in and
	   assemble into a planet with a tilted ring.
	2. The points condense into a real 3D model rendered in a ViewportFrame:
	   a near-black world lit from the top right with a few surface details,
	   and a ring made of dusty segments that passes behind the planet (the
	   depth buffer hides it) and in front of it. The points use exactly the
	   same geometry, camera and rotation, so they turn into the model in
	   place instead of being swapped for a different picture.
	3. Over the model sit the touches from the artwork: a thin bright crescent
	   on the lit limb, a pulsing flare with a long streak, a soft halo.
	4. The planet spins while the bar under it shows real progress and the
	   time left. When everything is ready the model breaks back into points
	   that burst outward with a flash and a shock wave, and the window grows
	   out of the burst.
]]

local Util = require("../Core/Util")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")
local Theme = require("../Theme")
local Locale = require("../Locale")
local Shared = require("../Shared")

local RunService = Env.Service("RunService")

local Loader = {}
Loader.__index = Loader

-- geometry shared by the point cloud and the 3D model (studs = pixels / RADIUS)
local SPHERE, RING = 520, 300
local RADIUS = 92                           -- planet radius on screen, px
local RING_IN, RING_OUT = 1.36, 2.02        -- ring radii in planet radii
local STAGE = 420                           -- stage and viewport size, px
local FOV = 30
local DIST = (STAGE / 2) / (RADIUS * math.tan(math.rad(FOV / 2)))  -- camera distance for that radius
local TILT_Z, TILT_X = math.rad(17), math.rad(15)   -- ring seen almost edge on, rising to the right
local LIGHT = Vector3.new(0.72, 0.55, 0.42).Unit

local SHADES = {}
for i = 0, 11 do
	local v = i / 11
	SHADES[i] = Color3.new(v, v, v)
end

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

local function smooth(x)
	x = math.clamp(x, 0, 1)
	return x * x * (3 - 2 * x)
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

local function buildModel(viewport)
	local rng = Random.new(7)
	local camera = Instance.new("Camera")
	camera.FieldOfView = FOV
	camera.CFrame = CFrame.new(0, 0, DIST)
	camera.Parent = viewport
	viewport.CurrentCamera = camera

	local planet = Instance.new("Model")
	planet.Name = "Planet"
	local body = part({ Name = "Body", Shape = Enum.PartType.Ball, Size = Vector3.one * 2, Color = Color3.fromRGB(11, 11, 13), Reflectance = 0.02 })
	body.Parent = planet
	-- surface detail so the rotation reads: soft darker and lighter patches
	for i = 1, 45 do
		local dir = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-1, 1), rng:NextNumber(-1, 1))
		if dir.Magnitude > 0.05 then
			dir = dir.Unit
			local size = rng:NextNumber(0.1, 0.3)
			local shade = rng:NextNumber() < 0.5 and rng:NextInteger(6, 9) or rng:NextInteger(13, 17)
			local patch = part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.012, size, size), Color = Color3.fromRGB(shade, shade, shade + 2) })
			patch.CFrame = CFrame.lookAt(dir * 0.998, dir * 2) * CFrame.Angles(0, math.rad(90), 0)
			patch.Parent = planet
		end
	end
	planet.PrimaryPart = body
	planet.Parent = viewport

	local ring = Instance.new("Model")
	ring.Name = "Ring"
	local hub = part({ Name = "Hub", Size = Vector3.one * 0.01, Transparency = 1 })
	hub.Parent = ring
	ring.PrimaryPart = hub
	local bands = { { 1.40, 0.16, 0.55 }, { 1.60, 0.20, 0.35 }, { 1.80, 0.12, 0.6 }, { 1.95, 0.08, 0.75 } }
	local segments = 72
	for _, band in bands do
		local r, width, base = band[1], band[2], band[3]
		local length = (2 * math.pi * r) / segments * 1.08
		for i = 0, segments - 1 do
			local a = (i / segments) * math.pi * 2
			-- dusty: transparency follows a few layered waves plus noise
			local dust = 0.5 + 0.25 * math.sin(a * 3 + r * 4) + 0.15 * math.sin(a * 7 + r) + rng:NextNumber(-0.12, 0.12)
			local seg = part({
				Size = Vector3.new(width, 0.004, length),
				Color = Color3.fromRGB(235, 235, 240),
				Material = Enum.Material.Neon,
				Transparency = math.clamp(base + (1 - dust) * 0.4, 0.25, 0.97),
			})
			seg.CFrame = CFrame.new(math.cos(a) * r, 0, math.sin(a) * r) * CFrame.Angles(0, -a, 0)
			seg.Parent = ring
		end
	end
	ring.Parent = viewport
	return planet, ring
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
	self.Solid = 0

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
	local halo = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(c.X, c.Y), Size = UDim2.fromOffset(RADIUS * 3.6, RADIUS * 3.6), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, ZIndex = 301, Parent = stage })
	Util.Round(halo)
	Util.Gradient(halo, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.6, 0.995), NumberSequenceKeypoint.new(0.85, 0.975), NumberSequenceKeypoint.new(1, 0.96) }), -45)
	self.Halo = halo

	-- the bright crescent: a white disc just behind the model, nudged towards
	-- the light, so only a thin lit limb peeks out around the planet
	local crescent = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(c.X + 1.6, c.Y - 1.4), Size = UDim2.fromOffset(RADIUS * 2 + 3, RADIUS * 2 + 3), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, ZIndex = 302, Parent = stage })
	Util.Round(crescent)
	local crescentGradient = Util.Gradient(crescent, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.6, 1), NumberSequenceKeypoint.new(0.85, 0.3), NumberSequenceKeypoint.new(1, 0) }), -40)
	self.Crescent, self.CrescentGradient = crescent, crescentGradient

	-- the model
	local viewport = Util.New("ViewportFrame", {
		Name = "Model",
		BackgroundTransparency = 1,
		ImageTransparency = 1,
		Size = UDim2.fromOffset(STAGE, STAGE),
		Ambient = Color3.fromRGB(14, 14, 18),
		LightColor = Color3.fromRGB(165, 165, 175),
		LightDirection = -LIGHT,
		ZIndex = 303,
		Parent = stage,
	})
	self.Viewport = viewport
	local ok, planet, ring = pcall(buildModel, viewport)
	if ok then
		self.Planet, self.Ring = planet, ring
	end

	-- soft rim light over the model
	local rim = Util.New("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(c.X, c.Y), Size = UDim2.fromOffset(RADIUS * 2 + 2, RADIUS * 2 + 2), ZIndex = 304, Parent = stage })
	Util.Round(rim)
	local rimStroke = Util.Stroke(rim, Color3.new(1, 1, 1), 1.6, 1)
	Util.Gradient(rimStroke, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.6, 1), NumberSequenceKeypoint.new(0.82, 0.35), NumberSequenceKeypoint.new(0.93, 0), NumberSequenceKeypoint.new(1, 0.3) }), -40)
	self.RimStroke = rimStroke

	-- points (same geometry as the model)
	local rng = Random.new(42)
	local golden = math.pi * (3 - math.sqrt(5))
	for i = 0, SPHERE - 1 do
		local y = 1 - (i / (SPHERE - 1)) * 2
		local r = math.sqrt(1 - y * y)
		local theta = golden * i
		table.insert(self.Points, { Base = Vector3.new(math.cos(theta) * r, y, math.sin(theta) * r), Kind = "Sphere" })
	end
	for _ = 1, RING do
		local t = rng:NextNumber() * math.pi * 2
		local rr = RING_IN + (RING_OUT - RING_IN) * (rng:NextNumber() ^ 1.5)
		table.insert(self.Points, { Base = Vector3.new(math.cos(t) * rr, 0, math.sin(t) * rr), Kind = "Ring", Glint = rng:NextNumber() < 0.08 })
	end
	for _, p in self.Points do
		local size = p.Kind == "Ring" and (p.Glint and 3 or 2) or 3
		p.Frame = Util.New("Frame", { BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(size, size), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, ZIndex = 305, Parent = stage })
		local a = rng:NextNumber() * math.pi * 2
		local d = 260 + rng:NextNumber() * 460
		p.From = c + Vector2.new(math.cos(a) * d, math.sin(a) * d)
		p.Delay = rng:NextNumber() * 0.7
		p.Seed = rng:NextNumber() * 10
	end

	-- flare + streaks
	local flare = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(10, 10), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, ZIndex = 307, Parent = stage })
	Util.Round(flare)
	local flareGlow = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(24, 24), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.85, ZIndex = 306, Parent = flare })
	Util.Round(flareGlow)
	local streak = Util.New("Frame", { AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(190, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, ZIndex = 307, Parent = stage })
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
	title.TextColor3 = Color3.new(1, 1, 1)
	local pct = label({ Text = "0%", FontFace = Theme.Fonts.MonoBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, 0, 0, 18) })
	pct.TextColor3 = Color3.new(1, 1, 1)
	local track = Util.New("Frame", { Size = UDim2.new(1, 0, 0, 3), Position = UDim2.fromOffset(0, 25), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 301, Parent = info })
	Util.Round(track)
	local fill = Util.New("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 302, Parent = track })
	Util.Round(fill)
	local glow = Util.New("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(18, 8), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.55, BorderSizePixel = 0, ZIndex = 302, Parent = fill })
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
	-- assembled -> solid model (and back to points for the burst)
	if self.Exploding then
		self.Solid = math.max(0, self.Solid - dt / 0.1)
	elseif t > 1.35 and self.Planet then
		self.Solid = math.min(1, self.Solid + dt / 1.0)
	end
	local solid = smooth(self.Solid)
	self.Angle += dt * (self.Exploding and 0.15 or 0.38)
	local spin = self.Angle
	local c = self.Center

	-- model
	if self.Planet then
		self.Planet:PivotTo(CFrame.Angles(0, 0, TILT_Z) * CFrame.Angles(0, spin, 0))
		self.Ring:PivotTo(CFrame.Angles(0, 0, TILT_Z) * CFrame.Angles(TILT_X, 0, 0) * CFrame.Angles(0, spin * 0.6, 0))
		self.Viewport.ImageTransparency = 1 - solid
		self.Crescent.BackgroundTransparency = 1 - solid * 0.95
		self.RimStroke.Transparency = 1 - solid * 0.9
		self.Halo.BackgroundTransparency = 1 - solid * (0.5 + 0.08 * math.sin(t * 1.3))
	end

	-- points
	local flarePos, best = nil, -math.huge
	for _, p in self.Points do
		local v
		if p.Kind == "Sphere" then
			v = rotZ(rotY(p.Base, spin), TILT_Z)
		else
			v = rotZ(rotX(rotY(p.Base, spin * 0.6), TILT_X), TILT_Z)
		end
		local s = DIST / (DIST - v.Z)
		local screen = c + Vector2.new(v.X, -v.Y) * RADIUS * s
		local alpha, shade = 1, 11
		if p.Kind == "Sphere" then
			if v.Z > -0.05 then
				local diffuse = math.max(0, v:Dot(LIGHT))
				local rim = (1 - math.abs(v.Z)) ^ 2.2
				local light = math.clamp(diffuse ^ 1.6 * 0.35 + rim * diffuse * 1.6, 0, 1)
				shade = math.floor(math.clamp(0.08 + light, 0, 1) * 11)
				alpha = math.clamp(0.55 - light * 0.6 - v.Z * 0.15, 0, 0.9)
				if light > 0.6 and v.Y > best then
					best = v.Y
					flarePos = screen
				end
			end
		else
			local behind = v.Z < 0 and (v.X * v.X + v.Y * v.Y) < 1.04
			if not behind then
				local lit = math.clamp(0.35 + (v.X / RING_OUT) * 0.45 + (v.Z / RING_OUT) * 0.2, 0, 1)
				shade = math.floor(math.clamp(0.25 + lit * 0.75 + (p.Glint and 0.3 or 0), 0, 1) * 11)
				alpha = math.clamp(0.75 - lit * 0.6 - (p.Glint and 0.3 or 0), 0, 0.95)
			end
		end
		local k = math.clamp((t - p.Delay) / 1.1, 0, 1)
		local e = 1 - (1 - k) ^ 3
		local pos = p.From:Lerp(screen, e)
		local fade = 1 - e * (1 - alpha)
		if self.Exploding then
			local et = os.clock() - self.ExplodeAt
			if not p.Dir then
				local away = screen - c
				p.Dir = (away.Magnitude > 1 and away.Unit or Vector2.new(1, 0)) * (190 + p.Seed * 75) + Vector2.new((p.Seed - 5) * 9, (p.Seed % 3 - 1.5) * 12)
			end
			pos = screen + p.Dir * (1 - (1 - math.min(et / 0.95, 1)) ^ 3) * 1.6
			fade = math.clamp(math.min(alpha, 0.35) + et / 0.9, 0, 1)
		else
			-- condense into the model: points thin out as it becomes solid
			fade = fade + (1 - fade) * solid * (p.Glint and 0.6 or 1)
		end
		local f = p.Frame
		f.Position = UDim2.fromOffset(pos.X, pos.Y)
		f.BackgroundTransparency = fade
		f.BackgroundColor3 = SHADES[shade]
	end

	-- flare on the brightest point of the lit limb
	if flarePos and t > 1.2 and not self.Exploding then
		self.Flare.Position = UDim2.fromOffset(flarePos.X, flarePos.Y)
		self.Streak.Position = UDim2.fromOffset(flarePos.X, flarePos.Y)
		self.Streak2.Position = UDim2.fromOffset(flarePos.X, flarePos.Y)
		local pulse = 0.2 + 0.15 * math.sin(t * 2.3)
		self.Flare.BackgroundTransparency = pulse
		self.FlareGlow.BackgroundTransparency = 0.8 + pulse * 0.3
		self.Streak.BackgroundTransparency = 0.15 + pulse
		self.Streak2.BackgroundTransparency = 0.4 + pulse
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
	if self.Exploding then
		return
	end
	local function burst()
		self.Exploding = true
		self.ExplodeAt = os.clock()
		self.Fill.Size = UDim2.fromScale(1, 1)
		self.Pct.Text = "100%"
		self.Status.Text = Locale.T("Ready")
		self.Eta.Text = ""
		local stage = self.Stage
		local flash = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(self.Center.X, self.Center.Y), Size = UDim2.fromOffset(RADIUS * 2.2, RADIUS * 2.2), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.05, ZIndex = 308, Parent = stage })
		Util.Round(flash)
		Tween.Play(flash, { Size = UDim2.fromOffset(30, 30), BackgroundTransparency = 1 }, 0.5)
		for i, size in { 1300, 900 } do
			local wave = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(self.Center.X, self.Center.Y), Size = UDim2.fromOffset(RADIUS * 2, RADIUS * 2), BackgroundTransparency = 1, ZIndex = 308, Parent = stage })
			Util.Round(wave)
			local ws = Util.Stroke(wave, Color3.new(1, 1, 1), i == 1 and 2 or 1, i == 1 and 0 or 0.4)
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
		while (self._shown or 0) < 0.97 and os.clock() - start < 0.6 do
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
