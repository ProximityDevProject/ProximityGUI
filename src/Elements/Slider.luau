--!nocheck
--[[
	Proximity · Elements/Slider
	One class, three shapes:
	  Section:Slider({ Name, Min = 0, Max = 100, Default = 50, Step = 1,
	                   Suffix = "%", Prefix, Format = fn(v) → string, Icon,
	                   Presets = { Low = 10, High = 90 }, Callback })
	  Section:RangeSlider({ ..., Default = { 10, 250 } })      → value { Min, Max }
	  Section:TextSlider({ ..., Labels = { "Slow", "Medium", "Fast" } })
	Double-click the value (or right-click -> Set value) to type an exact
	number. Arrow keys nudge while hovered (Shift = ×10). Hold Shift while
	dragging for a 10x finer step.
	Danger = 80 or { From = 80, To = 100 } paints a red zone on the track and
	turns the fill red inside it; Marks = { 0, 25, 50 } or Marks = 5 adds ticks.
	Methods: :SetMin :SetMax :SetLimits :SetStep :Increment :Decrement :GetPercent
]]

local Util = require("../Core/Util")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")
local Theme = require("../Theme")
local Icons = require("../Icons")
local Shared = require("../Shared")
local Base = require("./Base")

local UIS = Env.Service("UserInputService")

local Slider = Base.extend("Slider")

function Slider.new(section, options)
	local self = Base.new(Slider, section, options)
	self.Min = options.Min or 0
	self.Max = options.Max or 100
	if self.Min > self.Max then
		Shared.Lib:_optionWarning("Slider", self.Name, string.format("Min (%s) is bigger than Max (%s), swapped them", tostring(self.Min), tostring(self.Max)))
		self.Min, self.Max = self.Max, self.Min
	end
	self.Danger = options.Danger
	self.Marks = options.Marks
	self.Labels = options.Labels or options.TextProps
	if self.Labels then
		self.Min, self.Max, self.Step = 1, #self.Labels, 1
	else
		local decimals = options.Decimals or options.Rounding or options.Round
		self.Step = options.Step or options.Increment or (decimals and 10 ^ -decimals) or 1
	end
	self.Range = options.Range == true
	self.Suffix = options.Suffix or ""
	self.Prefix = options.Prefix or ""
	self.Format = options.Format
	self.Presets = options.Presets
	local default = Util.Opt(options, "Default", "Value")
	if self.Range then
		default = default or { self.Min, self.Max }
	elseif self.Labels and type(default) == "string" then
		default = table.find(self.Labels, default) or 1
	end
	self.Default = self:_normalize(default ~= nil and default or self.Min)
	self.Value = Util.DeepCopy(self.Default)
	return self:_register()
end

function Slider:_snap(v)
	v = tonumber(v)
	if not v then
		return nil
	end
	return Util.Clamp(Util.Snap(v, self.Step, self.Min), self.Min, self.Max)
end

function Slider:_normalize(v)
	if self.Range then
		if type(v) ~= "table" then
			return nil
		end
		local a = self:_snap(v.Min or v[1])
		local b = self:_snap(v.Max or v[2])
		if not a or not b then
			return nil
		end
		if a > b then
			a, b = b, a
		end
		return { Min = a, Max = b }
	end
	if self.Labels and type(v) == "string" then
		v = table.find(self.Labels, v)
	end
	return self:_snap(v)
end

function Slider:_callbackArgs()
	if self.Labels then
		return self.Labels[self.Value], self.Value
	end
	return self.Value
end

function Slider:GetText(): string
	return self:_format(self.Value)
end

function Slider:_format(v)
	if self.Range and type(v) == "table" then
		return self:_format(v.Min) .. " - " .. self:_format(v.Max)
	end
	if self.Labels then
		return tostring(self.Labels[v] or v)
	end
	if self.Format then
		local ok, text = pcall(self.Format, v)
		if ok then
			return tostring(text)
		end
	end
	return self.Prefix .. Util.FormatNumber(v, Util.Decimals(self.Step)) .. self.Suffix
