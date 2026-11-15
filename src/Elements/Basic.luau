--!nocheck
--[[
	Proximity · Elements/Basic
	Toggle, Button, ButtonGroup, Label, Paragraph, Divider, Spacer, Navigate.
]]

local Util = require("../Core/Util")
local Tween = require("../Core/Tween")
local Theme = require("../Theme")
local Icons = require("../Icons")
local Locale = require("../Locale")
local Shared = require("../Shared")
local Base = require("./Base")

local classes = {}

-- ═══ Toggle ═══════════════════════════════════════════════════════════════
--[[
	Section:Toggle({
		Name, Default = false, Flag, Callback(bool), Icon,
		Style = nil (menu-wide style) | "Switch" | "Compact" | "Checkbox" | "Chip"
		        | "Radio" | "Square" | "Pill" | "Dot" | "Orbit",
		Risky = false, Confirm = false (ask before turning on),
		Description, Tooltip, Badge, Locked,
	})
	Methods: :Toggle() :On() :Off() :IsOn() :SetStyle(name)
	Library:SetToggleStyle(name) changes every toggle that has no own Style.
]]
local Toggle = Base.extend("Toggle")
classes.Toggle = Toggle

Toggle.Styles = { "Switch", "Compact", "Checkbox", "Chip", "Radio", "Square", "Pill", "Dot", "Orbit" }

function Toggle.new(section, options)
	local self = Base.new(Toggle, section, options)
	self.Default = Util.Opt(options, "Default", "Value", "State") == true
	self.Value = self.Default
	self.Style = options.Style
	self.ConfirmText = options.Confirm
	return self:_register()
end

function Toggle:_normalize(v)
	if v == nil then
		return false
	end
	return v == true or v == 1 or v == "true"
end

function Toggle:Toggle()
	return self:Set(not self.Value)
end
function Toggle:On()
	return self:Set(true)
end
function Toggle:Off()
	return self:Set(false)
end
function Toggle:IsOn(): boolean
	return self.Value
end

function Toggle:_request(value: boolean)
	if value and (self.ConfirmText or self.Risky) and not self._confirmed and self.Window then
		task.spawn(function()
			local text = type(self.ConfirmText) == "string" and self.ConfirmText or Locale.T("RiskyConfirm")
			if self.Window:Confirm({ Title = self.Name, Content = text, Danger = true }) then
				self._confirmed = true
				self:_userSet(true)
			end
		end)
		return
	end
	self:_userSet(value)
end

function Toggle:_navActivate()
	self:_request(not self.Value)
end
function Toggle:_navAdjust(dir)
	self:_request(dir > 0)
end

function Toggle:GetStyle(): string
	return self.Style or Shared.Lib.ToggleStyle or "Switch"
end

-- Every style is a pair: build the control into `holder`, paint it for a state.
local styles = {}

local function track(holder, w, h, radius)
	local f = Util.New("Frame", { Name = "Control", Size = UDim2.fromOffset(w, h), LayoutOrder = 100, Parent = holder })
	if radius then
		Util.Corner(radius, f)
	else
		Util.Round(f)
	end
	local stroke = Util.Stroke(f)
	return f, stroke
end

local function knob(parent, size, radius)
	local k = Util.New("Frame", { Name = "Knob", Size = UDim2.fromOffset(size, size), AnchorPoint = Vector2.new(0, 0.5), Parent = parent })
	if radius then
		Util.Corner(radius, k)
	else
		Util.Round(k)
	end
	return k
end

styles.Switch = {
	build = function(self, holder)
		local f, stroke = track(holder, 32, 18)
		return { Frame = f, Stroke = stroke, Knob = knob(f, 12) }
	end,
	paint = function(r, on, t)
		Theme.Paint(r.Frame, { BackgroundColor3 = on and "Accent" or "Surface3" }, t)
		Theme.Paint(r.Stroke, { Color = on and "Accent" or "StrokeHi" }, t)
		Tween.Play(r.Stroke, { Thickness = on and 2.5 or 1, Transparency = on and 0.75 or 0 }, t)
		Theme.Paint(r.Knob, { BackgroundColor3 = on and "AccentInk" or "TextDim" }, t)
		Tween.Play(r.Knob, { Position = on and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }, t * 1.3, Enum.EasingStyle.Back)
	end,
}

