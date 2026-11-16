--!nocheck
--[[
	Proximity · Widgets/Intros
	More loading screens, next to the Planet (Widgets/Loader) and the menu
	Skeleton. All of them show real progress (built elements plus your own
	Window:Step tasks), the current stage and the time left.

	  Orbit          three thin orbits with moons; 96 ticks around the
	                 outside light up as it loads, the percent sits in the
	                 middle. Orbits fold into the centre and the menu grows
	                 out of that point.
	  Eclipse        a white sun and a black moon sliding over it; the more
	                 is loaded, the more it is covered. At 100% it is a total
	                 eclipse: the corona flares up, a diamond ring flashes
	                 and the menu opens from it.
	  Constellation  stars appear, and thin lines connect them one by one as
	                 progress grows. When the picture is complete it flashes
	                 and the stars rush into the middle.
	  Terminal       a small boot console types out what is happening, with
	                 an ASCII bar and a blinking caret; the menu then opens
	                 with your chosen menu animation.

	Interface (same as the planet loader):
	  Intros.new(window, options, style)  :SetStage(text)  :Finish(onOpen)  :Destroy()
]]

local Util = require("../Core/Util")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")
local Theme = require("../Theme")
local Locale = require("../Locale")
local Shared = require("../Shared")

local RunService = Env.Service("RunService")

local Intros = {}
Intros.__index = Intros
Intros.Styles = { "Orbit", "Eclipse", "Constellation", "Terminal" }

local STAGE = 420
local WHITE = Color3.new(1, 1, 1)
local TAU = math.pi * 2

local function escape(text)
	return (string.gsub(string.gsub(string.gsub(text, "&", "&amp;"), "<", "&lt;"), ">", "&gt;"))
end

local function smooth(x)
	x = math.clamp(x, 0, 1)
	return x * x * (3 - 2 * x)
end

local function frame(parent, props)
	props.BorderSizePixel = 0
	props.Parent = parent
	if props.BackgroundTransparency == nil then
		props.BackgroundTransparency = 1
	end
	return Util.New("Frame", props)
end

local function dot(parent, size, z)
	local d = frame(parent, { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(size, size), BackgroundColor3 = WHITE, ZIndex = z or 303 })
	Util.Round(d)
	return d
end

local function ring(parent, diameter, z, thickness)
	local r = frame(parent, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(STAGE / 2, STAGE / 2), Size = UDim2.fromOffset(diameter, diameter), ZIndex = z or 302 })
	Util.Round(r)
	local stroke = Util.Stroke(r, WHITE, thickness or 1, 1)
	return r, stroke
end

-- a straight line between two stage points
local function placeLine(line, a, b)
	local d = b - a
	line.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
	line.Size = UDim2.fromOffset(math.max(d.Magnitude, 0.01), line.Size.Y.Offset)
	line.Rotation = math.deg(math.atan2(d.Y, d.X))
end

-- ═══ styles ══════════════════════════════════════════════════════════════
local Styles = {}

