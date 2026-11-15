--!nocheck
--[[
	Proximity · Elements/Choice
	Dropdown (single / multi / players) and Input.

	Section:Dropdown({
		Name, Values = {...}, Default, Multi = false, Max, Min = 0,
		Search = auto (> 7 values), Placeholder = "None", AllowNone = true,
		Deletable = false, OnDelete = fn(value) → false to cancel,
		Icons = { value = icon }, Flags = { value = "🇷🇺" } (prefix text),
		Callback(value | {values}),
	})
	Methods: :SetValues(list, keepSelection?) :Refresh :AddValue :RemoveValue :Clear
	         :Open :Close :IsOpen :Select(v) :Deselect(v) :IsSelected(v) :GetValues

	Section:PlayerDropdown({ Name, Multi, ExcludeSelf = true, Callback })
		→ a Dropdown kept in sync with the server's players.

	Section:Input({
		Name, Default = "", Placeholder, Numeric = false, Min, Max,
		MaxLength, Finished = false (only on Enter/blur), ClearOnFocus = false,
		Validate = fn(text) → ok, message, Callback(text)
	})
	Methods: :Focus :Blur :Clear :SetPlaceholder
]]

local Util = require("../Core/Util")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")
local Theme = require("../Theme")
local Icons = require("../Icons")
local Locale = require("../Locale")
local Shared = require("../Shared")
local Base = require("./Base")

local Players = Env.Service("Players")

local classes = {}

-- ═══ Dropdown ═════════════════════════════════════════════════════════════
local Dropdown = Base.extend("Dropdown")
classes.Dropdown = Dropdown

function Dropdown.new(section, options)
	local self = Base.new(Dropdown, section, options)
	self.Values = table.clone(Util.Opt(options, "Values", "Options", "Items", "List") or {})
	self.Multi = options.Multi == true
	self.MaxSelect = options.Max
	self.MinSelect = options.Min or 0
	self.Placeholder = options.Placeholder or Locale.T("None")
	self.AllowNone = options.AllowNone ~= false
	self.SearchEnabled = options.Search
	self.Deletable = options.Deletable
	self.OnDelete = options.OnDelete
	self.ValueIcons = options.Icons or {}
	self.Prefixes = options.Prefixes or options.Flags or {}
	self.Display = options.Display -- fn(value) → text
	local default = Util.Opt(options, "Default", "Value")
	if self.Multi then
		default = type(default) == "table" and default or (default ~= nil and { default } or {})
	end
	self.Default = self:_normalize(default) or (self.Multi and {} or nil)
	self.Value = Util.DeepCopy(self.Default)
	local default = Util.Opt(options, "Default", "Value")
	if default ~= nil and not self.Multi and self.Value == nil then
		Shared.Lib:_optionWarning("Dropdown", self.Name, "default value " .. tostring(default) .. " is not in Values")
	end
	return self:_register()
end

function Dropdown:_normalize(v)
	if self.Multi then
		if type(v) ~= "table" then
			v = v ~= nil and { v } or {}
		end
		local out, seen = {}, {}
		-- accept both arrays and { Head = true } dictionaries
		local list = v
		if #v == 0 and next(v) ~= nil then
			list = {}
			for k, on in v do
				if on then
					table.insert(list, k)
				end
			end
		end
		for _, item in list do
			if table.find(self.Values, item) and not seen[item] then
				seen[item] = true
				table.insert(out, item)
			end
		end
		-- keep declaration order
		table.sort(out, function(a, b)
			return (table.find(self.Values, a) or 0) < (table.find(self.Values, b) or 0)
		end)
		return out
	end
	if v == nil then
		return nil
	end
	if table.find(self.Values, v) then
		return v
	end
	return nil
end

function Dropdown:Set(value, silent)
	if not self.Multi and value == nil then
		-- explicit clear of a single dropdown
		if self.Value == nil then
			return self
		end
		local old = self.Value
		self.Value = nil
		if self.Flag then
			self.Library.Flags[self.Flag] = nil
		end
		if self._mounted then
			self:_render(true)
		end
		if not silent then
			self:_fireCallbacks()
		end
		self.Changed:Fire(nil, old)
		self.Library:_onElementChanged(self, nil, old)
		return self
	end
	return Base.Set(self, value, silent)
