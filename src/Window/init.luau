--!nocheck
--[[
	Proximity · Window
	The window chrome, navigation, build scheduler and loading lifecycle.

	Lifecycle
	  Loading  → the skeleton is on screen; elements are declared instantly
	             (state only) and mounted by the scheduler with a 4 ms/frame
	             budget, tab by tab, while each tab's progress fills.
	  Ready    → declarations went quiet (AutoReady) or Window:Ready() was
	             called, every Task is done, the auto-load config is applied;
	             the skeleton cross-fades into the finished UI.
]]

local Util = require("../Core/Util")
local Signal = require("../Core/Signal")
local Maid = require("../Core/Maid")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")
local Keys = require("../Core/Keys")
local Theme = require("../Theme")
local Icons = require("../Icons")
local Locale = require("../Locale")
local Shared = require("../Shared")
local PageModule = require("./Page")
local Skeleton = require("./Skeleton")

local UIS = Env.Service("UserInputService")
local RunService = Env.Service("RunService")
local Players = Env.Service("Players")

local Tab = PageModule.Tab

local Window = {}
Window.__index = Window

local DEFAULT_SIZE = Vector2.new(740, 500)
local MOBILE_SIZE = Vector2.new(600, 380)

function Window.new(Lib, options)
	options = options or {}
	local self = setmetatable({}, Window)
	self.Library = Lib
	self.Options = options
	self.Title = Util.Opt(options, "Title", "Name") or "Proximity"
	self.Subtitle = Util.Opt(options, "Subtitle", "SubTitle", "SubName", "Description") or ("v" .. Lib.Version)
	self.Logo = Util.Opt(options, "Logo", "Icon")
	self.Keybind = Keys.Normalize(Util.Opt(options, "Keybind", "MenuKey", "Key") or "RightShift")
	self.SidebarWidth = options.SidebarWidth or 196
	local touch = UIS.TouchEnabled and not UIS.KeyboardEnabled
	local size = options.Size
	if typeof(size) == "UDim2" then
		size = Vector2.new(size.X.Offset, size.Y.Offset)
	end
	self.BaseSize = size or (touch and MOBILE_SIZE or DEFAULT_SIZE)
	self.MinSize = options.MinSize or Vector2.new(560, 360)
	self.Loading = type(options.Loading) == "table" and options.Loading or { Enabled = options.Loading ~= false }
	self.Loading.Enabled = self.Loading.Enabled ~= false
	self.Loading.MinTime = self.Loading.MinTime or 0.6
	self.AutoReady = options.AutoReady ~= false
	self.Tabs = {}
	self.State = "Loading"
	self.Maid = Maid.new()
	self.Ready = Signal.new()
	self.Opened = Signal.new()
	self.Closed = Signal.new()
	self.TabChanged = Signal.new()
	self.PageChanged = Signal.new()
	self._queue = {}
	self._tasks = {}
	self._declaring = true
	self._lastDeclare = os.clock()
	self._navOrder = 0
	self._history = {}
	self._isOpen = false
	self._commands = {}
	self.Touch = touch
	self:_build()
	if self.Loading.Enabled then
		self.Skeleton = Skeleton.new(self)
	end
	self:SetScale(options.Scale or Lib:GetSetting("Scale", "Auto"))
	self:Open()
	self:_bindInput()
	task.defer(function()
		self:_pump()
	end)
	return self
end

-- ═══ Chrome ═══════════════════════════════════════════════════════════════

function Window:_drawLogo(parent, size)
	local logo = Icons.Get(self.Logo)
	if logo then
		local img = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = logo, Size = UDim2.fromOffset(size, size), ScaleType = Enum.ScaleType.Crop, Parent = parent })
		Util.Round(img)
		return img
	end
	-- vector "eclipse": dark disc, white rim brightest at the top-right,
	-- a thin ring and a small flare — the Proximity mark.
	local holder = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(size, size), Parent = parent })
	local disc = Util.New("Frame", { Size = UDim2.fromScale(0.78, 0.78), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Parent = holder })
	Util.Round(disc)
	Theme.Paint(disc, { BackgroundColor3 = "Bg" })
	local rim = Util.Stroke(disc, nil, math.max(1.2, size / 18))
	Theme.Paint(rim, { Color = "Accent" })
	Util.Gradient(rim, nil, NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.45, 0.15),
		NumberSequenceKeypoint.new(0.75, 0.85),
		NumberSequenceKeypoint.new(1, 1),
	}), -45)
	local ring = Util.New("Frame", { Size = UDim2.new(1.25, 0, 0, 1), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.56), Rotation = -14, BorderSizePixel = 0, Parent = holder })
	Theme.Paint(ring, { BackgroundColor3 = "Accent" })
	Util.Gradient(ring, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0.7), NumberSequenceKeypoint.new(0.5, 0.95), NumberSequenceKeypoint.new(0.8, 0.3), NumberSequenceKeypoint.new(1, 1) }))
	local flare = Util.New("Frame", { Size = UDim2.fromOffset(math.max(3, size / 7), math.max(3, size / 7)), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.77, 0.2), Parent = holder })
	Util.Round(flare)
	Theme.Paint(flare, { BackgroundColor3 = "Accent" })
	return holder
end

