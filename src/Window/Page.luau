--!nocheck
--[[
	Proximity · Window/Page
	Tab  = an entry in the sidebar.
	Page = a scrollable surface with Left / Right / Full columns. A tab owns
	       one or more pages: the first is implicit; extra ones appear as
	       pills under the title (Tab:SubTab{}), or are reachable only through
	       a Navigate row (Tab:SubPage{ Hidden = true }) with a back arrow.
]]

local Util = require("../Core/Util")
local Signal = require("../Core/Signal")
local Tween = require("../Core/Tween")
local Theme = require("../Theme")
local Icons = require("../Icons")
local Shared = require("../Shared")
local Section = require("./Section")

-- ═══ Page ═════════════════════════════════════════════════════════════════
local Page = {}
Page.__index = Page

function Page.new(tab, options)
	options = type(options) == "string" and { Name = options } or (options or {})
	local self = setmetatable({}, Page)
	self.Tab = tab
	self.Window = tab.Window
	self.Name = options.Name or tab.Name
	self.Icon = options.Icon
	self.Description = options.Description
	self.Hidden = options.Hidden == true
	self.Implicit = options.Implicit == true
	self.Columns = options.Columns or 2
	self.Sections = {}
	self.Selected = Signal.new()
	self._order = 0
	return self
end

function Page:Section(options)
	local section = Section.new(self, options)
	self._order += 1
	section.Order = self._order
	table.insert(self.Sections, section)
	return section
end
Page.AddSection = Page.Section
Page.DrawSection = Page.Section
Page.CreateSection = Page.Section

-- Shortcuts so a page behaves like a tab.
function Page:LeftSection(options)
	options = type(options) == "string" and { Name = options } or (options or {})
	options.Side = "Left"
	return self:Section(options)
end
function Page:RightSection(options)
	options = type(options) == "string" and { Name = options } or (options or {})
	options.Side = "Right"
	return self:Section(options)
end
function Page:FullSection(options)
	options = type(options) == "string" and { Name = options } or (options or {})
	options.Side = "Full"
	return self:Section(options)
end

function Page:_ensureMounted()
	if self._mounted then
		return
	end
	self._mounted = true
	local window = self.Window
	local scroller = Util.New("ScrollingFrame", {
		Name = "Page_" .. self.Name,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		Visible = window.CurrentPage == self,
		Parent = window.Content,
	})
	Theme.Paint(scroller, { ScrollBarImageColor3 = "StrokeHi" })
	local remember = Util.Debounce(0.8, function()
		if window.State == "Ready" then
			Shared.Lib:SetSetting(window:_scrollKey(self), math.floor(scroller.CanvasPosition.Y))
		end
	end)
	scroller:GetPropertyChangedSignal("CanvasPosition"):Connect(remember)
	Util.Padding(scroller, 12, 12, 14, 12)
	Util.List(scroller, 10)
	self.Frame = scroller

	local full = Util.New("Frame", { Name = "Full", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 1, Parent = scroller })
	Util.List(full, 10)
	local row = Util.New("Frame", { Name = "Columns", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 2, Parent = scroller })
	local left = Util.New("Frame", { Name = "Left", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(0.5, -5, 0, 0), Parent = row })
	Util.List(left, 10)
	local right = Util.New("Frame", { Name = "Right", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(0.5, -5, 0, 0), Position = UDim2.new(0.5, 5, 0, 0), Parent = row })
	Util.List(right, 10)
	self._full, self._left, self._right, self._row = full, left, right, row
	self:_layoutColumns()
end

-- Two columns on wide windows, one on narrow ones (and on Columns = 1).
function Page:_layoutColumns()
	if not self._row then
		return
	end
	local width = self.Window.Content.AbsoluteSize.X / math.max(Shared.Scale or 1, 0.01)
	local single = self.Columns == 1 or width < 520
	if single then
		self._left.Size = UDim2.new(1, 0, 0, 0)
		self._right.Size = UDim2.new(1, 0, 0, 0)
		self._right.Position = UDim2.new(0, 0, 0, 0)
		-- stack right under left
		if not self._stack then
			self._stack = Util.List(self._row, 10)
		end
		self._right.LayoutOrder = 2
		self._left.LayoutOrder = 1
	else
		if self._stack then
			self._stack:Destroy()
			self._stack = nil
		end
		self._left.Size = UDim2.new(0.5, -5, 0, 0)
		self._right.Size = UDim2.new(0.5, -5, 0, 0)
		self._right.Position = UDim2.new(0.5, 5, 0, 0)
	end
end

function Page:_column(side)
	self:_ensureMounted()
	if side == "Right" then
		return self._right
	elseif side == "Full" then
		return self._full
	end
	return self._left
end

function Page:Select()
	self.Window:_selectPage(self)
	return self
end
Page.Open = Page.Select