end

function Dropdown:_text(v)
	if v == nil then
		return self.Placeholder
	end
	local text = self.Display and self.Display(v) or tostring(v)
	local prefix = self.Prefixes[v]
	return prefix and (prefix .. "  " .. text) or text
end

function Dropdown:GetText(): string
	if self.Multi then
		local n = #self.Value
		if n == 0 then
			return self.Placeholder
		elseif n <= 2 then
			local parts = {}
			for _, v in self.Value do
				table.insert(parts, self:_text(v))
			end
			return table.concat(parts, ", ")
		end
		return self:_text(self.Value[1]) .. ", +" .. (n - 1)
	end
	return self:_text(self.Value)
end

function Dropdown:IsSelected(v): boolean
	if self.Multi then
		return table.find(self.Value, v) ~= nil
	end
	return self.Value == v
end

function Dropdown:Select(v)
	if self.Multi then
		if self:IsSelected(v) then
			return self
		end
		if self.MaxSelect and #self.Value >= self.MaxSelect then
			return self
		end
		local nv = table.clone(self.Value)
		table.insert(nv, v)
		return self:Set(nv)
	end
	return self:Set(v)
end

function Dropdown:Deselect(v)
	if self.Multi then
		local nv = table.clone(self.Value)
		local i = table.find(nv, v)
		if i and #nv > self.MinSelect then
			table.remove(nv, i)
			return self:Set(nv)
		end
		return self
	end
	if self.Value == v and self.AllowNone then
		return self:Set(nil)
	end
	return self
end

function Dropdown:_pick(v)
	local before = Util.DeepCopy(self.Value)
	if self.Multi then
		if self:IsSelected(v) then
			self:Deselect(v)
		else
			self:Select(v)
		end
	else
		if self.Value == v and self.AllowNone and self.Opts.Toggleable then
			self:Set(nil)
		else
			self:Set(v)
		end
		self:Close()
	end
	if not Util.Equal(before, self.Value) then
		self.Library:_pushHistory(self, before, Util.DeepCopy(self.Value))
	end
end

function Dropdown:GetValues()
	return table.clone(self.Values)
end

function Dropdown:SetValues(values: { any }, keep: boolean?)
	self.Values = table.clone(values or {})
	local current = self.Value
	if keep ~= false then
		local nv = self:_normalize(current)
		if self.Multi then
			self.Value = nv or {}
		else
			self.Value = nv
		end
	else
		self.Value = self.Multi and {} or nil
	end
	if self.Flag then
		self.Library.Flags[self.Flag] = self.Value
	end
	if self._mounted then
		self:_render(false)
	end
	if self._popup and self._popup.Open then
		self:_fillList()
	end
	if not Util.Equal(current, self.Value) then
		self:_fireCallbacks()
		self.Changed:Fire(self.Value, current)
	end
	return self
end
Dropdown.Refresh = Dropdown.SetValues

function Dropdown:AddValue(v)
	if not table.find(self.Values, v) then
		local list = table.clone(self.Values)
		table.insert(list, v)
		self:SetValues(list, true)
	end
	return self
end
Dropdown.Add = Dropdown.AddValue

function Dropdown:RemoveValue(v)
	local list = table.clone(self.Values)
	local i = table.find(list, v)
	if i then
		table.remove(list, i)
		self:SetValues(list, true)
	end
	return self
end
Dropdown.Remove = Dropdown.RemoveValue

function Dropdown:Clear()
	return self:Set(self.Multi and {} or nil)
end

function Dropdown:_serialize()
	return self.Value
end

function Dropdown:_navActivate()
	if self:IsOpen() then
		self:Close()
	else
		self:Open()
	end
end