function Window:_build()
	local Lib = self.Library
	local gui = Shared.Gui
	local view = workspace.CurrentCamera.ViewportSize
	local saved = Lib:GetSetting("Window." .. self.Title)
	local size = self.BaseSize
	if type(saved) == "table" and saved.W then
		size = Vector2.new(math.max(saved.W, self.MinSize.X), math.max(saved.H, self.MinSize.Y))
	end
	self.Size = size

	local holder = Util.New("Frame", {
		Name = "Window_" .. self.Title,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = (type(saved) == "table" and saved.X) and UDim2.fromOffset(saved.X, saved.Y) or UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(size.X, size.Y),
		Active = true,
		Parent = gui.Windows,
	})
	self.Holder = holder
	self._uiScale = Util.New("UIScale", { Parent = holder })
	self._openScale = Util.New("UIScale", { Parent = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(), Parent = holder }) })

	local plate = Util.New("Frame", { Name = "Plate", Size = UDim2.fromScale(1, 1), Parent = holder })
	Util.Corner(10, plate)
	Theme.Paint(plate, { BackgroundColor3 = "Bg" })
	Shared.Overlay.Shadow(plate, 0.35, 28)
	self.Plate = plate

	local canvas = Util.New("CanvasGroup", { Name = "Canvas", Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = holder })
	Util.Corner(10, canvas)
	Theme.Paint(canvas, { BackgroundColor3 = "Bg" })
	self.Canvas = canvas

	-- border + animated eclipse rim
	local border = Util.New("Frame", { Name = "Border", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = holder })
	Util.Corner(10, border)
	local borderStroke = Util.Stroke(border)
	Theme.Paint(borderStroke, { Color = "Stroke" })
	local rimFrame = Util.New("Frame", { Name = "Rim", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 6, Parent = holder })
	Util.Corner(10, rimFrame)
	local rim = Util.Stroke(rimFrame, nil, 1.2)
	Theme.Paint(rim, { Color = "Accent" })
	local rimGradient = Util.Gradient(rim, nil, NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.4, 1),
		NumberSequenceKeypoint.new(0.5, 0.1),
		NumberSequenceKeypoint.new(0.6, 1),
		NumberSequenceKeypoint.new(1, 1),
	}))
	self._border, self._borderStroke, self._rim, self._rimGradient = border, borderStroke, rim, rimGradient
	self.RimEnabled = Lib:GetSetting("Rim", true)
	self.Maid:Connect(RunService.Heartbeat, function()
		if self._isOpen and self.RimEnabled and Tween.Speed > 0 then
			rimGradient.Rotation = (os.clock() * 24) % 360
		end
	end)

	-- top highlight line
	local top = Util.New("Frame", { Name = "TopLine", Size = UDim2.new(0.6, 0, 0, 1), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0), BorderSizePixel = 0, ZIndex = 7, Parent = canvas })
	Theme.Paint(top, { BackgroundColor3 = "Accent" })
	Util.Gradient(top, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.55), NumberSequenceKeypoint.new(1, 1) }))

	self:_buildBackdrop()
	self:_buildSidebar()
	self:_buildMain()
	self:_buildResize()
	self:_buildBubble()

	-- mouse unlock while open (first-person games)
	self._modal = Util.New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 0), Modal = true, Visible = false, Parent = holder })

	self.Maid:Connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
		if self._autoScale then
			self:SetScale("Auto")
		end
		self:_clampPosition()
	end)
	self.Maid:Give(holder)
end

-- ─── Backdrop (subtle star field / grid / dots behind the content) ───────

function Window:_buildBackdrop()
	local layer = Util.New("Frame", { Name = "Backdrop", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 1, Parent = self.Canvas })
	self._backdrop = layer
	self:SetBackdrop(self.Options.Backdrop or self.Library:GetSetting("Backdrop", "Stars"))
end

function Window:SetBackdrop(pattern)
	local spec = type(pattern) == "table" and pattern or { Pattern = pattern }
	local layer = self._backdrop
	for _, c in layer:GetChildren() do
		c:Destroy()
	end
	if self._backdropConn then
		self._backdropConn:Disconnect()
		self._backdropConn = nil
	end
	self.BackdropPattern = spec.Pattern or "None"
	local alpha = spec.Transparency or 0.9
	local rng = Random.new(7)
	if spec.Pattern == "Stars" then
		local stars = {}
		for i = 1, 46 do
			local s = rng:NextNumber() < 0.15 and 2 or 1
			local star = Util.New("Frame", { Size = UDim2.fromOffset(s, s), Position = UDim2.fromScale(rng:NextNumber(), rng:NextNumber()), BorderSizePixel = 0, BackgroundTransparency = alpha, ZIndex = 1, Parent = layer })
			Theme.Paint(star, { BackgroundColor3 = "Accent" })
			table.insert(stars, { star, rng:NextNumber() * 6, 0.6 + rng:NextNumber() * 1.4 })
		end
		self._backdropConn = RunService.Heartbeat:Connect(function()
			if not self._isOpen or Tween.Speed == 0 then
				return
			end
			local t = os.clock()
			for _, item in stars do
				item[1].BackgroundTransparency = alpha + (1 - alpha) * (0.5 + 0.5 * math.sin(t * item[3] + item[2])) * 0.9
			end
		end)
		self.Maid:Give(self._backdropConn)
	elseif spec.Pattern == "Grid" then
		for i = 1, 40 do
			local v = Util.New("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.fromOffset(i * 32, 0), BorderSizePixel = 0, BackgroundTransparency = 0.96, ZIndex = 1, Parent = layer })
			Theme.Paint(v, { BackgroundColor3 = "Accent" })
		end
		for i = 1, 30 do
			local h = Util.New("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.fromOffset(0, i * 32), BorderSizePixel = 0, BackgroundTransparency = 0.96, ZIndex = 1, Parent = layer })
			Theme.Paint(h, { BackgroundColor3 = "Accent" })
		end
	elseif spec.Pattern == "Dots" then
		for x = 0, 36 do
			for y = 0, 24 do
				local d = Util.New("Frame", { Size = UDim2.fromOffset(1, 1), Position = UDim2.fromOffset(12 + x * 26, 12 + y * 26), BorderSizePixel = 0, BackgroundTransparency = 0.82, ZIndex = 1, Parent = layer })
				Theme.Paint(d, { BackgroundColor3 = "TextMute" })
			end
		end
	end
	return self
end

-- ─── Sidebar ─────────────────────────────────────────────────────────────

function Window:_buildSidebar()
	local Lib = self.Library
	local side = Util.New("Frame", { Name = "Sidebar", Size = UDim2.new(0, self.SidebarWidth, 1, 0), BorderSizePixel = 0, ZIndex = 2, Parent = self.Canvas })
	Theme.Paint(side, { BackgroundColor3 = "Bg2" })
	side.BackgroundTransparency = 0.15
	local divider = Util.New("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BorderSizePixel = 0, ZIndex = 3, Parent = side })
	Theme.Paint(divider, { BackgroundColor3 = "Stroke" })
	self.Sidebar = side

	-- brand (drag handle)
	local brand = Util.New("Frame", { Name = "Brand", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 62), ZIndex = 3, Parent = side })
	local logo = self:_drawLogo(brand, 26)
	logo.Position = UDim2.fromOffset(16, 18)
	local title = Util.Label({ Text = self.Title, FontFace = Theme.Fonts.Bold, TextSize = 15, Size = UDim2.new(1, -60, 0, 18), Position = UDim2.fromOffset(52, 16), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3, Parent = brand })
	Theme.Paint(title, { TextColor3 = "Text" })
	local sub = Util.Label({ Text = self.Subtitle, FontFace = Theme.Fonts.Regular, TextSize = 11, Size = UDim2.new(1, -60, 0, 14), Position = UDim2.fromOffset(52, 34), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3, Parent = brand })
	Theme.Paint(sub, { TextColor3 = "TextMute" })
	self._titleLabel, self._subLabel, self._brand = title, sub, brand
	self:_makeDraggable(brand)

	-- search button
	local search = Util.New("TextButton", { Name = "Search", Text = "", AutoButtonColor = false, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.fromOffset(10, 64), ZIndex = 3, Parent = side })
	Util.Corner(6, search)
	Theme.Paint(search, { BackgroundColor3 = "Surface" })
	local searchStroke = Util.Stroke(search)
	Theme.Paint(searchStroke, { Color = "Stroke" })
	local sIcon = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get("search") or "", Size = UDim2.fromOffset(13, 13), Position = UDim2.new(0, 10, 0.5, -6), ZIndex = 3, Parent = search })
	Theme.Paint(sIcon, { ImageColor3 = "TextMute" })
	local sText = Util.Label({ Text = Locale.T("Search"), FontFace = Theme.Fonts.Regular, TextSize = 12, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.fromOffset(30, 0), ZIndex = 3, Parent = search })
	Theme.Paint(sText, { TextColor3 = "TextMute" })
	local kbd = Util.Label({ Text = "Ctrl K", FontFace = Theme.Fonts.Mono, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, -10, 1, 0), ZIndex = 3, Parent = search })
	Theme.Paint(kbd, { TextColor3 = "TextMute" })
	search.MouseEnter:Connect(function()
		Theme.Paint(searchStroke, { Color = "StrokeHi" }, 0.1)
	end)
	search.MouseLeave:Connect(function()
		Theme.Paint(searchStroke, { Color = "Stroke" }, 0.1)
	end)
	search.Activated:Connect(function()
		self:OpenSearch()
	end)
	self._searchText = sText

	-- tab list
	local profileH = self.Options.Profile == false and 0 or 56
	local list = Util.New("ScrollingFrame", {
		Name = "Tabs",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -104 - profileH),
		Position = UDim2.fromOffset(0, 102),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		ZIndex = 3,
		Parent = side,
	})
	Util.Padding(list, 4, 10, 8, 10)
	Util.List(list, 2)
	self.TabList = list

	if profileH > 0 then
		self:_buildProfile(side)
	end
	Locale.Changed:Connect(function()
		sText.Text = Locale.T("Search")
	end)
