--!nocheck
--[[
	Proximity · Elements/Base
	Every element inherits from here. An element is state first: it exists,
	has a value, flag and callbacks the moment you create it. The visual row
	is mounted later by the window's build scheduler (that is what drives the
	loading skeleton), and everything keeps working before it is mounted.

	Shared API (all elements):
	  :Get()  :Set(v, silent?)  :Reset()  :GetDefault()  :SetDefault(v)
	  :OnChanged(fn) → connection     .Changed (Signal)
	  :SetCallback(fn)  :AddCallback(fn)  :Fire()
	  :SetName(s)  :GetName()  :SetDescription(s)  :SetTooltip(s)
	  :SetVisible(b)  :Show()  :Hide()  :IsVisible()
	  :SetLocked(b, reason?)  :Lock(reason?)  :Unlock()  :IsLocked()
	  :SetRisky(b)  :SetBadge(text?)  :DependsOn(target, predicate?, mode?)
	  :Highlight()  :Focus()  :Copy()  :Paste()  :Destroy()
	  :Keybind(opts)  :ColorPicker(opts)  :Options(builder?)  (links)
]]

local Util = require("../Core/Util")
local Signal = require("../Core/Signal")
local Maid = require("../Core/Maid")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")
local Theme = require("../Theme")
local Icons = require("../Icons")
local Locale = require("../Locale")
local Shared = require("../Shared")

local HttpService = game:GetService("HttpService")

local Base = {}
Base.__index = Base

-- Creates a subclass: local Toggle = Base.extend("Toggle")
function Base.extend(kind: string)
	local class = setmetatable({}, { __index = Base })
	class.__index = class
	class.Kind = kind
	return class
end

function Base.new(class, section, options: { [string]: any })
	options = options or {}
	local Lib = Shared.Lib
	local self = setmetatable({}, class)
	self.Type = class.Kind
	self.Library = Lib
	self.Section = section
	self.Window = section and section.Window
	self.Tab = section and section.Tab
	self.Opts = options
	self.Id = Util.Uid()
	self.Name = Util.Opt(options, "Name", "Title", "Text") or class.Kind
	self.Description = Util.Opt(options, "Description", "Desc")
	self.TooltipText = Util.Opt(options, "Tooltip", "Info")
	self.Flag = options.Flag
	self.Save = options.Save
	self.Risky = options.Risky == true
	self.Visible = options.Visible ~= false
	self.Locked = options.Locked ~= nil and options.Locked ~= false
	self.LockReason = type(options.Locked) == "string" and options.Locked or options.LockReason
	self.BadgeText = options.Badge
	self.Icon = options.Icon
	self.Changed = Signal.new()
	self.Destroyed = Signal.new()
	self.Maid = Maid.new()
	self.Links = {}
	self._callbacks = {}
	self._depsOk = true
	self._mounted = false
	self.Parent = options.__parent -- set for linked (inline) elements
	local callback = Util.Opt(options, "Callback", "OnChanged")
	if type(callback) == "function" then
		table.insert(self._callbacks, callback)
	end
	return self
end

-- Called by every constructor once Value/Default are set.
function Base:_register()
	local Lib = self.Library
	if self.Flag then
		if Lib.Elements[self.Flag] and Lib.Debug then
			warn("[Proximity] duplicate flag '" .. self.Flag .. "' - the newest element wins")
		end
		Lib.Elements[self.Flag] = self
		Lib.Flags[self.Flag] = self.Value
	end
	table.insert(Lib.AllElements, self)
	if self.Section and not self.Parent then
		self.Section:_add(self)
	end
	return self
end

-- ─── Value ────────────────────────────────────────────────────────────────

function Base:Get()
	return self.Value
end
Base.GetValue = Base.Get

-- Override in subclasses: return the cleaned value or nil when invalid.
function Base:_normalize(value)
	return value
end

-- What callbacks receive.
function Base:_callbackArgs()
	return self.Value
end

function Base:Set(value: any, silent: boolean?)
	if self._destroyed then
		return self
	end
	local normalized = self:_normalize(value)
	if normalized == nil and value ~= nil then
		return self
	end
	local old = self.Value
	if Util.Equal(old, normalized) then
		return self
	end
	self.Value = normalized
	local Lib = self.Library
	if self.Flag then
		Lib.Flags[self.Flag] = normalized
	end
	if self._mounted then
		self:_render(true)
	end
	if not silent then
		self:_fireCallbacks()
	end
	self.Changed:Fire(normalized, old)
	Lib:_onElementChanged(self, normalized, old)
	return self
end
Base.SetValue = Base.Set