styles.Square = {
	build = function(self, holder)
		local f, stroke = track(holder, 32, 18, 4)
		return { Frame = f, Stroke = stroke, Knob = knob(f, 12, 3) }
	end,
	paint = styles.Switch.paint,
}

styles.Compact = {
	build = function(self, holder)
		local f, stroke = track(holder, 16, 16)
		local dot = Util.New("Frame", { Size = UDim2.fromOffset(0, 0), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Parent = f })
		Util.Round(dot)
		f.BackgroundTransparency = 1
		return { Frame = f, Stroke = stroke, Dot = dot }
	end,
	paint = function(r, on, t)
		Theme.Paint(r.Stroke, { Color = on and "Accent" or "StrokeHi" }, t)
		Theme.Paint(r.Dot, { BackgroundColor3 = "Accent" })
		Tween.Play(r.Dot, { Size = on and UDim2.fromOffset(10, 10) or UDim2.fromOffset(0, 0) }, t * 1.4, Enum.EasingStyle.Back)
	end,
}

styles.Radio = {
	build = function(self, holder)
		local f, stroke = track(holder, 18, 18)
		local dot = Util.New("Frame", { Size = UDim2.fromOffset(8, 8), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Parent = f })
		Util.Round(dot)
		return { Frame = f, Stroke = stroke, Dot = dot }
	end,
	paint = function(r, on, t)
		Theme.Paint(r.Frame, { BackgroundColor3 = on and "Accent" or "Surface3" }, t)
		Theme.Paint(r.Stroke, { Color = on and "Accent" or "StrokeHi" }, t)
		Theme.Paint(r.Dot, { BackgroundColor3 = "AccentInk" })
		Tween.Play(r.Dot, { Size = on and UDim2.fromOffset(7, 7) or UDim2.fromOffset(0, 0) }, t, Enum.EasingStyle.Back)
	end,
}

styles.Checkbox = {
	build = function(self, holder)
		local f, stroke = track(holder, 18, 18, 5)
		local check = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get("check") or "", Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Parent = f })
		return { Frame = f, Stroke = stroke, Check = check }
	end,
	paint = function(r, on, t, animate)
		Theme.Paint(r.Frame, { BackgroundColor3 = on and "Accent" or "Surface3" }, t)
		Theme.Paint(r.Stroke, { Color = on and "Accent" or "StrokeHi" }, t)
		Theme.Paint(r.Check, { ImageColor3 = "AccentInk" })
		r.Check.ImageTransparency = on and 0 or 1
		r.Check.Size = UDim2.fromOffset(on and 12 or 4, on and 12 or 4)
		if animate and on then
			r.Check.Size = UDim2.fromOffset(4, 4)
			Tween.Play(r.Check, { Size = UDim2.fromOffset(12, 12) }, 0.22, Enum.EasingStyle.Back)
		end
	end,
}

styles.Chip = {
	build = function(self, holder)
		local f, stroke = track(holder, 40, 20, 5)
		local label = Util.Label({ Text = "OFF", FontFace = Theme.Fonts.Bold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = f })
		return { Frame = f, Stroke = stroke, Label = label }
	end,
	paint = function(r, on, t)
		Theme.Paint(r.Frame, { BackgroundColor3 = on and "Accent" or "Surface3" }, t)
		Theme.Paint(r.Stroke, { Color = on and "Accent" or "StrokeHi" }, t)
		Theme.Paint(r.Label, { TextColor3 = on and "AccentInk" or "TextMute" }, t)
		r.Label.Text = on and "ON" or "OFF"
	end,
}

styles.Pill = {
	build = function(self, holder)
		local f, stroke = track(holder, 52, 20)
		local k = Util.New("Frame", { Size = UDim2.fromOffset(24, 14), AnchorPoint = Vector2.new(0, 0.5), Parent = f })
		Util.Round(k)
		local label = Util.Label({ Text = "", FontFace = Theme.Fonts.Bold, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), Parent = k })
		return { Frame = f, Stroke = stroke, Knob = k, Label = label }
	end,
	paint = function(r, on, t)
		Theme.Paint(r.Frame, { BackgroundColor3 = "Surface3" }, t)
		Theme.Paint(r.Stroke, { Color = on and "Accent" or "StrokeHi" }, t)
		Theme.Paint(r.Knob, { BackgroundColor3 = on and "Accent" or "Surface2" }, t)
		Theme.Paint(r.Label, { TextColor3 = on and "AccentInk" or "TextMute" }, t)
		r.Label.Text = on and "ON" or "OFF"
		Tween.Play(r.Knob, { Position = on and UDim2.new(1, -27, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }, t * 1.3, Enum.EasingStyle.Quint)
	end,
}