function Dropdown:_navAdjust(dir)
	if self.Multi or #self.Values == 0 then
		return
	end
	local i = table.find(self.Values, self.Value) or 0
	i = (i - 1 + dir) % #self.Values + 1
	self:_userSet(self.Values[i])
end

function Dropdown:_build(parent)
	local row = self:_row(parent, 34)
	local box = Util.New("TextButton", {
		Name = "Box",
		Text = "",
		AutoButtonColor = false,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 24),
		LayoutOrder = 100,
		Parent = self._right,
	})
	Util.Corner(5, box)
	Theme.Paint(box, { BackgroundColor3 = "Surface3" })
	local stroke = Util.Stroke(box)
	Theme.Paint(stroke, { Color = "Stroke" })
	Util.Padding(box, 0, 26, 0, 9)
	Util.New("UISizeConstraint", { MinSize = Vector2.new(70, 24), MaxSize = Vector2.new(190, 24), Parent = box })
	local label = Util.Label({
		Text = "",
		FontFace = Theme.Fonts.Medium,
		TextSize = 12,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = box,
	})
	Util.New("UISizeConstraint", { MaxSize = Vector2.new(135, 24), Parent = label })
	local chevron = Util.New("ImageLabel", {
		BackgroundTransparency = 1,
		Image = Icons.Get("chevron-down") or "",
		Size = UDim2.fromOffset(13, 13),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 19, 0.5, 0),
		Parent = box,
	})
	Theme.Paint(chevron, { ImageColor3 = "TextDim" })
	self._box, self._boxStroke, self._label, self._chevron = box, stroke, label, chevron
	box.Activated:Connect(function()
		if self:IsLocked() then
			return
		end
		if self:IsOpen() then
			self:Close()
		else
			self:Open()
		end
	end)
	local hit = Util.Hitbox(row, 0)
	hit.Activated:Connect(function()
		if not self:IsLocked() and not self:IsOpen() then
			self:Open()
		end
	end)
end