end

function Window:_buildProfile(side)
	local Lib = self.Library
	local card = Util.New("Frame", { Name = "Profile", Size = UDim2.new(1, -20, 0, 44), Position = UDim2.new(0, 10, 1, -52), ZIndex = 3, Parent = side })
	Util.Corner(8, card)
	Theme.Paint(card, { BackgroundColor3 = "Surface" })
	Theme.Paint(Util.Stroke(card), { Color = "Stroke" })
	local avatar = Util.New("ImageLabel", { Size = UDim2.fromOffset(28, 28), Position = UDim2.new(0, 8, 0.5, -14), ZIndex = 3, Parent = card })
	Util.Round(avatar)
	Theme.Paint(avatar, { BackgroundColor3 = "Surface3" })
	local q = Util.Label({ Text = "?", FontFace = Theme.Fonts.Bold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 4, Parent = avatar })
	Theme.Paint(q, { TextColor3 = "TextDim" })
	local name = Util.Label({ FontFace = Theme.Fonts.SemiBold, TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -52, 0, 15), Position = UDim2.fromOffset(44, 7), ZIndex = 3, Parent = card })
	Theme.Paint(name, { TextColor3 = "Text" })
	local status = Util.Label({ FontFace = Theme.Fonts.Regular, TextSize = 10, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -52, 0, 13), Position = UDim2.fromOffset(44, 23), ZIndex = 3, Parent = card })
	Theme.Paint(status, { TextColor3 = "TextMute" })
	local function refresh()
		local id = Lib:GetIdentity()
		name.Text = id.DisplayName
		status.Text = self.Options.Status or Lib.Status or ("@" .. id.Name)
		avatar.Image = id.Avatar or ""
		q.Visible = id.Avatar == nil
	end
	self._refreshProfile = refresh
	Lib.IdentityChanged:Connect(refresh)
	refresh()
end

-- Category label in the sidebar: Window:Category("Main")
function Window:Category(name)
	if type(name) == "table" then
		name = name.Name or name[1]
	end
	self._navOrder += 1
	local label = Util.Label({ Text = string.upper(tostring(name)), FontFace = Theme.Fonts.Bold, TextSize = 10, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = self._navOrder, ZIndex = 3, Parent = self.TabList })
	Util.Padding(label, 8, 0, 0, 8)
	Theme.Paint(label, { TextColor3 = "TextMute" })
	return label
end
Window.Divider = Window.Category
Window.Group = Window.Category
Window.DrawCategory = Window.Category
Window.AddTabDivider = Window.Category

function Window:Tab(options)
	local tab = Tab.new(self, options)
	table.insert(self.Tabs, tab)
	self._navOrder += 1
	tab.Order = tab.Order or self._navOrder
	self:_buildTabButton(tab)
	if self.Skeleton and not tab.Hidden then
		self.Skeleton:AddTab(tab)
	end
	if not self.CurrentTab then
		self:SelectTab(tab)
	end
	self._lastDeclare = os.clock()
	return tab
end
Window.AddTab = Window.Tab
Window.DrawTab = Window.Tab
Window.CreateTab = Window.Tab
Window.Page = Window.Tab

function Window:_buildTabButton(tab)
	local button = Util.New("TextButton", { Name = "Tab_" .. tab.Name, Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), LayoutOrder = tab.Order, Visible = tab.Visible, ZIndex = 3, Parent = self.TabList })
	Util.Corner(6, button)
	Theme.Paint(button, { BackgroundColor3 = "Surface2" })
	local bar = Util.New("Frame", { Size = UDim2.fromOffset(2, 0), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), BorderSizePixel = 0, ZIndex = 4, Parent = button })
	Util.Round(bar)
	Theme.Paint(bar, { BackgroundColor3 = "Accent" })
	local icon = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get(tab.Icon) or "", Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 10, 0.5, -8), ZIndex = 4, Parent = button })
	local hasIcon = Icons.Get(tab.Icon) ~= nil
	local label = Util.Label({ Text = tab.Name, FontFace = Theme.Fonts.Medium, TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.fromOffset(hasIcon and 34 or 12, 0), ZIndex = 4, Parent = button })
	local badge = Util.Label({ Text = tab.Badge and tostring(tab.Badge) or "", FontFace = Theme.Fonts.Bold, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Center, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 16), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Visible = tab.Badge ~= nil, BackgroundTransparency = 0, ZIndex = 4, Parent = button })
	Util.Padding(badge, 0, 5, 0, 5)
	Util.Corner(4, badge)
	Theme.Paint(badge, { BackgroundColor3 = "Accent", TextColor3 = "AccentInk" })
	tab.Button, tab._icon, tab._label, tab._bar, tab._badge = button, icon, label, bar, badge
	button.MouseEnter:Connect(function()
		if self.CurrentTab ~= tab then
			Tween.Play(button, { BackgroundTransparency = 0.6 }, 0.12)
			Theme.Paint(label, { TextColor3 = "Text" }, 0.12)
		end
	end)
	button.MouseLeave:Connect(function()
		if self.CurrentTab ~= tab then
			Tween.Play(button, { BackgroundTransparency = 1 }, 0.15)
			Theme.Paint(label, { TextColor3 = "TextDim" }, 0.15)
		end
	end)
	button.Activated:Connect(function()
		self:SelectTab(tab)
	end)
	self:_paintTab(tab, false)