-- A change that came from the user's hand: goes into undo history.
function Base:_userSet(value: any)
	local old = Util.DeepCopy(self.Value)
	self:Set(value)
	if not Util.Equal(old, self.Value) then
		self.Library:_pushHistory(self, old, Util.DeepCopy(self.Value))
	end
end

function Base:_fireCallbacks()
	for _, callback in self._callbacks do
		Util.SafeCall(callback, self:_callbackArgs())
	end
end

function Base:Fire()
	self:_fireCallbacks()
	return self
end

function Base:Reset(silent: boolean?)
	return self:Set(Util.DeepCopy(self.Default), silent)
end

function Base:GetDefault()
	return Util.DeepCopy(self.Default)
end

function Base:SetDefault(value: any)
	self.Default = self:_normalize(value) or self.Default
	return self
end

function Base:IsDefault(): boolean
	return Util.Equal(self.Value, self.Default)
end

function Base:OnChanged(fn: (any, any) -> ())
	return self.Changed:Connect(fn)
end

function Base:SetCallback(fn: (...any) -> ())
	self._callbacks = { fn }
	return self
end

function Base:AddCallback(fn: (...any) -> ())
	table.insert(self._callbacks, fn)
	return self
end

-- JSON-safe value for configs; override for Color3/Enum etc.
function Base:_serialize()
	return self.Value
end

function Base:_deserialize(value, silent)
	self:Set(value, silent)
end

-- ─── Text, state, decoration ─────────────────────────────────────────────

function Base:GetName(): string
	return self.Name
end

function Base:SetName(name: string)
	self.Name = tostring(name)
	if self._title then
		self._title.Text = self.Name
	end
	return self
end
Base.SetTitle = Base.SetName
Base.SetText = Base.SetName

function Base:SetDescription(text: string?)
	self.Description = text
	if self._desc then
		self._desc.Text = text or ""
		self._desc.Visible = text ~= nil and text ~= ""
	end
	return self
end

function Base:SetTooltip(text: string?)
	self.TooltipText = text
	return self
end

function Base:SetVisible(visible: boolean)
	self.Visible = visible and true or false
	self:_applyState()
	return self
end

function Base:Show()
	return self:SetVisible(true)
end

function Base:Hide()
	return self:SetVisible(false)
end

function Base:IsVisible(): boolean
	return self.Visible and self._depsOk ~= false
end

function Base:SetLocked(locked: boolean, reason: string?)
	self.Locked = locked and true or false
	self.LockReason = reason or (locked and self.LockReason) or nil
	self:_applyState()
	return self
end

function Base:Lock(reason: string?)
	return self:SetLocked(true, reason)
end

function Base:Unlock()
	return self:SetLocked(false)
end

function Base:IsLocked(): boolean
	return self.Locked or self._depsLocked == true or (self.Section ~= nil and self.Section:IsDisabled()) or (self.Parent ~= nil and self.Parent:IsLocked())
end

function Base:SetRisky(risky: boolean)
	self.Risky = risky and true or false
	self:_applyState()
	return self
end

function Base:SetBadge(text: string?)
	self.BadgeText = text
	if self._badge then
		self._badge.Visible = text ~= nil and text ~= ""
		self._badgeLabel.Text = text or ""
	end
	return self
end

--[[
	element:DependsOn("aim.enabled")                         -- visible while the flag is truthy
	element:DependsOn(toggle, function(v) return v end, "Lock")
	element:DependsOn(dropdown, function(v) return v == "Custom" end)
	mode: "Hide" (default) or "Lock"
]]
function Base:DependsOn(target: any, predicate: ((any) -> boolean)?, mode: string?)
	local Lib = self.Library
	mode = mode or "Hide"
	predicate = predicate
		or function(v)
			if type(v) == "table" then
				return next(v) ~= nil
			end
			return v ~= nil and v ~= false and v ~= 0 and v ~= "" and v ~= "None"
		end
	local function resolve()
		if type(target) == "string" then
			return Lib.Elements[target]
		end
		return target
	end
	local function update()
		local el = resolve()
		local ok = el == nil or predicate(el:Get()) and true or false
		if el and el.IsVisible and not el:IsVisible() then
			ok = false
		end
		if mode == "Lock" then
			self._depsLocked = not ok
		else
			self._depsOk = ok
		end
		self:_applyState()
	end
	if type(target) == "table" and target.Changed then
		self.Maid:Give(target.Changed:Connect(update))
	else
		self.Maid:Give(Lib.FlagChanged:Connect(function(flag)
			if flag == target then
				update()
			end
		end))
	end
	task.defer(update)
	update()
	return self
end

-- ─── Mounting ────────────────────────────────────────────────────────────