end

function Slider:GetPercent(): number
	local v = self.Range and self.Value.Max or self.Value
	return (v - self.Min) / math.max(self.Max - self.Min, 1e-9)
end

function Slider:SetMin(min: number)
	self.Min = min
	self:Set(self.Value, true)
	if self._mounted then
		self:_render(true)
	end
	return self
end
function Slider:SetMax(max: number)
	self.Max = max
	self:Set(self.Value, true)
	if self._mounted then
		self:_render(true)
	end
	return self
end
function Slider:SetLimits(min: number, max: number)
	self.Min, self.Max = min, max
	local v = self:_normalize(self.Value)
	if v ~= nil then
		self.Value = v
	end
	if self._mounted then
		self:_render(true)
	end
	return self
end
Slider.SetRange = Slider.SetLimits
function Slider:SetStep(step: number)
	self.Step = step
	return self
end
function Slider:Increment(n: number?)
	if self.Range then
		return self
	end
	return self:Set(self.Value + (n or 1) * self.Step)
end
function Slider:Decrement(n: number?)
	return self:Increment(-(n or 1))
end

function Slider:_navActivate() end
function Slider:_navAdjust(dir)
	if not self.Range then
		self:_userSet(self.Value + dir * self.Step)
	end
end

function Slider:_serialize()
	if self.Range then
		return { self.Value.Min, self.Value.Max }
	end
	return self.Value
end

