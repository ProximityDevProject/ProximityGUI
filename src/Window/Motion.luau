--!nocheck
--[[
	Proximity · Window/Motion
	How the window appears and hides (menu key, button, Window:Open/Close).

	Engine
	  · Physics, not fixed curves: one spring drives the progress p
	    (0 hidden, 1 shown). Opening may use an under-damped spring, so the
	    window lands with a small natural overshoot; hiding is critically
	    damped and quicker. Press the key mid-way and the spring turns around
	    keeping its speed - no jumps, no restarts.
	  · Every style is one function of p, so open and hide are the same
	    choreography played both ways.
	  · Layers moved together: content (CanvasGroup), plate, border, rim and
	    the soft shadow, which follows the window and hides while it tilts.
	  · Exposure: content brightens from dim to full as it arrives.
	  · FX layer: a clipped CanvasGroup above the window for glowing edges,
	    scan bands and flashes - it never spills outside the window shape.
	  · When it settles: a soft shine sweeps over the glass, the accent rim
	    pulses once and the page content rises in, sections one by one.

	Styles
	  Planet   grows out of the planet button (or its own centre) with a
	           ripple, curving in; folds back and the button ripples
	  Rise     lifts up into place from slightly below, shadow deepening
	  Zoom     springs out of the centre with a lively overshoot
	  Drop     falls from above with a tilt and settles with a wobble
	  Slide    glides in from the nearest screen side with motion trails
	  Swing    swings down on its top-left hinge like a hanging sign
	  Wipe     a glowing diagonal edge sweeps across and reveals it
	  Unfold   opens from a bright line in the middle, edges glowing
	  Scan     a scan band runs down and draws it line by line
	  Glitch   arrives in flickering horizontal slices with jitter
	  Fade     a quiet fade with a gentle focus pull
	  None     instant
]]

local Util = require("../Core/Util")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")

local RunService = Env.Service("RunService")

local Motion = {}

Motion.Styles = { "Planet", "Rise", "Zoom", "Drop", "Slide", "Swing", "Wipe", "Unfold", "Scan", "Glitch", "Fade", "None" }

local WHITE = Color3.new(1, 1, 1)

local function clamp01(x)
	return math.clamp(x, 0, 1)
end

