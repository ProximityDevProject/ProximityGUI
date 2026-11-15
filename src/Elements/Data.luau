--!nocheck
--[[
	Proximity · Elements/Data
	Display elements: Progress, Stat, StatGrid, Sparkline (Graph), Table
	(catalog with search, sort, filters, row actions, virtualised rows),
	Card (with optional 3D viewport), Image, Console, Code.
]]

local Util = require("../Core/Util")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")
local Theme = require("../Theme")
local Icons = require("../Icons")
local Locale = require("../Locale")
local Shared = require("../Shared")
local Base = require("./Base")

local RunService = Env.Service("RunService")

local classes = {}

local function noState(class)
	function class:_applyState()
		if self.Frame then
			self.Frame.Visible = self.Visible and self._depsOk ~= false
		end
	end
	function class:_contextItems()
		return {}
	end
end

-- Provider helper: value can be a constant or a function polled on an interval.
local function poll(self, source, interval, apply)
	if type(source) ~= "function" then
		return
	end
	local thread = task.spawn(function()
		while not self._destroyed do
			local ok, value = pcall(source)
			if ok then
				apply(value)
			end
			task.wait(interval or 1)
		end
	end)
	self.Maid:Give(thread)
end

-- ═══ Progress ═════════════════════════════════════════════════════════════
-- Section:Progress({ Name, Value = 0, Max = 100, Suffix = "%", ShowValue = true })
local Progress = Base.extend("Progress")
classes.Progress = Progress
noState(Progress)

function Progress.new(section, options)
	local self = Base.new(Progress, section, options)
	self.Max = options.Max or 100
	self.Suffix = options.Suffix or "%"
	self.ShowValue = options.ShowValue ~= false
	self.Value = math.clamp(tonumber(Util.Opt(options, "Value", "Default")) or 0, 0, self.Max)
	self.Default = self.Value
	return self:_register()
end

function Progress:_normalize(v)
	v = tonumber(v)
	return v and math.clamp(v, 0, self.Max) or nil
end

function Progress:SetMax(max: number)
	self.Max = max
	return self:Set(math.min(self.Value, max))
end

function Progress:_build(parent)
	local row = self:_row(parent, 40)
	self._textBox.Size = UDim2.new(1, -16, 0, 22)
	self._title.Position = UDim2.fromOffset(0, 4)
	local value = Util.Label({ FontFace = Theme.Fonts.Mono, TextSize = 12, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 26), LayoutOrder = 100, Parent = self._right })
	self._right.Size = UDim2.new(0, 0, 0, 26)
	Theme.Paint(value, { TextColor3 = "TextDim" })
	local track = Util.New("Frame", { Size = UDim2.new(1, -16, 0, 4), Position = UDim2.new(0, 8, 1, -10), Parent = row })
	Util.Round(track)
	Theme.Paint(track, { BackgroundColor3 = "Surface3" })
	local fill = Util.New("Frame", { Size = UDim2.fromScale(0, 1), Parent = track })
	Util.Round(fill)
	Theme.Paint(fill, { BackgroundColor3 = "Accent" })
	self._fill, self._value = fill, value
end

function Progress:_render(animate)
	if self._fill then
		Tween.Play(self._fill, { Size = UDim2.fromScale(self.Value / math.max(self.Max, 1e-9), 1) }, animate and 0.3 or 0)
		self._value.Text = self.ShowValue and (self.Suffix == "%" and Util.FormatNumber(self.Value / self.Max * 100, 0) .. "%" or Util.FormatNumber(self.Value, 1) .. self.Suffix) or ""
	end
end

-- ═══ Stat ═════════════════════════════════════════════════════════════════
-- Section:Stat({ Name = "Kills", Value = 0 | fn, Interval = 1, Icon, Suffix })
local Stat = Base.extend("Stat")
classes.Stat = Stat
noState(Stat)

function Stat.new(section, options)
	local self = Base.new(Stat, section, options)
	self.Icon = options.Icon
	self.Suffix = options.Suffix or ""
	local v = Util.Opt(options, "Value", "Default")
	self.Value = type(v) == "function" and "…" or v
	self.Default = self.Value
	self:_register()
	poll(self, v, options.Interval, function(value)
		self:Set(value)
	end)
	return self