function Dropdown:_renderChips()
	local box = self._box
	if not box then
		return
	end
	if self._chips then
		self._chips:Destroy()
		self._chips = nil
	end
	if not self.Multi or #self.Value == 0 then
		self._label.Visible = true
		return
	end
	self._label.Visible = false
	local holder = Util.New("Frame", { Name = "Chips", BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromScale(0, 1), Parent = box })
	Util.List(holder, 4, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
	self._chips = holder
	local shown = 0
	for _, v in self.Value do
		if shown >= 2 then
			break
		end
		shown += 1
		local chip = Util.New("TextButton", { Text = "", AutoButtonColor = false, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 18), LayoutOrder = shown, Parent = holder })
		Util.Corner(4, chip)
		Util.Padding(chip, 0, 4, 0, 6)
		Theme.Paint(chip, { BackgroundColor3 = "Surface2" })
		Util.List(chip, 3, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
		local text = Util.Label({ Text = Util.Truncate(self:_text(v), 10), FontFace = Theme.Fonts.Medium, TextSize = 11, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromScale(0, 1), Parent = chip })
		Theme.Paint(text, { TextColor3 = "Text" })
		local x = Util.New("ImageButton", { BackgroundTransparency = 1, Image = Icons.Get("x") or "", Size = UDim2.fromOffset(10, 10), LayoutOrder = 2, Parent = chip })
		Theme.Paint(x, { ImageColor3 = "TextMute" })
		x.Activated:Connect(function()
			if not self:IsLocked() then
				local before = Util.DeepCopy(self.Value)
				self:Deselect(v)
				self.Library:_pushHistory(self, before, Util.DeepCopy(self.Value))
			end
		end)
	end
	if #self.Value > shown then
		local more = Util.Label({ Text = "+" .. (#self.Value - shown), FontFace = Theme.Fonts.MonoBold, TextSize = 11, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromScale(0, 1), LayoutOrder = 9, Parent = holder })
		Theme.Paint(more, { TextColor3 = "TextDim" })
	end
end

function Dropdown:_render()
	self:_renderChips()
	if self._label then
		self._label.Text = self:GetText()
		Theme.Paint(self._label, { TextColor3 = (self.Value == nil or (self.Multi and #self.Value == 0)) and "TextMute" or "Text" })
	end
	if self._popup and self._popup.Open then
		self:_paintRows()
	end
end

function Dropdown:IsOpen(): boolean
	return self._popup ~= nil and self._popup.Open
end

function Dropdown:Close()
	if self._popup then
		self._popup:Close()
	end
	return self
end

function Dropdown:Open()
	if not self._box or self:IsOpen() then
		return self
	end
	local Overlay = Shared.Overlay
	local popup = Overlay.Popup({
		Anchor = self._box,
		Width = math.max(180, self._box.AbsoluteSize.X / (Shared.Scale or 1)),
		MaxHeight = 260,
		Align = "End",
		Padding = 4,
		OnClose = function()
			Theme.Paint(self._boxStroke, { Color = "Stroke" }, 0.15)
			Tween.Play(self._chevron, { Rotation = 0 }, 0.15)
		end,
	})
	self._popup = popup
	Theme.Paint(self._boxStroke, { Color = "Accent" }, 0.15)
	Tween.Play(self._chevron, { Rotation = 180 }, 0.15)
	self._query = ""
	local useSearch = self.SearchEnabled
	if useSearch == nil then
		useSearch = #self.Values > 7
	end
	if useSearch then
		local search = Util.New("TextBox", {
			Name = "Search",
			Text = "",
			PlaceholderText = Locale.T("Search") .. "…",
			ClearTextOnFocus = false,
			FontFace = Theme.Fonts.Regular,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 26),
			LayoutOrder = 0,
			ZIndex = popup.Frame.ZIndex,
			Parent = popup.Content,
		})
		Util.Corner(5, search)
		Util.Padding(search, 0, 8, 0, 8)
		Theme.Paint(search, { BackgroundColor3 = "Surface2", TextColor3 = "Text", PlaceholderColor3 = "TextMute" })
		search:GetPropertyChangedSignal("Text"):Connect(function()
			self._query = search.Text
			self:_fillList()
		end)
		task.defer(function()
			if not game:GetService("UserInputService").TouchEnabled then
				search:CaptureFocus()
			end
		end)
	end
	self:_fillList()
	return self
end

function Dropdown:_fillList()
	local popup = self._popup
	if not popup then
		return
	end
	for _, child in popup.Content:GetChildren() do
		if child.Name == "Item" or child.Name == "Empty" then
			child:Destroy()
		end
	end
	self._rows = {}
	local list = {}
	for i, v in self.Values do
		local score = Util.Fuzzy(self._query or "", self:_text(v))
		if score then
			table.insert(list, { v = v, s = score, i = i })
		end
	end
	if (self._query or "") ~= "" then
		table.sort(list, function(a, b)
			return a.s > b.s
		end)
	end
	if #list == 0 then
		local empty = Util.Label({ Name = "Empty", Text = Locale.T("NoResults"), FontFace = Theme.Fonts.Regular, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 28), LayoutOrder = 1, ZIndex = popup.Frame.ZIndex, Parent = popup.Content })
		Theme.Paint(empty, { TextColor3 = "TextMute" })
	end
	for order, item in list do
		local v = item.v
		local row = Util.New("TextButton", {
			Name = "Item",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 26),
			LayoutOrder = order + 1,
			ZIndex = popup.Frame.ZIndex,
			Parent = popup.Content,
		})
		Util.Corner(5, row)
		Theme.Paint(row, { BackgroundColor3 = "Surface3" })
		local x = 8
		local icon = Icons.Get(self.ValueIcons[v])
		if icon then
			local img = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = icon, Size = UDim2.fromOffset(14, 14), Position = UDim2.new(0, 8, 0.5, -7), ZIndex = row.ZIndex, Parent = row })
			Theme.Paint(img, { ImageColor3 = "TextDim" })
			x = 28
		end
		local label = Util.Label({ Text = self:_text(v), FontFace = Theme.Fonts.Medium, TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(x, 0), Size = UDim2.new(1, -x - 30, 1, 0), ZIndex = row.ZIndex, Parent = row })
		local check = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get("check") or "", Size = UDim2.fromOffset(13, 13), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), ZIndex = row.ZIndex, Parent = row })
		Theme.Paint(check, { ImageColor3 = "Accent" })
		if self.Deletable then
			check.Position = UDim2.new(1, -28, 0.5, 0)
			local del = Util.New("ImageButton", { BackgroundTransparency = 1, Image = Icons.Get("trash-2") or "", Size = UDim2.fromOffset(13, 13), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), ZIndex = row.ZIndex + 1, Parent = row })
			Theme.Paint(del, { ImageColor3 = "TextMute" })
			local armed = false
			del.Activated:Connect(function()
				if not armed then
					armed = true
					Theme.Paint(del, { ImageColor3 = "Risky" }, 0.1)
					task.delay(2, function()
						armed = false
						if del.Parent then
							Theme.Paint(del, { ImageColor3 = "TextMute" }, 0.1)
						end
					end)
					return
				end
				if self.OnDelete then
					local ok, result = Util.SafeCall(self.OnDelete, v)
					if ok and result == false then
						return
					end
				end
				self:RemoveValue(v)
			end)
		end
		row.MouseEnter:Connect(function()
			Tween.Play(row, { BackgroundTransparency = 0.4 }, 0.08)
		end)
		row.MouseLeave:Connect(function()
			Tween.Play(row, { BackgroundTransparency = 1 }, 0.12)
		end)
		row.Activated:Connect(function()
			self:_pick(v)
		end)
		self._rows[v] = { Label = label, Check = check }
	end
	self:_paintRows()
