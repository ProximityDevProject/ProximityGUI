--!nocheck
--[[
	Proximity · Window/Section
	A card on a page that holds elements. Extras taken from the best hubs:
	  • Toggle header  - Section{ Toggle = true, Flag = "aim" }: a checkbox in the
	    header switches the whole section; disabled content is dimmed and locked.
	  • Tabs inside    - section:Tabs({ "Silent", "Lock", "Rage" }) → sub-sections
	    with their own elements and a sliding indicator.
	  • Collapsible    - click the header (Collapsible = true, Collapsed = false).
	  • Floating       - the options panel of an element (element:Options()).

	Every element constructor exists in two spellings: Section:Toggle{} and
	Section:AddToggle{} (drop-in for Compkiller / Neverlose style scripts).
]]

local Util = require("../Core/Util")
local Signal = require("../Core/Signal")
local Maid = require("../Core/Maid")
local Tween = require("../Core/Tween")
local Theme = require("../Theme")
local Icons = require("../Icons")
local Shared = require("../Shared")

local Section = {}
Section.__index = Section

function Section.new(page, options)
	options = type(options) == "string" and { Name = options } or (options or {})
	local self = setmetatable({}, Section)
	self.Page = page
	self.Tab = page and page.Tab
	self.Window = page and page.Window
	self.Name = options.Name or options.Title or ""
	self.Icon = options.Icon
	self.Side = Section._side(options.Side or options.Position)
	self.Collapsible = options.Collapsible == true
	self.Collapsed = options.Collapsed == true
	self.HasToggle = options.Toggle == true or options.Enabled ~= nil and options.Toggle ~= false
	self.Enabled = options.Enabled ~= false
	self.Flag = options.Flag
	self.Callback = options.Callback
	self.Elements = {}
	self.Children = {}
	self.Maid = Maid.new()
	self.Changed = Signal.new()
	self._counter = 0
	self.Visible = options.Visible ~= false
	if self.HasToggle then
		Section._registerToggle(self)
	end
	return self
end

function Section._side(side)
	if side == 2 or side == "Right" or side == "right" then
		return "Right"
	elseif side == "Full" or side == "full" or side == 0 then
		return "Full"
	end
	return "Left"
end

-- The header checkbox behaves like a flagged element (saved in configs).
function Section._registerToggle(self)
	local Lib = Shared.Lib
	local proxy = {
		Type = "SectionToggle",
		Name = self.Name,
		Flag = self.Flag,
		Value = self.Enabled,
		Default = self.Enabled,
		Changed = self.Changed,
		Section = self,
	}
	function proxy._serialize()
		return self.Enabled
	end
	function proxy._deserialize(_, v, silent)
		self:SetEnabled(v == true, silent)
	end
	function proxy.Get()
		return self.Enabled
	end
	function proxy.Set(_, v)
		self:SetEnabled(v)
	end
	function proxy.IsVisible()
		return true
	end
	self._proxy = proxy
	if self.Flag then
		Lib.Elements[self.Flag] = proxy
		Lib.Flags[self.Flag] = self.Enabled
	end
end

-- Floating section used by element:Options().
function Section.newFloating(owner, options)
	local self = Section.new(nil, options)
	self.Owner = owner
	self.Window = owner.Window
	self.Tab = owner.Tab
	self.Page = owner.Section and owner.Section.Page
	self.Floating = true
	self.Name = options.Name or owner.Name
	return self
end

function Section:IsDisabled(): boolean
	if self.HasToggle and not self.Enabled then
		return true
	end
	if self.ParentSection then
		return self.ParentSection:IsDisabled()
	end
	if self.Owner and self.Owner.IsLocked then
		return self.Owner:IsLocked()
	end
	return false
end

-- ─── Elements ─────────────────────────────────────────────────────────────