styles.Dot = {
	build = function(self, holder)
		local f = Util.New("Frame", { Name = "Control", BackgroundTransparency = 1, Size = UDim2.fromOffset(18, 18), LayoutOrder = 100, Parent = holder })
		local dot = Util.New("Frame", { Size = UDim2.fromOffset(8, 8), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Parent = f })
		Util.Round(dot)
		local halo = Util.Stroke(dot, nil, 4, 1)
		return { Frame = f, Dot = dot, Halo = halo }
	end,
	paint = function(r, on, t)
		Theme.Paint(r.Dot, { BackgroundColor3 = on and "Accent" or "StrokeHi" }, t)
		Theme.Paint(r.Halo, { Color = "Accent" })
		Tween.Play(r.Halo, { Transparency = on and 0.75 or 1 }, t)
	end,
}

styles.Orbit = {
	build = function(self, holder)
		local f = Util.New("Frame", { Name = "Control", BackgroundTransparency = 1, Size = UDim2.fromOffset(34, 20), LayoutOrder = 100, Parent = holder })
		local ring = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(34, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Rotation = -12, Parent = f })
		Util.Round(ring)
		local stroke = Util.Stroke(ring)
		local planet = Util.New("Frame", { Size = UDim2.fromOffset(10, 10), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Parent = f })
		Util.Round(planet)
		local moon = Util.New("Frame", { Size = UDim2.fromOffset(6, 6), AnchorPoint = Vector2.new(0.5, 0.5), Parent = f })
		Util.Round(moon)
		return { Frame = f, Stroke = stroke, Planet = planet, Moon = moon }
	end,
	paint = function(r, on, t)
		Theme.Paint(r.Stroke, { Color = on and "Accent" or "StrokeHi" }, t)
		Theme.Paint(r.Planet, { BackgroundColor3 = on and "Accent" or "Surface3" }, t)
		Theme.Paint(r.Moon, { BackgroundColor3 = on and "Accent" or "TextMute" }, t)
		Tween.Play(r.Moon, { Position = on and UDim2.new(1, -2, 0.32, 0) or UDim2.new(0, 2, 0.68, 0) }, t * 1.6, Enum.EasingStyle.Sine)
	end,
}

Toggle._styleImpl = styles

function Toggle:_buildControl()
	if self._control and self._control.Frame then
		self._control.Frame:Destroy()
	end
	local style = styles[self:GetStyle()] or styles.Switch
	self._styleImpl = style
	self._control = style.build(self, self._right)
end

function Toggle:_build(parent)
	local row = self:_row(parent)
	self:_buildControl()
	local hit = Util.Hitbox(row, 0)
	hit.Activated:Connect(function()
		if not self:IsLocked() then
			self:_request(not self.Value)
		end
	end)
	self._hit = hit
end

function Toggle:_render(animate)
	local t = animate and 0.18 or 0
	local on = self.Value
	self._titleToken = on and "Text" or "TextDim"
	if self._title and not self.Risky and not self:IsLocked() then
		Theme.Paint(self._title, { TextColor3 = self._titleToken }, t)
	end
	if self._icon then
		Theme.Paint(self._icon, { ImageColor3 = on and "Accent" or "TextMute" }, t)
	end
	if self._control and self._styleImpl then
		self._styleImpl.paint(self._control, on, t, animate)
	end
end

function Toggle:SetStyle(style: string?)
	self.Style = style
	if self._mounted then
		self:_buildControl()
		self:_render(false)
	end
	return self
end