function Slider:_build(parent)
	local row = self:_row(parent, 46)
	row.Size = UDim2.new(1, 0, 0, self.Description and 54 or 46)
	local textBox = self._textBox
	textBox.Size = UDim2.new(1, -16, 0, 22)
	textBox.Position = UDim2.fromOffset(8, 2)
	self._title.Position = UDim2.new(0, 0, 0, 4)
	if self._desc then
		self._desc.Position = UDim2.new(0, 0, 0, 20)
	end
	-- value label (top right). Becomes a TextBox on double click.
	self._right.Size = UDim2.new(0, 0, 0, 26)
	local value = Util.New("TextBox", {
		Name = "Value",
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		TextEditable = false,
		Text = "",
		FontFace = Theme.Fonts.Mono,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 16),
		LayoutOrder = 100,
		Parent = self._right,
	})
	Theme.Paint(value, { TextColor3 = "Text" })
	self._valueBox = value

	local trackHolder = Util.New("TextButton", {
		Name = "Track",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -16, 0, 16),
		Position = UDim2.new(0, 8, 1, -20),
		Parent = row,
	})
	local track = Util.New("Frame", { Size = UDim2.new(1, 0, 0, 4), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Parent = trackHolder })
	Util.Round(track)
	Theme.Paint(track, { BackgroundColor3 = "Surface3" })
	local fill = Util.New("Frame", { Size = UDim2.fromScale(0, 1), Parent = track })
	Util.Round(fill)
	Theme.Paint(fill, { BackgroundColor3 = "Accent" })

	local function knob()
		local k = Util.New("Frame", { Size = UDim2.fromOffset(10, 10), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), ZIndex = 3, Parent = track })
		Util.Round(k)
		Theme.Paint(k, { BackgroundColor3 = "Accent" })
		local ring = Util.Stroke(k, nil, 2)
		Theme.Paint(ring, { Color = "Bg" })
		return k
	end
	self._track, self._fill = track, fill
	self._knobA = knob()
	if self.Range then
		self._knobB = knob()
	end
	-- the danger zone and the marks
	local function rel(v)
		return math.clamp((v - self.Min) / math.max(self.Max - self.Min, 1e-9), 0, 1)
	end
	if self.Danger and not self.Labels then
		local from = type(self.Danger) == "table" and (self.Danger.From or self.Danger[1]) or self.Danger
		local to = type(self.Danger) == "table" and (self.Danger.To or self.Danger[2]) or self.Max
		self._dangerFrom, self._dangerTo = from, to
		local zone = Util.New("Frame", { Size = UDim2.fromScale(rel(to) - rel(from), 1), Position = UDim2.fromScale(rel(from), 0), BackgroundTransparency = 0.6, ZIndex = 1, Parent = track })
		Util.Round(zone)
		Theme.Paint(zone, { BackgroundColor3 = "Risky" })
	end
	if self.Marks and not self.Labels then
		local marks = self.Marks
		if type(marks) == "number" then
			local list = {}
			for i = 0, marks - 1 do
				table.insert(list, self.Min + (self.Max - self.Min) * i / math.max(marks - 1, 1))
			end
			marks = list
		end
		for _, m in marks do
			local tick = Util.New("Frame", { Size = UDim2.fromOffset(2, 8), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(rel(m), 0.5), BorderSizePixel = 0, ZIndex = 2, Parent = track })
			Util.Round(tick)
			Theme.Paint(tick, { BackgroundColor3 = "StrokeHi" })
		end
	end
	-- discrete ticks for text sliders
	if self.Labels and #self.Labels <= 12 then
		for i = 1, #self.Labels do
			local tick = Util.New("Frame", { Size = UDim2.fromOffset(2, 2), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale((i - 1) / math.max(#self.Labels - 1, 1), 0.5), ZIndex = 2, Parent = track })
			Util.Round(tick)
			Theme.Paint(tick, { BackgroundColor3 = "TextMute" })
		end
	end

	-- dragging
	local dragging, which = false, nil
	local function valueAt(x)
		local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		return self.Min + (self.Max - self.Min) * rel
	end
	-- Shift while dragging: 10x finer, measured from where Shift went down
	local fineX, fineV = nil, nil
	local function apply(x)
		local v = valueAt(x)
		local shift = UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift)
		if shift and not self.Range and type(self.Value) == "number" then
			if not fineX then
				fineX, fineV = x, self.Value
			end
			v = fineV + (x - fineX) / math.max(track.AbsoluteSize.X, 1) * (self.Max - self.Min) / 10
		else
			fineX, fineV = nil, nil
		end
		if self.Range then
			local cur = self.Value
			if which == "A" then
				self:Set({ Min = math.min(v, cur.Max), Max = cur.Max })
			else
				self:Set({ Min = cur.Min, Max = math.max(v, cur.Min) })
			end
		else
			self:Set(v)
		end
	end
	trackHolder.InputBegan:Connect(function(input)
		if self:IsLocked() then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			fineX, fineV = nil, nil
			self._dragStart = Util.DeepCopy(self.Value)
			if self.Range then
				local v = valueAt(input.Position.X)
				which = math.abs(v - self.Value.Min) <= math.abs(v - self.Value.Max) and "A" or "B"
			end
			Tween.Play(self._knobA, { Size = UDim2.fromOffset(14, 14) }, 0.12)
			if self._knobB then
				Tween.Play(self._knobB, { Size = UDim2.fromOffset(14, 14) }, 0.12)
			end
			apply(input.Position.X)
		end
	end)
	self.Maid:Connect(UIS.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			apply(input.Position.X)
		end
	end)
	self.Maid:Connect(UIS.InputEnded, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			Tween.Play(self._knobA, { Size = UDim2.fromOffset(10, 10) }, 0.15)
			if self._knobB then
				Tween.Play(self._knobB, { Size = UDim2.fromOffset(10, 10) }, 0.15)
			end
			if not Util.Equal(self._dragStart, self.Value) then
				self.Library:_pushHistory(self, self._dragStart, Util.DeepCopy(self.Value))
			end
		end
	end)

	-- arrow keys while hovered
	local hovered = false
	row.MouseEnter:Connect(function()
		hovered = true
	end)
	row.MouseLeave:Connect(function()
		hovered = false
	end)
	self.Maid:Connect(UIS.InputBegan, function(input, processed)
		if not hovered or processed or self.Range or self:IsLocked() then
			return
		end
		local mult = (UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift)) and 10 or 1
		if input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.Up then
			self:_userSet(self.Value + self.Step * mult)
		elseif input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.Down then
			self:_userSet(self.Value - self.Step * mult)
		end
	end)

	-- exact input on double click
	local lastClick = 0
	value.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 or self.Range or self.Labels or self:IsLocked() then
			return
		end
		local now = os.clock()
		if now - lastClick < 0.35 then
			value.TextEditable = true
			value.Text = Util.FormatNumber(self.Value, Util.Decimals(self.Step))
			value:CaptureFocus()
		end
		lastClick = now
	end)
	value.FocusLost:Connect(function()
		if value.TextEditable then
			value.TextEditable = false
			local n = tonumber((string.gsub(value.Text, "[^%d%.%-]", "")))
			if n then
				self:_userSet(n)
			end
			self:_render(false)
		end
	end)

	-- preset chips
	if self.Presets then
		row.Size = UDim2.new(1, 0, 0, row.Size.Y.Offset + 24)
		trackHolder.Position = UDim2.new(0, 8, 1, -44)
		local chips = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -16, 0, 20), Position = UDim2.new(0, 8, 1, -22), Parent = row })
		Util.List(chips, 4, Enum.FillDirection.Horizontal)
		local names = Util.Keys(self.Presets)
		table.sort(names, function(a, b)
			local va, vb = self.Presets[a], self.Presets[b]
			if type(va) == "number" and type(vb) == "number" then
				return va < vb
			end
			return tostring(a) < tostring(b)
		end)
		for _, name in names do
			local chip = Util.New("TextButton", { Text = tostring(name), FontFace = Theme.Fonts.Medium, TextSize = 11, AutoButtonColor = false, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 18), Parent = chips })
			Util.Padding(chip, 0, 8, 0, 8)
			Util.Corner(4, chip)
			Theme.Paint(chip, { BackgroundColor3 = "Surface3", TextColor3 = "TextDim" })
			chip.Activated:Connect(function()
				if not self:IsLocked() then
					self:_userSet(self.Presets[name])
				end
			end)
		end
	end
