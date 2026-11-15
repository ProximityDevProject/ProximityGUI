--!nocheck
--[[
	Proximity · Widgets/Loader
	The intro: the screen dims, a planet assembles itself from hundreds of
	white, grey and black points, spins while the script loads, and bursts
	apart when everything is ready; the window then grows out of the burst.

	The planet is a real 3D point cloud (a Fibonacci sphere plus a tilted
	ring) projected with perspective every frame and lit from the top right,
	so it reads like the Proximity artwork: a dark body, a bright rim on the
	lit side, a ring passing behind and in front of it, and a flare.

	Progress under the planet is real: built elements + developer tasks,
	with a time-left estimate from the measured rate.
]]

local Util = require("../Core/Util")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")
local Theme = require("../Theme")
local Locale = require("../Locale")
local Shared = require("../Shared")
local Icons = require("../Icons")

local RunService = Env.Service("RunService")

local Loader = {}
Loader.__index = Loader

local SPHERE, RING = 560, 240
local RADIUS, RING_IN, RING_OUT = 92, 128, 168
local FOCAL = 700
local TILT_Z, TILT_X = math.rad(18), math.rad(75)
local LIGHT = Vector3.new(0.72, 0.55, 0.42).Unit

-- 12 grey levels reused every frame instead of allocating colors.
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