end

function Stat:_normalize(v)
	return v
end

function Stat:_build(parent)
	self:_row(parent, 30)
	self._titleToken = "TextDim"
	Theme.Paint(self._title, { TextColor3 = "TextDim" })
	local value = Util.Label({ FontFace = Theme.Fonts.MonoBold, TextSize = 12, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 16), LayoutOrder = 100, Parent = self._right })
	Theme.Paint(value, { TextColor3 = "Text" })
	self._value = value
end

function Stat:_render()
	if self._value then
		self._value.Text = tostring(self.Value) .. self.Suffix
	end
end

-- ═══ StatGrid (dashboard tiles) ═══════════════════════════════════════════
--[[
	Section:StatGrid({
		Columns = 3,
		Items = {
			{ Name = "Kills", Value = fn | value, Interval = 1, Accent = true },
			{ Name = "FPS", Value = fn, Sparkline = true },
		}
	})
	grid:SetItem(index | name, value)
]]
local StatGrid = Base.extend("StatGrid")
classes.StatGrid = StatGrid
noState(StatGrid)

function StatGrid.new(section, options)
	local self = Base.new(StatGrid, section, { Name = options.Name or "Stats" })
	self.Columns = options.Columns or 3
	self.Items = {}
	for i, item in options.Items or {} do
		self.Items[i] = {
			Name = item.Name or item[1],
			Source = item.Value or item[2],
			Interval = item.Interval or 1,
			Accent = item.Accent,
			Spark = item.Sparkline,
			History = {},
			Text = "…",
		}
	end
	self:_register()
	for _, item in self.Items do
		if type(item.Source) == "function" then
			poll(self, item.Source, item.Interval, function(value)
				self:_setItem(item, value)
			end)
		else
			item.Text = tostring(item.Source)
		end
	end
	return self
end

function StatGrid:_setItem(item, value)
	item.Text = tostring(value)
	if item.Spark and tonumber(value) then
		table.insert(item.History, tonumber(value))
		if #item.History > 30 then
			table.remove(item.History, 1)
		end
	end
	if item.Label then
		item.Label.Text = item.Text
		if item.Spark then
			Shared.Lib._drawSpark(item.SparkFrame, item.History)
		end
	end
end

function StatGrid:SetItem(key, value)
	for i, item in self.Items do
		if i == key or item.Name == key then
			self:_setItem(item, value)
		end
	end
	return self
end

function StatGrid:_build(parent)
	local cols = self.Columns
	local rows = math.ceil(#self.Items / cols)
	local frame = Util.New("Frame", { Name = "StatGrid", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, rows * 48 + (rows - 1) * 6), Parent = parent })
	self.Frame = frame
	Util.New("UIGridLayout", {
		CellSize = UDim2.new(1 / cols, -(6 * (cols - 1)) / cols, 0, 48),
		CellPadding = UDim2.fromOffset(6, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = frame,
	})
	for i, item in self.Items do
		local tile = Util.New("Frame", { LayoutOrder = i, Parent = frame })
		Util.Corner(6, tile)
		Theme.Paint(tile, { BackgroundColor3 = "Surface2" })
		Theme.Paint(Util.Stroke(tile), { Color = "Stroke" })
		local name = Util.Label({ Text = item.Name, FontFace = Theme.Fonts.Medium, TextSize = 11, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -16, 0, 14), Position = UDim2.fromOffset(8, 6), Parent = tile })
		Theme.Paint(name, { TextColor3 = "TextMute" })
		local value = Util.Label({ Text = item.Text, FontFace = Theme.Fonts.MonoBold, TextSize = 14, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -16, 0, 18), Position = UDim2.fromOffset(8, 23), Parent = tile })
		Theme.Paint(value, { TextColor3 = item.Accent and "Accent" or "Text" })
		item.Label = value
		if item.Spark then
			local spark = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0.5, -8, 0, 16), Position = UDim2.new(0.5, 0, 0, 5), ClipsDescendants = true, Parent = tile })
			item.SparkFrame = spark
			Shared.Lib._drawSpark(spark, item.History)
		end
		Shared.Overlay.Hover(tile, function()
			return item.Name .. ": " .. item.Text
		end)
	end