function Page:IsSelected(): boolean
	return self.Window.CurrentPage == self
end

function Page:ScrollTo(gui)
	if not self.Frame or not gui then
		return
	end
	local s = Shared.Scale or 1
	local y = (gui.AbsolutePosition.Y - self.Frame.AbsolutePosition.Y) / s + self.Frame.CanvasPosition.Y - 24
	Tween.Play(self.Frame, { CanvasPosition = Vector2.new(0, math.max(0, y)) }, 0.3)
end

function Page:GetSections()
	return table.clone(self.Sections)
end

-- ═══ Tab ══════════════════════════════════════════════════════════════════
local Tab = {}
Tab.__index = Tab

function Tab.new(window, options)
	options = type(options) == "string" and { Name = options } or (options or {})
	local self = setmetatable({}, Tab)
	self.Window = window
	self.Name = options.Name or options.Title or "Tab"
	self.Icon = options.Icon
	self.Description = options.Description or options.Desc
	self.Badge = options.Badge
	self.Visible = options.Visible ~= false
	self.Pages = {}
	self.Selected = Signal.new()
	self.Order = options.Order
	-- loading progress (driven by the window scheduler)
	self._total, self._done = 0, 0
	return self
end

function Tab:_defaultPage()
	if not self.Pages[1] then
		local page = Page.new(self, { Name = self.Name, Implicit = true, Columns = self.Columns })
		table.insert(self.Pages, page)
	end
	return self.Pages[1]
end

function Tab:Section(options)
	return self:_defaultPage():Section(options)
end
Tab.AddSection = Tab.Section
Tab.DrawSection = Tab.Section
Tab.CreateSection = Tab.Section
function Tab:LeftSection(o)
	return self:_defaultPage():LeftSection(o)
end
function Tab:RightSection(o)
	return self:_defaultPage():RightSection(o)
end
function Tab:FullSection(o)
	return self:_defaultPage():FullSection(o)
end

--[[
	Tab:SubTab({ Name, Icon })               -- pill under the title
	Tab:SubPage({ Name, Hidden = true })     -- reachable via Section:Navigate
]]
function Tab:SubTab(options)
	options = type(options) == "string" and { Name = options } or (options or {})
	-- the first explicit sub tab replaces an empty implicit page
	local first = self.Pages[1]
	if first and first.Implicit and #first.Sections == 0 and not options.Hidden then
		table.remove(self.Pages, 1)
	end
	local page = Page.new(self, options)
	table.insert(self.Pages, page)
	if self.Window.CurrentTab == self then
		self.Window:_refreshPills()
	end
	return page
end
Tab.SubPage = Tab.SubTab
Tab.AddSubTab = Tab.SubTab
Tab.Page = Tab.SubTab

function Tab:GetPage(name)
	for _, page in self.Pages do
		if page.Name == name then
			return page
		end
	end
	return nil
end

function Tab:Select()
	self.Window:SelectTab(self)
	return self
end
Tab.Open = Tab.Select

function Tab:IsSelected(): boolean
	return self.Window.CurrentTab == self
end

function Tab:SetName(name)
	self.Name = name
	if self._label then
		self._label.Text = name
	end
	if self:IsSelected() then
		self.Window:_refreshHeader()
	end
	return self
end

function Tab:SetIcon(icon)
	self.Icon = icon
	if self._icon then
		self._icon.Image = Icons.Get(icon) or ""
	end
	return self
end

function Tab:SetDescription(text)
	self.Description = text
	if self:IsSelected() then
		self.Window:_refreshHeader()
	end
	return self
end

function Tab:SetBadge(text)
	self.Badge = text
	if self._badge then
		self._badge.Visible = text ~= nil and text ~= ""
		self._badge.Text = text and tostring(text) or ""
	end
	return self
end

function Tab:SetVisible(visible)
	self.Visible = visible
	if self.Button then
		self.Button.Visible = visible
	end
	return self
end

function Tab:GetSections()
	local out = {}
	for _, page in self.Pages do
		for _, s in page.Sections do
			table.insert(out, s)
		end
	end
	return out
end

function Tab:GetElements()
	local out = {}
	for _, s in self:GetSections() do
		for _, el in s:AllElements() do
			table.insert(out, el)
		end
	end
	return out
end

function Tab:Destroy()
	for _, s in self:GetSections() do
		s:Destroy()
	end
	for _, page in self.Pages do
		if page.Frame then
			page.Frame:Destroy()
		end
	end
	if self.Button then
		self.Button:Destroy()
	end
	local tabs = self.Window.Tabs
	local i = table.find(tabs, self)
	if i then
		table.remove(tabs, i)
	end
	if self.Window.CurrentTab == self and tabs[1] then
		self.Window:SelectTab(tabs[1])
	end
end

return { Page = Page, Tab = Tab }