function Section:_add(element)
	self._counter += 1
	element._order = self._counter
	table.insert(self.Elements, element)
	if element.Type == "Toggle" then
		element.Changed:Connect(function()
			self:_updateCount()
		end)
		task.defer(function()
			self:_updateCount()
		end)
	end
	if self.Floating then
		if self._mounted then
			element:_mount(self.Body, element._order)
		end
		return
	end
	if self.Window then
		self.Window:_enqueue(element)
	end
end

function Section:_remove(element)
	local i = table.find(self.Elements, element)
	if i then
		table.remove(self.Elements, i)
	end
end

function Section:GetElements()
	return table.clone(self.Elements)
end

function Section:Find(name: string)
	for _, el in self.Elements do
		if el.Name == name or el.Flag == name then
			return el
		end
	end
	for _, child in self.Children do
		local found = child:Find(name)
		if found then
			return found
		end
	end
	return nil
end

function Section:Clear()
	for _, el in table.clone(self.Elements) do
		el:Destroy()
	end
	return self
end

-- ─── Mounting ────────────────────────────────────────────────────────────

function Section:_ensureMounted()
	if self._mounted then
		return
	end
	if self.ParentSection then
		self.ParentSection:_ensureMounted()
		self:_buildChild()
		return
	end
	self.Page:_ensureMounted()
	self:_build(self.Page:_column(self.Side))
end

function Section:_build(parent)
	self._mounted = true
	local frame = Util.New("Frame", {
		Name = "Section_" .. self.Name,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = self.Order or 0,
		Visible = self.Visible,
		Parent = parent,
	})
	Util.Corner(8, frame)
	Theme.Paint(frame, { BackgroundColor3 = "Surface" })
	local stroke = Util.Stroke(frame)
	Theme.Paint(stroke, { Color = "Stroke" })
	self.Frame, self.Stroke = frame, stroke

	local header = Util.New("TextButton", {
		Name = "Header",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 34),
		Visible = self.Name ~= "" or self.HasToggle,
		Parent = frame,
	})
	local x = 12
	local icon = Icons.Get(self.Icon)
	if icon then
		local img = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = icon, Size = UDim2.fromOffset(13, 13), Position = UDim2.new(0, 12, 0.5, -6), Parent = header })
		Theme.Paint(img, { ImageColor3 = "TextDim" })
		x = 31
	end
	local title = Util.Label({
		Text = string.upper(self.Name),
		FontFace = Theme.Fonts.Bold,
		TextSize = 11,
		Size = UDim2.new(1, -x - 50, 1, 0),
		Position = UDim2.fromOffset(x, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = header,
	})
	Theme.Paint(title, { TextColor3 = "TextDim" })
	self._title = title
	-- how many toggles in this section are on, e.g. "2/5"
	local count = Util.Label({ Text = "", FontFace = Theme.Fonts.Mono, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, (self.HasToggle and -36 or -12) - (self.Collapsible and 22 or 0), 0, 0), Parent = header })
	Theme.Paint(count, { TextColor3 = "TextMute" })
	self._count = count
	local line = Util.New("Frame", { BorderSizePixel = 0, Size = UDim2.new(1, -16, 0, 1), Position = UDim2.new(0, 8, 1, -1), Parent = header })
	Theme.Paint(line, { BackgroundColor3 = "Stroke" })

	-- header checkbox
	if self.HasToggle then
		local box = Util.New("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(16, 16), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Parent = header })
		Util.Corner(4, box)
		local boxStroke = Util.Stroke(box)
		local check = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get("check") or "", Size = UDim2.fromOffset(11, 11), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Parent = box })
		Theme.Paint(check, { ImageColor3 = "AccentInk" })
		self._box, self._boxStroke, self._check = box, boxStroke, check
		box.Activated:Connect(function()
			if self.Owner == nil then
				self:SetEnabled(not self.Enabled)
			end
		end)
	end

	-- collapse chevron
	if self.Collapsible then
		local chev = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get("chevron-down") or "", Size = UDim2.fromOffset(13, 13), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, self.HasToggle and -36 or -12, 0.5, 0), Parent = header })
		Theme.Paint(chev, { ImageColor3 = "TextMute" })
		self._chevron = chev
		header.Activated:Connect(function()
			self:SetCollapsed(not self.Collapsed)
		end)
	end

	header.LayoutOrder = 1
	Util.List(frame, 0)
	-- wrapper (no layout) holds the element list and the "disabled" dimmer
	local wrap = Util.New("Frame", {
		Name = "Wrap",
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = 2,
		Parent = frame,
	})
	local body = Util.New("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = wrap,
	})
	Util.Padding(body, 6, 6, 8, 6)
	Util.List(body, 2)
	self.Body, self.Wrap = body, wrap

	local dim = Util.New("TextButton", {
		Name = "Dimmer",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 30,
		Visible = false,
		Parent = wrap,
	})
	Theme.Paint(dim, { BackgroundColor3 = "Surface" })
	Util.Corner(8, dim)
	self._dim = dim

	self:_paintState(false)
	self:_updateCount()
	if self.Collapsed then
		self:SetCollapsed(true, true)
	end