end

function Window:_paintTab(tab, animate)
	local on = self.CurrentTab == tab
	local t = animate and 0.18 or 0
	if not tab.Button then
		return
	end
	Tween.Play(tab.Button, { BackgroundTransparency = on and 0 or 1 }, t)
	Theme.Paint(tab._label, { TextColor3 = on and "Text" or "TextDim" }, t)
	Theme.Paint(tab._icon, { ImageColor3 = on and "Accent" or "TextMute" }, t)
	Tween.Play(tab._bar, { Size = UDim2.fromOffset(2, on and 16 or 0) }, on and 0.3 or 0.15, on and Enum.EasingStyle.Back or Enum.EasingStyle.Quint)
end

-- ─── Main area ───────────────────────────────────────────────────────────

function Window:_buildMain()
	local main = Util.New("Frame", { Name = "Main", BackgroundTransparency = 1, Size = UDim2.new(1, -self.SidebarWidth, 1, 0), Position = UDim2.fromOffset(self.SidebarWidth, 0), ZIndex = 2, Parent = self.Canvas })
	self.Main = main

	local header = Util.New("Frame", { Name = "Header", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 56), ZIndex = 3, Parent = main })
	self.Header = header
	self:_makeDraggable(header)
	local back = Util.New("ImageButton", { BackgroundTransparency = 1, Image = Icons.Get("arrow-left") or "", Size = UDim2.fromOffset(18, 18), Position = UDim2.new(0, 16, 0.5, -9), Visible = false, ZIndex = 4, Parent = header })
	Theme.Paint(back, { ImageColor3 = "TextDim" })
	back.Activated:Connect(function()
		self:Back()
	end)
	local title = Util.Label({ FontFace = Theme.Fonts.SemiBold, TextSize = 17, Size = UDim2.new(1, -260, 0, 20), Position = UDim2.fromOffset(18, 10), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4, Parent = header })
	Theme.Paint(title, { TextColor3 = "Text" })
	local desc = Util.Label({ FontFace = Theme.Fonts.Regular, TextSize = 11, Size = UDim2.new(1, -260, 0, 14), Position = UDim2.fromOffset(18, 31), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4, Parent = header })
	Theme.Paint(desc, { TextColor3 = "TextMute" })
	self._back, self._title, self._desc = back, title, desc

	-- right-side buttons
	local actions = Util.New("Frame", { BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 0), ZIndex = 4, Parent = header })
	Util.List(actions, 6, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
	self._actions = actions
	if self.Options.ConfigButton ~= false then
		self:_buildConfigChip(actions)
	end
	self._homeButton = self:_headerButton("home", 10, function()
		if self.HomeTab then
			self.HomeTab:Select()
		end
	end)
	self._homeButton.Visible = false
	self._settingsButton = self:_headerButton("settings", 11, function()
		if self.SettingsTabRef then
			self.SettingsTabRef:Select()
		end
	end)
	self._settingsButton.Visible = false
	self:_headerButton("minus", 20, function()
		self:Close()
	end)

	local line = Util.New("Frame", { Size = UDim2.new(1, -24, 0, 1), Position = UDim2.new(0, 12, 1, -1), BorderSizePixel = 0, ZIndex = 3, Parent = header })
	Theme.Paint(line, { BackgroundColor3 = "Stroke" })

	-- sub tab pills
	local pills = Util.New("Frame", { Name = "Pills", BackgroundTransparency = 1, Size = UDim2.new(1, -24, 0, 34), Position = UDim2.fromOffset(12, 60), Visible = false, ZIndex = 3, Parent = main })
	Util.List(pills, 6, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
	self._pills = pills

	local content = Util.New("Frame", { Name = "Content", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -58), Position = UDim2.fromOffset(0, 58), ClipsDescendants = true, ZIndex = 2, Parent = main })
	self.Content = content
	content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		for _, tab in self.Tabs do
			for _, page in tab.Pages do
				page:_layoutColumns()
			end
		end
	end)
end

function Window:_headerButton(icon, order, callback)
	local b = Util.New("ImageButton", { BackgroundTransparency = 1, Size = UDim2.fromOffset(30, 30), LayoutOrder = order, ZIndex = 4, Parent = self._actions })
	Util.Corner(6, b)
	Theme.Paint(b, { BackgroundColor3 = "Surface2" })
	local stroke = Util.Stroke(b)
	stroke.Transparency = 1
	Theme.Paint(stroke, { Color = "Stroke" })
	local img = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get(icon) or "", Size = UDim2.fromOffset(15, 15), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 5, Parent = b })
	Theme.Paint(img, { ImageColor3 = "TextDim" })
	b.MouseEnter:Connect(function()
		Tween.Play(b, { BackgroundTransparency = 0 }, 0.1)
		Tween.Play(stroke, { Transparency = 0 }, 0.1)
		Theme.Paint(img, { ImageColor3 = "Text" }, 0.1)
	end)
	b.MouseLeave:Connect(function()
		Tween.Play(b, { BackgroundTransparency = 1 }, 0.15)
		Tween.Play(stroke, { Transparency = 1 }, 0.15)
		Theme.Paint(img, { ImageColor3 = "TextDim" }, 0.15)
	end)
	b.Activated:Connect(callback)
	return b
end

