--!nocheck
--[[
	Proximity · Elements/Pickers
	Keybind and ColorPicker. Both work as a standalone row or as a compact
	link on another element's row (toggle:Keybind{}, label:ColorPicker{}).

	Keybind({
		Name, Default = Enum.KeyCode.E | "E" | "MB2", Mode = "Toggle",
		Modes = { "Toggle", "Hold", "Always", "Release" } (allowed list),
		Flag, Callback(keyName), OnPress(), OnRelease(), OnToggle(active),
		ShowInList = true, Blacklist = { "W", "A", ... }
	})
	Methods: :SetKey :GetKey :SetMode :GetMode :IsActive :Listen :Clear :Press
	Signals: .StateChanged(active)

	ColorPicker({
		Name, Default = Color3, Alpha = nil | 0..1 (transparency; enables the bar),
		Flag, Callback(color, alpha), Presets = { Color3 ... }
	})
	Methods: :SetColor :GetColor :SetAlpha :GetAlpha :GetHex :SetHex :Open :Close :SetRainbow
]]

local Util = require("../Core/Util")
local Signal = require("../Core/Signal")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")
local Keys = require("../Core/Keys")
local Theme = require("../Theme")
local Icons = require("../Icons")
local Locale = require("../Locale")
local Shared = require("../Shared")
local Base = require("./Base")

local UIS = Env.Service("UserInputService")
local RunService = Env.Service("RunService")

local classes = {}

-- ═══ Keybind ══════════════════════════════════════════════════════════════
local Keybind = Base.extend("Keybind")
classes.Keybind = Keybind

local registry = {} -- every keybind, for the global dispatcher
local listening = nil -- keybind currently waiting for a key
local dispatcherReady = false

local function startDispatcher()
	if dispatcherReady then
		return
	end
	dispatcherReady = true
	Shared.Maid:Connect(UIS.InputBegan, function(input, processed)
		local name = Keys.FromInput(input)
		if listening then
			local kb = listening
			if input.KeyCode == Enum.KeyCode.Escape then
				kb:_stopListening()
			elseif input.KeyCode == Enum.KeyCode.Backspace then
				kb:_stopListening()
				kb:_userSet("None")
			elseif name and not (kb.Blacklist and table.find(kb.Blacklist, name)) then
				-- the click that started listening must not bind MB1 right away
				if name == "MB1" and os.clock() - kb._listenAt < 0.2 then
					return
				end
				kb:_stopListening()
				kb:_userSet(name)
			end
			return
		end
		if not name or UIS:GetFocusedTextBox() then
			return
		end
		if processed and string.sub(name, 1, 2) == "MB" then
			return -- clicks on GUI never trigger mouse binds
		end
		for _, kb in table.clone(registry) do
			if kb.Value == name and not kb:IsLocked() then
				kb:_down()
			end
		end
	end)
	Shared.Maid:Connect(UIS.InputEnded, function(input)
		local name = Keys.FromInput(input)
		if not name then
			return
		end
		for _, kb in table.clone(registry) do
			if kb.Value == name then
				kb:_up()
			end
		end
	end)
end

function Keybind.new(section, options)
	local self = Base.new(Keybind, section, options)
	self.Default = Keys.Normalize(Util.Opt(options, "Default", "Value", "Key"))
	self.Value = self.Default
	self.Mode = options.Mode or (self.Parent and self.Parent.Type == "Toggle" and "Toggle") or "Press"
	self.Modes = options.Modes or { "Toggle", "Hold", "Always", "Release" }
	self.Blacklist = options.Blacklist
	self.ShowInList = options.ShowInList ~= false
	self.OnPress = options.OnPress
	self.OnRelease = options.OnRelease
	self.OnToggle = options.OnToggle
	self.Active = self.Mode == "Always"
	self.StateChanged = Signal.new()
	if self.Parent and self.Name == "Keybind" then
		self.Name = self.Parent.Name
	end
	table.insert(registry, self)
	startDispatcher()
	return self:_register()
end

function Keybind:_normalize(v)
	return Keys.Normalize(v)
end

function Keybind:GetKey(): string
	return self.Value
end
function Keybind:GetKeyCode()
	return Keys.ToEnum(self.Value)
end
function Keybind:SetKey(key)
	return self:Set(key)
end
function Keybind:Clear()
	return self:Set("None")
end
function Keybind:GetMode(): string
	return self.Mode
end
function Keybind:IsActive(): boolean
	return self.Active
end