-- ═══ Button ═══════════════════════════════════════════════════════════════
--[[
	Section:Button({
		Name, Callback, Icon, Hint (right text),
		Style = "Secondary" | "Primary" | "Ghost" | "Danger",
		Confirm = false | "text"   (asks first)
		DoubleClick = false        (first click arms, second runs)
		Cooldown = 0               (seconds)
	})
	Methods: :Press() :SetStyle() :SetIcon() :SetHint() :SetCooldown()
]]
local Button = Base.extend("Button")
classes.Button = Button

function Button.new(section, options)
	local self = Base.new(Button, section, options)
	self.Style = options.Style or "Secondary"
	self.Icon = options.Icon
	self.Hint = options.Hint
	self.ConfirmText = options.Confirm
	self.DoubleClick = options.DoubleClick
	self.Cooldown = options.Cooldown or 0
	self._last = 0
	return self:_register()
end

function Button:_callbackArgs()
	return nil
end

function Button:_navActivate()
	self:_activate()
end

function Button:Press()
	if self:IsLocked() then
		return self
	end
	local now = os.clock()
	if now - self._last < self.Cooldown then
		return self
	end
	self._last = now
	self:_fireCallbacks()
	return self
end
Button.Click = Button.Press

function Button:_activate()
	if self:IsLocked() then
		return
	end
	if self.DoubleClick and not self._armed then
		self._armed = true
		self._label.Text = Locale.T("Confirm") .. "?"
		task.delay(2, function()
			self._armed = false
			if self._label then
				self._label.Text = self.Name
			end
		end)
		return
	end
	self._armed = false
	if self._label then
		self._label.Text = self.Name
	end
	if self.ConfirmText and self.Window then
		task.spawn(function()
			if self.Window:Confirm({ Title = self.Name, Content = type(self.ConfirmText) == "string" and self.ConfirmText or nil, Danger = self.Style == "Danger" }) then
				self:Press()
			end
		end)
		return
	end
	self:Press()
end

local buttonStyles = {
	Primary = { Bg = "Accent", Text = "AccentInk", Stroke = "Accent", BgT = 0 },
	Secondary = { Bg = "Surface3", Text = "Text", Stroke = "Stroke", BgT = 0 },
	Ghost = { Bg = "Surface3", Text = "TextDim", Stroke = "Stroke", BgT = 1 },
	Danger = { Bg = "Surface3", Text = "Risky", Stroke = "Risky", BgT = 0 },
}

function Button:_build(parent)
	local row = Util.New("Frame", { Name = "Button_" .. self.Name, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), Parent = parent })
	self.Frame = row
	local button = Util.New("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.fromOffset(0, 2),
		ClipsDescendants = true,
		Parent = row,
	})
	Util.Corner(6, button)
	local stroke = Util.Stroke(button)
	local label = Util.Label({
		Text = self.Name,
		FontFace = Theme.Fonts.SemiBold,
		TextSize = Theme.Size.Body,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		Parent = button,
	})
	local icon = Util.New("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(15, 15),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 10, 0.5, 0),
		Parent = button,
	})
	local hint = Util.Label({
		FontFace = Theme.Fonts.Mono,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(1, -10, 1, 0),
		Parent = button,
	})
	local scaleObj = Util.New("UIScale", { Parent = button })
	self._button, self._stroke, self._label, self._icon, self._hintLabel, self._title = button, stroke, label, icon, hint, label
	self._right = Util.New("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 0),
		Parent = button,
	})
	Util.List(self._right, 6, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
	self._lock = Util.New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 20, Visible = false, Parent = row })

	button.MouseEnter:Connect(function()
		Tween.Play(stroke, { Transparency = 0 }, 0.1)
		Theme.Paint(stroke, { Color = self.Style == "Danger" and "Risky" or "StrokeHi" }, 0.1)
	end)
	button.MouseLeave:Connect(function()
		Theme.Paint(stroke, { Color = buttonStyles[self.Style].Stroke }, 0.15)
		Tween.Play(scaleObj, { Scale = 1 }, 0.15)
	end)
	button.MouseButton1Down:Connect(function()
		Tween.Play(scaleObj, { Scale = 0.97 }, 0.08)
	end)
	button.MouseButton1Up:Connect(function()
		Tween.Play(scaleObj, { Scale = 1 }, 0.2, Enum.EasingStyle.Back)
	end)
	button.Activated:Connect(function(input)
		self:_ripple(input)
		self:_activate()
	end)
end