-- Current config chip: click the name for the quick list, the disk saves.
function Window:_buildConfigChip(parent)
	local Lib = self.Library
	local chip = Util.New("Frame", { Name = "Config", AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 30), LayoutOrder = 1, ZIndex = 4, Parent = parent })
	Util.Corner(6, chip)
	Theme.Paint(chip, { BackgroundColor3 = "Surface" })
	Theme.Paint(Util.Stroke(chip), { Color = "Stroke" })
	Util.List(chip, 0, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
	local save = Util.New("ImageButton", { BackgroundTransparency = 1, Size = UDim2.fromOffset(30, 30), LayoutOrder = 1, ZIndex = 5, Parent = chip })
	local saveIcon = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get("save") or "", Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 5, Parent = save })
	Theme.Paint(saveIcon, { ImageColor3 = "TextDim" })
	local nameButton = Util.New("TextButton", { Text = "", FontFace = Theme.Fonts.Medium, TextSize = 12, AutoButtonColor = false, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 30), LayoutOrder = 2, ZIndex = 5, Parent = chip })
	Util.Padding(nameButton, 0, 12, 0, 2)
	Theme.Paint(nameButton, { TextColor3 = "Text" })
	local dirty = Util.New("Frame", { Size = UDim2.fromOffset(5, 5), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -5, 0, 7), Visible = false, ZIndex = 6, Parent = save })
	Util.Round(dirty)
	Theme.Paint(dirty, { BackgroundColor3 = "Accent" })
	local function refresh()
		nameButton.Text = Lib.CurrentConfig or "default"
		dirty.Visible = Lib.Dirty == true
	end
	Lib.ConfigsChanged:Connect(refresh)
	Lib.ConfigLoaded:Connect(refresh)
	Lib.DirtyChanged:Connect(refresh)
	refresh()
	Shared.Overlay.Hover(save, function()
		return Locale.T("Save") .. " · Ctrl+S"
	end)
	save.Activated:Connect(function()
		Lib:QuickSave(self)
	end)
	nameButton.Activated:Connect(function()
		local items = {}
		for _, name in Lib:ListConfigs() do
			table.insert(items, {
				Text = name,
				Icon = name == Lib.CurrentConfig and "check" or "file",
				Callback = function()
					Lib:LoadConfig(name)
					Lib.CurrentConfig = name
					Lib:_setDirty(false)
					Lib:Notify({ Title = Locale.T("Loaded"), Content = name, Type = "success", Duration = 2.5 })
				end,
			})
		end
		if #items == 0 then
			table.insert(items, { Text = Locale.T("Empty") })
		end
		table.insert(items, { Separator = true })
		table.insert(items, { Text = Locale.T("Save") .. "…", Icon = "save", Callback = function()
			task.spawn(function()
				local name = self:Prompt({ Title = Locale.T("Save"), Placeholder = Locale.T("ConfigName"), Default = Lib.CurrentConfig })
				if name and name ~= "" then
					Lib:SaveConfig(name)
					Lib.CurrentConfig = Util.SafeName(name)
					Lib:_setDirty(false)
					Lib:Notify({ Title = Locale.T("Saved"), Content = Lib.CurrentConfig, Type = "success", Duration = 2.5 })
				end
			end)
		end })
		Shared.Overlay.Menu(items, { Anchor = chip, Align = "End", Width = 200 })
	end)
end

function Window:_buildResize()
	if self.Options.Resizable == false then
		return
	end
	local grip = Util.New("TextButton", { Name = "Resize", Text = "", BackgroundTransparency = 1, Size = UDim2.fromOffset(16, 16), AnchorPoint = Vector2.new(1, 1), Position = UDim2.fromScale(1, 1), ZIndex = 10, Parent = self.Holder })
	local mark = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get("move-diagonal-2") or "", Size = UDim2.fromOffset(10, 10), Position = UDim2.fromOffset(2, 2), ImageTransparency = 0.6, ZIndex = 10, Parent = grip })
	Theme.Paint(mark, { ImageColor3 = "TextMute" })
	local resizing, startMouse, startSize = false, nil, nil
	grip.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing, startMouse, startSize = true, Vector2.new(input.Position.X, input.Position.Y), self.Size
		end
	end)
	self.Maid:Connect(UIS.InputChanged, function(input)
		if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = (Vector2.new(input.Position.X, input.Position.Y) - startMouse) / self:GetScale()
			local w = math.max(self.MinSize.X, math.floor((startSize.X + delta.X) / 8 + 0.5) * 8)
			local h = math.max(self.MinSize.Y, math.floor((startSize.Y + delta.Y) / 8 + 0.5) * 8)
			self:SetSize(Vector2.new(w, h), true)
		end
	end)
	self.Maid:Connect(UIS.InputEnded, function(input)
		if resizing and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			resizing = false
			self:_saveState()
		end
	end)
end

function Window:_makeDraggable(handle)
	if self.Options.Draggable == false then
		return
	end
	local dragging, start, startPos = false, nil, nil
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging, start = true, Vector2.new(input.Position.X, input.Position.Y)
			startPos = self.Holder.AbsolutePosition + self.Holder.AbsoluteSize / 2 - self.Holder.Parent.AbsolutePosition
		end
	end)
	self.Maid:Connect(UIS.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local p = startPos + (Vector2.new(input.Position.X, input.Position.Y) - start)
			self.Holder.Position = UDim2.fromOffset(p.X, p.Y)
			self:_clampPosition()
		end
	end)
	self.Maid:Connect(UIS.InputEnded, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			self:_saveState()
		end
	end)
end

function Window:_clampPosition()
	local holder = self.Holder
	if holder.Position.X.Scale ~= 0 then
		return
	end
	local view = workspace.CurrentCamera.ViewportSize
	local half = holder.AbsoluteSize / 2
	local x = math.clamp(holder.Position.X.Offset, half.X * 0.3, view.X - half.X * 0.3)
	local y = math.clamp(holder.Position.Y.Offset, half.Y * 0.2 + 4, view.Y - half.Y * 0.3)
	holder.Position = UDim2.fromOffset(x, y)
end

function Window:_saveState()
	local p = self.Holder.Position
	self.Library:SetSetting("Window." .. self.Title, {
		X = p.X.Scale == 0 and p.X.Offset or nil,
		Y = p.X.Scale == 0 and p.Y.Offset or nil,
		W = self.Size.X,
		H = self.Size.Y,
		Tab = self.CurrentTab and self.CurrentTab.Name,
	})
end

-- Mobile: floating round button with the logo. Tap toggles the window.
function Window:_buildBubble()
	local want = self.Options.ToggleButton
	if want == nil then
		want = UIS.TouchEnabled
	end
	if not want then
		return
	end
	local bubble = Util.New("TextButton", { Name = "Bubble", Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(46, 46), Position = UDim2.new(0, 20, 0.3, 0), Parent = Shared.Gui.Widgets })
	Util.Round(bubble)
	Theme.Paint(bubble, { BackgroundColor3 = "Bg" })
	Theme.Paint(Util.Stroke(bubble), { Color = "StrokeHi" })
	local logo = self:_drawLogo(bubble, 26)
	logo.AnchorPoint = Vector2.new(0.5, 0.5)
	logo.Position = UDim2.fromScale(0.5, 0.5)
	local moved, start, startPos = false, nil, nil
	bubble.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			moved, start, startPos = false, Vector2.new(input.Position.X, input.Position.Y), bubble.AbsolutePosition - bubble.Parent.AbsolutePosition
		end
	end)
	self.Maid:Connect(UIS.InputChanged, function(input)
		if start and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = Vector2.new(input.Position.X, input.Position.Y) - start
			if d.Magnitude > 6 then
				moved = true
			end
			if moved then
				local view = workspace.CurrentCamera.ViewportSize
				bubble.Position = UDim2.fromOffset(math.clamp(startPos.X + d.X, 4, view.X - 50), math.clamp(startPos.Y + d.Y, 4, view.Y - 50))
			end
		end
	end)
	self.Maid:Connect(UIS.InputEnded, function(input)
		if start and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			if not moved then
				self:Toggle()
			end
			start = nil
		end
	end)
	self.Bubble = bubble
	self.Maid:Give(bubble)
