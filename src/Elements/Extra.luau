--!nocheck
--[[
	Proximity · Elements/Extra

	Section:Segmented({ Name, Values = { "Legit", "Rage", "Off" }, Default, Callback })
	  A row of options with one pill that slides to the chosen one.

	Section:Stepper({ Name, Min = 0, Max = 10, Step = 1, Default, Suffix, Callback })
	  - value + buttons; hold a button to repeat faster and faster.

	Section:Gallery({
	    Name = "Knife", Flag, Icon, Description,
	    Items = {
	        { Name = "Default", Image = "rbxassetid://...", Description = "Stock knife" },
	        { Name = "Fade", Image = "https://.../fade.png", Rarity = "Legendary", Badge = "NEW" },
	        ...
	    },
	    Default = "Default", Columns = 3, Callback = function(name, item) end,
	})
	  A card with the current choice (picture, name, "Change"). Clicking it
	  opens a full view inside the window: the current choice large at the
	  top, a search box, and every option as a picture card below. Pick one
	  and it is applied at once; Esc or the back arrow closes the view.
	  Images: asset ids, rbxasset/rbxthumb links or http(s) URLs (cached).
	  Rarity: "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | a Color3.
	  Methods: :SetItems(list) :GetItem() :Open() :Close()
]]

local Util = require("../Core/Util")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")
local Theme = require("../Theme")
local Icons = require("../Icons")
local Locale = require("../Locale")
local Shared = require("../Shared")
local Base = require("./Base")

local UIS = Env.Service("UserInputService")

local classes = {}

-- ═══ Segmented ═════════════════════════════════════════════════════════
local Segmented = Base.extend("Segmented")
classes.Segmented = Segmented

function Segmented.new(section, options)
	local self = Base.new(Segmented, section, options)
	self.Values = table.clone(Util.Opt(options, "Values", "Options", "Items") or {})
	self.Default = options.Default or self.Values[1]
	self.Value = self.Default
	return self:_register()
end

function Segmented:_normalize(v)
	return table.find(self.Values, v) and v or nil
end