-- a NumberSequence from loose points: clamps, sorts, pins both ends (max 20 points)
local function sequence(points)
	table.sort(points, function(a, b)
		return a[1] < b[1]
	end)
	local out, last = {}, -1
	for _, pt in points do
		local t = math.clamp(pt[1], 0, 1)
		if t <= last then
			t = last + 0.0005
		end
		if t <= 1 and #out < 18 then
			table.insert(out, NumberSequenceKeypoint.new(t, math.clamp(pt[2], 0, 1)))
			last = t
		end
	end
	if #out == 0 then
		return NumberSequence.new(1)
	end
	if out[1].Time > 0 then
		table.insert(out, 1, NumberSequenceKeypoint.new(0, out[1].Value))
	end
	if out[#out].Time < 1 then
		table.insert(out, NumberSequenceKeypoint.new(1, out[#out].Value))
	end
	return NumberSequence.new(out)
end

-- a soft bright band at position e (0..1) along the gradient
local function band(e, width, peak)
	return sequence({ { 0, 1 }, { e - width, 1 }, { e, 1 - peak }, { e + width * 0.6, 1 }, { 1, 1 } })
end

-- ═══ styles ══════════════════════════════════════════════════════════════
-- Open / Close: spring frequency (Hz) and damping ratio (<1 bounces)
-- Map(c, p, ctx): fill c for progress p (may overshoot past 1 when opening)
local S = {}

S.Planet = {
	Open = { 2.3, 0.74 },
	Close = { 3.4, 1 },
	Ripple = true,
	Map = function(c, p, ctx)
		local d = ctx.From
		if d then
			-- curve in: the sideways part arrives a little later than the vertical
			local qx, qy = clamp01(p) ^ 0.8, clamp01(p) ^ 1.15
			c.Offset = Vector2.new(d.X * (1 - qx), d.Y * (1 - qy))
			c.Scale = 0.04 + 0.96 * p
			c.Rotation = (1 - clamp01(p)) * (d.X >= 0 and 8 or -8)
		else
			c.Scale = 0.6 + 0.4 * p
			c.Offset = Vector2.new(0, (1 - p) * 16)
		end
		c.Alpha = clamp01(p * 2.4)
		c.Exposure = clamp01(p * 1.3)
		c.Frame = clamp01((p - 0.5) / 0.5)
	end,
}

S.Rise = {
	Open = { 2.1, 0.86 },
	Close = { 3.2, 1 },
	Map = function(c, p)
		c.Offset = Vector2.new(0, (1 - p) * 38)
		c.Scale = 0.95 + 0.05 * p
		c.Alpha = clamp01(p * 1.5)
		c.Exposure = clamp01(p * 1.2)
		c.ShadowK = clamp01(p) ^ 2
	end,
}

S.Zoom = {
	Open = { 2.7, 0.58 },
	Close = { 3.6, 1 },
	Map = function(c, p)
		c.Scale = 0.8 + 0.2 * p
		c.Alpha = clamp01(p * 2.2)
		c.Exposure = clamp01(p * 1.5)
		c.Offset = Vector2.new(0, (1 - p) * 10)
	end,
}

S.Drop = {
	Open = { 2.0, 0.5 },
	Close = { 3.0, 1 },
	Map = function(c, p)
		c.Offset = Vector2.new(0, -(1 - p) * 130)
		c.Rotation = (1 - p) * -3.2
		c.Scale = 0.96 + 0.04 * p
		c.Alpha = clamp01(p * 2.6)
		c.Exposure = clamp01(p * 1.4)
	end,
}

S.Slide = {
	Open = { 2.2, 0.8 },
	Close = { 3.2, 1 },
	Trail = true,
	Map = function(c, p, ctx)
		c.Offset = Vector2.new(ctx.Dir * (1 - p) * 240, 0)
		c.Rotation = ctx.Dir * (1 - p) * -1.6
		c.Alpha = clamp01(p * 1.9)
		c.Exposure = clamp01(p * 1.3)
	end,
}

S.Swing = {
	Open = { 1.7, 0.45 },
	Close = { 3.0, 1 },
	Map = function(c, p, ctx)
		-- rotate around the top-left corner: move the centre so the hinge stays put
		local theta = -(1 - p) * 17
		local r = math.rad(theta)
		local v = ctx.Size / 2
		local rv = Vector2.new(v.X * math.cos(r) - v.Y * math.sin(r), v.X * math.sin(r) + v.Y * math.cos(r))
		c.Rotation = theta
		c.Offset = rv - v + Vector2.new(0, (1 - p) * 18)
		c.Scale = 0.96 + 0.04 * p
		c.Alpha = clamp01(p * 2.4)
		c.Exposure = clamp01(p * 1.4)
	end,
}

S.Wipe = {
	Open = { 1.45, 1 },
	Close = { 2.3, 1 },
	Masked = true,
	Map = function(c, p)
		local e = p * 1.42 - 0.21
		c.Mask = { Rotation = 24, Seq = sequence({ { 0, 0 }, { e - 0.09, 0 }, { e + 0.09, 1 }, { 1, 1 } }) }
		c.Fx = { Rotation = 24, Seq = band(e + 0.05, 0.1, 0.55), Alpha = math.sin(clamp01(p) * math.pi) }
		c.Alpha = clamp01(p * 4)
		c.Exposure = 0.7 + 0.3 * clamp01(p)
		c.Frame = clamp01((p - 0.72) / 0.28)
		c.Offset = Vector2.new((1 - p) * -12, 0)
	end,
}

S.Unfold = {
	Open = { 1.6, 1 },
	Close = { 2.5, 1 },
	Masked = true,
	Map = function(c, p)
		local half, soft = clamp01(p) * 0.57, 0.04
		c.Mask = { Rotation = 90, Seq = sequence({ { 0, 1 }, { 0.5 - half - soft, 1 }, { 0.5 - half, 0 }, { 0.5 + half, 0 }, { 0.5 + half + soft, 1 }, { 1, 1 } }) }
		local glow = 1 - clamp01((p - 0.8) / 0.2)
		c.Fx = { Rotation = 90, Seq = sequence({ { 0, 1 }, { 0.5 - half - 0.035, 1 }, { 0.5 - half, 0.35 }, { 0.5 - half + 0.03, 1 }, { 0.5 + half - 0.03, 1 }, { 0.5 + half, 0.35 }, { 0.5 + half + 0.035, 1 }, { 1, 1 } }), Alpha = glow * clamp01(p * 6) }
		c.Scale = 0.985 + 0.015 * p
		c.Alpha = clamp01(p * 5)
		c.Exposure = 0.75 + 0.25 * clamp01(p)
		c.Frame = clamp01((p - 0.75) / 0.25)
	end,
}

S.Scan = {
	Open = { 1.35, 1 },
	Close = { 2.2, 1 },
	Masked = true,
	Map = function(c, p)
		local e = p * 1.16 - 0.08
		c.Mask = { Rotation = 90, Seq = sequence({ { 0, 0 }, { e, 0 }, { e + 0.03, 1 }, { 1, 1 } }) }
		c.Fx = { Rotation = 90, Seq = sequence({ { 0, 1 }, { e - 0.14, 1 }, { e - 0.005, 0.72 }, { e + 0.004, 0.15 }, { e + 0.02, 1 }, { 1, 1 } }), Alpha = math.sin(clamp01(p) * math.pi) ^ 0.6 }
		c.Alpha = clamp01(p * 5)
		c.Exposure = 0.8 + 0.2 * clamp01(p)
		c.Frame = clamp01((p - 0.82) / 0.18)
	end,
}

-- fixed order in which the slices appear
local SLICES = 9
local SLICE_AT = {}
do
	local rng = Random.new(31)
	for k = 1, SLICES do
		SLICE_AT[k] = rng:NextNumber(0.02, 0.9)
	end
end

S.Glitch = {
	Open = { 1.5, 1 },
	Close = { 2.4, 1 },
	Masked = true,
	Map = function(c, p)
		local rng = Random.new(math.floor(os.clock() * 22))
		local calm = clamp01(p) ^ 2
		local pts = {}
		for k = 1, SLICES do
			local on = (p * 1.18 - 0.08) > SLICE_AT[k]
			if p < 0.97 and rng:NextNumber() < 0.14 * (1 - calm) then
				on = not on
			end
			local v = on and 0 or 1
			table.insert(pts, { (k - 1) / SLICES, v })
			table.insert(pts, { k / SLICES - 0.001, v })
		end
		c.Mask = { Rotation = 90, Seq = sequence(pts) }
		c.Offset = Vector2.new((rng:NextNumber() - 0.5) * 18 * (1 - calm), (rng:NextNumber() - 0.5) * 4 * (1 - calm))
		c.Alpha = clamp01(p * 3)
		c.Exposure = 0.65 + 0.35 * clamp01(p) + (rng:NextNumber() < 0.2 and 0.25 * (1 - calm) or 0)
		c.Fx = { Rotation = 0, Seq = NumberSequence.new(0.4), Alpha = (rng:NextNumber() < 0.25 and 0.18 or 0.04) * (1 - calm) }
		c.Frame = clamp01((p - 0.85) / 0.15)
	end,
}

S.Fade = {
	Open = { 1.8, 1 },
	Close = { 2.8, 1 },
	Map = function(c, p)
		c.Scale = 1.018 - 0.018 * p
		c.Alpha = clamp01(p)
		c.Exposure = clamp01(p)
	end,
}

function Motion.Has(style)
	return S[style] ~= nil
end

-- ═══ helpers ═════════════════════════════════════════════════════════════
local function shadowOf(window)
	local plate = window.Plate
	local shadow = plate and (plate:FindFirstChildOfClass("UIShadow") or plate:FindFirstChild("Shadow"))
	if shadow and window._shadowBase == nil then
		local ok, value = pcall(function()
			return shadow:IsA("ImageLabel") and shadow.ImageTransparency or shadow.Transparency
		end)
		window._shadowBase = ok and value or 0.35
	end
	return shadow
end

local function setShadow(window, k)
	local shadow = shadowOf(window)
	if shadow then
		local value = 1 - (1 - (window._shadowBase or 0.35)) * clamp01(k)
		pcall(function()
			if shadow:IsA("ImageLabel") then
				shadow.ImageTransparency = value
			else
				shadow.Transparency = value
			end
		end)
	end
end

-- a clipped glow layer over the window
local function fxLayer(window)
	local fx = window.Holder:FindFirstChild("ProximityMotionFx")
	if not fx then
		fx = Util.New("CanvasGroup", { Name = "ProximityMotionFx", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 8, GroupTransparency = 1, Parent = window.Holder })
		Util.Corner(10, fx)
		Util.New("Frame", { BorderSizePixel = 0, BackgroundColor3 = WHITE, Size = UDim2.fromScale(1, 1), Parent = fx })
		Util.New("UIGradient", { Name = "Shape", Parent = fx })
	end
	return fx
end

-- a ring that ripples out from a point in window-container space
local function ripple(window, point, size, strong)
	local parent = window.Holder.Parent
	if not (parent and point) then
		return
	end
	local ring = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(point.X, point.Y), Size = UDim2.fromOffset(8, 8), BackgroundTransparency = 1, ZIndex = 50, Parent = parent })
	Util.Round(ring)
	local stroke = Util.Stroke(ring, WHITE, strong and 1.6 or 1.1, strong and 0.15 or 0.4)
	local dot = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = WHITE, BackgroundTransparency = 0.3, ZIndex = 51, Parent = ring })
	Util.Round(dot)
	Tween.Play(ring, { Size = UDim2.fromOffset(size, size) }, 0.75, Enum.EasingStyle.Quint)
	Tween.Play(stroke, { Transparency = 1, Thickness = 0.4 }, 0.75, Enum.EasingStyle.Sine)
	Tween.Play(dot, { BackgroundTransparency = 1, Size = UDim2.fromOffset(2, 2) }, 0.4)
	task.delay(0.8, function()
		ring:Destroy()
	end)