function Loader.new(window, options)
	options = options or {}
	local self = setmetatable({}, Loader)
	self.Window = window
	self.Started = os.clock()
	self.Points = {}
	self.Angle = 0
	self.Display = 0
	self.Samples = {}

	local root = Util.New("Frame", { Name = "ProximityLoader", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 300, Parent = Shared.Gui.Root })
	self.Root = root
	local dim = Util.New("Frame", { BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 300, Parent = root })
	Util.Gradient(dim, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 0.15) }), 90)
	Tween.Play(dim, { BackgroundTransparency = options.Dim or 0.25 }, 0.6, Enum.EasingStyle.Sine)
	self.Dim = dim

	local stage = Util.New("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.47), Size = UDim2.fromOffset(420, 420), ZIndex = 301, Parent = root })
	local view = workspace.CurrentCamera.ViewportSize
	Util.New("UIScale", { Scale = math.clamp(math.min(view.X, view.Y) / 820, 0.55, 1.15), Parent = stage })
	self.Stage = stage
	self.Center = Vector2.new(210, 210)

	-- soft halo behind the planet
	local halo = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(250, 250), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, ZIndex = 301, Parent = stage })
	Util.Round(halo)
	Util.Gradient(halo, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.97), NumberSequenceKeypoint.new(0.5, 0.99), NumberSequenceKeypoint.new(1, 1) }), 45)
	Tween.Play(halo, { BackgroundTransparency = 0 }, 1.2)
	self.Halo = halo

	-- points
	local rng = Random.new(42)
	local golden = math.pi * (3 - math.sqrt(5))
	for i = 0, SPHERE - 1 do
		local y = 1 - (i / (SPHERE - 1)) * 2
		local r = math.sqrt(1 - y * y)
		local theta = golden * i
		local base = Vector3.new(math.cos(theta) * r, y, math.sin(theta) * r) * RADIUS
		table.insert(self.Points, { Base = base, Kind = "Sphere" })
	end
	for _ = 1, RING do
		local t = rng:NextNumber() * math.pi * 2
		local rr = RING_IN + (RING_OUT - RING_IN) * (rng:NextNumber() ^ 1.6)
		local base = Vector3.new(math.cos(t) * rr, (rng:NextNumber() - 0.5) * 3, math.sin(t) * rr)
		table.insert(self.Points, { Base = base, Kind = "Ring", Glint = rng:NextNumber() < 0.08 })
	end
	for _, p in self.Points do
		local size = p.Kind == "Ring" and (p.Glint and 3 or 2) or 3
		p.Frame = Util.New("Frame", { BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(size, size), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, ZIndex = 302, Parent = stage })
		-- start scattered around the screen
		local a = rng:NextNumber() * math.pi * 2
		local d = 260 + rng:NextNumber() * 420
		p.From = self.Center + Vector2.new(math.cos(a) * d, math.sin(a) * d)
		p.Delay = rng:NextNumber() * 0.7
		p.Seed = rng:NextNumber() * 10
	end

	-- flare where light hits the rim, and its streak
	local flare = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(9, 9), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, ZIndex = 305, Parent = stage })
	Util.Round(flare)
	local streak = Util.New("Frame", { AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(150, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, ZIndex = 305, Parent = stage })
	Util.Gradient(streak, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }))
	local streak2 = streak:Clone()
	streak2.AnchorPoint = Vector2.new(1, 0.5)
	streak2.Size = UDim2.fromOffset(60, 1)
	streak2.Parent = stage
	streak2:FindFirstChildOfClass("UIGradient").Rotation = 180
	self.Flare, self.Streak, self.Streak2 = flare, streak, streak2

	-- The points settle into the real Proximity artwork: a solid planet with
	-- its glowing rim and ring. On top of it a highlight travels around the
	-- rim, the halo breathes and the flare pulses, so it never looks static.
	-- planet in the artwork: centre at 47.5 % / 50 %, radius 37.5 % of the image
	local artSize = RADIUS * 2 / 0.75
	local art = Util.New("ImageLabel", {
		Name = "Planet",
		BackgroundTransparency = 1,
		ImageTransparency = 1,
		Size = UDim2.fromOffset(artSize, artSize),
		AnchorPoint = Vector2.new(0.475, 0.5),
		Position = UDim2.fromOffset(self.Center.X, self.Center.Y),
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 303,
		Parent = stage,
	})
	Util.New("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = art })
	-- soft round edge so the square artwork melts into the dimmed screen
	Util.Gradient(art, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.08, 0), NumberSequenceKeypoint.new(0.92, 0), NumberSequenceKeypoint.new(1, 1) }), 0)
	local rim = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(RADIUS * 2 + 4, RADIUS * 2 + 4), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(self.Center.X, self.Center.Y), ZIndex = 304, Parent = stage })
	Util.Round(rim)
	local rimStroke = Util.Stroke(rim, Color3.new(1, 1, 1), 1.6, 1)
	local rimGradient = Util.Gradient(rimStroke, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.42, 1), NumberSequenceKeypoint.new(0.5, 0.1), NumberSequenceKeypoint.new(0.58, 1), NumberSequenceKeypoint.new(1, 1) }))
	self.Art, self.Rim, self.RimStroke, self.RimGradient = art, rim, rimStroke, rimGradient
	self.Solid = 0
	task.spawn(function()
		local image
		for attempt = 1, 3 do
			local ok, id = pcall(Icons.Get, "https://raw.githubusercontent.com/ProximityDevProject/ProximityGUI/main/assets/logo-512.png")
			if ok and id then
				image = id
				break
			end
			task.wait(attempt)
		end
		if image and self.Root then
			art.Image = image
			pcall(function()
				game:GetService("ContentProvider"):PreloadAsync({ art })
			end)
			self.ArtReady = true
		end
	end)

	-- progress block
	local info = Util.New("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.47, 0), Size = UDim2.fromOffset(280, 60), ZIndex = 301, Parent = root })
	info.Position = UDim2.new(0.5, 0, 0.47, 210 * (stage:FindFirstChildOfClass("UIScale").Scale) + 6)
	local title = Util.Label({ Text = window.Title, FontFace = Theme.Fonts.SemiBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -60, 0, 18), TextTransparency = 1, ZIndex = 301, Parent = info })
	title.TextColor3 = Color3.new(1, 1, 1)
	local pct = Util.Label({ Text = "0%", FontFace = Theme.Fonts.MonoBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, 0, 0, 18), TextTransparency = 1, ZIndex = 301, Parent = info })
	pct.TextColor3 = Color3.new(1, 1, 1)
	local track = Util.New("Frame", { Size = UDim2.new(1, 0, 0, 3), Position = UDim2.fromOffset(0, 24), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 301, Parent = info })
	Util.Round(track)
	local fill = Util.New("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 302, Parent = track })
	Util.Round(fill)
	local glow = Util.New("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(16, 7), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.6, BorderSizePixel = 0, ZIndex = 302, Parent = fill })
	Util.Round(glow)
	local status = Util.Label({ Text = Locale.T("Preparing"), FontFace = Theme.Fonts.Regular, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -70, 0, 16), Position = UDim2.fromOffset(0, 34), TextTransparency = 1, ZIndex = 301, Parent = info })
	status.TextColor3 = Color3.fromRGB(170, 170, 178)
	local eta = Util.Label({ Text = "", FontFace = Theme.Fonts.Mono, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, 0, 0, 16), Position = UDim2.fromOffset(0, 34), TextTransparency = 1, ZIndex = 301, Parent = info })
	eta.TextColor3 = Color3.fromRGB(120, 120, 128)
	self.Info, self.Pct, self.Fill, self.Track, self.Status, self.Eta, self.TitleLabel = info, pct, fill, track, status, eta, title
	task.delay(0.5, function()
		if self.Root then
			for _, l in { title, pct, status, eta } do
				Tween.Play(l, { TextTransparency = 0 }, 0.5)
			end
			Tween.Play(track, { BackgroundTransparency = 0.85 }, 0.5)
		end
	end)

	self.Conn = RunService.RenderStepped:Connect(function(dt)
		self:_step(dt)
	end)
	return self