function Segmented:_navAdjust(dir)
	local i = table.find(self.Values, self.Value) or 1
	self:_userSet(self.Values[math.clamp(i + dir, 1, #self.Values)])
end

function Segmented:_build(parent)
	local row = self:_row(parent, 60)
	self._textBox.Size = UDim2.new(1, -16, 0, 22)
	self._textBox.Position = UDim2.fromOffset(8, 2)
	self._title.Position = UDim2.new(0, 0, 0, 4)
	local bar = Util.New("Frame", { Name = "Segments", Size = UDim2.new(1, -16, 0, 26), Position = UDim2.new(0, 8, 1, -31), Parent = row })
	Util.Corner(7, bar)
	Theme.Paint(bar, { BackgroundColor3 = "Surface2" })
	Theme.Paint(Util.Stroke(bar), { Color = "Stroke" })
	local pill = Util.New("Frame", { Size = UDim2.new(1 / math.max(#self.Values, 1), -4, 1, -4), Position = UDim2.fromOffset(2, 2), ZIndex = 2, Parent = bar })
	Util.Corner(5, pill)
	Theme.Paint(pill, { BackgroundColor3 = "Accent" })
	self._pill, self._labels = pill, {}
	for i, v in self.Values do
		local b = Util.New("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1 / #self.Values, 0, 1, 0), Position = UDim2.fromScale((i - 1) / #self.Values, 0), ZIndex = 3, Parent = bar })
		local label = Util.Label({ Text = tostring(v), FontFace = Theme.Fonts.SemiBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -6, 1, 0), Position = UDim2.fromOffset(3, 0), ZIndex = 4, Parent = b })
		self._labels[i] = label
		b.Activated:Connect(function()
			if not self:IsLocked() then
				self:_userSet(v)
			end
		end)
	end
end

function Segmented:_render(animate)
	if not self._pill then
		return
	end
	local i = table.find(self.Values, self.Value) or 1
	local n = math.max(#self.Values, 1)
	Tween.Play(self._pill, { Position = UDim2.new((i - 1) / n, 2, 0, 2) }, animate and 0.32 or 0, Enum.EasingStyle.Back)
	for j, label in self._labels do
		Theme.Paint(label, { TextColor3 = j == i and "AccentInk" or "TextDim" }, animate and 0.15 or 0)
	end
end

function Segmented:SetValues(values)
	self.Values = table.clone(values)
	if not table.find(self.Values, self.Value) then
		self.Value = self.Values[1]
	end
	return self:_rebuild()
end

function Segmented:_rebuild()
	if self.Frame and self.Frame.Parent then
		local parent, order = self.Frame.Parent, self.Frame.LayoutOrder
		self.Frame:Destroy()
		self:_build(parent)
		self.Frame.LayoutOrder = order
		self:_render(false)
	end
	return self
end

-- ═══ Stepper ═══════════════════════════════════════════════════════════
local Stepper = Base.extend("Stepper")
classes.Stepper = Stepper

function Stepper.new(section, options)
	local self = Base.new(Stepper, section, options)
	self.Min = options.Min or 0
	self.Max = options.Max or 100
	self.Step = options.Step or options.Increment or 1
	self.Suffix = options.Suffix or ""
	self.Default = math.clamp(options.Default or self.Min, self.Min, self.Max)
	self.Value = self.Default
	return self:_register()
end

function Stepper:_normalize(v)
	v = tonumber(v)
	if not v then
		return nil
	end
	return math.clamp(Util.Snap(v, self.Step, self.Min), self.Min, self.Max)
end

function Stepper:_navAdjust(dir)
	self:_userSet(self.Value + dir * self.Step)
end

function Stepper:_build(parent)
	self:_row(parent)
	local function button(text, order, dir)
		local b = Util.New("TextButton", { Text = text, AutoButtonColor = false, FontFace = Theme.Fonts.Bold, TextSize = 14, Size = UDim2.fromOffset(24, 22), LayoutOrder = order, Parent = self._right })
		Util.Corner(5, b)
		Theme.Paint(b, { BackgroundColor3 = "Surface3", TextColor3 = "Text" })
		Theme.Paint(Util.Stroke(b), { Color = "Stroke" })
		local holding = 0
		b.MouseButton1Down:Connect(function()
			if self:IsLocked() then
				return
			end
			holding += 1
			local mine = holding
			self:_userSet(self.Value + dir * self.Step)
			task.delay(0.4, function()
				local wait = 0.12
				while holding == mine do
					self:_userSet(self.Value + dir * self.Step)
					task.wait(wait)
					wait = math.max(0.03, wait * 0.85)
				end
			end)
		end)
		local function stop()
			holding += 1
		end
		b.MouseButton1Up:Connect(stop)
		b.MouseLeave:Connect(stop)
		return b
	end
	button("-", 100, -1)
	local value = Util.Label({ Text = "", FontFace = Theme.Fonts.Mono, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromOffset(46, 22), LayoutOrder = 101, Parent = self._right })
	Theme.Paint(value, { TextColor3 = "Text" })
	self._valueLabel = value
	button("+", 102, 1)
end

function Stepper:_render()
	if self._valueLabel then
		self._valueLabel.Text = Util.FormatNumber(self.Value, Util.Decimals(self.Step)) .. self.Suffix
	end
end

-- ═══ Gallery ═══════════════════════════════════════════════════════════
local Gallery = Base.extend("Gallery")
classes.Gallery = Gallery

local rarityColors = {
	common = Color3.fromRGB(176, 176, 184),
	uncommon = Color3.fromRGB(110, 200, 140),
	rare = Color3.fromRGB(100, 150, 240),
	epic = Color3.fromRGB(170, 110, 240),
	legendary = Color3.fromRGB(240, 180, 80),
	mythic = Color3.fromRGB(240, 90, 110),
}
local function rarityColor(r)
	if typeof(r) == "Color3" then
		return r
	end
	return r and rarityColors[string.lower(tostring(r))] or nil
end

local function normalizeItems(items)
	local list = {}
	for k, v in items or {} do
		if type(v) == "table" then
			table.insert(list, { Name = tostring(v.Name or v[1] or k), Image = v.Image or v.Icon or v[2], Description = v.Description, Rarity = v.Rarity, Badge = v.Badge, Data = v.Data })
		elseif type(k) == "string" then
			table.insert(list, { Name = k, Image = v })
		else
			table.insert(list, { Name = tostring(v) })
		end
	end
	return list
end

local function image(source)
	if source == nil then
		return ""
	end
	return Icons.Get(source) or (type(source) == "string" and source) or ""
end

function Gallery.new(section, options)
	local self = Base.new(Gallery, section, options)
	self.Items = normalizeItems(Util.Opt(options, "Items", "Values", "Options"))
	self.Columns = options.Columns or 3
	self.Default = options.Default or (self.Items[1] and self.Items[1].Name)
	self.Value = self.Default
	self.Placeholder = options.Placeholder
	return self:_register()
end

function Gallery:_normalize(v)
	for _, item in self.Items do
		if item.Name == v then
			return v
		end
	end
	return nil
end

function Gallery:GetItem()
	for _, item in self.Items do
		if item.Name == self.Value then
			return item
		end
	end
	return nil
end

function Gallery:_callbackArgs()
	return self.Value, self:GetItem()
end

function Gallery:_navActivate()
	self:Open()
end

function Gallery:SetItems(items)
	self.Items = normalizeItems(items)
	if not self:_normalize(self.Value) then
		self.Value = self.Items[1] and self.Items[1].Name
	end
	self:_render(false)
	return self
end

function Gallery:_build(parent)
	local row = self:_row(parent, 84)
	self._textBox.Position = UDim2.fromOffset(92, 0)
	self._textBox.Size = UDim2.new(1, -100, 1, 0)
	local thumb = Util.New("Frame", { Name = "Thumb", Size = UDim2.fromOffset(76, 64), Position = UDim2.fromOffset(8, 10), ClipsDescendants = true, Parent = row })
	Util.Corner(8, thumb)
	Theme.Paint(thumb, { BackgroundColor3 = "Surface2" })
	local thumbStroke = Util.Stroke(thumb)
	Theme.Paint(thumbStroke, { Color = "Stroke" })
	local pic = Util.New("ImageLabel", { BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, Size = UDim2.new(1, -8, 1, -8), Position = UDim2.fromOffset(4, 4), Parent = thumb })
	local stripe = Util.New("Frame", { BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2), Parent = thumb })
	local current = Util.Label({ Text = "", FontFace = Theme.Fonts.Regular, TextSize = 12, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 16), LayoutOrder = 99, Parent = self._right })
	Theme.Paint(current, { TextColor3 = "TextDim" })
	local arrow = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get("chevron-right") or "", Size = UDim2.fromOffset(15, 15), LayoutOrder = 100, Parent = self._right })
	Theme.Paint(arrow, { ImageColor3 = "TextDim" })
	self._thumb, self._pic, self._stripe, self._current = thumb, pic, stripe, current
	local hit = Util.Hitbox(row, 0)
	hit.Activated:Connect(function()
		if not self:IsLocked() then
			self:Open()
		end
	end)
	hit.MouseEnter:Connect(function()
		Theme.Paint(thumbStroke, { Color = "StrokeHi" }, 0.12)
	end)
	hit.MouseLeave:Connect(function()
		Theme.Paint(thumbStroke, { Color = "Stroke" }, 0.12)
	end)
	hit.MouseButton2Click:Connect(function()
		self:OpenContextMenu()
	end)
end

function Gallery:_render()
	if not self._pic then
		return
	end
	local item = self:GetItem()
	self._pic.Image = image(item and item.Image or self.Placeholder)
	self._current.Text = item and item.Name or ""
	local color = item and rarityColor(item.Rarity)
	self._stripe.Visible = color ~= nil
	if color then
		self._stripe.BackgroundColor3 = color
	end
	if self._view then
		self:_renderView()
	end
end

-- the full view inside the window
function Gallery:Open()
	local window = self.Window
	if not window or not window.Main or self._view then
		return self
	end
	window:Open()
	local T = Locale.T
	local view = Util.New("Frame", { Name = "GalleryView", Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, ZIndex = 60, Active = true, Parent = window.Main })
	Theme.Paint(view, { BackgroundColor3 = "Bg" })
	local scale = Util.New("UIScale", { Scale = 0.97, Parent = view })
	view.BackgroundTransparency = 1
	Tween.Play(view, { BackgroundTransparency = 0 }, 0.2)
	Tween.Play(scale, { Scale = 1 }, 0.35, Enum.EasingStyle.Quint)
	self._view = view

	-- header: back, title, search
	local back = Util.New("ImageButton", { BackgroundTransparency = 1, Image = Icons.Get("arrow-left") or "", Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(16, 19), ZIndex = 61, Parent = view })
	Theme.Paint(back, { ImageColor3 = "TextDim" })
	local title = Util.Label({ Text = self.Name, FontFace = Theme.Fonts.SemiBold, TextSize = 16, Size = UDim2.new(0.5, -50, 0, 20), Position = UDim2.fromOffset(44, 18), ZIndex = 61, Parent = view })
	Theme.Paint(title, { TextColor3 = "Text" })
	local search = Util.New("TextBox", { Text = "", PlaceholderText = T("Search"), ClearTextOnFocus = false, FontFace = Theme.Fonts.Medium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(0.42, 0, 0, 28), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 14), ZIndex = 61, Parent = view })
	Util.Corner(7, search)
	Util.Padding(search, 0, 10, 0, 10)
	Theme.Paint(search, { BackgroundColor3 = "Surface2", TextColor3 = "Text", PlaceholderColor3 = "TextMute" })
	Theme.Paint(Util.Stroke(search), { Color = "Stroke" })

	-- the current choice, large
	local hero = Util.New("Frame", { Size = UDim2.new(1, -32, 0, 128), Position = UDim2.fromOffset(16, 54), ZIndex = 61, Parent = view })
	Util.Corner(10, hero)
	Theme.Paint(hero, { BackgroundColor3 = "Surface" })
	Theme.Paint(Util.Stroke(hero), { Color = "Stroke" })
	local heroPicBox = Util.New("Frame", { Size = UDim2.fromOffset(150, 108), Position = UDim2.fromOffset(10, 10), ClipsDescendants = true, ZIndex = 62, Parent = hero })
	Util.Corner(8, heroPicBox)
	Theme.Paint(heroPicBox, { BackgroundColor3 = "Surface2" })
	local heroPic = Util.New("ImageLabel", { BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, Size = UDim2.new(1, -12, 1, -12), Position = UDim2.fromOffset(6, 6), ZIndex = 63, Parent = heroPicBox })
	local heroCaption = Util.Label({ Text = T("Equipped"), FontFace = Theme.Fonts.Bold, TextSize = 10, Size = UDim2.new(1, -190, 0, 14), Position = UDim2.fromOffset(176, 16), ZIndex = 62, Parent = hero })
	Theme.Paint(heroCaption, { TextColor3 = "TextMute" })
	local heroName = Util.Label({ Text = "", FontFace = Theme.Fonts.SemiBold, TextSize = 18, Size = UDim2.new(1, -190, 0, 22), Position = UDim2.fromOffset(176, 32), ZIndex = 62, Parent = hero })
	Theme.Paint(heroName, { TextColor3 = "Text" })
	local heroRarity = Util.Label({ Text = "", FontFace = Theme.Fonts.Bold, TextSize = 11, Size = UDim2.new(1, -190, 0, 14), Position = UDim2.fromOffset(176, 58), ZIndex = 62, Parent = hero })
	local heroDesc = Util.Label({ Text = "", FontFace = Theme.Fonts.Regular, TextSize = 12, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Size = UDim2.new(1, -190, 0, 40), Position = UDim2.fromOffset(176, 76), ZIndex = 62, Parent = hero })
	Theme.Paint(heroDesc, { TextColor3 = "TextDim" })

	-- every option as a card
	local grid = Util.New("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, -24, 1, -200), Position = UDim2.fromOffset(12, 194), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ZIndex = 61, Parent = view })
	Util.Padding(grid, 4, 4, 12, 4)
	local layout = Util.New("UIGridLayout", { CellPadding = UDim2.fromOffset(10, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = grid })
	local function cellSize()
		local w = grid.AbsoluteSize.X - 8
		local cols = math.max(2, math.min(self.Columns + 1, math.floor(w / 130)))
		local cw = math.floor((w - (cols - 1) * 10) / cols)
		layout.CellSize = UDim2.fromOffset(cw, math.floor(cw * 0.86) + 30)
	end
	grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(cellSize)
	task.defer(cellSize)

	self._viewParts = { hero = heroPic, name = heroName, rarity = heroRarity, desc = heroDesc, grid = grid, cards = {}, search = search }
	for i, item in self.Items do
		local card = Util.New("TextButton", { Text = "", AutoButtonColor = false, LayoutOrder = i, ZIndex = 62, Parent = grid })
		Util.Corner(9, card)
		Theme.Paint(card, { BackgroundColor3 = "Surface" })
		local stroke = Util.Stroke(card)
		Theme.Paint(stroke, { Color = "Stroke" })
		local box = Util.New("Frame", { Size = UDim2.new(1, -12, 1, -38), Position = UDim2.fromOffset(6, 6), ClipsDescendants = true, ZIndex = 63, Parent = card })
		Util.Corner(7, box)
		Theme.Paint(box, { BackgroundColor3 = "Surface2" })
		local pic = Util.New("ImageLabel", { BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, Size = UDim2.new(1, -10, 1, -10), Position = UDim2.fromOffset(5, 5), Image = image(item.Image), ZIndex = 64, Parent = box })
		local picScale = Util.New("UIScale", { Parent = pic })
		local name = Util.Label({ Text = item.Name, FontFace = Theme.Fonts.Medium, TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -16, 0, 16), Position = UDim2.new(0, 8, 1, -26), ZIndex = 63, Parent = card })
		Theme.Paint(name, { TextColor3 = "Text" })
		local color = rarityColor(item.Rarity)
		if color then
			local stripe = Util.New("Frame", { BorderSizePixel = 0, BackgroundColor3 = color, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2), ZIndex = 64, Parent = box })
			Util.New("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }), Parent = stripe })
		end
		if item.Badge then
			local badge = Util.Label({ Text = string.upper(item.Badge), FontFace = Theme.Fonts.Bold, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Center, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 14), Position = UDim2.fromOffset(6, 6), BackgroundTransparency = 0, ZIndex = 65, Parent = box })
			Util.Padding(badge, 0, 5, 0, 5)
			Util.Corner(4, badge)
			Theme.Paint(badge, { BackgroundColor3 = "Accent", TextColor3 = "AccentInk" })
		end
		card.MouseEnter:Connect(function()
			Tween.Play(picScale, { Scale = 1.06 }, 0.25, Enum.EasingStyle.Quint)
			if self.Value ~= item.Name then
				Theme.Paint(stroke, { Color = "StrokeHi" }, 0.12)
			end
		end)
		card.MouseLeave:Connect(function()
			Tween.Play(picScale, { Scale = 1 }, 0.25, Enum.EasingStyle.Quint)
			if self.Value ~= item.Name then
				Theme.Paint(stroke, { Color = "Stroke" }, 0.12)
			end
		end)
		card.Activated:Connect(function()
			if self:IsLocked() then
				return
			end
			self:_userSet(item.Name)
			-- a small pulse on the chosen card
			local s = Util.New("UIScale", { Scale = 0.95, Parent = card })
			Tween.Play(s, { Scale = 1 }, 0.3, Enum.EasingStyle.Back)
			task.delay(0.35, function()
				s:Destroy()
			end)
		end)
		self._viewParts.cards[i] = { Card = card, Stroke = stroke, Item = item }
	end
	search:GetPropertyChangedSignal("Text"):Connect(function()
		local q = search.Text
		for _, c in self._viewParts.cards do
			c.Card.Visible = q == "" or Util.Fuzzy(q, c.Item.Name .. " " .. tostring(c.Item.Rarity or "")) ~= nil
		end
	end)
	back.Activated:Connect(function()
		self:Close()
	end)
	self._viewConn = UIS.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Escape and not UIS:GetFocusedTextBox() then
			self:Close()
		end
	end)
	self:_renderView()
	return self
end

function Gallery:_renderView()
	local parts = self._viewParts
	if not parts then
		return
	end
	local item = self:GetItem()
	parts.hero.Image = image(item and item.Image or self.Placeholder)
	parts.name.Text = item and item.Name or "-"
	local color = item and rarityColor(item.Rarity)
	parts.rarity.Text = item and item.Rarity and string.upper(tostring(item.Rarity)) or ""
	parts.rarity.TextColor3 = color or Color3.fromRGB(150, 150, 158)
	parts.desc.Text = item and item.Description or ""
	for _, c in parts.cards do
		local on = c.Item.Name == self.Value
		Theme.Paint(c.Stroke, { Color = on and "Accent" or "Stroke" }, 0.15)
		c.Stroke.Thickness = on and 2 or 1
	end
end

function Gallery:Close()
	local view = self._view
	if not view then
		return self
	end
	self._view, self._viewParts = nil, nil
	if self._viewConn then
		self._viewConn:Disconnect()
		self._viewConn = nil
	end
	Tween.Play(view, { BackgroundTransparency = 1 }, 0.15)
	for _, d in view:GetDescendants() do
		if d:IsA("GuiObject") then
			d.Visible = false
		end
	end
	task.delay(0.16, function()
		view:Destroy()
	end)
	return self
end

function Gallery:Destroy()
	self:Close()
	Base.Destroy(self)
end

return classes