end

-- when the window has landed: shine over the glass, a rim pulse
local function flourish(window)
	local fx = fxLayer(window)
	local shape = fx.Shape
	shape.Rotation = 24
	fx.GroupTransparency = 0
	local token = window._motionToken
	Tween.Value(0, 1, 0.95, function(k)
		if window._motionToken ~= token or not fx.Parent then
			return
		end
		local e = -0.25 + 1.5 * k
		shape.Transparency = sequence({ { 0, 1 }, { e - 0.2, 1 }, { e, 0.9 }, { e + 0.06, 0.93 }, { e + 0.2, 1 }, { 1, 1 } })
		if k >= 1 then
			fx:Destroy()
		end
	end, Enum.EasingStyle.Sine)
	local rim = window._rim
	if rim and window.RimEnabled then
		local base = window._rimThickness or rim.Thickness
		window._rimThickness = base
		Tween.Play(rim, { Thickness = base + 1.3 }, 0.18, Enum.EasingStyle.Quad)
		task.delay(0.18, function()
			Tween.Play(rim, { Thickness = base }, 0.5, Enum.EasingStyle.Sine)
		end)
	end
end

-- the page content rises in, sections one after another
function Motion.Cascade(window)
	local page = window.CurrentPage
	if not (page and page.Frame) or Tween.Speed <= 0 then
		return
	end
	page.Frame.Position = UDim2.fromOffset(0, 12)
	Tween.Play(page.Frame, { Position = UDim2.fromOffset(0, 0) }, 0.65, Enum.EasingStyle.Quint)
	for i, section in page.Sections or {} do
		local stroke = section.Stroke
		if stroke then
			stroke.Transparency = 1
			task.delay(0.04 * i, function()
				Tween.Play(stroke, { Transparency = 0 }, 0.45)
			end)
		end
	end