end

function Section:_paintState(animate)
	local t = animate and 0.18 or 0
	if self._box then
		Theme.Paint(self._box, { BackgroundColor3 = self.Enabled and "Accent" or "Surface3" }, t)
		Theme.Paint(self._boxStroke, { Color = self.Enabled and "Accent" or "StrokeHi" }, t)
		self._check.ImageTransparency = self.Enabled and 0 or 1
		Theme.Paint(self._title, { TextColor3 = self.Enabled and "Text" or "TextDim" }, t)
	end
	if self._dim then
		local off = self.HasToggle and not self.Enabled
		self._dim.Visible = off
		Tween.Play(self._dim, { BackgroundTransparency = off and 0.45 or 1 }, t)
	end
end

function Section:SetEnabled(enabled: boolean, silent: boolean?)
	enabled = enabled and true or false
	if self.Enabled == enabled then
		return self
	end
	self.Enabled = enabled
	local Lib = Shared.Lib
	if self.Flag then
		Lib.Flags[self.Flag] = enabled
	end
	if self._proxy then
		self._proxy.Value = enabled
	end
	self:_paintState(true)
	for _, el in self:AllElements() do
		el:_applyState()
	end
	if not silent and self.Callback then
		Util.SafeCall(self.Callback, enabled)
	end
	self.Changed:Fire(enabled)
	if self._proxy then
		Lib:_onElementChanged(self._proxy, enabled, not enabled)
	end
	return self
end

function Section:_updateCount()
	if self.ParentSection then
		return self.ParentSection:_updateCount()
	end
	if not self._count then
		return
	end
	local on, total = 0, 0
	for _, el in self:AllElements() do
		if el.Type == "Toggle" then
			total += 1
			if el.Value then
				on += 1
			end
		end
	end
	self._count.Text = total >= 2 and (on .. "/" .. total) or ""
	Theme.Paint(self._count, { TextColor3 = on > 0 and "TextDim" or "TextMute" })
end

function Section:IsEnabled(): boolean
	return self.Enabled
end

function Section:AllElements()
	local out = table.clone(self.Elements)
	for _, child in self.Children do
		for _, el in child:AllElements() do
			table.insert(out, el)
		end
	end
	return out
end

function Section:SetCollapsed(collapsed: boolean, instant: boolean?)
	self.Collapsed = collapsed
	if not self.Body then
		return self
	end
	;(self.Wrap or self.Body).Visible = not collapsed
	if self._chevron then
		Tween.Play(self._chevron, { Rotation = collapsed and -90 or 0 }, instant and 0 or 0.18)
	end
	return self
end
function Section:Collapse()
	return self:SetCollapsed(true)
end
function Section:Expand()
	return self:SetCollapsed(false)
end

function Section:SetName(name: string)
	self.Name = name
	if self._title then
		self._title.Text = string.upper(name)
	end
	return self
end
Section.SetTitle = Section.SetName

function Section:SetVisible(visible: boolean)
	self.Visible = visible
	if self.Frame then
		self.Frame.Visible = visible
	end
	return self
end