function Button:_ripple(input)
	local button = self._button
	if not button or Tween.Speed == 0 then
		return
	end
	local pos = input and input.Position and Vector2.new(input.Position.X, input.Position.Y) or (button.AbsolutePosition + button.AbsoluteSize / 2)
	local rel = pos - button.AbsolutePosition
	local s = Shared.Scale or 1
	local circle = Util.New("Frame", {
		BackgroundTransparency = 0.82,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(rel.X / s, rel.Y / s),
		Size = UDim2.fromOffset(0, 0),
		ZIndex = 3,
		Parent = button,
	})
	Theme.Paint(circle, { BackgroundColor3 = self.Style == "Primary" and "AccentInk" or "Accent" })
	Util.Round(circle)
	local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2 / s
	Tween.Play(circle, { Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1 }, 0.5)
	task.delay(0.5, function()
		circle:Destroy()
	end)
end

function Button:_render()
	local style = buttonStyles[self.Style] or buttonStyles.Secondary
	Theme.Paint(self._button, { BackgroundColor3 = style.Bg })
	self._button.BackgroundTransparency = style.BgT
	Theme.Paint(self._stroke, { Color = style.Stroke })
	Theme.Paint(self._label, { TextColor3 = style.Text })
	Theme.Paint(self._hintLabel, { TextColor3 = self.Style == "Primary" and "AccentInk" or "TextMute" })
	local icon = Icons.Get(self.Icon)
	self._icon.Image = icon or ""
	self._icon.Visible = icon ~= nil
	Theme.Paint(self._icon, { ImageColor3 = style.Text })
	self._hintLabel.Text = self.Hint or ""
	self._label.Text = self.Name
end

function Button:_onState(locked)
	if self._button then
		self._button.BackgroundTransparency = locked and 0.6 or (buttonStyles[self.Style] or buttonStyles.Secondary).BgT
		Theme.Paint(self._label, { TextColor3 = locked and "TextMute" or (buttonStyles[self.Style] or buttonStyles.Secondary).Text })
	end
end

function Button:SetStyle(style: string)
	self.Style = buttonStyles[style] and style or "Secondary"
	if self._mounted then
		self:_render()
	end
	return self
end
function Button:SetIcon(icon)
	self.Icon = icon
	if self._mounted then
		self:_render()
	end
	return self
end
function Button:SetHint(text)
	self.Hint = text
	if self._mounted then
		self:_render()
	end
	return self
end
function Button:SetCooldown(seconds: number)
	self.Cooldown = seconds
	return self
end
function Button:_applyState()
	if not self._mounted then
		return
	end
	self.Frame.Visible = self.Visible and self._depsOk ~= false
	self._lock.Visible = self:IsLocked()
	self:_onState(self:IsLocked())
end
function Button:_contextItems()
	return {}
end

-- ═══ ButtonGroup ══════════════════════════════════════════════════════════
-- Section:ButtonGroup({ { Name = "A", Callback = fn }, { Name = "B", Style = "Primary", Callback = fn } })
local ButtonGroup = Base.extend("ButtonGroup")
classes.ButtonGroup = ButtonGroup

function ButtonGroup.new(section, options)
	local buttons = options.Buttons or options
	local self = Base.new(ButtonGroup, section, { Name = options.Name or "Buttons" })
	self.ButtonsSpec = {}
	for _, spec in buttons do
		if type(spec) == "table" then
			table.insert(self.ButtonsSpec, spec)
		end
	end
	return self:_register()
end

function ButtonGroup:_build(parent)
	local row = Util.New("Frame", { Name = "ButtonGroup", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), Parent = parent })
	self.Frame = row
	local n = #self.ButtonsSpec
	for i, spec in self.ButtonsSpec do
		local style = buttonStyles[spec.Style or "Secondary"] or buttonStyles.Secondary
		local b = Util.New("TextButton", {
			Text = spec.Name or spec[1] or "",
			FontFace = Theme.Fonts.SemiBold,
			TextSize = Theme.Size.Body,
			AutoButtonColor = false,
			Size = UDim2.new(1 / n, -(6 * (n - 1)) / n, 0, 30),
			Position = UDim2.new((i - 1) / n, (i - 1) * 6 / n, 0, 2),
			Parent = row,
		})
		Util.Corner(6, b)
		Theme.Paint(b, { BackgroundColor3 = style.Bg, TextColor3 = style.Text })
		local stroke = Util.Stroke(b)
		Theme.Paint(stroke, { Color = style.Stroke })
		b.MouseEnter:Connect(function()
			Theme.Paint(stroke, { Color = "StrokeHi" }, 0.1)
		end)
		b.MouseLeave:Connect(function()
			Theme.Paint(stroke, { Color = style.Stroke }, 0.1)
		end)
		b.Activated:Connect(function()
			if not self:IsLocked() then
				Util.SafeCall(spec.Callback or spec[2])
			end
		end)
	end