end

function Slider:_render(animate)
	if not self._fill then
		return
	end
	local t = animate and 0.08 or 0
	local span = math.max(self.Max - self.Min, 1e-9)
	if self.Range then
		local a = (self.Value.Min - self.Min) / span
		local b = (self.Value.Max - self.Min) / span
		Tween.Play(self._fill, { Position = UDim2.fromScale(a, 0), Size = UDim2.fromScale(b - a, 1) }, t)
		Tween.Play(self._knobA, { Position = UDim2.fromScale(a, 0.5) }, t)
		Tween.Play(self._knobB, { Position = UDim2.fromScale(b, 0.5) }, t)
	else
		local p = (self.Value - self.Min) / span
		self._fill.Visible = p > 0.015
		Tween.Play(self._fill, { Size = UDim2.fromScale(p, 1) }, t)
		Tween.Play(self._knobA, { Position = UDim2.fromScale(p, 0.5) }, t)
		-- inside the danger zone the fill and the knob turn red
		if self._dangerFrom then
			local danger = self.Value >= self._dangerFrom and self.Value <= (self._dangerTo or self.Max)
			if danger ~= self._inDanger then
				self._inDanger = danger
				Theme.Paint(self._fill, { BackgroundColor3 = danger and "Risky" or "Accent" }, 0.15)
				Theme.Paint(self._knobA, { BackgroundColor3 = danger and "Risky" or "Accent" }, 0.15)
			end
		end
	end
	if not self._valueBox.TextEditable then
		self._valueBox.Text = self:_format(self.Value)
	end
end

function Slider:_onState(locked)
	if self._fill then
		Theme.Paint(self._fill, { BackgroundColor3 = locked and "TextMute" or "Accent" }, 0.15)
		Theme.Paint(self._knobA, { BackgroundColor3 = locked and "TextMute" or "Accent" }, 0.15)
		if self._knobB then
			Theme.Paint(self._knobB, { BackgroundColor3 = locked and "TextMute" or "Accent" }, 0.15)
		end
	end
end

return { Slider = Slider }