end

function Dropdown:_paintRows()
	for v, refs in self._rows or {} do
		local on = self:IsSelected(v)
		refs.Check.Visible = on
		Theme.Paint(refs.Label, { TextColor3 = on and "Text" or "TextDim" })
	end
end

function Dropdown:Destroy()
	self:Close()
	Base.Destroy(self)
end

-- ═══ PlayerDropdown ═══════════════════════════════════════════════════════
function classes.PlayerDropdown(section, options)
	options = table.clone(options or {})
	local exclude = options.ExcludeSelf ~= false
	local function names()
		local out = {}
		for _, p in Players:GetPlayers() do
			if not (exclude and p == Players.LocalPlayer) then
				table.insert(out, p.Name)
			end
		end
		table.sort(out, function(a, b)
			return string.lower(a) < string.lower(b)
		end)
		return out
	end
	options.Values = names()
	options.Display = options.Display
		or function(name)
			local p = Players:FindFirstChild(name)
			if p and p.DisplayName ~= p.Name then
				return p.DisplayName .. " (@" .. name .. ")"
			end
			return name
		end
	local dropdown = Dropdown.new(section, options)
	dropdown.Type = "PlayerDropdown"
	local refresh = function()
		dropdown:SetValues(names(), true)
	end
	dropdown.Maid:Connect(Players.PlayerAdded, refresh)
	dropdown.Maid:Connect(Players.PlayerRemoving, function()
		task.defer(refresh)
	end)
	function dropdown:GetPlayer()
		if self.Multi then
			local out = {}
			for _, name in self.Value do
				local p = Players:FindFirstChild(name)
				if p then
					table.insert(out, p)
				end
			end
			return out
		end
		return self.Value and Players:FindFirstChild(self.Value) or nil
	end
	return dropdown
end

-- ═══ Input ════════════════════════════════════════════════════════════════
local Input = Base.extend("Input")
classes.Input = Input

function Input.new(section, options)
	local self = Base.new(Input, section, options)
	self.Placeholder = options.Placeholder or ""
	self.Numeric = options.Numeric == true
	self.Min, self.Max = options.Min, options.Max
	self.MaxLength = options.MaxLength
	self.Finished = options.Finished == true
	self.ClearOnFocus = options.ClearOnFocus == true
	self.Validate = options.Validate
	self.Wide = options.Wide
	self.Default = self:_normalize(Util.Opt(options, "Default", "Value", "Text") or (self.Numeric and (self.Min or 0) or "")) or ""
	self.Value = self.Default
	return self:_register()