-- Make sure the user can see this section (tab, page, tab-in-section, expanded).
function Section:_reveal()
	if self.ParentSection then
		self.ParentSection:_reveal()
		if self.ParentSection._tabs then
			self.ParentSection:SelectTab(self)
		end
	end
	if self.Page then
		self.Page:Select()
	end
	if self.Collapsed then
		self:SetCollapsed(false)
	end
end

-- ─── Tabs inside a section ───────────────────────────────────────────────

--[[
	local silent, lock, rage = section:Tabs({ "Silent", "Lock", "Rage" }, { Flag = "aim.mode", Icons = { "eye-off", "lock", "flame" } })
	silent:Toggle({...})
	section:SelectTab("Lock")   section:GetTab() → name
]]
function Section:Tabs(names: { string }, options: { [string]: any }?)
	options = options or {}
	self._tabs = {}
	self._tabIcons = options.Icons or {}
	local out = {}
	for i, name in names do
		local child = Section.new(nil, { Name = name })
		child.ParentSection = self
		child.Window = self.Window
		child.Tab = self.Tab
		child.Page = self.Page
		child.Owner = nil
		child.TabIndex = i
		child.Floating = self.Floating
		table.insert(self._tabs, child)
		table.insert(self.Children, child)
		table.insert(out, child)
	end
	self._tabFlag = options.Flag
	self._activeTab = self._tabs[1]
	local default = options.Default
	for _, t in self._tabs do
		if t.Name == default then
			self._activeTab = t
		end
	end
	-- register as a flagged value so the chosen tab is saved
	if self._tabFlag then
		local Lib = Shared.Lib
		local proxy = { Type = "SectionTabs", Name = self.Name, Flag = self._tabFlag, Changed = Signal.new() }
		function proxy._serialize()
			return self._activeTab and self._activeTab.Name
		end
		function proxy._deserialize(_, v)
			self:SelectTab(v)
		end
		function proxy.Get()
			return self._activeTab and self._activeTab.Name
		end
		function proxy.Set(_, v)
			self:SelectTab(v)
		end
		function proxy.IsVisible()
			return true
		end
		self._tabProxy = proxy
		Lib.Elements[self._tabFlag] = proxy
		Lib.Flags[self._tabFlag] = proxy.Get()
	end
	if self._mounted then
		self:_buildTabBar()
	end
	return table.unpack(out)
end