end

-- ═══ Sparkline / Graph ════════════════════════════════════════════════════
-- Section:Graph({ Name, Max = 60 points, Min, MaxValue, Height = 60, Source = fn, Interval })
-- graph:Push(v) graph:SetData({...}) graph:Clear()
local Graph = Base.extend("Graph")
classes.Graph = Graph
noState(Graph)

function Graph.new(section, options)
	local self = Base.new(Graph, section, options)
	self.Points = options.Points or options.Max or 40
	self.Height = options.Height or 64
	self.FixedMin, self.FixedMax = options.Min, options.MaxValue
	self.Suffix = options.Suffix or ""
	self.Data = {}
	self.Value = self.Data
	self:_register()
	poll(self, options.Source, options.Interval or 0.5, function(v)
		self:Push(v)
	end)
	return self
end

function Graph:Push(v)
	v = tonumber(v)
	if not v then
		return self
	end
	table.insert(self.Data, v)
	while #self.Data > self.Points do
		table.remove(self.Data, 1)
	end
	if self._mounted then
		self:_render()
	end
	return self
end

function Graph:SetData(list)
	self.Data = table.clone(list or {})
	self.Value = self.Data
	if self._mounted then
		self:_render()
	end
	return self
end

function Graph:Clear()
	return self:SetData({})
end

function Graph:_build(parent)
	local row = Util.New("Frame", { Name = "Graph", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, self.Height + 26), Parent = parent })
	self.Frame = row
	local title = Util.Label({ Text = self.Name, FontFace = Theme.Fonts.Medium, TextSize = 12, Size = UDim2.new(1, -16, 0, 18), Position = UDim2.fromOffset(8, 2), Parent = row })
	Theme.Paint(title, { TextColor3 = "TextDim" })
	local last = Util.Label({ FontFace = Theme.Fonts.Mono, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, -16, 0, 18), Position = UDim2.fromOffset(8, 2), Parent = row })
	Theme.Paint(last, { TextColor3 = "Text" })
	local area = Util.New("Frame", { Size = UDim2.new(1, -16, 0, self.Height), Position = UDim2.fromOffset(8, 22), ClipsDescendants = true, Parent = row })
	Util.Corner(6, area)
	Theme.Paint(area, { BackgroundColor3 = "Surface2" })
	Theme.Paint(Util.Stroke(area), { Color = "Stroke" })
	self._area, self._last = area, last
end