function Keybind:SetMode(mode: string)
	if not table.find({ "Toggle", "Hold", "Always", "Release", "Press" }, mode) then
		return self
	end
	self.Mode = mode
	if mode == "Always" then
		self:_setActive(true)
	elseif mode ~= "Toggle" then
		self:_setActive(false)
	end
	if self.Flag then
		self.Library:_onElementChanged(self, self.Value, self.Value)
	end
	self.Library.KeybindsChanged:Fire()
	return self
end

function Keybind:_setActive(state: boolean)
	if self.Active == state then
		return
	end
	self.Active = state
	self.StateChanged:Fire(state)
	self.Library.KeybindsChanged:Fire()
	if self.OnToggle then
		Util.SafeCall(self.OnToggle, state)
	end
	local parent = self.Parent
	if parent and parent.Type == "Toggle" and parent.Value ~= state then
		parent:Set(state)
	end
end

function Keybind:_down()
	local mode = self.Mode
	if self.OnPress then
		Util.SafeCall(self.OnPress)
	end
	local parent = self.Parent
	if parent and parent.Type == "Button" then
		parent:Press()
	end
	if mode == "Toggle" then
		local current = parent and parent.Type == "Toggle" and parent.Value or self.Active
		self:_setActive(not current)
	elseif mode == "Hold" then
		self:_setActive(true)
	elseif mode == "Press" and not parent then
		self.StateChanged:Fire(true)
	end
end

function Keybind:_up()
	if self.OnRelease then
		Util.SafeCall(self.OnRelease)
	end
	if self.Mode == "Hold" then
		self:_setActive(false)
	elseif self.Mode == "Release" then
		local parent = self.Parent
		self:_setActive(not (parent and parent.Type == "Toggle" and parent.Value or self.Active))
	end
end

-- Simulate the key from code.
function Keybind:Press()
	self:_down()
	task.defer(function()
		self:_up()
	end)
	return self
end

function Keybind:Listen()
	if listening and listening ~= self then
		listening:_stopListening()
	end
	listening = self
	Shared.KeybindListening = true
	self._listenAt = os.clock()
	if self._chipLabel then
		self._chipLabel.Text = "…"
		Theme.Paint(self._chipStroke, { Color = "Accent" }, 0.1)
	end
	return self
end

function Keybind:_stopListening()
	if listening == self then
		listening = nil
		task.defer(function()
			Shared.KeybindListening = listening ~= nil
		end)
	end
	if self._chipStroke then
		Theme.Paint(self._chipStroke, { Color = "Stroke" }, 0.1)
	end
	self:_render()
end

function Keybind:_serialize()
	return { self.Value, self.Mode }
end

function Keybind:_deserialize(v, silent)
	if type(v) == "table" then
		self:Set(v[1] or v.Key, silent)
		if v[2] or v.Mode then
			self:SetMode(v[2] or v.Mode)
		end
	else
		self:Set(v, silent)
	end
end

function Keybind:_chip(holder, order)
	local chip = Util.New("TextButton", {
		Name = "Keybind",
		Text = "",
		AutoButtonColor = false,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 20),
		LayoutOrder = order or 100,
		Parent = holder,
	})
	Util.Corner(5, chip)
	Util.Padding(chip, 0, 7, 0, 7)
	Util.New("UISizeConstraint", { MinSize = Vector2.new(26, 20), Parent = chip })
	Theme.Paint(chip, { BackgroundColor3 = "Surface3" })
	local stroke = Util.Stroke(chip)
	Theme.Paint(stroke, { Color = "Stroke" })
	local label = Util.Label({
		Text = "",
		FontFace = Theme.Fonts.MonoBold,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Center,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		Parent = chip,
	})
	self._chip, self._chipStroke, self._chipLabel = chip, stroke, label
	chip.Activated:Connect(function()
		if not self:IsLocked() then
			self:Listen()
		end
	end)
	chip.MouseButton2Click:Connect(function()
		if not self:IsLocked() then
			self:OpenModeMenu()
		end
	end)
	Shared.Overlay.Hover(chip, function()
		return Locale.T("Mode") .. ": " .. Locale.T(self.Mode) .. "  ·  RMB"
	end)
	return chip
end

-- One shared menu builder (created on demand, never pre-built per element).
function Keybind:OpenModeMenu()
	local items = {}
	for _, mode in self.Modes do
		table.insert(items, {
			Text = (self.Mode == mode and "● " or "   ") .. Locale.T(mode),
			Callback = function()
				self:SetMode(mode)
			end,
		})
	end
	table.insert(items, { Separator = true })
	table.insert(items, { Text = Locale.T("Reset"), Icon = "rotate-ccw", Callback = function()
		self:_userSet(self.Default)
	end })
	table.insert(items, { Text = Locale.T("None"), Icon = "x", Callback = function()
		self:_userSet("None")
	end })
	Shared.Overlay.Menu(items, { Anchor = self._chip, Align = "End", Width = 160 })