function Section:_buildTabBar()
	if self._tabBar or not self._tabs then
		return
	end
	local bar = Util.New("Frame", { Name = "TabBar", Size = UDim2.new(1, 0, 0, 30), LayoutOrder = -1, Parent = self.Body })
	Util.Corner(6, bar)
	Theme.Paint(bar, { BackgroundColor3 = "Bg2" })
	Theme.Paint(Util.Stroke(bar), { Color = "Stroke" })
	local indicator = Util.New("Frame", { Name = "Indicator", Size = UDim2.new(1 / #self._tabs, -6, 1, -6), Position = UDim2.fromOffset(3, 3), Parent = bar })
	Util.Corner(5, indicator)
	Theme.Paint(indicator, { BackgroundColor3 = "Surface3" })
	Theme.Paint(Util.Stroke(indicator), { Color = "StrokeHi" })
	self._tabBar, self._tabIndicator, self._tabButtons = bar, indicator, {}
	for i, child in self._tabs do
		local b = Util.New("TextButton", {
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(1 / #self._tabs, 0, 1, 0),
			Position = UDim2.fromScale((i - 1) / #self._tabs, 0),
			ZIndex = 2,
			Parent = bar,
		})
		local holder = Util.New("Frame", { BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromScale(0, 1), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0), ZIndex = 2, Parent = b })
		Util.List(holder, 5, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)
		local iconId = Icons.Get(self._tabIcons[i])
		local img
		if iconId then
			img = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = iconId, Size = UDim2.fromOffset(13, 13), ZIndex = 2, Parent = holder })
		end
		local label = Util.Label({ Text = child.Name, FontFace = Theme.Fonts.SemiBold, TextSize = 12, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromScale(0, 1), LayoutOrder = 2, ZIndex = 2, Parent = holder })
		self._tabButtons[child] = { Label = label, Icon = img }
		b.Activated:Connect(function()
			self:SelectTab(child)
		end)
	end
	self:_paintTabs(false)
end

function Section:_paintTabs(animate)
	if not self._tabBar then
		return
	end
	local index = self._activeTab and self._activeTab.TabIndex or 1
	Tween.Play(self._tabIndicator, { Position = UDim2.new((index - 1) / #self._tabs, 3, 0, 3) }, animate and 0.25 or 0, Enum.EasingStyle.Back)
	for child, refs in self._tabButtons do
		local on = child == self._activeTab
		Theme.Paint(refs.Label, { TextColor3 = on and "Text" or "TextMute" }, animate and 0.15 or 0)
		if refs.Icon then
			Theme.Paint(refs.Icon, { ImageColor3 = on and "Accent" or "TextMute" }, animate and 0.15 or 0)
		end
		if child.Body then
			child.Body.Visible = on
		end
	end
end

function Section:SelectTab(which)
	if not self._tabs then
		return self
	end
	for _, child in self._tabs do
		if child == which or child.Name == which or child.TabIndex == which then
			if self._activeTab ~= child then
				self._activeTab = child
				self:_paintTabs(true)
				if self._tabProxy then
					Shared.Lib.Flags[self._tabFlag] = child.Name
					Shared.Lib:_onElementChanged(self._tabProxy, child.Name, nil)
				end
			end
		end
	end
	return self
end

function Section:GetTab(): string?
	return self._activeTab and self._activeTab.Name
end

function Section:_buildChild()
	if self._mounted then
		return
	end
	self._mounted = true
	local parent = self.ParentSection
	parent:_buildTabBar()
	local body = Util.New("Frame", {
		Name = "Tab_" .. self.Name,
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = self.TabIndex,
		Visible = parent._activeTab == self,
		Parent = parent.Body,
	})
	Util.Padding(body, 4, 0, 0, 0)
	Util.List(body, 2)
	self.Body = body
	self.Frame = body
end

-- ─── Floating (options panel) ────────────────────────────────────────────

function Section:Toggle(anchor)
	if self._popup and self._popup.Open then
		self._popup:Close()
		return
	end
	self:Open(anchor)
end

function Section:Open(anchor)
	if not self.Floating then
		return self
	end
	local Overlay = Shared.Overlay
	local popup = Overlay.Popup({
		Anchor = anchor,
		Width = 260,
		MaxHeight = 380,
		Side = "Right",
		Padding = 6,
		Spacing = 2,
		OnClose = function()
			self._mounted = false
			self.Body = nil
			for _, el in self:AllElements() do
				el._mounted = false
				el.Frame = nil
				for _, link in el.Links do
					link._mounted = false
				end
			end
			for _, child in self.Children do
				child._mounted = false
				child.Body = nil
			end
			self._tabBar = nil
		end,
	})
	self._popup = popup
	local z = popup.Frame.ZIndex
	local title = Util.Label({ Text = string.upper(self.Name), FontFace = Theme.Fonts.Bold, TextSize = 11, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = -2, ZIndex = z, Parent = popup.Content })
	Util.Padding(title, 0, 0, 0, 6)
	Theme.Paint(title, { TextColor3 = "TextDim" })
	self.Body = popup.Content
	self._mounted = true
	if self._tabs then
		self:_buildTabBar()
	end
	for _, el in self.Elements do
		el:_mount(self.Body, el._order)
	end
	for _, child in self.Children do
		child:_buildChild()
		for _, el in child.Elements do
			el:_mount(child.Body, el._order)
		end
	end
	self:_paintTabs(false)
	-- popups render above everything: bump element z-index
	for _, d in popup.Content:GetDescendants() do
		if d:IsA("GuiObject") then
			d.ZIndex = z + (d.ZIndex > 1 and d.ZIndex - 1 or 0)
		end
	end
	return self
end

function Section:Close()
	if self._popup then
		self._popup:Close()
	end
	return self
end

function Section:Destroy()
	self:Clear()
	for _, child in self.Children do
		child:Destroy()
	end
	if self._popup then
		self._popup:Close()
	end
	self.Maid:Clean()
	if self.Frame and not self.Floating then
		self.Frame:Destroy()
	end
	if self.Page then
		local i = table.find(self.Page.Sections, self)
		if i then
			table.remove(self.Page.Sections, i)
		end
	end
end

-- ─── Element constructors ────────────────────────────────────────────────

local constructors = {
	Toggle = "Toggle",
	Checkbox = "Toggle",
	Button = "Button",
	ButtonGroup = "ButtonGroup",
	Buttons = "ButtonGroup",
	Label = "Label",
	Text = "Label",
	Paragraph = "Paragraph",
	Divider = "Divider",
	Separator = "Divider",
	Spacer = "Spacer",
	Navigate = "Navigate",
	Link = "Navigate",
	Slider = "Slider",
	Dropdown = "Dropdown",
	Input = "Input",
	TextBox = "Input",
	Textbox = "Input",
	Keybind = "Keybind",
	Bind = "Keybind",
	ColorPicker = "ColorPicker",
	Colorpicker = "ColorPicker",
	Color = "ColorPicker",
	Progress = "Progress",
	ProgressBar = "Progress",
	Stat = "Stat",
	StatGrid = "StatGrid",
	Graph = "Graph",
	Sparkline = "Graph",
	Chart = "Graph",
	Table = "Table",
	Catalog = "Table",
	List = "Table",
	Card = "Card",
	Image = "Image",
	Console = "Console",
	Log = "Console",
	Code = "Code",
}

for method, className in constructors do
	local function make(self, options)
		local class = Shared.Lib._classes[className]
		if type(options) ~= "table" and className ~= "Label" and className ~= "Divider" and className ~= "Paragraph" and className ~= "Spacer" then
			options = { Name = options }
		end
		if className == "Toggle" and method == "Checkbox" then
			options.Style = options.Style or "Checkbox"
		end
		return class.new(self, options or {})
	end
	-- the Section:Toggle(anchor) of floating sections is reserved, keep element ctor on AddToggle
	if method ~= "Toggle" then
		Section[method] = make
	end
	Section["Add" .. method] = make
	Section["Create" .. method] = make
end

-- Toggle needs special care: Section:Toggle(anchor) toggles a floating panel.
local originalToggle = Section.Toggle
function Section:Toggle(arg)
	if typeof(arg) == "Instance" or (arg == nil and self.Floating) then
		return originalToggle(self, arg)
	end
	return Shared.Lib._classes.Toggle.new(self, type(arg) == "table" and arg or { Name = arg })
end

function Section:RangeSlider(options)
	options = options or {}
	options.Range = true
	return Shared.Lib._classes.Slider.new(self, options)
end
Section.AddRangeSlider = Section.RangeSlider
Section.RangedSlider = Section.RangeSlider

function Section:TextSlider(options)
	options = options or {}
	options.Labels = options.Labels or options.Values or options.TextProps
	return Shared.Lib._classes.Slider.new(self, options)
end
Section.AddTextSlider = Section.TextSlider

function Section:MultiDropdown(options)
	options = options or {}
	options.Multi = true
	return Shared.Lib._classes.Dropdown.new(self, options)
end
Section.AddMultiDropdown = Section.MultiDropdown

function Section:PlayerDropdown(options)
	return Shared.Lib._classes.PlayerDropdown(self, options or {})
end
Section.AddPlayerDropdown = Section.PlayerDropdown

-- Registered custom elements: Library:RegisterElement("Name", class)
function Section:Custom(name: string, options)
	local class = Shared.Lib._custom[name]
	assert(class, "[Proximity] unknown custom element '" .. tostring(name) .. "'")
	return class.new(self, options or {})
end

return Section