-- ─── Orbit ───────────────────────────────────────────────────────────────
Styles.Orbit = {
	Build = function(self)
		local c = self.Center
		self.Rings, self.Moons = {}, {}
		for i, spec in { { 120, 0.9, 1.1 }, { 196, -0.55, 0.85 }, { 272, 0.32, 0.7 } } do
			local r, stroke = ring(self.Stage, spec[1], 302)
			r.Size = UDim2.fromOffset(0, 0)
			table.insert(self.Rings, { Frame = r, Stroke = stroke, D = spec[1], Speed = spec[2], Delay = (i - 1) * 0.12 })
			local moon = dot(self.Stage, i == 1 and 7 or 5, 304)
			moon.BackgroundTransparency = 1
			local trail = {}
			for k = 1, 6 do
				local t = dot(self.Stage, math.max(2, 5 - k * 0.6), 303)
				t.BackgroundTransparency = 1
				trail[k] = t
			end
			table.insert(self.Moons, { Dot = moon, Trail = trail, R = spec[1] / 2, Speed = spec[2] * 1.4, Phase = i * 2.1 })
		end
		-- progress ticks around the outside
		self.Ticks = {}
		local n, radius = 96, 168
		for i = 0, n - 1 do
			local a = i / n * TAU - math.pi / 2
			local tick = frame(self.Stage, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(i % 8 == 0 and 10 or 6, 2),
				Position = UDim2.fromOffset(c.X + math.cos(a) * radius, c.Y + math.sin(a) * radius),
				Rotation = math.deg(a),
				BackgroundColor3 = WHITE,
				BackgroundTransparency = 1,
				ZIndex = 303,
			})
			self.Ticks[i + 1] = tick
		end
		-- the percent in the middle, the logo above it
		local logo = self.Window:_drawLogo(self.Stage, 30)
		logo.AnchorPoint = Vector2.new(0.5, 0.5)
		logo.Position = UDim2.fromOffset(c.X, c.Y - 30)
		logo.ZIndex = 305
		self.Logo = logo
		self.BigPct = Util.Label({ Text = "0", FontFace = Theme.Fonts.MonoBold, TextSize = 30, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(c.X, c.Y + 12), Size = UDim2.fromOffset(120, 34), ZIndex = 305, Parent = self.Stage })
		self.BigPct.TextColor3 = WHITE
		self.BigPct.TextTransparency = 1
		self.HidePct = true
	end,
	Step = function(self, t, shown)
		local c = self.Center
		for _, r in self.Rings do
			local k = smooth((t - 0.15 - r.Delay) / 0.7)
			r.Frame.Size = UDim2.fromOffset(r.D * (0.6 + 0.4 * k), r.D * (0.6 + 0.4 * k))
			r.Stroke.Transparency = 1 - k * 0.78
		end
		local appear = smooth((t - 0.5) / 0.6)
		for _, m in self.Moons do
			local a = m.Phase + t * m.Speed
			m.Dot.Position = UDim2.fromOffset(c.X + math.cos(a) * m.R, c.Y + math.sin(a) * m.R)
			m.Dot.BackgroundTransparency = 1 - appear
			for k, tr in m.Trail do
				local b = a - k * 0.07 * math.sign(m.Speed)
				tr.Position = UDim2.fromOffset(c.X + math.cos(b) * m.R, c.Y + math.sin(b) * m.R)
				tr.BackgroundTransparency = 1 - appear * (0.55 - k * 0.08)
			end
		end
		local lit = shown * #self.Ticks
		for i, tick in self.Ticks do
			local on = math.clamp(lit - (i - 1), 0, 1)
			local head = math.max(0, 1 - math.abs(lit - i) / 3)
			tick.BackgroundTransparency = 1 - appear * (0.12 + on * 0.75 + head * 0.13)
			tick.Size = UDim2.fromOffset(((i - 1) % 8 == 0 and 10 or 6) + head * 5, 2)
		end
		self.BigPct.Text = tostring(math.floor(shown * 100 + 0.5))
		self.BigPct.TextTransparency = 1 - appear
	end,
	Burst = function(self)
		for _, r in self.Rings do
			Tween.Play(r.Frame, { Size = UDim2.fromOffset(0, 0) }, 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			Tween.Play(r.Stroke, { Transparency = 1 }, 0.35)
		end
		for _, tick in self.Ticks do
			Tween.Play(tick, { BackgroundTransparency = 1 }, 0.3)
		end
		Tween.Play(self.BigPct, { TextTransparency = 1 }, 0.2)
		self.Logo.Visible = false
		return 0.3
	end,
}