end

-- ═══ engine ══════════════════════════════════════════════════════════════
local function pieces(window)
	local holder = window.Holder
	return holder:FindFirstChild("Border"), holder:FindFirstChild("Rim")
end

local function cleanup(window)
	local holder, canvas = window.Holder, window.Canvas
	for _, name in { "ProximityMotionMask" } do
		local m = canvas:FindFirstChild(name)
		if m then
			m:Destroy()
		end
		local pm = window.Plate:FindFirstChild(name)
		if pm then
			pm:Destroy()
		end
	end
	local fx = holder:FindFirstChild("ProximityMotionFx")
	if fx then
		fx:Destroy()
	end
	if window._ghosts then
		for _, g in window._ghosts do
			g.Frame:Destroy()
		end
		window._ghosts = nil
	end
	local border, rimFrame = pieces(window)
	for _, f in { canvas, window.Plate, border, rimFrame } do
		if f then
			f.Rotation = 0
		end
	end
	canvas.GroupColor3 = WHITE
end

--[[
	Motion.Play(window, style, opening, rest, info, done)
	info.From: point (window-container space) to grow out of / fold into
]]
function Motion.Play(window, style, opening, rest, info, done)
	info = info or {}
	local holder, canvas, plate = window.Holder, window.Canvas, window.Plate
	local def = S[style]
	window._motionToken = (window._motionToken or 0) + 1
	local token = window._motionToken
	local glass = window.GlassTransparency or 0
	local scale = window:GetScale()
	local target = opening and 1 or 0

	local function finalOpen()
		cleanup(window)
		holder.Position = rest
		window._uiScale.Scale = scale
		canvas.GroupTransparency = glass
		plate.BackgroundTransparency = glass
		window._borderStroke.Transparency = 0
		window._rim.Transparency = window.RimEnabled and 0 or 1
		setShadow(window, 1)
	end

	if not def or Tween.Speed <= 0 then
		window._motion = nil
		if opening then
			finalOpen()
		else
			cleanup(window)
		end
		if done then
			done()
		end
		return
	end

	-- context for this run
	local parent = holder.Parent
	local area = parent and parent.AbsoluteSize or Vector2.new(1920, 1080)
	local restPx = Vector2.new(rest.X.Scale * area.X + rest.X.Offset, rest.Y.Scale * area.Y + rest.Y.Offset)
	local ctx = {
		Size = holder.AbsoluteSize.Magnitude > 0 and (Vector2.new(holder.Size.X.Offset, holder.Size.Y.Offset) * scale) or Vector2.new(700, 480),
		Dir = restPx.X < area.X / 2 and -1 or 1,
		From = info.From and (info.From - restPx) or nil,
	}

	-- keep position and speed from an animation that is being interrupted
	local state = window._motion
	if not state or state.Style ~= style then
		state = { P = opening and 0 or 1, V = 0, Style = style }
		if window._motion and window._motion.Style ~= style then
			state.P = window._motion.P
			cleanup(window)
		end
	end
	window._motion = state
	local spring = opening and def.Open or def.Close
	local omega = spring[1] * math.pi * 2
	local zeta = spring[2]

	local border, rimFrame = pieces(window)
	local masked = def.Masked
	local mask, plateMask
	local history = {}

	if opening and def.Ripple and state.P < 0.3 then
		ripple(window, info.From or restPx, 340, info.From ~= nil)
	end
	if opening and state.P < 0.2 then
		task.delay(masked and 0.25 or 0.08, function()
			if window._motionToken == token then
				Motion.Cascade(window)
			end
		end)
	end

	local function apply(p)
		local c = { Offset = Vector2.zero, Scale = 1, Rotation = 0, Alpha = 1, Exposure = 1 }
		def.Map(c, p, ctx)
		local alpha = clamp01(c.Alpha)
		local frameA = clamp01(c.Frame or alpha)
		holder.Position = rest + UDim2.fromOffset(c.Offset.X, c.Offset.Y)
		window._uiScale.Scale = scale * math.max(c.Scale, 0.01)
		for _, f in { canvas, plate, border, rimFrame } do
			if f then
				f.Rotation = c.Rotation
			end
		end
		canvas.GroupTransparency = glass + (1 - glass) * (1 - alpha)
		local e = 0.42 + 0.58 * clamp01(c.Exposure)
		canvas.GroupColor3 = Color3.new(e, e, e)
		window._borderStroke.Transparency = 1 - frameA
		window._rim.Transparency = window.RimEnabled and (1 - frameA) or 1
		-- the plate follows the content (masked styles: masked the same way)
		if c.Mask then
			if not mask then
				mask = canvas:FindFirstChild("ProximityMotionMask") or Util.New("UIGradient", { Name = "ProximityMotionMask", Parent = canvas })
				plateMask = plate:FindFirstChild("ProximityMotionMask")
				if not plateMask and not plate:FindFirstChildOfClass("UIGradient") then
					plateMask = Util.New("UIGradient", { Name = "ProximityMotionMask", Parent = plate })
				end
			end
			mask.Rotation, mask.Transparency = c.Mask.Rotation, c.Mask.Seq
			if plateMask then
				plateMask.Rotation, plateMask.Transparency = c.Mask.Rotation, c.Mask.Seq
				plate.BackgroundTransparency = glass + (1 - glass) * (1 - alpha)
			else
				plate.BackgroundTransparency = 1 - frameA * (1 - glass)
			end
		else
			plate.BackgroundTransparency = glass + (1 - glass) * (1 - alpha)
		end
		-- shadow: grows with the window, hides while it is tilted
		local tilt = 1 - clamp01(math.abs(c.Rotation) / 2.5)
		setShadow(window, (c.ShadowK or (c.Mask and frameA or alpha)) * tilt)
		-- glow layer
		if c.Fx then
			local fx = fxLayer(window)
			fx.Shape.Rotation = c.Fx.Rotation
			fx.Shape.Transparency = c.Fx.Seq
			fx.GroupTransparency = 1 - clamp01(c.Fx.Alpha)
		else
			local fx = holder:FindFirstChild("ProximityMotionFx")
			if fx and not fx:GetAttribute("Shine") then
				fx.GroupTransparency = 1
			end
		end
		-- motion trails: faint copies of the outline that lag behind
		if def.Trail then
			table.insert(history, 1, c.Offset)
			if #history > 16 then
				table.remove(history)
			end
			if not window._ghosts then
				window._ghosts = {}
				for i = 1, 3 do
					local g = Util.New("Frame", { Name = "ProximityMotionGhost", AnchorPoint = holder.AnchorPoint, Size = holder.Size, BackgroundColor3 = canvas.BackgroundColor3, BackgroundTransparency = 1, ZIndex = 0, Parent = holder.Parent })
					Util.Corner(10, g)
					local st = Util.Stroke(g, WHITE, 1, 1)
					local gs = Util.New("UIScale", { Parent = g })
					window._ghosts[i] = { Frame = g, Stroke = st, Scale = gs, Lag = i * 4 }
				end
			end
			for i, g in window._ghosts do
				local lagged = history[math.min(g.Lag, #history)] or c.Offset
				local gap = (lagged - c.Offset).Magnitude
				local a = clamp01(gap / 90) * (0.16 - i * 0.04) * alpha
				g.Frame.Position = rest + UDim2.fromOffset(lagged.X, lagged.Y)
				g.Frame.Rotation = c.Rotation
				g.Scale.Scale = scale * c.Scale
				g.Frame.BackgroundTransparency = 1 - a
				g.Stroke.Transparency = 1 - a * 1.6
			end
		end
	end

	local finished = false
	local conn
	conn = RunService.RenderStepped:Connect(function(dt)
		if window._motionToken ~= token or not holder.Parent then
			conn:Disconnect()
			return
		end
		dt = math.min(dt, 1 / 20) / math.max(Tween.Speed, 0.05)
		local steps = math.max(1, math.ceil(dt / (1 / 240)))
		local h = dt / steps
		for _ = 1, steps do
			local a = -omega * omega * (state.P - target) - 2 * zeta * omega * state.V
			state.V += a * h
			state.P += state.V * h
		end
		if not opening then
			state.P = math.max(state.P, -0.02)
		end
		if math.abs(state.P - target) < 0.0015 and math.abs(state.V) < 0.02 then
			state.P, state.V = target, 0
			finished = true
		end
		apply(state.P)
		if finished then
			conn:Disconnect()
			window._motion = nil
			if opening then
				finalOpen()
				flourish(window)
			else
				cleanup(window)
				if def.Ripple and info.From then
					ripple(window, info.From, 120, true)
				end
			end
			if done then
				done()
			end
		end
	end)
end

function Motion.Stop(window)
	window._motionToken = (window._motionToken or 0) + 1
	window._motion = nil
	cleanup(window)
end

return Motion
