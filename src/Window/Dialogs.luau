--!nocheck
--[[
	Proximity · Window/Dialogs
	Modal layer inside a window: Dialog, Confirm, Prompt, the Ctrl+K command
	palette and the onboarding Tour. Installed onto the Window class.
]]

local Util = require("../Core/Util")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")
local Theme = require("../Theme")
local Icons = require("../Icons")
local Locale = require("../Locale")
local Shared = require("../Shared")

local UIS = Env.Service("UserInputService")

return function(Window)
	-- Dim layer covering the window; returns the layer and a close function.
	local function modal(self, width, height)
		local layer = Util.New("TextButton", { Name = "Modal", Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 80, Parent = self.Canvas })
		Tween.Play(layer, { BackgroundTransparency = 0.45 }, 0.18)
		local box = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.fromOffset(width, height or 0), AutomaticSize = height and Enum.AutomaticSize.None or Enum.AutomaticSize.Y, ZIndex = 81, Parent = layer })
		Util.Corner(10, box)
		Theme.Paint(box, { BackgroundColor3 = "Elevated" })
		Theme.Paint(Util.Stroke(box), { Color = "StrokeHi" })
		local scale = Util.New("UIScale", { Scale = 0.96, Parent = box })
		Tween.Play(scale, { Scale = 1 }, 0.25, Enum.EasingStyle.Back)
		Tween.Play(box, { Position = UDim2.fromScale(0.5, 0.5) }, 0.25)
		local closed = false
		local function close()
			if closed then
				return
			end
			closed = true
			Tween.Play(layer, { BackgroundTransparency = 1 }, 0.15)
			Tween.Play(scale, { Scale = 0.97 }, 0.15)
			box.Visible = false
			task.delay(0.16, function()
				layer:Destroy()
			end)
		end
		return layer, box, close
	end

	local function zfix(root, base)
		for _, d in root:GetDescendants() do
			if d:IsA("GuiObject") then
				d.ZIndex = math.max(d.ZIndex, base)
			end
		end
	end

	--[[
		Window:Dialog({
			Title, Content, Icon,
			Buttons = { { Text = "Cancel" }, { Text = "Delete", Style = "Danger", Callback = fn } },
		}) → returns the index of the pressed button (yields)
	]]
	function Window:Dialog(options)
		options = options or {}
		local layer, box, close = modal(self, options.Width or 340)
		Util.Padding(box, 18, 18, 16, 18)
		Util.List(box, 10)
		local title = Util.Label({ Text = options.Title or "", FontFace = Theme.Fonts.SemiBold, TextSize = 16, AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, LayoutOrder = 1, Parent = box })
		Theme.Paint(title, { TextColor3 = "Text" })
		if options.Content then
			local content = Util.Label({ Text = options.Content, FontFace = Theme.Fonts.Regular, TextSize = 13, RichText = true, AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, LineHeight = 1.1, LayoutOrder = 2, Parent = box })
			Theme.Paint(content, { TextColor3 = "TextDim" })
		end
		if options.Build then
			Util.SafeCall(options.Build, box)
		end
		local row = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), LayoutOrder = 10, Parent = box })
		Util.List(row, 8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
		local result = nil
		local thread = coroutine.running()
		local buttons = options.Buttons or { { Text = Locale.T("Ok"), Style = "Primary" } }
		local function finish(i)
			if result ~= nil then
				return
			end
			result = i
			close()
			local b = buttons[i]
			if b and b.Callback then
				Util.SafeCall(b.Callback)
			end
			if coroutine.status(thread) == "suspended" then
				task.spawn(thread, i)
			end
		end
		for i, b in buttons do
			local primary = b.Style == "Primary"
			local danger = b.Style == "Danger"
			local button = Util.New("TextButton", { Text = b.Text or b[1] or "", FontFace = Theme.Fonts.SemiBold, TextSize = 13, AutoButtonColor = false, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 30), LayoutOrder = i, Parent = row })
			Util.Corner(6, button)
			Util.Padding(button, 0, 14, 0, 14)
			Theme.Paint(button, { BackgroundColor3 = primary and "Accent" or (danger and "Risky" or "Surface3"), TextColor3 = (primary or danger) and "AccentInk" or "Text" })
			if danger then
				Theme.Paint(button, { TextColor3 = Color3.new(1, 1, 1) })
			end
			Theme.Paint(Util.Stroke(button), { Color = primary and "Accent" or (danger and "Risky" or "Stroke") })
			button.Activated:Connect(function()
				finish(i)
			end)
		end
		layer.Activated:Connect(function()
			if options.Dismissable ~= false then
				finish(0)
			end
		end)
		local esc = UIS.InputBegan:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.Escape then
				finish(0)
			end
		end)
		layer.Destroying:Connect(function()
			esc:Disconnect()
		end)
		zfix(layer, 82)
		if options.Async then
			return finish
		end
		if coroutine.isyieldable() then
			return coroutine.yield()
		end
		return nil
	end

	-- Yields: true when confirmed.
	function Window:Confirm(options)
		if type(options) == "string" then
			options = { Title = options }
		end
		options = options or {}
		local index = self:Dialog({
			Title = options.Title or Locale.T("Confirm"),
			Content = options.Content,
			Buttons = {
				{ Text = options.CancelText or Locale.T("Cancel") },
				{ Text = options.ConfirmText or Locale.T("Confirm"), Style = options.Danger and "Danger" or "Primary" },
			},
		})
		return index == 2
	end

	-- Yields: the text or nil when cancelled.
	function Window:Prompt(options)
		if type(options) == "string" then
			options = { Title = options }
		end
		options = options or {}
		local box
		local index = self:Dialog({
			Title = options.Title,
			Content = options.Content,
			Build = function(parent)
				box = Util.New("TextBox", { Text = options.Default or "", PlaceholderText = options.Placeholder or "", ClearTextOnFocus = false, FontFace = Theme.Fonts.Medium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 32), LayoutOrder = 5, Parent = parent })
				Util.Corner(6, box)
				Util.Padding(box, 0, 10, 0, 10)
				Theme.Paint(box, { BackgroundColor3 = "Surface2", TextColor3 = "Text", PlaceholderColor3 = "TextMute" })
				Theme.Paint(Util.Stroke(box), { Color = "StrokeHi" })
				task.defer(function()
					box:CaptureFocus()
				end)
			end,
			Buttons = { { Text = Locale.T("Cancel") }, { Text = options.ConfirmText or Locale.T("Ok"), Style = "Primary" } },
		})
		if index == 2 and box then
			return box.Text
		end
		return nil
	end

	-- ─── Command palette (Ctrl+K) ────────────────────────────────────────
	function Window:OpenSearch(query)
		if self._palette then
			return self
		end
		self:Open()
		local Lib = self.Library
		local layer, box, close = modal(self, 460, 340)
		box.Position = UDim2.new(0.5, 0, 0, 40)
		box.AnchorPoint = Vector2.new(0.5, 0)
		self._palette = true
		local input = Util.New("TextBox", { Text = query or "", PlaceholderText = Locale.T("SearchHint"), ClearTextOnFocus = false, FontFace = Theme.Fonts.Medium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(1, -50, 0, 46), Position = UDim2.fromOffset(42, 0), Parent = box })
		Theme.Paint(input, { TextColor3 = "Text", PlaceholderColor3 = "TextMute" })
		local icon = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get("search") or "", Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(16, 15), Parent = box })
		Theme.Paint(icon, { ImageColor3 = "TextDim" })
		local line = Util.New("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.fromOffset(0, 46), BorderSizePixel = 0, Parent = box })
		Theme.Paint(line, { BackgroundColor3 = "Stroke" })
		local list = Util.New("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, -74), Position = UDim2.fromOffset(0, 50), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, Parent = box })
		Util.Padding(list, 4, 8, 4, 8)
		Util.List(list, 2)
		local foot = Util.Label({ Text = "↑↓  " .. Locale.T("Elements") .. "   ⏎  open   esc  close", FontFace = Theme.Fonts.Mono, TextSize = 10, Size = UDim2.new(1, -24, 0, 22), Position = UDim2.new(0, 12, 1, -24), Parent = box })
		Theme.Paint(foot, { TextColor3 = "TextMute" })

		local results, selected, rows = {}, 1, {}
		local function collect(q)
			local out = {}
			for _, cmd in self._commands do
				local s = Util.Fuzzy(q, cmd.Name)
				if s then
					table.insert(out, { Kind = Locale.T("Commands"), Text = cmd.Name, Sub = cmd.Hint, Icon = cmd.Icon or "circle-dot", Score = s + 5, Run = function()
						Util.SafeCall(cmd.Callback)
					end })
				end
			end
			for _, tab in self.Tabs do
				local s = Util.Fuzzy(q, tab.Name)
				if s then
					table.insert(out, { Kind = Locale.T("Tabs"), Text = tab.Name, Icon = tab.Icon or "layout-grid", Score = s + 2, Run = function()
						tab:Select()
					end })
				end
			end
			for _, el in Lib.AllElements do
				if el.Window == self and el.Section and not el.Parent and el.Name and el.Name ~= "" and el.Type ~= "Divider" and el.Type ~= "Spacer" and el.Type ~= "Label" and el.Type ~= "Paragraph" then
					local parent = el.Section.ParentSection
					local hay = el.Name .. " " .. (el.Description or "") .. " " .. (el.Section.Name or "") .. " " .. (parent and parent.Name or "")
					local s = Util.Fuzzy(q, hay)
					if s then
						local value = ""
						if el.Type == "Toggle" then
							value = el.Value and "ON" or "OFF"
						elseif el.GetText then
							value = el:GetText()
						end
						table.insert(out, { Kind = Locale.T("Elements"), Text = el.Name, Sub = el:GetPath(), Value = value, Icon = Lib:IsFavorite(el) and "star" or "corner-down-right", Score = s, Run = function()
							el:Focus()
						end })
					end
				end
			end
			table.sort(out, function(a, b)
				return a.Score > b.Score
			end)
			while #out > 40 do
				table.remove(out)
			end
			return out
		end
		local function paint()
			for i, row in rows do
				Theme.Paint(row, { BackgroundColor3 = "Surface3" })
				row.BackgroundTransparency = i == selected and 0 or 1
			end
		end
		local function render()
			for _, c in list:GetChildren() do
				if c:IsA("GuiObject") then
					c:Destroy()
				end
			end
			rows = {}
			results = collect(input.Text)
			selected = 1
			if #results == 0 then
				local empty = Util.Label({ Text = Locale.T("NoResults"), FontFace = Theme.Fonts.Regular, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 60), Parent = list })
				Theme.Paint(empty, { TextColor3 = "TextMute" })
			end
			for i, r in results do
				local row = Util.New("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 38), LayoutOrder = i, Parent = list })
				Util.Corner(6, row)
				local img = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get(r.Icon) or "", Size = UDim2.fromOffset(15, 15), Position = UDim2.new(0, 10, 0.5, -7), Parent = row })
				Theme.Paint(img, { ImageColor3 = "TextDim" })
				local t = Util.Label({ Text = r.Text, FontFace = Theme.Fonts.Medium, TextSize = 13, Size = UDim2.new(1, -150, 0, 16), Position = UDim2.fromOffset(34, r.Sub and 4 or 11), TextTruncate = Enum.TextTruncate.AtEnd, Parent = row })
				Theme.Paint(t, { TextColor3 = "Text" })
				if r.Sub then
					local sub = Util.Label({ Text = r.Sub, FontFace = Theme.Fonts.Regular, TextSize = 11, Size = UDim2.new(1, -150, 0, 13), Position = UDim2.fromOffset(34, 21), TextTruncate = Enum.TextTruncate.AtEnd, Parent = row })
					Theme.Paint(sub, { TextColor3 = "TextMute" })
				end
				local kind = Util.Label({ Text = (r.Value and r.Value ~= "" and (r.Value .. "  ·  ") or "") .. r.Kind, FontFace = Theme.Fonts.Mono, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(0, 130, 1, 0), Position = UDim2.new(1, -140, 0, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = row })
				Theme.Paint(kind, { TextColor3 = "TextMute" })
				row.MouseEnter:Connect(function()
					selected = i
					paint()
				end)
				row.Activated:Connect(function()
					close()
					self._palette = nil
					r.Run()
				end)
				rows[i] = row
			end
			zfix(layer, 82)
			paint()
		end
		input:GetPropertyChangedSignal("Text"):Connect(render)
		local conn = UIS.InputBegan:Connect(function(io)
			if io.KeyCode == Enum.KeyCode.Down then
				selected = math.min(selected + 1, #results)
				paint()
			elseif io.KeyCode == Enum.KeyCode.Up then
				selected = math.max(selected - 1, 1)
				paint()
			elseif io.KeyCode == Enum.KeyCode.Return then
				local r = results[selected]
				close()
				self._palette = nil
				if r then
					r.Run()
				end
			elseif io.KeyCode == Enum.KeyCode.Escape then
				close()
				self._palette = nil
			end
		end)
		layer.Activated:Connect(function()
			close()
			self._palette = nil
		end)
		layer.Destroying:Connect(function()
			conn:Disconnect()
			self._palette = nil
		end)
		render()
		task.defer(function()
			input:CaptureFocus()
		end)
		return self
	end
	Window.Search = Window.OpenSearch

	-- ─── Tour (onboarding) ───────────────────────────────────────────────
	--[[
		Window:Tour({
			{ Target = element | gui | "search", Title = "Search", Text = "Press Ctrl+K…" },
			...
		}, { Key = "intro-v1" })   -- shown once per key (stored in settings)
	]]
	function Window:Tour(steps, options)
		options = options or {}
		local Lib = self.Library
		if options.Key and Lib:GetSetting("Tour." .. options.Key) and not options.Force then
			return self
		end
		task.spawn(function()
			self:WaitUntilReady(15)
			for i, step in steps do
				local target = step.Target
				if type(target) == "table" and target.Focus then
					target:Focus()
					task.wait(0.35)
					target = target.Frame
				elseif target == "search" then
					target = self.Sidebar and self.Sidebar:FindFirstChild("Search")
				elseif target == "config" then
					target = self._actions and self._actions:FindFirstChild("Config")
				end
				local ring
				if typeof(target) == "Instance" and target:IsA("GuiObject") then
					ring = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 8, 1, 8), Position = UDim2.fromOffset(-4, -4), ZIndex = 79, Parent = target })
					Util.Corner(8, ring)
					local stroke = Util.Stroke(ring, nil, 2)
					Theme.Paint(stroke, { Color = "Accent" })
					task.spawn(function()
						while ring.Parent do
							Tween.Await(stroke, { Transparency = 0.7 }, 0.6, Enum.EasingStyle.Sine)
							Tween.Await(stroke, { Transparency = 0 }, 0.6, Enum.EasingStyle.Sine)
						end
					end)
				end
				local index = self:Dialog({
					Title = string.format("%d/%d  ·  %s", i, #steps, step.Title or ""),
					Content = step.Text or step.Content,
					Buttons = { { Text = Locale.T("Cancel") }, { Text = i == #steps and Locale.T("Ok") or "→", Style = "Primary" } },
				})
				if ring then
					ring:Destroy()
				end
				if index ~= 2 then
					break
				end
			end
			if options.Key then
				Lib:SetSetting("Tour." .. options.Key, true)
			end
		end)
		return self
	end
end