end

function Input:_normalize(v)
	if self.Numeric then
		local n = tonumber(v)
		if not n then
			return nil
		end
		if self.Min then
			n = math.max(n, self.Min)
		end
		if self.Max then
			n = math.min(n, self.Max)
		end
		return n
	end
	v = tostring(v == nil and "" or v)
	if self.MaxLength then
		v = string.sub(v, 1, self.MaxLength)
	end
	return v
end

function Input:_build(parent)
	local row = self:_row(parent, self.Wide and 60 or 34)
	local box = Util.New("TextBox", {
		Name = "Box",
		Text = tostring(self.Value),
		PlaceholderText = self.Placeholder,
		ClearTextOnFocus = self.ClearOnFocus,
		FontFace = Theme.Fonts.Medium,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.fromOffset(124, 24),
		LayoutOrder = 100,
		Parent = self._right,
	})
	if self.Wide then
		box.Parent = row
		box.Size = UDim2.new(1, -16, 0, 26)
		box.Position = UDim2.new(0, 8, 1, -31)
		self._textBox.Size = UDim2.new(1, -16, 0, 30)
		self._title.Position = UDim2.new(0, 0, 0, 8)
	end
	Util.Corner(5, box)
	Util.Padding(box, 0, 8, 0, 8)
	Theme.Paint(box, { BackgroundColor3 = "Surface3", TextColor3 = "Text", PlaceholderColor3 = "TextMute" })
	local stroke = Util.Stroke(box)
	Theme.Paint(stroke, { Color = "Stroke" })
	self._box, self._boxStroke = box, stroke
	box.Focused:Connect(function()
		Theme.Paint(stroke, { Color = "Accent" }, 0.15)
	end)
	local function commit()
		local text = box.Text
		if self.Validate then
			local ok, valid, message = pcall(self.Validate, text)
			if ok and valid == false then
				Theme.Paint(stroke, { Color = "Risky" }, 0.1)
				if message and self.Library.Notify then
					self.Library:Notify({ Title = self.Name, Content = tostring(message), Type = "warning", Duration = 3 })
				end
				return false
			end
		end
		local v = self:_normalize(text)
		if v == nil then
			box.Text = tostring(self.Value)
			return false
		end
		self:_userSet(v)
		return true
	end
	box.FocusLost:Connect(function()
		Theme.Paint(stroke, { Color = "Stroke" }, 0.15)
		if self.Finished or self.Numeric then
			commit()
		end
		box.Text = tostring(self.Value)
	end)
	box:GetPropertyChangedSignal("Text"):Connect(function()
		if self.Numeric then
			local cleaned = string.gsub(box.Text, "[^%d%.%-]", "")
			if cleaned ~= box.Text then
				box.Text = cleaned
				return
			end
		end
		if self.MaxLength and #box.Text > self.MaxLength then
			box.Text = string.sub(box.Text, 1, self.MaxLength)
			return
		end
		if not self.Finished and not self.Numeric and box:IsFocused() then
			commit()
		end
	end)
end

function Input:_render()
	if self._box and not self._box:IsFocused() then
		self._box.Text = tostring(self.Value)
	end
end

function Input:_onState(locked)
	if self._box then
		self._box.TextEditable = not locked
	end
end

function Input:_navActivate()
	self:Focus()
end

function Input:Focus()
	if self._box then
		self._box:CaptureFocus()
	end
	return self
end
function Input:Blur()
	if self._box then
		self._box:ReleaseFocus()
	end
	return self
end
function Input:Clear()
	return self:Set(self.Numeric and (self.Min or 0) or "")
end
function Input:SetPlaceholder(text: string)
	self.Placeholder = text
	if self._box then
		self._box.PlaceholderText = text
	end
	return self
end
classes.TextBox = Input
classes.Textbox = Input

return classes