end

-- ═══ Navigation ═══════════════════════════════════════════════════════════

function Window:GetTab(name)
	for _, tab in self.Tabs do
		if tab.Name == name or tab == name then
			return tab
		end
	end
	return nil
end

function Window:GetTabs()
	return table.clone(self.Tabs)
end

function Window:SelectTab(which)
	local tab = type(which) == "table" and which or self:GetTab(which)
	if type(which) == "number" then
		tab = self.Tabs[which]
	end
	if not tab then
		return self
	end
	local page = tab._lastPage
	if not page then
		for _, p in tab.Pages do
			if not p.Hidden then
				page = p
				break
			end
		end
	end
	page = page or tab:_defaultPage()
	self:_selectPage(page)
	return self
end

function Window:_selectPage(page, fromBack)
	local tab = page.Tab
	local previous = self.CurrentPage
	if previous == page then
		return
	end
	if previous and not fromBack and page.Hidden then
		table.insert(self._history, previous)
	elseif not page.Hidden then
		table.clear(self._history)
	end
	local oldTab = self.CurrentTab
	self.CurrentTab, self.CurrentPage = tab, page
	tab._lastPage = not page.Hidden and page or tab._lastPage
	if previous and previous.Frame then
		previous.Frame.Visible = false
	end
	page:_ensureMounted()
	local frame = page.Frame
	frame.Visible = true
	if Tween.Speed > 0 and self.State ~= "Loading" then
		frame.Position = UDim2.fromOffset(0, 8)
		Tween.Play(frame, { Position = UDim2.fromOffset(0, 0) }, 0.25)
	end
	if oldTab ~= tab then
		if oldTab then
			self:_paintTab(oldTab, true)
		end
		self:_paintTab(tab, true)
		self.TabChanged:Fire(tab, oldTab)
		tab.Selected:Fire()
	end
	page.Selected:Fire()
	self.PageChanged:Fire(page, previous)
	self:_refreshHeader()
	if self.State == "Ready" then
		self:_saveState()
	end
end

function Window:Back()
	local last = table.remove(self._history)
	if last then
		self:_selectPage(last, true)
	elseif self.CurrentPage and self.CurrentPage.Hidden then
		self:SelectTab(self.CurrentTab)
	end
	return self
end

function Window:_refreshHeader()
	local tab, page = self.CurrentTab, self.CurrentPage
	if not tab then
		return
	end
	local inner = page and page.Hidden
	self._back.Visible = inner == true
	local x = inner and 42 or 18
	self._title.Position = UDim2.fromOffset(x, (tab.Description or (inner and page.Description)) and 10 or 18)
	self._desc.Position = UDim2.fromOffset(x, 31)
	self._title.Text = inner and (tab.Name .. "  ›  " .. page.Name) or tab.Name
	local d = inner and page.Description or tab.Description
	self._desc.Text = d or ""
	self._desc.Visible = d ~= nil
	self:_refreshPills()
end

function Window:_refreshPills()
	local tab = self.CurrentTab
	for _, c in self._pills:GetChildren() do
		if c:IsA("GuiObject") then
			c:Destroy()
		end
	end
	local visible = {}
	for _, p in tab and tab.Pages or {} do
		if not p.Hidden then
			table.insert(visible, p)
		end
	end
	local show = #visible > 1 and not (self.CurrentPage and self.CurrentPage.Hidden)
	self._pills.Visible = show
	self.Content.Size = UDim2.new(1, 0, 1, show and -96 or -58)
	self.Content.Position = UDim2.fromOffset(0, show and 96 or 58)
	if not show then
		return
	end
	for i, page in visible do
		local on = page == self.CurrentPage
		local pill = Util.New("TextButton", { Text = "", AutoButtonColor = false, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 26), LayoutOrder = i, ZIndex = 4, Parent = self._pills })
		Util.Corner(13, pill)
		Util.Padding(pill, 0, 12, 0, 12)
		Theme.Paint(pill, { BackgroundColor3 = on and "Accent" or "Surface2" })
		local stroke = Util.Stroke(pill)
		Theme.Paint(stroke, { Color = on and "Accent" or "Stroke" })
		local holder = Util.New("Frame", { BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromScale(0, 1), ZIndex = 4, Parent = pill })
		Util.List(holder, 5, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
		local iconId = Icons.Get(page.Icon)
		if iconId then
			local img = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = iconId, Size = UDim2.fromOffset(13, 13), ZIndex = 4, Parent = holder })
			Theme.Paint(img, { ImageColor3 = on and "AccentInk" or "TextDim" })
		end
		local label = Util.Label({ Text = page.Name, FontFace = Theme.Fonts.SemiBold, TextSize = 12, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromScale(0, 1), LayoutOrder = 2, ZIndex = 4, Parent = holder })
		Theme.Paint(label, { TextColor3 = on and "AccentInk" or "TextDim" })
		pill.Activated:Connect(function()
			page:Select()
		end)
	end
end

-- ═══ Build scheduler & loading ════════════════════════════════════════════

function Window:_enqueue(element)
	table.insert(self._queue, element)
	local tab = element.Tab
	if tab then
		tab._total += 1
		if self.Skeleton then
			self.Skeleton:AddTab(tab)
		end
	end
	self._lastDeclare = os.clock()
	if not self._pumping then
		self._pumping = true
		task.defer(function()
			self:_pump()
		end)
	end
end

function Window:_pump()
	self._pumping = true
	local budget = self.Loading.Budget or 0.004
	while #self._queue > 0 and not self._destroyed do
		local start = os.clock()
		while #self._queue > 0 and os.clock() - start < budget do
			local el = table.remove(self._queue, 1)
			if not el._destroyed then
				self._buildingTab = el.Tab
				local ok, err = pcall(function()
					local section = el.Section
					section:_ensureMounted()
					el:_mount(section.Body, el._order)
				end)
				if not ok then
					warn("[Proximity] failed to build '" .. tostring(el.Name) .. "': " .. tostring(err))
					if el.Tab then
						el.Tab._errors = (el.Tab._errors or 0) + 1
					end
				end
			end
			if el.Tab then
				el.Tab._done += 1
			end
		end
		if self.Skeleton then
			local tab = self._buildingTab
			self.Skeleton:Update(tab and (Locale.T("Building") .. " · " .. tab.Name .. "  " .. tab._done .. "/" .. tab._total) or nil)
		end
		task.wait()
	end
	self._buildingTab = nil
	self._pumping = false
	if self.Skeleton then
		self.Skeleton:Update()
	end
	self:_checkReady()