end

function Loader:_project(v)
	local scale = FOCAL / (FOCAL - v.Z)
	return self.Center + Vector2.new(v.X * scale, -v.Y * scale), scale
end

function Loader:_step(dt)
	local t = os.clock() - self.Started
	-- once assembled (and the artwork is loaded) the cloud becomes solid
	if self.ArtReady and not self.Exploding and t > 1.5 then
		self.Solid = math.min(1, self.Solid + dt / 0.9)
	elseif self.Exploding then
		self.Solid = math.max(0, self.Solid - dt / 0.12)
	end
	local solid = self.Solid
	local eased = solid * solid * (3 - 2 * solid)
	if self.Art then
		self.Art.ImageTransparency = 1 - eased
		-- a slow sway gives the flat artwork some depth
		self.Art.Rotation = math.sin(t * 0.35) * 2.5
		self.Art.Size = UDim2.fromOffset(RADIUS * 2 / 0.75 * (1 + math.sin(t * 0.8) * 0.012), RADIUS * 2 / 0.75 * (1 + math.sin(t * 0.8) * 0.012))
		self.RimStroke.Transparency = 1 - eased * 0.85
		self.RimGradient.Rotation = (t * 40) % 360
		self.Halo.Size = UDim2.fromOffset(250 + math.sin(t * 1.2) * 14, 250 + math.sin(t * 1.2) * 14)
	end
	self.Angle += dt * (self.Exploding and 0.2 or 0.42)
	local spin = self.Angle
	local fx, fyMax = nil, -math.huge
	for _, p in self.Points do
		local v
		if p.Kind == "Sphere" then
			v = rotZ(rotY(p.Base, spin), TILT_Z)
		else
			v = rotZ(rotX(rotY(p.Base, spin * 0.6), TILT_X), TILT_Z)
		end
		local screen, scale = self:_project(v)
		local alpha, shade = 1, 11
		if p.Kind == "Sphere" then
			local n = v / RADIUS
			if n.Z < -0.05 then
				alpha = 1 -- back side
			else
				local diffuse = math.max(0, n:Dot(LIGHT))
				local rim = (1 - math.abs(n.Z)) ^ 2.2
				local light = math.clamp(diffuse ^ 1.6 * 0.35 + rim * diffuse * 1.6, 0, 1)
				shade = math.floor(math.clamp(0.08 + light, 0, 1) * 11)
				alpha = math.clamp(0.55 - light * 0.6 - n.Z * 0.15, 0, 0.9)
				if light > 0.6 and v.Y > fyMax then
					fyMax = v.Y
					fx = screen
				end
			end
		else
			-- ring: hidden where it passes behind the planet
			local behind = v.Z < 0 and (v.X * v.X + v.Y * v.Y) < (RADIUS * 1.02) ^ 2
			if behind then
				alpha = 1
			else
				local lit = math.clamp(0.35 + (v.X / RING_OUT) * 0.45 + (v.Z / RING_OUT) * 0.2, 0, 1)
				shade = math.floor(math.clamp(0.25 + lit * 0.75 + (p.Glint and 0.3 or 0), 0, 1) * 11)
				alpha = math.clamp(0.75 - lit * 0.6 - (p.Glint and 0.3 or 0), 0, 0.95)
			end
		end
		-- assembly
		local k = math.clamp((t - p.Delay) / 1.1, 0, 1)
		local e = 1 - (1 - k) ^ 3
		local pos = p.From:Lerp(screen, e)
		local fade = 1 - e * (1 - alpha)
		if self.Exploding then
			local et = os.clock() - self.ExplodeAt
			if not p.Dir then
				local away = (screen - self.Center)
				p.Dir = (away.Magnitude > 1 and away.Unit or Vector2.new(1, 0)) * (180 + p.Seed * 70) + Vector2.new((p.Seed - 5) * 8, (p.Seed % 3 - 1.5) * 12)
			end
			pos = screen + p.Dir * (1 - (1 - math.min(et / 0.9, 1)) ^ 3) * 1.6
			fade = math.clamp(alpha + et / 0.85, 0, 1)
		end
		local f = p.Frame
		f.Position = UDim2.fromOffset(pos.X, pos.Y)
		if not self.Exploding and eased > 0 then
			-- points dissolve into the solid planet; a few ring glints stay
			fade = fade + (1 - fade) * eased * (p.Glint and 0.55 or 1)
		end
		f.BackgroundTransparency = fade
		f.BackgroundColor3 = SHADES[shade]
		f.ZIndex = p.Kind == "Ring" and (v.Z >= 0 and 304 or 302) or 303
	end
	-- flare follows the brightest point of the rim
	local ready = t > 1.2 and not self.Exploding
	if fx and ready then
		self.Flare.Position = UDim2.fromOffset(fx.X, fx.Y)
		self.Streak.Position = UDim2.fromOffset(fx.X, fx.Y)
		self.Streak2.Position = UDim2.fromOffset(fx.X, fx.Y)
		local pulse = 0.25 + 0.15 * math.sin(t * 2.4) + eased * 0.15
		self.Flare.BackgroundTransparency = pulse
		self.Streak.BackgroundTransparency = 0.2 + pulse
		self.Streak2.BackgroundTransparency = 0.45 + pulse
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
	-- smooth the bar towards the real value
	local shown = self._shown or 0
	shown += (self.Display - shown) * 0.15
	self._shown = shown
	self.Fill.Size = UDim2.fromScale(shown, 1)
	self.Pct.Text = math.floor(shown * 100 + 0.5) .. "%"
	-- time left from the measured rate over the last second
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