-- ─── Eclipse ─────────────────────────────────────────────────────────────
Styles.Eclipse = {
	Dim = 0.12,
	Build = function(self)
		local c, R = self.Center, 64
		self.R = R
		-- corona: soft layered glow plus thin rays, brightest at totality
		self.Corona = {}
		for i, spec in { { 3.2, 0.985 }, { 2.4, 0.95 }, { 1.7, 0.86 } } do
			local g = frame(self.Stage, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(c.X, c.Y), Size = UDim2.fromOffset(R * 2 * spec[1], R * 2 * spec[1]), BackgroundColor3 = WHITE, BackgroundTransparency = 1, ZIndex = 301 })
			Util.Round(g)
			self.Corona[i] = { Frame = g, Base = spec[2] }
		end
		self.Rays = {}
		for i = 1, 10 do
			local a = i / 10 * TAU + (i % 2) * 0.17
			local len = R * (1.6 + (i % 3) * 0.55)
			local ray = frame(self.Stage, { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(len, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 1, ZIndex = 301 })
			Util.Gradient(ray, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }))
			local mid = Vector2.new(math.cos(a), math.sin(a)) * (R + len / 2)
			ray.Position = UDim2.fromOffset(c.X + mid.X, c.Y + mid.Y)
			ray.Rotation = math.deg(a)
			self.Rays[i] = ray
		end
		local sun = frame(self.Stage, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(c.X, c.Y), Size = UDim2.fromOffset(R * 2, R * 2), BackgroundColor3 = WHITE, BackgroundTransparency = 1, ZIndex = 302 })
		Util.Round(sun)
		Util.Gradient(sun, ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(205, 205, 212)), nil, -45)
		self.Sun = sun
		local moon = frame(self.Stage, { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(R * 2 + 2, R * 2 + 2), BackgroundColor3 = Color3.fromRGB(3, 3, 4), BackgroundTransparency = 1, ZIndex = 303 })
		Util.Round(moon)
		self.MoonStroke = Util.Stroke(moon, Color3.fromRGB(40, 40, 46), 1, 1)
		self.Moon = moon
		-- the diamond ring flash at totality
		local diamond = dot(self.Stage, 9, 305)
		diamond.BackgroundTransparency = 1
		local streak = frame(self.Stage, { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(220, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 1, ZIndex = 305 })
		Util.Gradient(streak, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }))
		local a = math.rad(-38)
		local p = c + Vector2.new(math.cos(a), math.sin(a)) * R
		diamond.Position = UDim2.fromOffset(p.X, p.Y)
		streak.Position = UDim2.fromOffset(p.X, p.Y)
		self.Diamond, self.Streak = diamond, streak
	end,
	Step = function(self, t, shown)
		local c, R = self.Center, self.R
		local appear = smooth((t - 0.1) / 0.7)
		self.Sun.BackgroundTransparency = 1 - appear
		-- the moon slides in from the lower left along a gentle arc
		local cover = smooth(shown)
		local off = (1 - cover) * R * 2.3
		self.Moon.Position = UDim2.fromOffset(c.X - off, c.Y + off * 0.35)
		self.Moon.BackgroundTransparency = 1 - appear
		self.MoonStroke.Transparency = 1 - appear * 0.6
		local total = smooth((cover - 0.9) / 0.1)
		local pulse = 0.5 + 0.5 * math.sin(t * 2.2)
		for i, g in self.Corona do
			local base = g.Base + (1 - g.Base) * (1 - appear)
			g.Frame.BackgroundTransparency = base - total * (0.06 + i * 0.03) - pulse * 0.01
		end
		for i, ray in self.Rays do
			ray.BackgroundTransparency = 1 - (0.12 + total * 0.5) * appear * (0.6 + 0.4 * math.sin(t * 1.3 + i))
		end
		self.Diamond.BackgroundTransparency = 1 - total * (0.75 + 0.25 * pulse)
		self.Streak.BackgroundTransparency = 1 - total * 0.8
	end,
	Burst = function(self)
		local flash = dot(self.Stage, 12, 306)
		flash.Position = self.Diamond.Position
		Tween.Play(flash, { Size = UDim2.fromOffset(900, 900), BackgroundTransparency = 1 }, 0.7, Enum.EasingStyle.Quint)
		for _, o in { self.Sun, self.Moon, self.Diamond, self.Streak } do
			Tween.Play(o, { BackgroundTransparency = 1 }, 0.35)
		end
		Tween.Play(self.MoonStroke, { Transparency = 1 }, 0.3)
		for _, g in self.Corona do
			Tween.Play(g.Frame, { BackgroundTransparency = 1, Size = UDim2.fromOffset(g.Frame.Size.X.Offset * 1.4, g.Frame.Size.Y.Offset * 1.4) }, 0.6)
		end
		for _, ray in self.Rays do
			Tween.Play(ray, { BackgroundTransparency = 1 }, 0.3)
		end
		return 0.15
	end,
}