end

function Window:GetLoadProgress(): number
	local total, done = 0, 0
	for _, tab in self.Tabs do
		total += tab._total
		done += tab._done
	end
	-- developer tasks together weigh at least as much as the element work,
	-- otherwise a slow download hides behind hundreds of instant toggles
	local elements = total
	for _, t in self._tasks do
		local weight = math.max(t.Weight, elements / #self._tasks)
		total += weight
		done += weight * (t.Finished and 1 or t.Amount)
	end
	if total == 0 then
		return 0
	end
	return done / total
end

function Window:_checkReady()
	if self.State ~= "Loading" or self._checking then
		return
	end
	local function blocked()
		if #self._queue > 0 then
			return true
		end
		for _, t in self._tasks do
			if not t.Finished then
				return true
			end
		end
		if self._explicitReady then
			return false
		end
		if not self.AutoReady then
			return true
		end
		return os.clock() - self._lastDeclare < 0.2
	end
	if blocked() then
		if self.AutoReady or self._explicitReady then
			self._checking = true
			task.delay(0.1, function()
				self._checking = false
				self:_checkReady()
			end)
		end
		return
	end
	self:_finishLoading()
end

function Window:_finishLoading()
	if self.State ~= "Loading" then
		return
	end
	self.State = "Finishing"
	self._declaring = false
	local Lib = self.Library
	task.spawn(function()
		-- apply the auto-load config while the skeleton still covers the UI
		if self.Options.AutoLoad ~= false and Lib:GetAutoLoad() and not Lib._autoLoaded then
			Lib._autoLoaded = true
			if self.Skeleton then
				self.Skeleton:Update(Locale.T("ApplyingConfig") .. " · " .. Lib:GetAutoLoad())
			end
			Lib:LoadAutoConfig()
			Lib.CurrentConfig = Lib:GetAutoLoad()
		end
		local elapsed = self.Skeleton and (os.clock() - self.Skeleton.Started) or 0
		local wait = (self.Loading.MinTime or 0) - elapsed
		if wait > 0 and Tween.Speed > 0 then
			task.wait(wait)
		end
		self:_reveal()
	end)
end

function Window:_reveal(force)
	if self.State == "Ready" then
		return
	end
	self.State = "Ready"
	self._declaring = false
	local Lib = self.Library
	Lib._autoSaveArmed = true
	-- restore the last tab
	local saved = Lib:GetSetting("Window." .. self.Title)
	if type(saved) == "table" and saved.Tab and not self._restoredTab then
		self._restoredTab = true
		local tab = self:GetTab(saved.Tab)
		if tab then
			self:SelectTab(tab)
		end
	end
	local function rise()
		local page = self.CurrentPage
		if page and page.Frame and Tween.Speed > 0 then
			page.Frame.Position = UDim2.fromOffset(0, 6)
			Tween.Play(page.Frame, { Position = UDim2.fromOffset(0, 0) }, 0.45)
		end
	end
	if self.Skeleton then
		local skeleton = self.Skeleton
		self.Skeleton = nil
		if force then
			skeleton.Stage.Text = Locale.T("Building") .. "…"
		end
		skeleton:Finish(rise)
	else
		rise()
	end
	self.Ready:Fire()
	Lib.WindowReady:Fire(self)
end

-- Explicit "everything is declared" (use with AutoReady = false).
function Window:SetReady()
	self._explicitReady = true
	self:_checkReady()
	return self
end
Window.Finish = Window.SetReady
Window.Init = Window.SetReady

function Window:IsReady(): boolean
	return self.State == "Ready"
end

function Window:OnReady(fn)
	if self.State == "Ready" then
		task.spawn(fn)
		return { Disconnect = function() end }
	end
	return self.Ready:Once(fn)
end

function Window:WaitUntilReady(timeout)
	if self.State ~= "Ready" then
		self.Ready:Wait(timeout)
	end
	return self.State == "Ready"
end

--[[
	A unit of your own loading work shown in the skeleton:
	  local t = Window:Task("Fetching player data", 20)   -- weight (default 10)
	  t:Progress(0.5)  t:SetText("…")  t:Done()  /  t:Fail("reason")
]]
function Window:Task(name, weight)
	local window = self
	local t = { Name = name, Weight = weight or 10, Amount = 0, Finished = false }
	function t:Progress(p)
		self.Amount = math.clamp(p, 0, 1)
		if window.Skeleton then
			window.Skeleton:Update(self.Name .. " · " .. math.floor(self.Amount * 100) .. "%")
		end
		return self
	end
	t.SetProgress = t.Progress
	function t:SetText(text)
		self.Name = text
		if window.Skeleton then
			window.Skeleton:Update(text)
		end
		return self
	end
	function t:Done()
		self.Finished, self.Amount = true, 1
		if window.Skeleton then
			window.Skeleton:Update()
		end
		window:_checkReady()
		return self
	end
	t.Complete = t.Done
	function t:Fail(reason)
		warn("[Proximity] task '" .. tostring(self.Name) .. "' failed: " .. tostring(reason))
		self.Failed = reason
		return self:Done()
	end
	table.insert(self._tasks, t)
	if self.Skeleton then
		self.Skeleton:Update(name)
	end
	return t
end

-- Runs fn(task) in its own thread as a loading step.
function Window:Step(name, fn, weight)
	local t = self:Task(name, weight)
	task.spawn(function()
		local ok, err = pcall(fn, t)
		if ok then
			t:Done()
		else
			t:Fail(err)
		end
	end)
	return t
end

-- ═══ Open / close / scale / size ═════════════════════════════════════════

function Window:Open()
	if self._isOpen then
		return self
	end
	self._isOpen = true
	local holder = self.Holder
	holder.Visible = true
	self._modal.Visible = self.Options.UnlockMouse ~= false
	local canvas = self.Canvas
	canvas.GroupTransparency = 1
	self._openScale.Scale = 1
	local s = self:GetScale()
	self._uiScale.Scale = s * 0.96
	Tween.Play(canvas, { GroupTransparency = self.GlassTransparency or 0 }, 0.25)
	Tween.Play(self._uiScale, { Scale = s }, 0.3, Enum.EasingStyle.Back)
	Tween.Play(self._borderStroke, { Transparency = 0 }, 0.25)
	Tween.Play(self._rim, { Transparency = self.RimEnabled and 0 or 1 }, 0.4)
	Tween.Play(self.Plate, { BackgroundTransparency = self.GlassTransparency or 0 }, 0.25)
	self.Opened:Fire()
	return self
end

function Window:Close()
	if not self._isOpen then
		return self
	end
	self._isOpen = false
	self._modal.Visible = false
	Shared.Overlay.CloseAll()
	Shared.Overlay.HideTooltip()
	local s = self:GetScale()
	Tween.Play(self.Canvas, { GroupTransparency = 1 }, 0.18)
	Tween.Play(self._uiScale, { Scale = s * 0.97 }, 0.18)
	Tween.Play(self._borderStroke, { Transparency = 1 }, 0.18)
	Tween.Play(self._rim, { Transparency = 1 }, 0.18)
	Tween.Play(self.Plate, { BackgroundTransparency = 1 }, 0.18)
	task.delay(Tween.Speed > 0 and 0.19 or 0, function()
		if not self._isOpen and self.Holder then
			self.Holder.Visible = false
		end
	end)
	self.Closed:Fire()
	if self.Options.HiddenHint ~= false and not self._hintShown then
		self._hintShown = true
		self.Library:Notify({ Content = Locale.T("Hidden", Keys.Display(self.Keybind)), Duration = 3 })
	end
	return self
end
Window.Minimize = Window.Close
Window.Hide = Window.Close
Window.Show = Window.Open

function Window:Toggle()
	if self._isOpen then
		return self:Close()
	end
	return self:Open()
end

function Window:SetOpen(open)
	return open and self:Open() or self:Close()
end

function Window:IsOpen(): boolean
	return self._isOpen
end

function Window:SetScale(value)
	if value == "Auto" or value == nil then
		self._autoScale = true
		local view = workspace.CurrentCamera.ViewportSize
		value = math.min(1, (view.X - 40) / self.Size.X, (view.Y - 40) / self.Size.Y)
		value = math.max(value, 0.5)
	else
		self._autoScale = false
		value = math.clamp(tonumber(value) or 1, 0.5, 2)
	end
	self._scaleValue = value
	self._uiScale.Scale = value
	Shared.Scale = value
	Shared.Overlay.SetScale(value)
	return self
end

function Window:GetScale(): number
	return self._scaleValue or 1
end

function Window:SetSize(size, keepScale)
	if typeof(size) == "UDim2" then
		size = Vector2.new(size.X.Offset, size.Y.Offset)
	end
	self.Size = Vector2.new(math.max(size.X, self.MinSize.X), math.max(size.Y, self.MinSize.Y))
	self.Holder.Size = UDim2.fromOffset(self.Size.X, self.Size.Y)
	if self._autoScale and not keepScale then
		self:SetScale("Auto")
	end
	return self
end

function Window:GetSize(): Vector2
	return self.Size
end

function Window:SetPosition(pos)
	if typeof(pos) == "Vector2" then
		pos = UDim2.fromOffset(pos.X, pos.Y)
	end
	self.Holder.Position = pos
	return self
end

function Window:Center()
	self.Holder.Position = UDim2.fromScale(0.5, 0.5)
	return self
end

function Window:SetTitle(text)
	self.Title = text
	self._titleLabel.Text = text
	return self
end

function Window:SetSubtitle(text)
	self.Subtitle = text
	self._subLabel.Text = text
	return self
end

function Window:SetKeybind(key)
	self.Keybind = Keys.Normalize(key)
	return self
end
Window.SetMenuKey = Window.SetKeybind

function Window:GetKeybind(): string
	return self.Keybind
end

-- 0 = solid, up to 0.4 = glass
function Window:SetTransparency(value)
	self.GlassTransparency = math.clamp(tonumber(value) or 0, 0, 0.4)
	if self._isOpen then
		self.Canvas.GroupTransparency = self.GlassTransparency
		self.Plate.BackgroundTransparency = self.GlassTransparency
	end
	return self
end

function Window:SetRim(enabled)
	self.RimEnabled = enabled and true or false
	Tween.Play(self._rim, { Transparency = (self.RimEnabled and self._isOpen) and 0 or 1 }, 0.3)
	return self
end

function Window:SetDraggable(value)
	self.Options.Draggable = value
	return self
end

-- ═══ Input ════════════════════════════════════════════════════════════════

function Window:_bindInput()
	local Lib = self.Library
	self.Maid:Connect(UIS.InputBegan, function(input, processed)
		if UIS:GetFocusedTextBox() or Shared.KeybindListening then
			return
		end
		local name = Keys.FromInput(input)
		if name and name == self.Keybind and string.sub(name, 1, 2) ~= "MB" then
			self:Toggle()
			return
		end
		if not self._isOpen then
			return
		end
		local ctrl = UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)
		if ctrl and input.KeyCode == Enum.KeyCode.K then
			self:OpenSearch()
		elseif ctrl and input.KeyCode == Enum.KeyCode.Z then
			Lib:Undo()
		elseif ctrl and input.KeyCode == Enum.KeyCode.Y then
			Lib:Redo()
		elseif ctrl and input.KeyCode == Enum.KeyCode.S then
			Lib:QuickSave(self)
		end
	end)