function Graph:_render()
	if not self._area then
		return
	end
	Shared.Lib._drawSpark(self._area, self.Data, self.FixedMin, self.FixedMax)
	local v = self.Data[#self.Data]
	self._last.Text = v and (Util.FormatNumber(v, 1) .. self.Suffix) or ""
end

-- ═══ Table / Catalog ══════════════════════════════════════════════════════
--[[
	Section:Table({
		Name, Height = 260,
		Columns = { { Key = "map", Name = "Map", Width = 0.4 }, { Key = "players", Name = "Players", Width = 0.2, Align = "Center" } },
		Rows = { { map = "Border", players = 28 }, ... },
		Search = true, SortBy = "players", Descending = true,
		Filter = fn(row) → bool,
		Actions = { { Icon = "log-in", Tooltip = "Join", Callback = fn(row) } },
		OnSelect = fn(row),
	})
	t:SetRows(rows) t:AddRow(row) t:RemoveRow(index|fn) t:Clear() t:SortBy(key, desc)
	t:SetFilter(fn) t:SetQuery(text) t:GetSelected() t:GetRows()
]]
local Table = Base.extend("Table")
classes.Table = Table
noState(Table)

function Table.new(section, options)
	local self = Base.new(Table, section, options)
	self.Columns = options.Columns or { { Key = 1, Name = "Value", Width = 1 } }
	self.Rows = table.clone(options.Rows or {})
	self.Height = options.Height or 240
	self.RowHeight = options.RowHeight or 30
	self.SearchEnabled = options.Search ~= false
	self.SortKey = options.SortBy
	self.Descending = options.Descending == true
	self.Filter = options.Filter
	self.Actions = options.Actions or {}
	self.OnSelect = options.OnSelect
	self.Query = ""
	self.Value = nil
	return self:_register()
end

function Table:_view()
	local out = {}
	for i, row in self.Rows do
		local ok = true
		if self.Filter then
			local s, r = pcall(self.Filter, row)
			ok = s and r ~= false
		end
		if ok and self.Query ~= "" then
			local hay = {}
			for _, col in self.Columns do
				table.insert(hay, tostring(row[col.Key] or ""))
			end
			ok = Util.Fuzzy(self.Query, table.concat(hay, " ")) ~= nil
		end
		if ok then
			table.insert(out, row)
		end
	end
	if self.SortKey then
		local key, desc = self.SortKey, self.Descending
		table.sort(out, function(a, b)
			local va, vb = a[key], b[key]
			if type(va) ~= type(vb) then
				va, vb = tostring(va), tostring(vb)
			end
			if va == nil or vb == nil then
				return vb == nil and va ~= nil
			end
			if desc then
				return va > vb
			end
			return va < vb
		end)
	end
	return out
end

function Table:SetRows(rows)
	self.Rows = table.clone(rows or {})
	self:_refresh()
	return self
end
function Table:AddRow(row)
	table.insert(self.Rows, row)
	self:_refresh()
	return self
end
function Table:RemoveRow(which)
	for i = #self.Rows, 1, -1 do
		if i == which or (type(which) == "function" and which(self.Rows[i])) or self.Rows[i] == which then
			table.remove(self.Rows, i)
		end
	end
	self:_refresh()
	return self
end
function Table:Clear()
	return self:SetRows({})
end
function Table:GetRows()
	return table.clone(self.Rows)
end
function Table:GetSelected()
	return self.Value
end
function Table:SortBy(key, descending)
	self.SortKey, self.Descending = key, descending == true
	self:_refresh()
	return self
end
function Table:SetFilter(fn)
	self.Filter = fn
	self:_refresh()
	return self
end
function Table:SetQuery(text)
	self.Query = text or ""
	self:_refresh()
	return self
end

function Table:_build(parent)
	local frame = Util.New("Frame", { Name = "Table", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, self.Height), Parent = parent })
	self.Frame = frame
	local y = 0
	if self.SearchEnabled then
		local search = Util.New("TextBox", { Text = "", PlaceholderText = Locale.T("Search") .. "…", ClearTextOnFocus = false, FontFace = Theme.Fonts.Regular, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -8, 0, 26), Position = UDim2.fromOffset(4, 0), Parent = frame })
		Util.Corner(5, search)
		Util.Padding(search, 0, 8, 0, 26)
		Theme.Paint(search, { BackgroundColor3 = "Surface2", TextColor3 = "Text", PlaceholderColor3 = "TextMute" })
		local icon = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get("search") or "", Size = UDim2.fromOffset(13, 13), Position = UDim2.new(0, -19, 0.5, -6), Parent = search })
		Theme.Paint(icon, { ImageColor3 = "TextMute" })
		search:GetPropertyChangedSignal("Text"):Connect(function()
			self.Query = search.Text
			self:_refresh()
		end)
		y = 32
	end
	-- header
	local header = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 22), Position = UDim2.fromOffset(4, y), Parent = frame })
	local x = 0
	self._headers = {}
	for _, col in self.Columns do
		local w = col.Width or (1 / #self.Columns)
		local h = Util.New("TextButton", { Text = col.Name or tostring(col.Key), FontFace = Theme.Fonts.SemiBold, TextSize = 11, AutoButtonColor = false, BackgroundTransparency = 1, TextXAlignment = col.Align == "Center" and Enum.TextXAlignment.Center or (col.Align == "Right" and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left), Size = UDim2.new(w, -6, 1, 0), Position = UDim2.new(x, 8, 0, 0), Parent = header })
		Theme.Paint(h, { TextColor3 = "TextMute" })
		h.Activated:Connect(function()
			if self.SortKey == col.Key then
				self.Descending = not self.Descending
			else
				self.SortKey, self.Descending = col.Key, false
			end
			self:_refresh()
		end)
		self._headers[col.Key] = { Button = h, Name = col.Name or tostring(col.Key) }
		x += w
	end
	y += 24
	local list = Util.New("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, -y), Position = UDim2.fromOffset(0, y), CanvasSize = UDim2.new(), ScrollBarThickness = 2, Parent = frame })
	Theme.Paint(list, { ScrollBarImageColor3 = "StrokeHi" })
	self._list = list
	local empty = Util.Label({ Text = Locale.T("Empty"), FontFace = Theme.Fonts.Regular, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 40), Visible = false, Parent = list })
	Theme.Paint(empty, { TextColor3 = "TextMute" })
	self._empty = empty
	self._pool = {}
	list:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		self:_drawVisible()
	end)
	list:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_drawVisible()
	end)