-- Override: build the row inside self.Frame (created by _row helpers).
function Base:_build() end

-- Override: refresh visuals from self.Value.
function Base:_render(animate: boolean?) end

function Base:_mount(parent: Instance, order: number?)
	if self._mounted or self._destroyed then
		return
	end
	self._mounted = true
	self:_build(parent, order)
	if self.Frame then
		self.Frame.LayoutOrder = order or self.Frame.LayoutOrder
		self:_wireRow()
	end
	for _, link in self.Links do
		self:_mountLink(link)
	end
	self:_render(false)
	self:_applyState()
end

function Base:IsMounted(): boolean
	return self._mounted
end

-- Standard row: [title + description] ........ [links][control]
function Base:_row(parent: Instance, height: number?)
	height = height or 34
	local row = Util.New("Frame", {
		Name = self.Type .. "_" .. self.Name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, height),
		Parent = parent,
	})
	Theme.Paint(row, { BackgroundColor3 = "Surface2" })
	Util.Corner(6, row)
	self.Frame = row

	local textBox = Util.New("Frame", {
		Name = "Text",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -110, 1, 0),
		Position = UDim2.fromOffset(8, 0),
		Parent = row,
	})
	self._textBox = textBox
	local title = Util.Label({
		Name = "Title",
		Text = self.Name,
		FontFace = Theme.Fonts.Medium,
		TextSize = Theme.Size.Body,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, 0, 0, 16),
		Position = UDim2.new(0, 0, 0.5, -8),
		Parent = textBox,
	})
	Theme.Paint(title, { TextColor3 = "Text" })
	self._title = title

	-- optional icon before the title; follows the title if a subclass moves it
	local iconId = self.Icon and Icons.Get(self.Icon)
	if iconId then
		Util.New("UIPadding", { PaddingLeft = UDim.new(0, 22), Parent = textBox })
		local icon = Util.New("ImageLabel", { Name = "Icon", BackgroundTransparency = 1, Image = iconId, Size = UDim2.fromOffset(15, 15), Parent = textBox })
		Theme.Paint(icon, { ImageColor3 = "TextDim" })
		local function follow()
			icon.Position = UDim2.new(0, -22, title.Position.Y.Scale, title.Position.Y.Offset + 1)
		end
		title:GetPropertyChangedSignal("Position"):Connect(follow)
		follow()
		self._icon = icon
	end

	if self.Description and self.Description ~= "" then
		title.Position = UDim2.new(0, 0, 0.5, -15)
		local desc = Util.Label({
			Name = "Description",
			Text = self.Description,
			FontFace = Theme.Fonts.Regular,
			TextSize = Theme.Size.Small,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, 0, 0, 13),
			Position = UDim2.new(0, 0, 0.5, 2),
			Parent = textBox,
		})
		Theme.Paint(desc, { TextColor3 = "TextMute" })
		self._desc = desc
		row.Size = UDim2.new(1, 0, 0, math.max(height, 42))
	end

	-- badge (NEW / BETA / …) placed right after the title text
	local badge = Util.New("Frame", {
		Name = "Badge",
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 14),
		AnchorPoint = Vector2.new(0, 0.5),
		Visible = false,
		Parent = textBox,
	})
	Theme.Paint(badge, { BackgroundColor3 = "Accent" })
	Util.Corner(4, badge)
	Util.Padding(badge, 0, 5, 0, 5)
	local badgeLabel = Util.Label({
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		FontFace = Theme.Fonts.Bold,
		TextSize = 9,
		Text = "",
		Parent = badge,
	})
	Theme.Paint(badgeLabel, { TextColor3 = "AccentInk" })
	self._badge, self._badgeLabel = badge, badgeLabel
	local function placeBadge()
		badge.Position = UDim2.new(0, math.min(title.TextBounds.X, title.AbsoluteSize.X) + 6, 0, title.Position.Y.Offset + title.AbsoluteSize.Y / 2 + (title.Position.Y.Scale * textBox.AbsoluteSize.Y))
	end
	title:GetPropertyChangedSignal("TextBounds"):Connect(placeBadge)
	task.defer(placeBadge)
	self:SetBadge(self.BadgeText)

	local right = Util.New("Frame", {
		Name = "Right",
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 0),
		Parent = row,
	})
	Util.List(right, 6, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
	self._right = right
	right:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		textBox.Size = UDim2.new(1, -(right.AbsoluteSize.X / math.max(Shared.Scale or 1, 0.01)) - 26, 1, 0)
	end)

	-- lock layer: swallows input, explains why
	local lock = Util.New("TextButton", {
		Name = "Lock",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 20,
		Visible = false,
		Parent = row,
	})
	local lockIcon = Util.New("ImageLabel", {
		BackgroundTransparency = 1,
		Image = Icons.Get("lock") or "",
		Size = UDim2.fromOffset(12, 12),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		ZIndex = 21,
		Parent = lock,
	})
	Theme.Paint(lockIcon, { ImageColor3 = "TextMute" })
	self._lock = lock
	return row