-- ─── Constellation ───────────────────────────────────────────────────────
Styles.Constellation = {
	Build = function(self)
		local rng = Random.new(19)
		local c = self.Center
		-- faint dust behind
		self.Dust = {}
		for i = 1, 60 do
			local d = dot(self.Stage, rng:NextNumber() < 0.2 and 2 or 1, 301)
			d.Position = UDim2.fromOffset(rng:NextNumber(0, STAGE), rng:NextNumber(30, STAGE - 60))
			d.BackgroundTransparency = 1
			self.Dust[i] = { Dot = d, A = 0.55 + rng:NextNumber() * 0.35, Phase = rng:NextNumber() * TAU }
		end
		-- stars, kept apart from each other
		local stars = {}
		local tries = 0
		while #stars < 22 and tries < 600 do
			tries += 1
			local p = Vector2.new(c.X + rng:NextNumber(-170, 170), c.Y - 20 + rng:NextNumber(-115, 115))
			local ok = true
			for _, s in stars do
				if (s.P - p).Magnitude < 46 then
					ok = false
					break
				end
			end
			if ok then
				local big = rng:NextNumber() < 0.25
				local d = dot(self.Stage, big and 6 or 4, 304)
				d.Position = UDim2.fromOffset(p.X, p.Y)
				d.BackgroundTransparency = 1
				local glow = dot(self.Stage, big and 16 or 10, 303)
				glow.Position = d.Position
				glow.BackgroundTransparency = 1
				table.insert(stars, { P = p, Dot = d, Glow = glow, Big = big, Delay = rng:NextNumber() * 0.7, Lit = 0 })
			end
		end
		-- a path through the nearest stars, plus a few cross links
		local edges, used = {}, { [1] = true }
		local current = 1
		for _ = 2, #stars do
			local best, bestD
			for j, s in stars do
				if not used[j] then
					local d = (s.P - stars[current].P).Magnitude
					if not bestD or d < bestD then
						best, bestD = j, d
					end
				end
			end
			used[best] = true
			table.insert(edges, { current, best })
			current = best
		end
		for _ = 1, 7 do
			local a = rng:NextInteger(1, #stars)
			local best, bestD
			for j, s in stars do
				local d = (s.P - stars[a].P).Magnitude
				if j ~= a and d > 1 and (not bestD or d < bestD) then
					local dup = false
					for _, e in edges do
						if (e[1] == a and e[2] == j) or (e[1] == j and e[2] == a) then
							dup = true
						end
					end
					if not dup then
						best, bestD = j, d
					end
				end
			end
			if best then
				table.insert(edges, { a, best })
			end
		end
		for _, e in edges do
			e.Line = frame(self.Stage, { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(0, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 1, ZIndex = 302 })
			e.Q = 0
		end
		self.Stars, self.Edges = stars, edges
	end,
	Step = function(self, t, shown, dt)
		for _, d in self.Dust do
			d.Dot.BackgroundTransparency = 1 - smooth((t - 0.1) / 0.8) * (1 - d.A) * (0.7 + 0.3 * math.sin(t * 1.7 + d.Phase))
		end
		for _, s in self.Stars do
			local k = smooth((t - 0.2 - s.Delay) / 0.5)
			s.Dot.BackgroundTransparency = 1 - k * (0.55 + s.Lit * 0.45)
			s.Glow.BackgroundTransparency = 1 - k * (0.05 + s.Lit * 0.12) * (0.8 + 0.2 * math.sin(t * 3 + s.P.X))
			s.Lit = math.max(0, s.Lit - dt * 0.6)
		end
		-- edges draw in order as progress grows, each growing from its first star
		local n = #self.Edges
		local want = shown * n
		for i, e in self.Edges do
			local target = math.clamp(want - (i - 1), 0, 1)
			if t < 1 then
				target = 0
			end
			if e.Q ~= target then
				e.Q = math.min(target, e.Q + dt * 4)
				local a, b = self.Stars[e[1]], self.Stars[e[2]]
				placeLine(e.Line, a.P, a.P:Lerp(b.P, smooth(e.Q)))
				e.Line.BackgroundTransparency = e.Q > 0 and 0.55 or 1
				if e.Q >= 1 then
					a.Lit, b.Lit = 1, 1
				end
			end
		end
	end,
	Burst = function(self)
		local c = self.Center
		for _, e in self.Edges do
			e.Line.BackgroundTransparency = 0.1
			Tween.Play(e.Line, { BackgroundTransparency = 1 }, 0.45)
		end
		for _, s in self.Stars do
			Tween.Play(s.Dot, { Position = UDim2.fromOffset(c.X, c.Y), BackgroundTransparency = 1 }, 0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			Tween.Play(s.Glow, { BackgroundTransparency = 1 }, 0.3)
		end
		for _, d in self.Dust do
			Tween.Play(d.Dot, { BackgroundTransparency = 1 }, 0.3)
		end
		return 0.35
	end,
}

-- ─── Terminal ────────────────────────────────────────────────────────────
Styles.Terminal = {
	NoInfo = true,
	Dim = 0.18,
	Build = function(self)
		local c = self.Center
		local panel = frame(self.Stage, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(c.X, c.Y), Size = UDim2.fromOffset(470, 250), BackgroundColor3 = Color3.fromRGB(9, 9, 11), BackgroundTransparency = 1, ZIndex = 302 })
		Util.Corner(10, panel)
		self.PanelStroke = Util.Stroke(panel, Color3.fromRGB(46, 46, 52), 1, 1)
		local scale = Util.New("UIScale", { Scale = 0.97, Parent = panel })
		self.Panel, self.PanelScale = panel, scale
		local function text(props)
			local l = Util.Label(props)
			l.Parent = panel
			l.ZIndex = 303
			l.TextTransparency = 1
			l.RichText = true
			return l
		end
		self.Head = text({ Text = escape(string.lower(self.Window.Title)) .. "  ·  boot", FontFace = Theme.Fonts.Mono, TextSize = 12, Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -120, 0, 16) })
		self.Head.TextColor3 = Color3.fromRGB(150, 150, 158)
		self.Ver = text({ Text = "v" .. tostring(self.Window.Library.Version), FontFace = Theme.Fonts.Mono, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(1, -116, 0, 10), Size = UDim2.fromOffset(100, 16) })
		self.Ver.TextColor3 = Color3.fromRGB(90, 90, 98)
		self.Rule = frame(panel, { Position = UDim2.fromOffset(0, 34), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Color3.fromRGB(32, 32, 38), BackgroundTransparency = 1, ZIndex = 303 })
		self.Body = text({ Text = "", FontFace = Theme.Fonts.Mono, TextSize = 13, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = false, Position = UDim2.fromOffset(16, 46), Size = UDim2.new(1, -32, 1, -58), LineHeight = 1.25 })
		self.Body.TextColor3 = Color3.fromRGB(215, 215, 222)
		self.Lines = {}
		self.Typed = 0
		self:_term("<font color=\"#7a7a84\">$</font> proximity load")
		self:_term("<font color=\"#7a7a84\">resolving theme, fonts, configs</font>")
	end,
	Step = function(self, t, shown, dt)
		local appear = smooth(t / 0.4)
		self.Panel.BackgroundTransparency = 1 - appear * 0.94
		self.PanelStroke.Transparency = 1 - appear
		self.PanelScale.Scale = 0.97 + 0.03 * appear
		for _, l in { self.Head, self.Ver, self.Body } do
			l.TextTransparency = 1 - appear
		end
		self.Rule.BackgroundTransparency = 1 - appear
		-- typing: reveal characters of the stored lines at a steady pace
		self.Typed += dt * 120
		local width = 26
		local filled = math.floor(shown * width + 0.5)
		local bar = "[" .. string.rep("#", filled) .. string.rep(".", width - filled) .. "]"
		local pct = string.format("%3d%%", math.floor(shown * 100 + 0.5))
		local eta = self.EtaText or ""
		local caret = (math.floor(t * 2.2) % 2 == 0) and "_" or " "
		local budget = math.floor(self.Typed)
		local out = {}
		for _, line in self.Lines do
			local plain = line.Plain
			if budget <= 0 then
				break
			end
			if budget >= #plain then
				table.insert(out, line.Rich)
				budget -= #plain
			else
				table.insert(out, escape(string.sub(plain, 1, budget)))
				budget = 0
			end
		end
		local done = budget > 0
		while #out > 7 do
			table.remove(out, 1)
		end
		if done then
			table.insert(out, bar .. "  " .. pct .. "  <font color=\"#7a7a84\">" .. eta .. "</font>")
			table.insert(out, "<font color=\"#7a7a84\">" .. caret .. "</font>")
		end
		self.Body.Text = table.concat(out, "\n")
	end,
	Stage = function(self, text)
		self:_term("<font color=\"#7a7a84\">&gt;</font> " .. escape(text))
	end,
	Burst = function(self)
		self:_term("<font color=\"#ffffff\">ready.</font>")
		self.Typed += 999
		task.wait(0.25)
		Tween.Play(self.PanelScale, { Scale = 1.03 }, 0.35, Enum.EasingStyle.Quint)
		Tween.Play(self.Panel, { BackgroundTransparency = 1 }, 0.3)
		Tween.Play(self.PanelStroke, { Transparency = 1 }, 0.3)
		for _, l in { self.Head, self.Ver, self.Body } do
			Tween.Play(l, { TextTransparency = 1 }, 0.25)
		end
		Tween.Play(self.Rule, { BackgroundTransparency = 1 }, 0.25)
		return 0.1, true -- open with the chosen menu animation instead of from a point
	end,
}

-- ═══ shared shell ════════════════════════════════════════════════════════
function Intros.Has(style)
	return Styles[style] ~= nil
end

function Intros.new(window, options, style)
	options = options or {}
	local def = Styles[style]
	local self = setmetatable({}, Intros)
	self.Window = window
	self.Def = def
	self.Started = os.clock()
	self.T = 0
	self.Display = 0
	self.Samples = {}

	local root = frame(Shared.Gui.Root, { Name = "ProximityIntro", Size = UDim2.fromScale(1, 1), ZIndex = 300 })
	self.Root = root
	local dim = frame(root, { BackgroundColor3 = Color3.new(0, 0, 0), Size = UDim2.fromScale(1, 1), ZIndex = 300 })
	Util.Gradient(dim, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 0.2) }), 90)
	Tween.Play(dim, { BackgroundTransparency = options.Dim or def.Dim or 0.22 }, 0.6, Enum.EasingStyle.Sine)
	self.Dim = dim
	local stage = frame(root, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.46), Size = UDim2.fromOffset(STAGE, STAGE), ZIndex = 301 })
	local view = workspace.CurrentCamera.ViewportSize
	local scale = Util.New("UIScale", { Scale = math.clamp(math.min(view.X, view.Y) / 820, 0.55, 1.2), Parent = stage })
	self.Stage = stage
	self.Center = Vector2.new(STAGE / 2, STAGE / 2)

	def.Build(self)
	if not def.NoInfo then
		self:_buildInfo(root, scale.Scale)
	end
	self.Conn = RunService.RenderStepped:Connect(function(dt)
		-- frame-based clock: a heavy start-up frame can not skip the intro
		self.T += math.min(dt, 1 / 30)
		local shown = self:_progress(os.clock() - self.Started)
		def.Step(self, self.T, shown, math.min(dt, 1 / 30))
	end)
	return self