end

function Table:_refresh()
	if not self._list then
		return
	end
	self._viewRows = self:_view()
	self._list.CanvasSize = UDim2.fromOffset(0, #self._viewRows * (self.RowHeight + 4))
	self._empty.Visible = #self._viewRows == 0
	for key, h in self._headers or {} do
		h.Button.Text = h.Name .. (self.SortKey == key and (self.Descending and "  ↓" or "  ↑") or "")
		Theme.Paint(h.Button, { TextColor3 = self.SortKey == key and "Text" or "TextMute" })
	end
	self:_drawVisible()
end

-- Only rows inside the viewport exist (pooled), so 5 000 rows stay cheap.
function Table:_drawVisible()
	local list = self._list
	local rows = self._viewRows or {}
	local s = Shared.Scale or 1
	local h = self.RowHeight + 4
	local top = list.CanvasPosition.Y
	local first = math.max(1, math.floor(top / h) + 1)
	local last = math.min(#rows, first + math.ceil(list.AbsoluteSize.Y / s / h) + 1)
	local used = {}
	for i = first, last do
		local row = rows[i]
		local item = self._pool[#used + 1]
		if not item then
			item = self:_newRow()
			self._pool[#used + 1] = item
		end
		used[#used + 1] = item
		item.Row = row
		item.Frame.Visible = true
		item.Frame.Position = UDim2.fromOffset(4, (i - 1) * h)
		for c, col in self.Columns do
			item.Cells[c].Text = tostring(row[col.Key] == nil and "" or row[col.Key])
		end
		Theme.Paint(item.Frame, { BackgroundColor3 = self.Value == row and "Surface3" or "Surface2" })
	end
	for i = #used + 1, #self._pool do
		self._pool[i].Frame.Visible = false
	end
end

function Table:_newRow()
	local item = { Cells = {} }
	local frame = Util.New("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.new(1, -10, 0, self.RowHeight), Parent = self._list })
	Util.Corner(5, frame)
	Theme.Paint(frame, { BackgroundColor3 = "Surface2" })
	local x = 0
	local actionsWidth = #self.Actions * 22
	for c, col in self.Columns do
		local w = col.Width or (1 / #self.Columns)
		local cell = Util.Label({ FontFace = c == 1 and Theme.Fonts.SemiBold or Theme.Fonts.Regular, TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = col.Align == "Center" and Enum.TextXAlignment.Center or (col.Align == "Right" and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left), Size = UDim2.new(w, c == #self.Columns and -actionsWidth - 10 or -6, 1, 0), Position = UDim2.new(x, 8, 0, 0), Parent = frame })
		Theme.Paint(cell, { TextColor3 = c == 1 and "Text" or "TextDim" })
		item.Cells[c] = cell
		x += w
	end
	for a, action in self.Actions do
		local b = Util.New("ImageButton", { BackgroundTransparency = 1, Image = Icons.Get(action.Icon) or "", Size = UDim2.fromOffset(15, 15), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8 - (a - 1) * 22, 0.5, 0), ZIndex = 2, Parent = frame })
		Theme.Paint(b, { ImageColor3 = "TextDim" })
		if action.Tooltip then
			Shared.Overlay.Hover(b, function()
				return action.Tooltip
			end)
		end
		b.Activated:Connect(function()
			if item.Row then
				Util.SafeCall(action.Callback, item.Row)
			end
		end)
	end
	frame.MouseEnter:Connect(function()
		Theme.Paint(frame, { BackgroundColor3 = "Surface3" }, 0.08)
	end)
	frame.MouseLeave:Connect(function()
		Theme.Paint(frame, { BackgroundColor3 = self.Value == item.Row and "Surface3" or "Surface2" }, 0.12)
	end)
	frame.Activated:Connect(function()
		self.Value = item.Row
		self:_drawVisible()
		self.Changed:Fire(item.Row)
		if self.OnSelect then
			Util.SafeCall(self.OnSelect, item.Row)
		end
		self:_fireCallbacks()
	end)
	item.Frame = frame
	return item
end

function Table:_render()
	self:_refresh()
end

-- ═══ Card ═════════════════════════════════════════════════════════════════
--[[
	Section:Card({
		Title, Subtitle, Body, Image = icon/asset, Model = Instance (3D viewport),
		Progress = { 3, 13 }, Badge, Callback = fn (makes the card clickable), Height = 96
	})
]]
local Card = Base.extend("Card")
classes.Card = Card
noState(Card)

function Card.new(section, options)
	local self = Base.new(Card, section, { Name = options.Title or options.Name or "", Callback = options.Callback, Visible = options.Visible })
	self.Subtitle = options.Subtitle
	self.Body = options.Body or options.Content
	self.Image = options.Image
	self.Model = options.Model
	self.ProgressValue = options.Progress
	self.Badge = options.Badge
	self.Height = options.Height or 96
	return self:_register()
end

function Card:_build(parent)
	local card = Util.New("TextButton", { Name = "Card", Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, self.Height), ClipsDescendants = true, Parent = parent })
	self.Frame = card
	Util.Corner(8, card)
	Theme.Paint(card, { BackgroundColor3 = "Surface2" })
	local stroke = Util.Stroke(card)
	Theme.Paint(stroke, { Color = "Stroke" })
	local left = 12
	local media = self.Height - 16
	if self.Model and typeof(self.Model) == "Instance" then
		local vp = Util.New("ViewportFrame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(media, media), Position = UDim2.fromOffset(8, 8), Ambient = Color3.fromRGB(200, 200, 200), LightColor = Color3.new(1, 1, 1), Parent = card })
		Util.Corner(6, vp)
		Shared.Lib:_fillViewport(vp, self.Model)
		left = media + 18
	elseif Icons.Get(self.Image) then
		local img = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get(self.Image), ScaleType = Enum.ScaleType.Crop, Size = UDim2.fromOffset(media, media), Position = UDim2.fromOffset(8, 8), Parent = card })
		Util.Corner(6, img)
		left = media + 18
	end
	local title = Util.Label({ Text = self.Name, FontFace = Theme.Fonts.SemiBold, TextSize = 14, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -left - 10, 0, 18), Position = UDim2.fromOffset(left, 10), Parent = card })
	Theme.Paint(title, { TextColor3 = "Text" })
	local sub = Util.Label({ Text = self.Subtitle or "", FontFace = Theme.Fonts.Regular, TextSize = 11, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -left - 10, 0, 14), Position = UDim2.fromOffset(left, 29), Parent = card })
	Theme.Paint(sub, { TextColor3 = "TextMute" })
	local body = Util.Label({ Text = self.Body or "", FontFace = Theme.Fonts.Regular, TextSize = 12, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Size = UDim2.new(1, -left - 10, 1, -64), Position = UDim2.fromOffset(left, 46), Parent = card })
	Theme.Paint(body, { TextColor3 = "TextDim" })
	if self.ProgressValue then
		local cur, max = self.ProgressValue[1] or 0, self.ProgressValue[2] or 1
		local track = Util.New("Frame", { Size = UDim2.new(1, -left - 60, 0, 3), Position = UDim2.new(0, left, 1, -12), Parent = card })
		Util.Round(track)
		Theme.Paint(track, { BackgroundColor3 = "Surface3" })
		local fill = Util.New("Frame", { Size = UDim2.fromScale(math.clamp(cur / math.max(max, 1), 0, 1), 1), Parent = track })
		Util.Round(fill)
		Theme.Paint(fill, { BackgroundColor3 = "Accent" })
		local label = Util.Label({ Text = cur .. " / " .. max, FontFace = Theme.Fonts.Mono, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(0, 50, 0, 14), Position = UDim2.new(1, -60, 1, -19), Parent = card })
		Theme.Paint(label, { TextColor3 = "TextDim" })
	end
	if self.Badge then
		local badge = Util.Label({ Text = self.Badge, FontFace = Theme.Fonts.Bold, TextSize = 9, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 16), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 10), BackgroundTransparency = 0, Parent = card })
		Util.Padding(badge, 0, 6, 0, 6)
		Util.Corner(4, badge)
		Theme.Paint(badge, { BackgroundColor3 = "Accent", TextColor3 = "AccentInk" })
	end
	card.MouseEnter:Connect(function()
		Theme.Paint(stroke, { Color = "StrokeHi" }, 0.12)
	end)
	card.MouseLeave:Connect(function()
		Theme.Paint(stroke, { Color = "Stroke" }, 0.15)
	end)
	card.Activated:Connect(function()
		self:_fireCallbacks()
	end)
	self._titleLabel, self._subLabel, self._bodyLabel = title, sub, body
end

function Card:_callbackArgs()
	return self
end

function Card:SetTitle(t)
	self.Name = t
	if self._titleLabel then
		self._titleLabel.Text = t
	end
	return self
end
function Card:SetSubtitle(t)
	self.Subtitle = t
	if self._subLabel then
		self._subLabel.Text = t or ""
	end
	return self
end
function Card:SetBody(t)
	self.Body = t
	if self._bodyLabel then
		self._bodyLabel.Text = t or ""
	end
	return self
end

-- ═══ Image ════════════════════════════════════════════════════════════════
-- Section:Image({ Image = id|url|icon, Height = 120, ScaleType = Enum.ScaleType.Fit, Caption })
local Image = Base.extend("Image")
classes.Image = Image
noState(Image)

function Image.new(section, options)
	local self = Base.new(Image, section, { Name = options.Caption or "Image" })
	self.Value = options.Image
	self.Height = options.Height or 120
	self.ScaleType = options.ScaleType or Enum.ScaleType.Fit
	self.Caption = options.Caption
	return self:_register()
end

function Image:_build(parent)
	local frame = Util.New("Frame", { Name = "Image", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, self.Height + (self.Caption and 18 or 0)), Parent = parent })
	self.Frame = frame
	local img = Util.New("ImageLabel", { ScaleType = self.ScaleType, Size = UDim2.new(1, -8, 0, self.Height), Position = UDim2.fromOffset(4, 0), Parent = frame })
	Util.Corner(6, img)
	Theme.Paint(img, { BackgroundColor3 = "Surface2" })
	self._img = img
	if self.Caption then
		local cap = Util.Label({ Text = self.Caption, FontFace = Theme.Fonts.Regular, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, self.Height + 2), Parent = frame })
		Theme.Paint(cap, { TextColor3 = "TextMute" })
	end
end

function Image:_render()
	if self._img then
		self._img.Image = Icons.Get(self.Value) or ""
	end
end

-- ═══ Console ══════════════════════════════════════════════════════════════
-- Section:Console({ Name, Height = 160, MaxLines = 200 }) → :Log(text, level) :Clear() :GetLines()
local Console = Base.extend("Console")
classes.Console = Console
noState(Console)

local levelTokens = { info = "TextDim", success = "Success", warn = "Warning", warning = "Warning", error = "Error", debug = "TextMute" }

function Console.new(section, options)
	local self = Base.new(Console, section, options)
	self.Height = options.Height or 160
	self.MaxLines = options.MaxLines or 200
	self.Lines = {}
	self.Value = self.Lines
	return self:_register()
end

function Console:Log(text, level)
	level = level or "info"
	local line = { Text = tostring(text), Level = level, Time = os.date("%H:%M:%S") }
	table.insert(self.Lines, line)
	while #self.Lines > self.MaxLines do
		table.remove(self.Lines, 1)
		if self._labels and self._labels[1] then
			table.remove(self._labels, 1):Destroy()
		end
	end
	if self._list then
		self:_line(line)
	end
	return self
end
function Console:Info(t)
	return self:Log(t, "info")
end
function Console:Warn(t)
	return self:Log(t, "warn")
end
function Console:Error(t)
	return self:Log(t, "error")
end
function Console:Success(t)
	return self:Log(t, "success")
end
function Console:Clear()
	table.clear(self.Lines)
	for _, l in self._labels or {} do
		l:Destroy()
	end
	self._labels = {}
	return self
end
function Console:GetLines()
	return table.clone(self.Lines)
end

function Console:_line(line)
	self._order = (self._order or 0) + 1
	local label = Util.Label({ Text = "<font transparency=\"0.5\">" .. line.Time .. "</font>  " .. Util.Escape(line.Text), RichText = true, FontFace = Theme.Fonts.Mono, TextSize = 11, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = self._order, Parent = self._list })
	Theme.Paint(label, { TextColor3 = levelTokens[line.Level] or "TextDim" })
	table.insert(self._labels, label)
	task.defer(function()
		if self._list then
			self._list.CanvasPosition = Vector2.new(0, 1e6)
		end
	end)
end

function Console:_build(parent)
	local frame = Util.New("Frame", { Name = "Console", Size = UDim2.new(1, 0, 0, self.Height), Parent = parent })
	self.Frame = frame
	Util.Corner(6, frame)
	Theme.Paint(frame, { BackgroundColor3 = "Bg" })
	Theme.Paint(Util.Stroke(frame), { Color = "Stroke" })
	local list = Util.New("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, Parent = frame })
	Theme.Paint(list, { ScrollBarImageColor3 = "StrokeHi" })
	Util.List(list, 1)
	Util.Padding(list, 6, 8, 6, 8)
	self._list, self._labels = list, {}
	for _, line in self.Lines do
		self:_line(line)
	end
end

-- ═══ Code ═════════════════════════════════════════════════════════════════
-- Section:Code({ Title, Code = "...", Copy = true })
local Code = Base.extend("Code")
classes.Code = Code
noState(Code)

function Code.new(section, options)
	local self = Base.new(Code, section, { Name = options.Title or options.Name or "" })
	self.Value = tostring(options.Code or options.Content or "")
	return self:_register()
end

function Code:_build(parent)
	local frame = Util.New("Frame", { Name = "Code", AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), Parent = parent })
	self.Frame = frame
	Util.Corner(6, frame)
	Theme.Paint(frame, { BackgroundColor3 = "Bg" })
	Theme.Paint(Util.Stroke(frame), { Color = "Stroke" })
	Util.Padding(frame, 8, 34, 8, 10)
	local text = Util.Label({ Text = self.Value, FontFace = Theme.Fonts.Mono, TextSize = 11, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), Parent = frame })
	Theme.Paint(text, { TextColor3 = "Text" })
	local copy = Util.New("ImageButton", { BackgroundTransparency = 1, Image = Icons.Get("copy") or "", Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 26, 0, 0), Parent = frame })
	Theme.Paint(copy, { ImageColor3 = "TextDim" })
	copy.Activated:Connect(function()
		Env.Clipboard(self.Value)
		Theme.Paint(copy, { ImageColor3 = "Success" }, 0.1)
		task.delay(1, function()
			Theme.Paint(copy, { ImageColor3 = "TextDim" }, 0.3)
		end)
		if self.Library.Notify then
			self.Library:Notify({ Content = Locale.T("Copied"), Type = "success", Duration = 2 })
		end
	end)
	self._text = text
end

function Code:_render()
	if self._text then
		self._text.Text = self.Value
	end
end

return classes