end
function ButtonGroup:_contextItems()
	return {}
end

-- ═══ Label ════════════════════════════════════════════════════════════════
-- Section:Label("text")  or  Section:Label({ Text, Color = token|Color3, Icon, Center })
-- Labels can host links: label:ColorPicker{...}, label:Keybind{...}
local Label = Base.extend("Label")
classes.Label = Label

function Label.new(section, options)
	if type(options) ~= "table" then
		options = { Text = tostring(options) }
	end
	local self = Base.new(Label, section, options)
	self.Color = options.Color
	self.Icon = options.Icon
	self.Center = options.Center
	self.Rich = options.RichText
	return self:_register()
end

function Label:_build(parent)
	local row = self:_row(parent, 26)
	self._title.FontFace = Theme.Fonts.Regular
	self._title.RichText = self.Rich == true
	if self.Center then
		self._title.TextXAlignment = Enum.TextXAlignment.Center
		self._textBox.Size = UDim2.new(1, -16, 1, 0)
	end
	self._titleToken = type(self.Color) == "string" and self.Color or "TextDim"
	if typeof(self.Color) == "Color3" then
		Theme.Paint(self._title, { TextColor3 = self.Color })
	end
	return row
end

function Label:SetColor(color)
	self.Color = color
	self._titleToken = type(color) == "string" and color or "TextDim"
	if self._title then
		Theme.Paint(self._title, { TextColor3 = color })
	end
	return self
end
function Label:_contextItems()
	return {}
end

-- ═══ Paragraph ════════════════════════════════════════════════════════════
-- Section:Paragraph({ Title, Content, RichText })
local Paragraph = Base.extend("Paragraph")
classes.Paragraph = Paragraph

function Paragraph.new(section, options)
	if type(options) ~= "table" then
		options = { Content = tostring(options) }
	end
	local self = Base.new(Paragraph, section, { Name = options.Title or options.Name or "", Visible = options.Visible })
	self.Content = Util.Opt(options, "Content", "Text", "Body") or ""
	self.Rich = options.RichText ~= false
	return self:_register()
end

function Paragraph:_build(parent)
	local row = Util.New("Frame", { Name = "Paragraph", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), Parent = parent })
	self.Frame = row
	Util.Padding(row, 4, 8, 6, 8)
	Util.List(row, 3)
	local title = Util.Label({ Text = self.Name, FontFace = Theme.Fonts.SemiBold, TextSize = Theme.Size.Body, AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, LayoutOrder = 1, Visible = self.Name ~= "", Parent = row })
	Theme.Paint(title, { TextColor3 = "Text" })
	local body = Util.Label({ Text = self.Content, FontFace = Theme.Fonts.Regular, TextSize = 12, RichText = self.Rich, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), LineHeight = 1.1, LayoutOrder = 2, Parent = row })
	Theme.Paint(body, { TextColor3 = "TextDim" })
	self._title, self._body = title, body
end

function Paragraph:SetContent(text: string)
	self.Content = text
	if self._body then
		self._body.Text = text
	end
	return self
end
Paragraph.Set = Paragraph.SetContent
function Paragraph:Get()
	return self.Content
end
function Paragraph:SetTitle(text: string)
	self.Name = text
	if self._title then
		self._title.Text = text
		self._title.Visible = text ~= ""
	end
	return self
end
function Paragraph:_applyState()
	if self.Frame then
		self.Frame.Visible = self.Visible and self._depsOk ~= false
	end
end

-- ═══ Divider ══════════════════════════════════════════════════════════════
-- Section:Divider()  /  Section:Divider("Advanced")
local Divider = Base.extend("Divider")
classes.Divider = Divider