end

function Intros:_term(rich)
	local plain = string.gsub(rich, "<[^>]+>", "")
	plain = string.gsub(string.gsub(string.gsub(plain, "&lt;", "<"), "&gt;", ">"), "&amp;", "&")
	table.insert(self.Lines, { Rich = rich, Plain = plain })
	while #self.Lines > 12 do
		local first = table.remove(self.Lines, 1)
		self.Typed = math.max(0, self.Typed - #first.Plain)
	end
end

function Intros:_buildInfo(root, s)
	local info = frame(root, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.46, (STAGE / 2) * s * 0.9), Size = UDim2.fromOffset(300, 60), ZIndex = 301 })
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
	local track = frame(info, { Size = UDim2.new(1, 0, 0, 2), Position = UDim2.fromOffset(0, 25), BackgroundColor3 = WHITE, ZIndex = 301 })
	local fill = frame(track, { Size = UDim2.fromScale(0, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 0, ZIndex = 302 })
	fill.Visible = false
	local status = label({ Text = Locale.T("Preparing"), FontFace = Theme.Fonts.Regular, TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -70, 0, 16), Position = UDim2.fromOffset(0, 34) })
	status.TextColor3 = Color3.fromRGB(170, 170, 178)
	local eta = label({ Text = "", FontFace = Theme.Fonts.Mono, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, 0, 0, 16), Position = UDim2.fromOffset(0, 34) })
	eta.TextColor3 = Color3.fromRGB(120, 120, 128)
	if self.HidePct then
		pct.Visible = false
	end
	self.Info, self.Pct, self.Fill, self.Track, self.Status, self.Eta, self.TitleLabel = info, pct, fill, track, status, eta, title
	task.delay(0.5, function()
		if self.Root then
			for _, l in { title, pct, status, eta } do
				Tween.Play(l, { TextTransparency = 0 }, 0.6)
			end
			Tween.Play(track, { BackgroundTransparency = 0.86 }, 0.6)
			fill.Visible = true
		end
	end)