end

function Keybind:_buildInline(holder, order)
	self:_chip(holder, order)
	self._mounted = true
end

function Keybind:_build(parent)
	self:_row(parent)
	self:_chip(self._right, 100)
end

function Keybind:_render()
	if self._chipLabel and listening ~= self then
		self._chipLabel.Text = Keys.Display(self.Value)
		Theme.Paint(self._chipLabel, { TextColor3 = self.Value == "None" and "TextMute" or "Text" })
	end
end

function Keybind:Destroy()
	local i = table.find(registry, self)
	if i then
		table.remove(registry, i)
	end
	if listening == self then
		listening = nil
	end
	if self._chip and self.Parent then
		self._chip:Destroy()
	end
	Base.Destroy(self)
	self.Library.KeybindsChanged:Fire()
end

function Keybind.All()
	return registry
end

-- ═══ ColorPicker ══════════════════════════════════════════════════════════
local ColorPicker = Base.extend("ColorPicker")
classes.ColorPicker = ColorPicker

local recent = {}

local defaultPresets = {
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(160, 160, 168),
	Color3.fromRGB(60, 60, 66),
	Color3.fromRGB(232, 76, 84),
	Color3.fromRGB(240, 196, 110),
	Color3.fromRGB(120, 220, 160),
	Color3.fromRGB(110, 170, 255),
	Color3.fromRGB(190, 130, 255),
}

function ColorPicker.new(section, options)
	local self = Base.new(ColorPicker, section, options)
	self.Default = Util.ToColor(Util.Opt(options, "Default", "Value", "Color")) or Color3.new(1, 1, 1)
	self.Value = self.Default
	self.HasAlpha = options.Alpha ~= nil or options.Transparency ~= nil
	self.Alpha = self.HasAlpha and (options.Alpha or options.Transparency or 0) or 0
	self.DefaultAlpha = self.Alpha
	self.Presets = options.Presets or defaultPresets
	self.Rainbow = false
	if self.Parent and self.Name == "ColorPicker" then
		self.Name = self.Parent.Name
	end
	return self:_register()
end

function ColorPicker:_normalize(v)
	return Util.ToColor(v)
end

function ColorPicker:_callbackArgs()
	return self.Value, self.Alpha
end

function ColorPicker:GetColor(): Color3
	return self.Value
end
function ColorPicker:SetColor(c)
	return self:Set(c)
end
function ColorPicker:GetAlpha(): number
	return self.Alpha
end
function ColorPicker:SetAlpha(a: number, silent: boolean?)
	a = math.clamp(tonumber(a) or 0, 0, 1)
	if a == self.Alpha then
		return self
	end
	self.Alpha = a
	if self._mounted then
		self:_render()
	end
	if not silent then
		self:_fireCallbacks()
	end
	self.Changed:Fire(self.Value, self.Value)
	self.Library:_onElementChanged(self, self.Value, self.Value)
	return self
end
function ColorPicker:GetHex(): string
	return Util.ToHex(self.Value)
end
function ColorPicker:SetHex(hex: string)
	return self:Set(hex)
end

function ColorPicker:Reset(silent)
	self:SetAlpha(self.DefaultAlpha, true)
	return Base.Reset(self, silent)
end

function ColorPicker:SetRainbow(on: boolean, speed: number?)
	self.Rainbow = on
	if self._rainbowConn then
		self._rainbowConn:Disconnect()
		self._rainbowConn = nil
	end
	if on then
		speed = speed or 4
		self._rainbowConn = RunService.Heartbeat:Connect(function()
			local _, s, v = self.Value:ToHSV()
			self:Set(Color3.fromHSV((os.clock() / speed) % 1, math.max(s, 0.6), math.max(v, 0.8)))
		end)
		self.Maid:Give(self._rainbowConn)
	end
	return self
end

function ColorPicker:_serialize()
	return { Util.ToHex(self.Value), self.Alpha }
end

function ColorPicker:_deserialize(v, silent)
	if type(v) == "table" then
		self:SetAlpha(v[2] or v.Alpha or 0, true)
		self:Set(v[1] or v.Color, silent)
	else
		self:Set(v, silent)
	end
end