-- Burst the planet, call `onOpen` while the burst is still flying so the
-- window grows out of it, then clean up.
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
		-- flash
		local flash = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(180, 180), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.1, ZIndex = 306, Parent = stage })
		Util.Round(flash)
		Tween.Play(flash, { Size = UDim2.fromOffset(40, 40), BackgroundTransparency = 1 }, 0.45)
		-- shock wave
		local wave = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(190, 190), BackgroundTransparency = 1, ZIndex = 306, Parent = stage })
		Util.Round(wave)
		local ws = Util.Stroke(wave, Color3.new(1, 1, 1), 2, 0)
		Tween.Play(wave, { Size = UDim2.fromOffset(1100, 1100) }, 0.9, Enum.EasingStyle.Quart)
		Tween.Play(ws, { Transparency = 1, Thickness = 0.5 }, 0.9)
		Tween.Play(self.Halo, { BackgroundTransparency = 1 }, 0.4)
		if self.Art then
			Tween.Play(self.Art, { ImageTransparency = 1, Size = UDim2.fromOffset(RADIUS * 3.4, RADIUS * 3.4) }, 0.18)
			Tween.Play(self.RimStroke, { Transparency = 1 }, 0.15)
		end
		for _, o in { self.Flare, self.Streak, self.Streak2 } do
			Tween.Play(o, { BackgroundTransparency = 1 }, 0.25)
		end
		for _, l in { self.TitleLabel, self.Pct, self.Status, self.Eta } do
			Tween.Play(l, { TextTransparency = 1 }, 0.35)
		end
		Tween.Play(self.Track, { BackgroundTransparency = 1 }, 0.35)
		Tween.Play(self.Fill, { BackgroundTransparency = 1 }, 0.35)
		Tween.Play(self.Dim, { BackgroundTransparency = 1 }, 0.9, Enum.EasingStyle.Sine)
		task.delay(0.22, function()
			if onOpen then
				onOpen(stage.AbsolutePosition + stage.AbsoluteSize / 2 - Shared.Gui.Root.AbsolutePosition)
			end
		end)
		task.delay(1.1, function()
			self:Destroy()
		end)
	end
	-- let the bar visibly reach 100 first
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