end

-- real progress, smoothed, with the time left; returns what is shown (0..1)
function Intros:_progress(t)
	if self.Exploding then
		return 1
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
	table.insert(self.Samples, { t, self.Display })
	while #self.Samples > 2 and self.Samples[1][1] < t - 1.5 do
		table.remove(self.Samples, 1)
	end
	local first = self.Samples[1]
	local rate = (self.Display - first[2]) / math.max(t - first[1], 0.05)
	local etaText
	if rate > 0.002 and self.Display < 0.98 then
		local left = (1 - self.Display) / rate
		etaText = left < 1 and "<1 s" or ("~" .. math.ceil(left) .. " s")
	else
		etaText = string.format("%.1f s", t)
	end
	self.EtaText = etaText
	if self.Fill then
		self.Fill.Size = UDim2.fromScale(shown, 1)
		self.Pct.Text = math.floor(shown * 100 + 0.5) .. "%"
		self.Eta.Text = etaText
	end
	return shown
end

function Intros:SetStage(text)
	if not text then
		return
	end
	if self.Status then
		self.Status.Text = text
	end
	if self.Def.Stage then
		self.Def.Stage(self, text)
	end
end

function Intros:Finish(onOpen)
	if self.Finishing then
		return
	end
	self.Finishing = true
	task.spawn(function()
		local start = os.clock()
		while self.Root and (self._shown or 0) < 0.97 and os.clock() - start < 1.2 do
			self.Display = 1
			RunService.RenderStepped:Wait()
		end
		if not self.Root then
			return
		end
		-- let the last state (full ring, totality, finished picture) read for a moment
		task.wait(0.25)
		self.Exploding = true
		if self.Fill then
			self.Fill.Size = UDim2.fromScale(1, 1)
			self.Pct.Text = "100%"
			self.Status.Text = Locale.T("Ready")
			self.Eta.Text = ""
			for _, l in { self.TitleLabel, self.Pct, self.Status, self.Eta } do
				Tween.Play(l, { TextTransparency = 1 }, 0.35)
			end
			Tween.Play(self.Track, { BackgroundTransparency = 1 }, 0.35)
			Tween.Play(self.Fill, { BackgroundTransparency = 1 }, 0.35)
		end
		local delay, ownAnimation = self.Def.Burst(self)
		Tween.Play(self.Dim, { BackgroundTransparency = 1 }, 0.8, Enum.EasingStyle.Sine)
		task.delay(delay or 0.2, function()
			if onOpen then
				local stage = self.Stage
				local point = stage and (stage.AbsolutePosition + stage.AbsoluteSize / 2 - Shared.Gui.Root.AbsolutePosition)
				onOpen((not ownAnimation) and point or nil)
			end
		end)
		task.delay(1.1, function()
			self:Destroy()
		end)
	end)
end

function Intros:Destroy()
	if self.Conn then
		self.Conn:Disconnect()
		self.Conn = nil
	end
	if self.Root then
		self.Root:Destroy()
		self.Root = nil
	end
end

return Intros
