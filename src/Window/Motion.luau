--!nocheck
--[[
	Proximity · Window/Motion
	How the window appears and hides (menu key, button, Window:Open/Close).

	Every style is one function of p (0 = hidden, 1 = shown) that places the
	window, so opening and closing are the same motion played forwards and
	backwards, and a close in the middle of an open turns around smoothly
	from wherever it is.

	  Planet   grows out of the planet button and folds back (default)
	  Rise     floats up a little while it fades in, sinks when it hides
	  Zoom     springs out of the centre, pops back in
	  Drop     drops from above with a soft settle, lifts away
	  Slide    glides in from the left, leaves the same way
	  Swing    swings up from a slight tilt like a card being dealt
	  Wipe     a soft diagonal edge sweeps across and reveals it
	  Unfold   opens from a thin line in the middle, top and bottom apart
	  Scan     a bright scan line runs down and draws it line by line
	  Fade     a plain, quiet crossfade
	  None     instant
]]

local Util = require("../Core/Util")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")

local RunService = Env.Service("RunService")

local Motion = {}

Motion.Styles = { "Planet", "Rise", "Zoom", "Drop", "Slide", "Swing", "Wipe", "Unfold", "Scan", "Fade", "None" }

local function clamp01(x)
	return math.clamp(x, 0, 1)
end

-- easing for x in 0..1
local Ease = {}
function Ease.Quint(x)
	return 1 - (1 - x) ^ 5
end
function Ease.Cubic(x)
	return 1 - (1 - x) ^ 3
end
function Ease.Back(x)
	local c1, c3 = 1.4, 2.4
	return 1 + c3 * (x - 1) ^ 3 + c1 * (x - 1) ^ 2
end
function Ease.Sine(x)
	return -(math.cos(math.pi * x) - 1) / 2
end
function Ease.QuintIn(x)
	return x ^ 4
end