function Divider.new(section, options)
	if type(options) ~= "table" then
		options = { Text = options }
	end
	local self = Base.new(Divider, section, { Name = options.Text or options.Name or "" })
	return self:_register()
end

function Divider:_build(parent)
	local row = Util.New("Frame", { Name = "Divider", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, self.Name ~= "" and 24 or 11), Parent = parent })
	self.Frame = row
	local line = Util.New("Frame", { BorderSizePixel = 0, Size = UDim2.new(1, -16, 0, 1), Position = UDim2.new(0, 8, 0.5, 0), Parent = row })
	Theme.Paint(line, { BackgroundColor3 = "Stroke" })
	if self.Name ~= "" then
		local label = Util.Label({ Text = string.upper(self.Name), FontFace = Theme.Fonts.Bold, TextSize = 10, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 14), Position = UDim2.new(0, 8, 0.5, -7), Parent = row })
		Theme.Paint(label, { TextColor3 = "TextMute" })
		Util.Padding(label, 0, 6, 0, 0)
		local cover = Util.New("Frame", { BorderSizePixel = 0, Size = UDim2.new(0, 0, 0, 14), AutomaticSize = Enum.AutomaticSize.X, Position = label.Position, ZIndex = 0, Parent = row })
		cover.BackgroundTransparency = 1
		line.Position = UDim2.new(0, 0, 0.5, 0)
		label:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			local w = label.AbsoluteSize.X / (Shared.Scale or 1) + 14
			line.Position = UDim2.new(0, w, 0.5, 0)
			line.Size = UDim2.new(1, -w - 8, 0, 1)
		end)
	end
end
function Divider:_applyState()
	if self.Frame then
		self.Frame.Visible = self.Visible and self._depsOk ~= false
	end
end
classes.Separator = Divider

-- ═══ Spacer ═══════════════════════════════════════════════════════════════
local Spacer = Base.extend("Spacer")
classes.Spacer = Spacer
function Spacer.new(section, options)
	local self = Base.new(Spacer, section, { Name = "Spacer" })
	self.Height = type(options) == "number" and options or (type(options) == "table" and options.Height) or 8
	return self:_register()
end
function Spacer:_build(parent)
	self.Frame = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, self.Height), Parent = parent })
end
function Spacer:_applyState() end

-- ═══ Navigate (row with ► that opens a sub page) ════════════════════════
--[[
	local weaponPage = Tab:SubPage({ Name = "Weapon setup", Hidden = true })
	Section:Navigate({ Name = "Weapon setup", Page = weaponPage, Icon = "crosshair" })
	or Section:Navigate({ Name = "...", Callback = fn })
]]
local Navigate = Base.extend("Navigate")
classes.Navigate = Navigate

function Navigate.new(section, options)
	local self = Base.new(Navigate, section, options)
	self.Target = options.Page or options.Target
	self.Icon = options.Icon
	self.Value2 = options.Value
	return self:_register()
end

function Navigate:_callbackArgs()
	return nil
end

function Navigate:_navActivate()
	if self.Target and self.Target.Select then
		self.Target:Select()
	end
	self:_fireCallbacks()
end

function Navigate:_build(parent)
	local row = self:_row(parent)
	local value = Util.Label({ Text = self.Value2 or "", FontFace = Theme.Fonts.Regular, TextSize = 12, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 16), LayoutOrder = 99, Parent = self._right })
	Theme.Paint(value, { TextColor3 = "TextMute" })
	self._valueLabel = value
	local arrow = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get("chevron-right") or "", Size = UDim2.fromOffset(15, 15), LayoutOrder = 100, Parent = self._right })
	Theme.Paint(arrow, { ImageColor3 = "TextDim" })
	local hit = Util.Hitbox(row, 0)
	hit.Activated:Connect(function()
		if self:IsLocked() then
			return
		end
		if self.Target and self.Target.Select then
			self.Target:Select()
		end
		self:_fireCallbacks()
	end)
end

function Navigate:SetValue(text)
	self.Value2 = text
	if self._valueLabel then
		self._valueLabel.Text = text or ""
	end
	return self
end
function Navigate:_contextItems()
	return {}
end

return classes