end

-- Hover, tooltip and context menu on the row.
function Base:_wireRow()
	local row = self.Frame
	local Overlay = Shared.Overlay
	row.MouseEnter:Connect(function()
		if not self:IsLocked() then
			Tween.Play(row, { BackgroundTransparency = 0.55 }, 0.12)
		end
	end)
	row.MouseLeave:Connect(function()
		Tween.Play(row, { BackgroundTransparency = 1 }, 0.18)
	end)
	Overlay.Hover(row, function()
		if self:IsLocked() and self.LockReason then
			return "🔒 " .. self.LockReason
		end
		return self.TooltipText
	end)
	row.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			self:OpenContextMenu(Vector2.new(input.Position.X, input.Position.Y))
		end
	end)
end

function Base:_applyState()
	if not self._mounted or not self.Frame then
		return
	end
	local visible = self.Visible and self._depsOk ~= false
	self.Frame.Visible = visible
	local locked = self:IsLocked()
	if self._lock then
		self._lock.Visible = locked
	end
	if self._title then
		local token = self.Risky and "Risky" or (locked and "TextMute" or (self._titleToken or "Text"))
		Theme.Paint(self._title, { TextColor3 = token }, 0.15)
	end
	if self._onState then
		self:_onState(locked)
	end
end

-- ─── Context menu & clipboard ───────────────────────────────────────────

function Base:_contextItems()
	local T = Locale.T
	local items = {}
	if self.Default ~= nil then
		table.insert(items, { Text = T("Reset"), Icon = "rotate-ccw", Callback = function()
			self:_userSet(Util.DeepCopy(self.Default))
		end })
	end
	if self.Value ~= nil then
		table.insert(items, { Text = T("Copy"), Icon = "copy", Callback = function()
			self:Copy()
		end })
		table.insert(items, { Text = T("Paste"), Icon = "clipboard", Callback = function()
			self:Paste()
		end })
	end
	if self.Flag then
		table.insert(items, { Text = T("CopyFlag"), Icon = "hash", Hint = self.Flag, Callback = function()
			Env.Clipboard(self.Flag)
		end })
	end
	local Lib = self.Library
	table.insert(items, { Separator = true })
	table.insert(items, {
		Text = Lib:IsFavorite(self) and "★ " .. T("Favorites") or "☆ " .. T("Favorites"),
		Icon = "star",
		Callback = function()
			Lib:ToggleFavorite(self)
		end,
	})
	return items
end

function Base:OpenContextMenu(at: Vector2?)
	if self:IsLocked() then
		return
	end
	local items = self:_contextItems()
	if #items == 0 then
		return
	end
	if not at then
		at = game:GetService("UserInputService"):GetMouseLocation() - game:GetService("GuiService"):GetGuiInset()
	end
	Shared.Overlay.Menu(items, { At = at })
end

local clipboard = nil -- library-local clipboard (works without setclipboard)

function Base:Copy(): string
	local ok, encoded = pcall(function()
		return HttpService:JSONEncode({ t = self.Type, v = self:_serialize() })
	end)
	if ok then
		clipboard = encoded
		Env.Clipboard(encoded)
		return encoded
	end
	return ""
end

function Base:Paste(text: string?): boolean
	local raw = text or clipboard
	if not raw then
		return false
	end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(raw)
	end)
	if ok and type(data) == "table" and data.t == self.Type then
		local before = Util.DeepCopy(self.Value)
		self:_deserialize(data.v)
		self.Library:_pushHistory(self, before, Util.DeepCopy(self.Value))
		return true
	end
	return false
end

-- ─── Navigation ──────────────────────────────────────────────────────────

function Base:Highlight()
	local row = self.Frame
	if not row then
		return self
	end
	task.spawn(function()
		for _ = 1, 2 do
			Theme.Paint(row, { BackgroundColor3 = "Accent" })
			row.BackgroundTransparency = 0.82
			Tween.Await(row, { BackgroundTransparency = 1 }, 0.45, Enum.EasingStyle.Sine)
		end
		Theme.Paint(row, { BackgroundColor3 = "Surface2" })
	end)
	return self
end