function ColorPicker:_swatch(holder, order)
	local swatch = Util.New("TextButton", {
		Name = "Swatch",
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromOffset(28, 16),
		LayoutOrder = order or 100,
		Parent = holder,
	})
	Util.Corner(4, swatch)
	local stroke = Util.Stroke(swatch)
	Theme.Paint(stroke, { Color = "StrokeHi" })
	self._swatch = swatch
	swatch.Activated:Connect(function()
		if self:IsLocked() then
			return
		end
		if self._popup and self._popup.Open then
			self:Close()
		else
			self:Open()
		end
	end)
	return swatch
end

function ColorPicker:_buildInline(holder, order)
	self:_swatch(holder, order)
	self._mounted = true
end

function ColorPicker:_build(parent)
	self:_row(parent)
	self:_swatch(self._right, 100)
end

function ColorPicker:_render()
	if self._swatch then
		self._swatch.BackgroundColor3 = self.Value
		self._swatch.BackgroundTransparency = self.Alpha * 0.85
	end
	if self._popupRefs then
		self:_paintPopup()
	end
end

function ColorPicker:Close()
	if self._popup then
		self._popup:Close()
	end
	return self
end

function ColorPicker:Open()
	if not self._swatch or (self._popup and self._popup.Open) then
		return self
	end
	local Overlay = Shared.Overlay
	local startColor, startAlpha = self.Value, self.Alpha
	local popup = Overlay.Popup({
		Anchor = self._swatch,
		Width = 236,
		MaxHeight = 400,
		Align = "End",
		Padding = 10,
		Spacing = 8,
		OnClose = function()
			self._popupRefs = nil
			if self.Value ~= startColor then
				table.insert(recent, 1, self.Value)
				for i = #recent, 2, -1 do
					if recent[i] == self.Value then
						table.remove(recent, i)
					end
				end
				while #recent > 8 do
					table.remove(recent)
				end
				self.Library:_pushHistory(self, startColor, self.Value)
			end
		end,
	})
	self._popup = popup
	local z = popup.Frame.ZIndex
	local content = popup.Content
	local h, s, v = self.Value:ToHSV()
	self._hsv = { h, s, v }
	local refs = {}

	-- saturation / value square
	local sv = Util.New("TextButton", { Name = "SV", Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 140), LayoutOrder = 1, ZIndex = z, Parent = content })
	Util.Corner(6, sv)
	local white = Util.New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = z, Parent = sv })
	Util.Corner(6, white)
	Util.Gradient(white, nil, NumberSequence.new(0, 1), 0)
	local black = Util.New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = z, Parent = sv })
	Util.Corner(6, black)
	Util.Gradient(black, nil, NumberSequence.new(1, 0), 90)
	local svKnob = Util.New("Frame", { Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, ZIndex = z + 2, Parent = sv })
	Util.Round(svKnob)
	Util.Stroke(svKnob, Color3.new(1, 1, 1), 2)
	refs.SV, refs.SVKnob = sv, svKnob

	-- hue bar
	local hue = Util.New("TextButton", { Name = "Hue", Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 10), BackgroundColor3 = Color3.new(1, 1, 1), LayoutOrder = 2, ZIndex = z, Parent = content })
	Util.Round(hue)
	local keys = {}
	for i = 0, 6 do
		table.insert(keys, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6 % 1, 1, 1)))
	end
	Util.Gradient(hue, ColorSequence.new(keys))
	local hueKnob = Util.New("Frame", { Size = UDim2.fromOffset(6, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = z + 2, Parent = hue })
	Util.Corner(3, hueKnob)
	Util.Stroke(hueKnob, Color3.new(0, 0, 0), 1, 0.5)
	refs.Hue, refs.HueKnob = hue, hueKnob

	-- alpha bar
	if self.HasAlpha then
		local alpha = Util.New("TextButton", { Name = "Alpha", Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 10), LayoutOrder = 3, ZIndex = z, Parent = content })
		Util.Round(alpha)
		local grad = Util.Gradient(alpha, nil, NumberSequence.new(0, 1))
		local alphaKnob = Util.New("Frame", { Size = UDim2.fromOffset(6, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = z + 2, Parent = alpha })
		Util.Corner(3, alphaKnob)
		Util.Stroke(alphaKnob, Color3.new(0, 0, 0), 1, 0.5)
		refs.Alpha, refs.AlphaKnob, refs.AlphaGrad = alpha, alphaKnob, grad
	end

	-- hex + old/new preview
	local line = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = 4, ZIndex = z, Parent = content })
	local hex = Util.New("TextBox", { Text = "", ClearTextOnFocus = false, FontFace = Theme.Fonts.Mono, TextSize = 12, Size = UDim2.new(1, -66, 1, 0), ZIndex = z, Parent = line })
	Util.Corner(5, hex)
	Theme.Paint(hex, { BackgroundColor3 = "Surface2", TextColor3 = "Text" })
	local old = Util.New("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(28, 26), Position = UDim2.new(1, -60, 0, 0), BackgroundColor3 = startColor, ZIndex = z, Parent = line })
	Util.Corner(5, old)
	local new = Util.New("Frame", { Size = UDim2.fromOffset(28, 26), Position = UDim2.new(1, -28, 0, 0), ZIndex = z, Parent = line })
	Util.Corner(5, new)
	Shared.Overlay.Hover(old, function()
		return Locale.T("Reset")
	end)
	old.Activated:Connect(function()
		self:SetAlpha(startAlpha)
		self:Set(startColor)
		self._hsv = { startColor:ToHSV() }
		self:_paintPopup()
	end)
	hex.FocusLost:Connect(function()
		local c = Util.FromHex(hex.Text)
		if c then
			self._hsv = { c:ToHSV() }
			self:Set(c)
		end
		self:_paintPopup()
	end)
	refs.Hex, refs.New = hex, new

	-- presets + recent
	local function swatchRow(order, colors)
		local row = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = order, ZIndex = z, Parent = content })
		Util.List(row, 6, Enum.FillDirection.Horizontal)
		for _, c in colors do
			local b = Util.New("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(18, 18), BackgroundColor3 = c, ZIndex = z, Parent = row })
			Util.Round(b)
			Theme.Paint(Util.Stroke(b), { Color = "StrokeHi" })
			b.Activated:Connect(function()
				self._hsv = { c:ToHSV() }
				self:Set(c)
				self:_paintPopup()
			end)
		end
	end
	swatchRow(5, self.Presets)
	if #recent > 0 then
		swatchRow(6, recent)
	end

	-- dragging
	local dragging = nil
	local function update(pos)
		if dragging == "SV" then
			local rel = (pos - sv.AbsolutePosition) / sv.AbsoluteSize
			self._hsv[2] = math.clamp(rel.X, 0, 1)
			self._hsv[3] = 1 - math.clamp(rel.Y, 0, 1)
		elseif dragging == "Hue" then
			self._hsv[1] = math.clamp((pos.X - hue.AbsolutePosition.X) / hue.AbsoluteSize.X, 0, 0.999)
		elseif dragging == "Alpha" then
			self:SetAlpha(math.clamp((pos.X - refs.Alpha.AbsolutePosition.X) / refs.Alpha.AbsoluteSize.X, 0, 1))
			self:_paintPopup()
			return
		end
		self:Set(Color3.fromHSV(self._hsv[1], self._hsv[2], self._hsv[3]))
		self:_paintPopup()
	end
	local function hook(gui, name)
		gui.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = name
				update(Vector2.new(input.Position.X, input.Position.Y))
			end
		end)
	end
	hook(sv, "SV")
	hook(hue, "Hue")
	if refs.Alpha then
		hook(refs.Alpha, "Alpha")
	end
	local c1 = UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(Vector2.new(input.Position.X, input.Position.Y))
		end
	end)
	local c2 = UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = nil
		end
	end)
	popup.Frame.Destroying:Connect(function()
		c1:Disconnect()
		c2:Disconnect()
	end)

	self._popupRefs = refs
	self:_paintPopup()
	return self
end

function ColorPicker:_paintPopup()
	local refs = self._popupRefs
	if not refs then
		return
	end
	local hsv = self._hsv or { self.Value:ToHSV() }
	refs.SV.BackgroundColor3 = Color3.fromHSV(hsv[1], 1, 1)
	refs.SVKnob.Position = UDim2.fromScale(hsv[2], 1 - hsv[3])
	refs.HueKnob.Position = UDim2.fromScale(hsv[1], 0.5)
	if refs.Alpha then
		refs.Alpha.BackgroundColor3 = self.Value
		refs.AlphaKnob.Position = UDim2.fromScale(self.Alpha, 0.5)
	end
	if not refs.Hex:IsFocused() then
		refs.Hex.Text = Util.ToHex(self.Value)
	end
	refs.New.BackgroundColor3 = self.Value
	refs.New.BackgroundTransparency = self.Alpha * 0.85
end

function ColorPicker:Destroy()
	self:Close()
	if self._swatch and self.Parent then
		self._swatch:Destroy()
	end
	Base.Destroy(self)
end
classes.Colorpicker = ColorPicker

return classes
