--!nocheck
--[[
	Proximity · Widgets
	Notifications, Watermark, Keybind list and the Dock (corner snapping for
	any floating widget). Installed onto the Library table.
]]

local Util = require("../Core/Util")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")
local Keys = require("../Core/Keys")
local Theme = require("../Theme")
local Icons = require("../Icons")
local Locale = require("../Locale")
local Shared = require("../Shared")

local UIS = Env.Service("UserInputService")
local RunService = Env.Service("RunService")

return function(Lib)
	-- ═══ Dock ═════════════════════════════════════════════════════════════
	-- Makes `frame` draggable; on release it snaps to the nearest corner /
	-- edge zone when close enough, and the position is remembered under `key`.
	local function dock(frame, key, default)
		local saved = Lib:GetSetting("Dock." .. key)
		if type(saved) == "table" then
			frame.AnchorPoint = Vector2.new(saved[1], saved[2])
			frame.Position = UDim2.new(saved[1], saved[3], saved[2], saved[4])
		elseif default then
			frame.AnchorPoint = default.AnchorPoint
			frame.Position = default.Position
		end
		local dragging, start, startPos
		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging, start = true, Vector2.new(input.Position.X, input.Position.Y)
				startPos = frame.AbsolutePosition
				frame.AnchorPoint = Vector2.new(0, 0)
				frame.Position = UDim2.fromOffset(startPos.X, startPos.Y)
			end
		end)
		Shared.Maid:Connect(UIS.InputChanged, function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local p = startPos + Vector2.new(input.Position.X, input.Position.Y) - start
				frame.Position = UDim2.fromOffset(p.X, p.Y)
			end
		end)
		Shared.Maid:Connect(UIS.InputEnded, function(input)
			if not dragging or (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) then
				return
			end
			dragging = false
			local view = workspace.CurrentCamera.ViewportSize
			local pos, size = frame.AbsolutePosition, frame.AbsoluteSize
			local cx, cy = (pos.X + size.X / 2) / view.X, (pos.Y + size.Y / 2) / view.Y
			-- snap to 3×3 zones with a 12 px margin
			local ax = cx < 0.33 and 0 or (cx > 0.66 and 1 or 0.5)
			local ay = cy < 0.33 and 0 or (cy > 0.66 and 1 or 0.5)
			local ox = ax == 0 and 12 or (ax == 1 and -12 or 0)
			local oy = ay == 0 and 12 or (ay == 1 and -12 or 0)
			-- keep free placement when the widget is far from any edge
			local nearX = pos.X < 60 or pos.X + size.X > view.X - 60 or ax == 0.5
			local nearY = pos.Y < 60 or pos.Y + size.Y > view.Y - 60
			if not nearX then
				ax, ox = 0, pos.X
			end
			if not nearY then
				ay, oy = 0, pos.Y
			end
			frame.AnchorPoint = Vector2.new(ax, ay)
			local target = UDim2.new(ax, ox, ay, oy)
			Tween.Play(frame, { Position = target }, 0.25, Enum.EasingStyle.Back)
			Lib:SetSetting("Dock." .. key, { ax, ay, ox, oy })
		end)
	end
	Lib.Dock = function(_, frame, key, default)
		dock(frame, key, default)
	end

	local function panel(name, parent)
		local frame = Util.New("Frame", { Name = name, AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.new(), Active = true, Parent = parent or Shared.Gui.Widgets })
		Util.Corner(8, frame)
		Theme.Paint(frame, { BackgroundColor3 = "Bg" })
		frame.BackgroundTransparency = 0.08
		Theme.Paint(Util.Stroke(frame), { Color = "Stroke" })
		Shared.Overlay.Shadow(frame, 0.6, 16)
		return frame
	end

	-- ═══ Notifications ════════════════════════════════════════════════════
	local holder = Util.New("Frame", { Name = "Notifications", BackgroundTransparency = 1, Size = UDim2.new(0, 300, 1, -24), ZIndex = 90, Parent = Shared.Gui.Root })
	local layout = Util.List(holder, 8)
	local notifyScale = Util.New("UIScale", { Parent = holder })
	Lib.NotificationHistory = {}
	local active = {}

	function Lib:SetNotifyPosition(position)
		local map = {
			TopRight = { Vector2.new(1, 0), UDim2.new(1, -12, 0, 12), Enum.VerticalAlignment.Top },
			BottomRight = { Vector2.new(1, 1), UDim2.new(1, -12, 1, -12), Enum.VerticalAlignment.Bottom },
			TopLeft = { Vector2.new(0, 0), UDim2.new(0, 12, 0, 12), Enum.VerticalAlignment.Top },
			BottomLeft = { Vector2.new(0, 1), UDim2.new(0, 12, 1, -12), Enum.VerticalAlignment.Bottom },
			TopCenter = { Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 12), Enum.VerticalAlignment.Top },
		}
		local spec = map[position] or map.BottomRight
		holder.AnchorPoint, holder.Position = spec[1], spec[2]
		layout.VerticalAlignment = spec[3]
		layout.HorizontalAlignment = position:find("Left") and Enum.HorizontalAlignment.Left or (position:find("Center") and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Right)
		Lib.NotifyPosition = position
	end
	Lib:SetNotifyPosition(Lib:GetSetting("NotifyPosition", "BottomRight"))

	local typeIcons = { info = "info", success = "check-circle", warning = "alert-triangle", warn = "alert-triangle", error = "x-circle" }
	local typeTokens = { info = "Accent", success = "Success", warning = "Warning", warn = "Warning", error = "Error" }

	--[[
		Library:Notify("text")
		Library:Notify({ Title, Content, Duration = 4, Type = "info"|"success"|"warning"|"error",
		                 Icon, Actions = { { Text = "Undo", Callback = fn } }, Persistent = false })
		→ handle: :Close() :SetTitle() :SetContent() :SetProgress(0..1) :Extend(seconds)
	]]
	function Lib:Notify(options)
		if type(options) ~= "table" then
			options = { Content = tostring(options) }
		end
		local kind = options.Type or "info"
		local duration = options.Duration or options.Time or options.Delay or 4
		local handle = { Title = options.Title, Content = options.Content or options.Text or options.Description or "" }
		table.insert(Lib.NotificationHistory, { Title = handle.Title, Content = handle.Content, Type = kind, Time = os.time() })
		while #Lib.NotificationHistory > 50 do
			table.remove(Lib.NotificationHistory, 1)
		end
		notifyScale.Scale = Shared.Scale or 1

		local wrap = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = false, LayoutOrder = -os.clock() * 1000, Parent = holder })
		local card = Util.New("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.fromOffset(Lib.NotifyPosition:find("Left") and -320 or 320, 0), Parent = wrap })
		Util.Corner(8, card)
		Theme.Paint(card, { BackgroundColor3 = "Elevated" })
		Theme.Paint(Util.Stroke(card), { Color = "StrokeHi" })
		Shared.Overlay.Shadow(card, 0.55, 14)
		Util.Padding(card, 11, 12, 13, 14)
		local bar = Util.New("Frame", { Size = UDim2.new(0, 2, 1, -16), Position = UDim2.new(0, -8, 0, 8), BorderSizePixel = 0, Parent = card })
		Util.Round(bar)
		Theme.Paint(bar, { BackgroundColor3 = typeTokens[kind] or "Accent" })
		local list = Util.List(card, 3)
		local top = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 1, Parent = card })
		local icon = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get(options.Icon or typeIcons[kind]) or "", Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(0, 1), Parent = top })
		Theme.Paint(icon, { ImageColor3 = typeTokens[kind] or "Accent" })
		local title = Util.Label({ Text = handle.Title or (Lib.Windows[1] and Lib.Windows[1].Title) or "Proximity", FontFace = Theme.Fonts.SemiBold, TextSize = 13, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.fromOffset(20, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = top })
		Theme.Paint(title, { TextColor3 = "Text" })
		local close = Util.New("ImageButton", { BackgroundTransparency = 1, Image = Icons.Get("x") or "", Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 2), Parent = top })
		Theme.Paint(close, { ImageColor3 = "TextMute" })
		local content = Util.Label({ Text = handle.Content, FontFace = Theme.Fonts.Regular, TextSize = 12, RichText = true, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 2, Parent = card })
		Theme.Paint(content, { TextColor3 = "TextDim" })
		content.Visible = handle.Content ~= ""
		if options.Actions then
			local row = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = 3, Parent = card })
			Util.List(row, 6, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
			for i, action in options.Actions do
				local b = Util.New("TextButton", { Text = action.Text or action[1], FontFace = Theme.Fonts.SemiBold, TextSize = 12, AutoButtonColor = false, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 22), LayoutOrder = i, Parent = row })
				Util.Corner(5, b)
				Util.Padding(b, 0, 10, 0, 10)
				Theme.Paint(b, { BackgroundColor3 = i == 1 and "Accent" or "Surface3", TextColor3 = i == 1 and "AccentInk" or "Text" })
				b.Activated:Connect(function()
					Util.SafeCall(action.Callback or action[2])
					handle:Close()
				end)
			end
		end
		local progress = Util.New("Frame", { Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, 10), BorderSizePixel = 0, BackgroundTransparency = 0.6, Parent = card })
		Theme.Paint(progress, { BackgroundColor3 = "Accent" })

		local closed = false
		local expires = os.clock() + duration
		function handle:Close()
			if closed then
				return
			end
			closed = true
			local i = table.find(active, handle)
			if i then
				table.remove(active, i)
			end
			Tween.Play(card, { Position = UDim2.fromOffset(Lib.NotifyPosition:find("Left") and -320 or 320, 0) }, 0.25)
			task.delay(0.22, function()
				Tween.Play(wrap, { Size = UDim2.new(1, 0, 0, 0) }, 0.18)
				task.delay(0.2, function()
					wrap:Destroy()
				end)
			end)
		end
		function handle:SetTitle(t)
			title.Text = t
			return self
		end
		function handle:SetContent(t)
			content.Text = t
			content.Visible = t ~= ""
			return self
		end
		function handle:SetProgress(p)
			progress.Size = UDim2.new(math.clamp(p, 0, 1), 0, 0, 2)
			return self
		end
		function handle:Extend(seconds)
			expires += seconds
			return self
		end
		close.Activated:Connect(function()
			handle:Close()
		end)
		-- slide in once the card knows its height
		task.defer(function()
			wrap.Size = UDim2.new(1, 0, 0, card.AbsoluteSize.Y / notifyScale.Scale)
			card:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				if not closed then
					wrap.Size = UDim2.new(1, 0, 0, card.AbsoluteSize.Y / notifyScale.Scale)
				end
			end)
			Tween.Play(card, { Position = UDim2.fromOffset(0, 0) }, 0.35, Enum.EasingStyle.Back)
		end)
		if not options.Persistent then
			task.spawn(function()
				local hovered = false
				card.MouseEnter:Connect(function()
					hovered = true
				end)
				card.MouseLeave:Connect(function()
					hovered = false
				end)
				local last = os.clock()
				while not closed do
					local now = os.clock()
					if hovered then
						expires += now - last
					end
					last = now
					local left = expires - now
					progress.Size = UDim2.new(math.clamp(left / duration, 0, 1), 0, 0, 2)
					if left <= 0 then
						handle:Close()
					end
					RunService.Heartbeat:Wait()
				end
			end)
		end
		table.insert(active, handle)
		while #active > 5 do
			active[1]:Close()
		end
		return handle
	end
	Lib.Notification = Lib.Notify
	Lib.SetNotification = Lib.Notify
	function Lib:Success(content, title)
		return Lib:Notify({ Title = title, Content = content, Type = "success" })
	end
	function Lib:Error(content, title)
		return Lib:Notify({ Title = title, Content = content, Type = "error" })
	end
	function Lib:Warn(content, title)
		return Lib:Notify({ Title = title, Content = content, Type = "warning" })
	end
	function Lib:Info(content, title)
		return Lib:Notify({ Title = title, Content = content, Type = "info" })
	end
	function Lib:ClearNotifications()
		for _, h in table.clone(active) do
			h:Close()
		end
	end

	-- ═══ Watermark ════════════════════════════════════════════════════════
	--[[
		local wm = Library:Watermark({ Text = "Proximity", Items = { "FPS", "Ping", "Time" } })
		wm:AddItem({ Icon = "user", Text = "name" | fn, Interval = 1 }) → item:Set(text) :Remove()
		wm:SetVisible(bool)  wm:SetText(text)
	]]
	function Lib:Watermark(options)
		options = options or {}
		if Lib.WatermarkWidget then
			return Lib.WatermarkWidget
		end
		local frame = panel("Watermark")
		Util.Padding(frame, 0, 12, 0, 10)
		Util.List(frame, 10, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
		Util.New("UISizeConstraint", { MinSize = Vector2.new(0, 30), Parent = frame })
		local logoHolder = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(16, 30), LayoutOrder = 0, Parent = frame })
		local w = Lib.Windows[1]
		if w then
			local logo = w:_drawLogo(logoHolder, 16)
			logo.Position = UDim2.fromOffset(0, 7)
		end
		local name = Util.Label({ Text = options.Text or (w and w.Title) or "Proximity", FontFace = Theme.Fonts.Bold, TextSize = 12, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 30), LayoutOrder = 1, Parent = frame })
		Theme.Paint(name, { TextColor3 = "Text" })
		local widget = { Frame = frame, Items = {} }
		local order = 1
		function widget:AddItem(spec)
			if type(spec) == "string" then
				spec = Lib.WatermarkPresets[spec] or { Text = spec }
			end
			order += 1
			local dot = Util.New("Frame", { Size = UDim2.fromOffset(3, 3), LayoutOrder = order, BorderSizePixel = 0, Parent = frame })
			Util.Round(dot)
			Theme.Paint(dot, { BackgroundColor3 = "TextMute" })
			order += 1
			local label = Util.Label({ Text = "", FontFace = Theme.Fonts.Mono, TextSize = 11, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 30), LayoutOrder = order, Parent = frame })
			Theme.Paint(label, { TextColor3 = "TextDim" })
			local item = { Label = label }
			function item:Set(text)
				label.Text = tostring(text)
				return self
			end
			function item:Remove()
				dot:Destroy()
				label:Destroy()
				self.Removed = true
			end
			if type(spec.Text) == "function" then
				task.spawn(function()
					while not item.Removed and not Lib.Unloaded do
						local ok, v = pcall(spec.Text)
						if ok then
							item:Set(v)
						end
						task.wait(spec.Interval or 1)
					end
				end)
			else
				item:Set(spec.Text or "")
			end
			table.insert(widget.Items, item)
			return item
		end
		function widget:SetVisible(v)
			frame.Visible = v
			return self
		end
		function widget:SetText(t)
			name.Text = t
			return self
		end
		for _, it in options.Items or { "FPS", "Ping", "Time" } do
			widget:AddItem(it)
		end
		dock(frame, "Watermark", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 12) })
		frame.Visible = Lib:GetSetting("Watermark", options.Visible ~= false)
		Lib.WatermarkWidget = widget
		return widget
	end

	Lib.WatermarkPresets = {
		FPS = { Text = function()
			return Lib.Providers.FPS() .. " fps"
		end, Interval = 0.5 },
		Ping = { Text = function()
			return Lib.Providers.Ping()
		end, Interval = 1 },
		Time = { Text = function()
			return os.date("%H:%M:%S")
		end, Interval = 1 },
		Game = { Text = function()
			return Lib.Providers.GameName()
		end, Interval = 60 },
		Player = { Text = function()
			return Lib:GetIdentity().DisplayName
		end, Interval = 5 },
	}

	-- ═══ Keybind list ═════════════════════════════════════════════════════
	function Lib:KeybindList(options)
		options = options or {}
		if Lib.KeybindListWidget then
			return Lib.KeybindListWidget
		end
		local frame = panel("Keybinds")
		Util.New("UISizeConstraint", { MinSize = Vector2.new(200, 0), Parent = frame })
		Util.Padding(frame, 8, 10, 8, 10)
		Util.List(frame, 3)
		local head = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 0, Parent = frame })
		local icon = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get("keyboard") or "", Size = UDim2.fromOffset(13, 13), Position = UDim2.fromOffset(0, 2), Parent = head })
		Theme.Paint(icon, { ImageColor3 = "TextDim" })
		local title = Util.Label({ Text = options.Title or Locale.T("KeybindList"), FontFace = Theme.Fonts.Bold, TextSize = 11, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(19, 0), Parent = head })
		Theme.Paint(title, { TextColor3 = "Text" })
		local rows = {}
		local showAll = options.ShowInactive == true
		local function rebuild()
			for _, r in rows do
				r:Destroy()
			end
			rows = {}
			local list = {}
			for _, kb in Lib._classes.Keybind.All() do
				if kb.ShowInList and kb.Value ~= "None" and not kb._destroyed and (showAll or kb.Active or kb.Mode == "Always") and kb.Window then
					table.insert(list, kb)
				end
			end
			table.sort(list, function(a, b)
				return a.Name < b.Name
			end)
			for i, kb in list do
				local row = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = i, Parent = frame })
				local name = Util.Label({ Text = kb.Name, FontFace = Theme.Fonts.Medium, TextSize = 12, Size = UDim2.new(1, -96, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = row })
				Theme.Paint(name, { TextColor3 = kb.Active and "Text" or "TextMute" })
				local mode = Util.Label({ Text = Locale.T(kb.Mode), FontFace = Theme.Fonts.Regular, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(0, 56, 1, 0), Position = UDim2.new(1, -96, 0, 0), Parent = row })
				Theme.Paint(mode, { TextColor3 = "TextMute" })
				local key = Util.Label({ Text = Keys.Display(kb.Value), FontFace = Theme.Fonts.MonoBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(0, 36, 1, 0), Position = UDim2.new(1, -36, 0, 0), Parent = row })
				Theme.Paint(key, { TextColor3 = kb.Active and "Accent" or "TextDim" })
				table.insert(rows, row)
			end
			frame.Visible = Lib:GetSetting("KeybindList", options.Visible ~= false) and (#list > 0 or showAll)
		end
		Lib.KeybindsChanged:Connect(function()
			task.defer(rebuild)
		end)
		dock(frame, "Keybinds", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0) })
		local widget = { Frame = frame }
		function widget:SetVisible(v)
			Lib:SetSetting("KeybindList", v)
			rebuild()
			return self
		end
		function widget:ShowInactive(v)
			showAll = v
			rebuild()
			return self
		end
		widget.Refresh = rebuild
		rebuild()
		Lib.KeybindListWidget = widget
		return widget
	end
end