-- Opens the window on this element's tab, scrolls to it and highlights it.
function Base:Focus()
	local window = self.Window
	if not window then
		return self
	end
	window:Open()
	if self.Section then
		self.Section:_reveal()
	end
	task.delay(0.05, function()
		if self.Section and self.Section.Page then
			self.Section.Page:ScrollTo(self.Frame)
		end
		task.delay(0.12, function()
			self:Highlight()
		end)
	end)
	return self
end
Base.ScrollTo = Base.Focus

function Base:GetPath(): string
	local parts = {}
	if self.Tab then
		table.insert(parts, self.Tab.Name)
	end
	if self.Section and self.Section.Page and self.Section.Page.Name ~= (self.Tab and self.Tab.Name) and not self.Section.Page.Implicit then
		table.insert(parts, self.Section.Page.Name)
	end
	if self.Section and self.Section.ParentSection then
		table.insert(parts, self.Section.ParentSection.Name)
	end
	if self.Section and self.Section.Name then
		table.insert(parts, self.Section.Name)
	end
	return table.concat(parts, " › ")
end

-- ─── Links ───────────────────────────────────────────────────────────────

function Base:_mountLink(link)
	if not self._mounted or link._mounted then
		return
	end
	local holder = self._right
	if not holder then
		return
	end
	link._mounted = true
	link:_buildInline(holder, #self.Links)
	link:_render(false)
end

-- toggle:Keybind({ Default = Enum.KeyCode.E, Mode = "Toggle", Flag = "x.key" })
function Base:Keybind(options: { [string]: any }?)
	options = options or {}
	options.__parent = self
	local link = Shared.Lib._classes.Keybind.new(self.Section, options)
	table.insert(self.Links, link)
	self:_mountLink(link)
	return link
end
Base.AddKeybind = Base.Keybind

-- label:ColorPicker({ Default = Color3.new(1,1,1), Alpha = 0 })
function Base:ColorPicker(options: { [string]: any }?)
	options = options or {}
	options.__parent = self
	local link = Shared.Lib._classes.ColorPicker.new(self.Section, options)
	table.insert(self.Links, link)
	self:_mountLink(link)
	return link
end
Base.AddColorPicker = Base.ColorPicker
Base.Colorpicker = Base.ColorPicker

--[[
	Options panel (the "gear"): a popup section anchored to a small button on
	the row. Built lazily the first time it opens.
	  local opts = toggle:Options()          -- returns the panel section
	  opts:Slider({ ... })
	  toggle:Options(function(o) o:Slider({...}) end)
]]
function Base:Options(builder: any?)
	if not self._options then
		local Lib = Shared.Lib
		local section = Lib._classes.Section.newFloating(self, type(builder) == "table" and builder or {})
		self._options = section
		local link = { _mounted = false, Type = "OptionsLink" }
		function link._buildInline(_, holder, order)
			local button = Util.New("ImageButton", {
				Name = "Options",
				BackgroundTransparency = 1,
				Image = Icons.Get("sliders-horizontal") or Icons.Get("settings") or "",
				Size = UDim2.fromOffset(16, 16),
				LayoutOrder = order,
				Parent = holder,
			})
			Theme.Paint(button, { ImageColor3 = "TextDim" })
			button.MouseEnter:Connect(function()
				Theme.Paint(button, { ImageColor3 = "Text" }, 0.1)
			end)
			button.MouseLeave:Connect(function()
				Theme.Paint(button, { ImageColor3 = "TextDim" }, 0.1)
			end)
			button.Activated:Connect(function()
				if self:IsLocked() then
					return
				end
				section:Toggle(button)
			end)
			link.Button = button
		end
		function link._render() end
		table.insert(self.Links, link)
		self:_mountLink(link)
	end
	if type(builder) == "function" then
		Util.SafeCall(builder, self._options)
	end
	return self._options
end
Base.Settings = Base.Options
Base.AddOption = Base.Options

-- ─── Destroy ─────────────────────────────────────────────────────────────

function Base:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	local Lib = self.Library
	if self.Flag and Lib.Elements[self.Flag] == self then
		Lib.Elements[self.Flag] = nil
		Lib.Flags[self.Flag] = nil
	end
	local index = table.find(Lib.AllElements, self)
	if index then
		table.remove(Lib.AllElements, index)
	end
	if self.Section then
		self.Section:_remove(self)
	end
	for _, link in self.Links do
		if link.Destroy then
			link:Destroy()
		end
	end
	if self._options then
		self._options:Destroy()
	end
	self.Maid:Clean()
	if self.Frame then
		self.Frame:Destroy()
	end
	self.Destroyed:Fire()
	self.Changed:DisconnectAll()
end
Base.Remove = Base.Destroy

return Base