end

-- ═══ Search & commands (palette lives in Dialogs) ═══════════════════════

--[[
	Window:Command({ Name = "Rejoin", Icon = "refresh-cw", Hint = "server", Callback = fn })
	Commands appear in the Ctrl+K palette next to features and tabs.
]]
function Window:Command(options, callback)
	if type(options) == "string" then
		options = { Name = options, Callback = callback }
	end
	table.insert(self._commands, options)
	return options
end
Window.AddCommand = Window.Command

-- ═══ Misc ═════════════════════════════════════════════════════════════════

function Window:Notify(options)
	return self.Library:Notify(options)
end

function Window:GetElements()
	local out = {}
	for _, tab in self.Tabs do
		for _, el in tab:GetElements() do
			table.insert(out, el)
		end
	end
	return out
end

function Window:Find(name)
	for _, el in self:GetElements() do
		if el.Name == name or el.Flag == name then
			return el
		end
	end
	return nil
end

function Window:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	if self.Skeleton then
		self.Skeleton:Destroy()
	end
	for _, tab in table.clone(self.Tabs) do
		for _, el in tab:GetElements() do
			pcall(el.Destroy, el)
		end
	end
	self.Maid:Clean()
	local list = self.Library.Windows
	local i = table.find(list, self)
	if i then
		table.remove(list, i)
	end
end

return Window