-- a NumberSequence from loose points: clamps, sorts and pins both ends
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
		if t <= 1 then
			table.insert(out, NumberSequenceKeypoint.new(t, math.clamp(pt[2], 0, 1)))
			last = t
		end
	end
	if out[1].Time > 0 then
		table.insert(out, 1, NumberSequenceKeypoint.new(0, out[1].Value))
	end
	if out[#out].Time < 1 then
		table.insert(out, NumberSequenceKeypoint.new(1, out[#out].Value))
	end
	return NumberSequence.new(out)
end

-- each style: T = seconds to open, Ease = curve for opening (closing uses QuintIn),
-- Apply(ctx, p) sets offset / scale / rotation / alpha / mask for that moment
local S = {}

S.Rise = { T = 0.42, Ease = "Quint", Apply = function(c, p)
	c.Offset = Vector2.new(0, (1 - p) * 26)
	c.Scale = 0.985 + 0.015 * p
	c.Alpha = p
end }

S.Zoom = { T = 0.5, Ease = "Back", Apply = function(c, p)
	c.Scale = 0.82 + 0.18 * p
	c.Alpha = clamp01(p * 1.7)
end }

S.Drop = { T = 0.55, Ease = "Back", Apply = function(c, p)
	c.Offset = Vector2.new(0, -(1 - p) * 80)
	c.Scale = 0.97 + 0.03 * p
	c.Alpha = clamp01(p * 1.5)
end }

S.Slide = { T = 0.48, Ease = "Quint", Apply = function(c, p)
	c.Offset = Vector2.new(-(1 - p) * 140, 0)
	c.Alpha = clamp01(p * 1.3)
end }

S.Swing = { T = 0.6, Ease = "Back", Apply = function(c, p)
	c.Rotation = -(1 - p) * 9
	c.Offset = Vector2.new(-(1 - p) * 30, (1 - p) * 40)
	c.Scale = 0.9 + 0.1 * p
	c.Alpha = clamp01(p * 1.6)
	c.Frame = clamp01((p - 0.85) / 0.15) -- border and rim come in once it is straight
end }

S.Wipe = { T = 0.6, Ease = "Sine", Apply = function(c, p)
	local e = p * 1.36 - 0.18
	c.Mask = { Rotation = 20, Seq = sequence({ { 0, 0 }, { e - 0.12, 0 }, { e + 0.12, 1 }, { 1, 1 } }) }
	c.Alpha = clamp01(p * 3)
	c.Frame = clamp01((p - 0.7) / 0.3)
	c.Offset = Vector2.new((1 - p) * -10, 0)
end }

S.Unfold = { T = 0.5, Ease = "Quint", Apply = function(c, p)
	local half, soft = p * 0.56, 0.05
	c.Mask = { Rotation = 90, Seq = sequence({ { 0, 1 }, { 0.5 - half - soft, 1 }, { 0.5 - half, 0 }, { 0.5 + half, 0 }, { 0.5 + half + soft, 1 }, { 1, 1 } }) }
	c.Scale = 0.97 + 0.03 * p
	c.Alpha = clamp01(p * 4)
	c.Frame = clamp01((p - 0.75) / 0.25)
end }

S.Scan = { T = 0.62, Ease = "Cubic", Apply = function(c, p)
	local e = p * 1.12 - 0.06
	c.Mask = { Rotation = 90, Seq = sequence({ { 0, 0 }, { e, 0 }, { e + 0.035, 1 }, { 1, 1 } }) }
	c.Line = { Y = e, Alpha = math.sin(math.clamp(p, 0, 1) * math.pi) }
	c.Alpha = clamp01(p * 4)
	c.Frame = clamp01((p - 0.8) / 0.2)
end }

S.Fade = { T = 0.32, Ease = "Sine", Apply = function(c, p)
	c.Scale = 0.995 + 0.005 * p
	c.Alpha = p
end }

function Motion.Has(style)
	return S[style] ~= nil
end

--[[
	Motion.Play(window, style, opening, rest, done)
	Drives the window's holder, canvas, plate, border and rim every frame.
	A newer call (open after close or the other way) takes over smoothly.
]]
function Motion.Play(window, style, opening, rest, done)
	local def = S[style]
	window._motionToken = (window._motionToken or 0) + 1
	local token = window._motionToken
	local holder, canvas = window.Holder, window.Canvas
	local scale = window:GetScale()
	local glass = window.GlassTransparency or 0
	local from = window._motionP or (opening and 0 or 1)
	local to = opening and 1 or 0
	local duration = def.T * (opening and 1 or 0.7) * math.abs(to - from) * Tween.Speed

	-- scratch pieces that only live during the animation
	local mask = canvas:FindFirstChild("ProximityMotionMask")
	local line = holder:FindFirstChild("ProximityMotionLine")
	local function cleanup()
		if mask then
			mask:Destroy()
			mask = nil
		end
		if line then
			line:Destroy()
			line = nil
		end
		canvas.Rotation = 0
	end

	local function apply(p)
		window._motionP = p
		local c = { Offset = Vector2.zero, Scale = 1, Rotation = 0, Alpha = 1, Frame = nil, Mask = nil, Line = nil }
		def.Apply(c, p)
		local frameA = c.Frame or c.Alpha
		holder.Position = rest + UDim2.fromOffset(c.Offset.X, c.Offset.Y)
		window._uiScale.Scale = scale * c.Scale
		canvas.Rotation = c.Rotation
		canvas.GroupTransparency = glass + (1 - glass) * (1 - c.Alpha)
		window.Plate.BackgroundTransparency = c.Mask and 1 or (glass + (1 - glass) * (1 - c.Alpha))
		window._borderStroke.Transparency = 1 - frameA
		window._rim.Transparency = window.RimEnabled and (1 - frameA) or 1
		if c.Mask then
			if not mask then
				mask = Util.New("UIGradient", { Name = "ProximityMotionMask", Parent = canvas })
			end
			mask.Rotation = c.Mask.Rotation
			mask.Transparency = c.Mask.Seq
		elseif mask then
			mask:Destroy()
			mask = nil
		end
		if c.Line then
			if not line then
				line = Util.New("Frame", { Name = "ProximityMotionLine", BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.new(1, 24, 0, 2), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 20, Parent = holder })
				Util.Gradient(line, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0.2), NumberSequenceKeypoint.new(0.8, 0.2), NumberSequenceKeypoint.new(1, 1) }))
				local glow = Util.New("Frame", { BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.85, Size = UDim2.new(1, 0, 0, 10), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), ZIndex = 19, Parent = line })
				Util.Gradient(glow, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }), 90)
			end
			line.Position = UDim2.new(0.5, 0, math.clamp(c.Line.Y, 0, 1), 0)
			line.BackgroundTransparency = 1 - c.Line.Alpha * 0.9
		elseif line then
			line:Destroy()
			line = nil
		end
	end

	local function settle()
		apply(1)
		cleanup()
		window.Plate.BackgroundTransparency = glass
	end

	if duration <= 0 then
		apply(to)
		if opening then
			settle()
		end
		if done then
			done()
		end
		return
	end

	local ease = opening and Ease[def.Ease] or Ease.QuintIn
	local started = os.clock()
	local conn
	conn = RunService.RenderStepped:Connect(function()
		if window._motionToken ~= token or not holder.Parent then
			conn:Disconnect()
			return
		end
		local x = clamp01((os.clock() - started) / duration)
		local k = ease(x)
		apply(from + (to - from) * k)
		if x >= 1 then
			conn:Disconnect()
			if opening then
				settle()
			end
			if done then
				done()
			end
		end
	end)
end

-- stop any running motion and forget where it was (planet style takes over)
function Motion.Stop(window)
	window._motionToken = (window._motionToken or 0) + 1
	window._motionP = nil
	local canvas = window.Canvas
	local mask = canvas and canvas:FindFirstChild("ProximityMotionMask")
	if mask then
		mask:Destroy()
	end
	local line = window.Holder and window.Holder:FindFirstChild("ProximityMotionLine")
	if line then
		line:Destroy()
	end
	if canvas then
		canvas.Rotation = 0
	end
end

return Motion
