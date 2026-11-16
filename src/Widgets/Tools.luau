--!nocheck
--[[
	Proximity · Widgets/Tools
	Ready-made widgets and section blocks for hub scripts.

	Floating widgets (draggable HUD panels, remembered position):
	  Library:SessionData()          time in server, server age, players, joins/leaves, FPS, ping, memory
	  Library:EventFeed()            who joined, left or died, with the time
	  Library:ChatLog()              chat messages with a search box
	  Library:FriendsHere()          your friends on this server
	  Library:LookingAtMe()          players whose camera / head points at you
	  Library:InventoryViewer()      tools a chosen player carries
	  Library:MusicPlayer({ Songs = { { Name, Id } } })

	Section blocks:
	  section:CrosshairEditor({ Flag = "xhair" })   style, size, gap, thickness, colour, outline, spin
	  section:EspPreview({ Box, Name, Health, Distance, Tracer })  -> preview:Set(key, value)
	  section:MusicPlayer({ Songs })
	  section:Discord({ Invite = "abc123", Name = "My Hub" })
	  section:CodeEditor({ Name, Default, Height, Run = true })

	Other:
	  Library:SetCrosshair({ Enabled, Style = "Cross"|"Dot"|"Circle"|"T", Size, Gap, Thickness, Color, Outline, Spin })
	  Library:SetPriority(player, "Friendly"|"Neutral"|"Enemy")  Library:GetPriority(player)  Library.PriorityChanged
	  Library:ImportTheme(theme, "Rayfield"|"Linoria"|"Orion", name?)   -> a Proximity theme from another library's
	  Library:SetHints(on)   beginner mode: descriptions show right away on hover
	  toggle option Sound = "neverlose" (any Media hit sound) plays when it turns on
]]

local Util = require("../Core/Util")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")
local Theme = require("../Theme")
local Signal = require("../Core/Signal")
local Icons = require("../Icons")
local Locale = require("../Locale")
local Shared = require("../Shared")

local Players = Env.Service("Players")
local RunService = Env.Service("RunService")

return function(Lib)
	local T = Locale.T
	local Section = Lib._classes.Section
	local LP = Players.LocalPlayer

	local function clock()
		return os.date("%H:%M:%S")
	end

	-- ═══ Session data ══════════════════════════════════════════════════════
	local joined, left = 0, 0
	Players.PlayerAdded:Connect(function()
		joined += 1
	end)
	Players.PlayerRemoving:Connect(function()
		left += 1
	end)
	function Lib:SessionData()
		if self._sessionWidget then
			return self._sessionWidget
		end
		local w = self:Widget({ Title = T("SessionData"), Icon = "clock" })
		local P = self.Providers
		w:Stat({ Name = T("TimeInServer"), Value = P.Session, Interval = 1 })
		w:Stat({ Name = T("ServerAge"), Value = P.ServerUptime or function()
			return "-"
		end, Interval = 1 })
		w:Stat({ Name = T("PlayersNow"), Value = P.Players, Interval = 1 })
		w:Stat({ Name = T("JoinedLeft"), Value = function()
			return ("+%d / -%d"):format(joined, left)
		end, Interval = 1 })
		w:Stat({ Name = "FPS", Value = P.FPS, Interval = 0.5 })
		w:Stat({ Name = T("Ping"), Value = P.Ping, Interval = 1 })
		if P.Memory then
			w:Stat({ Name = T("Memory"), Value = P.Memory, Interval = 2 })
		end
		self._sessionWidget = w
		return w
	end

	-- ═══ Event feed ════════════════════════════════════════════════════════
	function Lib:EventFeed()
		if self._eventWidget then
			return self._eventWidget
		end
		local w = self:Widget({ Title = T("Events"), Icon = "activity" })
		local console = w:Console({ Height = 150 })
		local function watch(player)
			local function hook(char)
				local hum = char:WaitForChild("Humanoid", 10)
				if hum then
					self:Connect(hum.Died, function()
						console:Log(("%s  %s %s"):format(clock(), player.DisplayName, T("Died")), "warning")
					end)
				end
			end
			if player.Character then
				task.spawn(hook, player.Character)
			end
			self:Connect(player.CharacterAdded, hook)
		end
		for _, p in Players:GetPlayers() do
			watch(p)
		end
		self:Connect(Players.PlayerAdded, function(p)
			console:Log(("%s  %s %s"):format(clock(), p.DisplayName, T("Joined")), "success")
			watch(p)
		end)
		self:Connect(Players.PlayerRemoving, function(p)
			console:Log(("%s  %s %s"):format(clock(), p.DisplayName, T("Left")), "info")
		end)
		self._eventWidget = w
		return w
	end

	-- ═══ Chat log ══════════════════════════════════════════════════════════
	function Lib:ChatLog()
		if self._chatWidget then
			return self._chatWidget
		end
		local w = self:Widget({ Title = T("ChatLog"), Icon = "message", Width = 280 })
		local history = {}
		local query = ""
		local console
		local function matches(line)
			return query == "" or Util.Fuzzy(query, line) ~= nil
		end
		w:Input({ Name = T("Search"), Placeholder = T("SearchChat"), Save = false, Callback = function(text)
			query = text or ""
			console:Clear()
			for _, line in history do
				if matches(line) then
					console:Log(line)
				end
			end
		end })
		console = w:Console({ Height = 170 })
		local function add(name, text)
			local line = ("%s  %s: %s"):format(clock(), name, text)
			table.insert(history, line)
			if #history > 300 then
				table.remove(history, 1)
			end
			if matches(line) then
				console:Log(line)
			end
		end
		local ok = pcall(function()
			local TCS = game:GetService("TextChatService")
			self:Connect(TCS.MessageReceived, function(msg)
				local src = msg.TextSource
				local p = src and Players:GetPlayerByUserId(src.UserId)
				add(p and p.DisplayName or "?", msg.Text)
			end)
		end)
		if not ok then
			for _, p in Players:GetPlayers() do
				self:Connect(p.Chatted, function(text)
					add(p.DisplayName, text)
				end)
			end
		end
		self._chatWidget = w
		return w
	end

	-- ═══ Friends on this server ════════════════════════════════════════════
	function Lib:FriendsHere()
		if self._friendsWidget then
			return self._friendsWidget
		end
		local w = self:Widget({ Title = T("FriendsHere"), Icon = "users" })
		local label = w:Paragraph({ Content = "..." })
		local function refresh()
			local names = {}
			for _, p in Players:GetPlayers() do
				if p ~= LP then
					local ok, friend = pcall(LP.IsFriendsWith, LP, p.UserId)
					if ok and friend then
						table.insert(names, p.DisplayName)
					end
				end
			end
			label:SetContent(#names > 0 and table.concat(names, ", ") or T("NoFriendsHere"))
		end
		task.spawn(refresh)
		self:Connect(Players.PlayerAdded, function()
			task.delay(1, refresh)
		end)
		self:Connect(Players.PlayerRemoving, function()
			task.defer(refresh)
		end)
		self._friendsWidget = w
		return w
	end

	-- ═══ Who is looking at me ══════════════════════════════════════════════
	function Lib:LookingAtMe(options)
		options = options or {}
		if self._lookWidget then
			return self._lookWidget
		end
		local w = self:Widget({ Title = T("LookingAtMe"), Icon = "eye" })
		local label = w:Paragraph({ Content = "-" })
		local angle = math.cos(math.rad(options.Angle or 10))
		self:Loop(function()
			local me = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
			local names = {}
			if me then
				for _, p in Players:GetPlayers() do
					local head = p ~= LP and p.Character and p.Character:FindFirstChild("Head")
					if head then
						local to = me.Position - head.Position
						if to.Magnitude < (options.Range or 600) and head.CFrame.LookVector:Dot(to.Unit) > angle then
							table.insert(names, ("%s (%dm)"):format(p.DisplayName, math.floor(to.Magnitude / 3.57)))
						end
					end
				end
			end
			label:SetContent(#names > 0 and table.concat(names, "\n") or T("Nobody"))
		end, 0.3)
		self._lookWidget = w
		return w
	end

	-- ═══ Inventory viewer ══════════════════════════════════════════════════
	function Lib:InventoryViewer()
		if self._invWidget then
			return self._invWidget
		end
		local w = self:Widget({ Title = T("Inventory"), Icon = "inventory" })
		local target
		local label
		local function refresh()
			if not target or not target.Parent then
				label:SetContent("-")
				return
			end
			local items = {}
			local function scan(container, equipped)
				if not container then
					return
				end
				for _, tool in container:GetChildren() do
					if tool:IsA("Tool") then
						table.insert(items, (equipped and "▸ " or "· ") .. tool.Name)
					end
				end
			end
			scan(target.Character, true)
			scan(target:FindFirstChildOfClass("Backpack"), false)
			label:SetContent(#items > 0 and table.concat(items, "\n") or T("EmptyInventory"))
		end
		w:PlayerDropdown({ Name = T("Player"), Save = false, Callback = function(name)
			target = name and Players:FindFirstChild(name)
			refresh()
		end })
		label = w:Paragraph({ Content = "-" })
		self:Loop(refresh, 1)
		self._invWidget = w
		return w
	end

	-- ═══ Music player ══════════════════════════════════════════════════════
	local function buildMusic(section, options)
		local songs = options.Songs or {}
		local index, sound = 1, nil
		local now = section:Label({ Text = T("NothingPlaying") })
		local function play(i)
			if #songs == 0 then
				return
			end
			index = (i - 1) % #songs + 1
			local song = songs[index]
			if not sound then
				sound = Lib:Create("Sound", { Volume = (options.Volume or 50) / 100, Parent = Env.Service("SoundService") })
				Lib:Connect(sound.Ended, function()
					if not sound.Looped then
						play(index + 1)
					end
				end)
			end
			local id = song.Id or song[2]
			sound.SoundId = type(id) == "number" and ("rbxassetid://" .. id) or tostring(id)
			sound:Play()
			now:SetText("♪ " .. tostring(song.Name or song[1] or id))
		end
		section:ButtonGroup({
			{ Name = "⏮", Callback = function()
				play(index - 1)
			end },
			{ Name = "⏯", Callback = function()
				if sound and sound.IsPlaying then
					sound:Pause()
				elseif sound and sound.TimePosition > 0 then
					sound:Resume()
				else
					play(index)
				end
			end },
			{ Name = "⏭", Callback = function()
				play(index + 1)
			end },
		})
		section:Slider({ Name = T("Volume"), Min = 0, Max = 100, Default = options.Volume or 50, Suffix = "%", Save = false, Callback = function(v)
			if sound then
				sound.Volume = v / 100
			end
		end })
		section:Toggle({ Name = T("Repeat"), Save = false, Callback = function(on)
			if sound then
				sound.Looped = on
			end
		end })
		return { Play = play }
	end
	function Lib:MusicPlayer(options)
		local w = self:Widget({ Title = T("Music"), Icon = "music" })
		buildMusic(w, options or {})
		return w
	end
	function Section:MusicPlayer(options)
		return buildMusic(self, options or {})
	end

	-- ═══ Crosshair ═════════════════════════════════════════════════════════
	local xh = { Enabled = false, Style = "Cross", Size = 8, Gap = 4, Thickness = 2, Color = Color3.new(1, 1, 1), Outline = true, Spin = 0 }
	local xhRoot, xhConn
	local function drawCrosshair()
		if xhRoot then
			xhRoot:Destroy()
			xhRoot = nil
		end
		if not xh.Enabled then
			return
		end
		xhRoot = Util.New("Frame", { Name = "Crosshair", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(1, 1), ZIndex = 400, Parent = Shared.Gui.Root })
		local function bar(x, y, w, h)
			local f = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), BorderSizePixel = 0, BackgroundColor3 = xh.Color, ZIndex = 401, Parent = xhRoot })
			if xh.Outline then
				Util.Stroke(f, Color3.new(0, 0, 0), 1, 0.2)
			end
			return f
		end
		local s, g, t = xh.Size, xh.Gap, xh.Thickness
		if xh.Style == "Dot" then
			local d = bar(0, 0, t + 2, t + 2)
			Util.Round(d)
		elseif xh.Style == "Circle" then
			local c = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset((s + g) * 2, (s + g) * 2), BackgroundTransparency = 1, ZIndex = 401, Parent = xhRoot })
			Util.Round(c)
			Util.Stroke(c, xh.Color, t, 0)
			local d = bar(0, 0, 2, 2)
			Util.Round(d)
		else
			bar(0, -(g + s / 2), t, s)
			bar(-(g + s / 2), 0, s, t)
			bar(g + s / 2, 0, s, t)
			if xh.Style ~= "T" then
				bar(0, g + s / 2, t, s)
			end
		end
		if xh.Spin ~= 0 and not xhConn then
			xhConn = RunService.RenderStepped:Connect(function(dt)
				if xhRoot then
					xhRoot.Rotation = (xhRoot.Rotation + dt * xh.Spin) % 360
				end
			end)
			Shared.Maid:Give(xhConn)
		elseif xh.Spin == 0 and xhConn then
			xhConn:Disconnect()
			xhConn = nil
		end
	end
	function Lib:SetCrosshair(options)
		for k, v in options or {} do
			xh[k] = v
		end
		drawCrosshair()
		return self
	end
	function Section:CrosshairEditor(options)
		options = options or {}
		local flag = options.Flag or "crosshair"
		local function set(key)
			return function(v)
				Lib:SetCrosshair({ [key] = v })
			end
		end
		self:Toggle({ Name = T("Crosshair"), Flag = flag .. ".enabled", Icon = "crosshair", Callback = set("Enabled") })
		self:Segmented({ Name = T("Style"), Flag = flag .. ".style", Values = { "Cross", "T", "Dot", "Circle" }, Callback = set("Style") })
		self:Slider({ Name = T("Size"), Flag = flag .. ".size", Min = 2, Max = 30, Default = 8, Callback = set("Size") })
		self:Slider({ Name = T("Gap"), Flag = flag .. ".gap", Min = 0, Max = 20, Default = 4, Callback = set("Gap") })
		self:Slider({ Name = T("Thickness"), Flag = flag .. ".thickness", Min = 1, Max = 6, Default = 2, Callback = set("Thickness") })
		self:ColorPicker({ Name = T("Color"), Flag = flag .. ".color", Default = Color3.new(1, 1, 1), Callback = set("Color") })
		self:Toggle({ Name = T("Outline"), Flag = flag .. ".outline", Default = true, Callback = set("Outline") })
		self:Slider({ Name = T("Spin"), Flag = flag .. ".spin", Min = 0, Max = 360, Default = 0, Suffix = "°/s", Callback = set("Spin") })
		return self
	end
	Lib:OnUnload(function()
		xh.Enabled = false
		drawCrosshair()
	end)

	-- ═══ ESP preview ═══════════════════════════════════════════════════════
	function Section:EspPreview(options)
		options = options or {}
		local state = { Box = options.Box ~= false, Name = options.Name ~= false, Health = options.Health ~= false, Distance = options.Distance ~= false, Tracer = options.Tracer == true, Color = options.Color or Color3.new(1, 1, 1) }
		local parts = {}
		local function render()
			if not parts.rect then
				return
			end
			parts.rect.Visible = state.Box
			parts.rectStroke.Color = state.Color
			parts.name.Visible = state.Name
			parts.name.TextColor3 = state.Color
			parts.dist.Visible = state.Distance
			parts.dist.TextColor3 = state.Color
			parts.hpBack.Visible = state.Health
			parts.tracer.Visible = state.Tracer
			parts.tracer.BackgroundColor3 = state.Color
		end
		self:Canvas({ Height = options.Height or 230, Build = function(frame)
			local box = Util.New("Frame", { Size = UDim2.new(1, -16, 1, -4), Position = UDim2.fromOffset(8, 2), ClipsDescendants = true, Parent = frame })
			Util.Corner(8, box)
			Theme.Paint(box, { BackgroundColor3 = "Surface2" })
			Theme.Paint(Util.Stroke(box), { Color = "Stroke" })
			local vp = Util.New("ViewportFrame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Ambient = Color3.fromRGB(140, 140, 150), LightColor = Color3.new(1, 1, 1), LightDirection = Vector3.new(-1, -1, -1), Parent = box })
			local cam = Instance.new("Camera")
			cam.FieldOfView = 40
			cam.Parent = vp
			vp.CurrentCamera = cam
			task.spawn(function()
				local char = LP.Character or LP.CharacterAdded:Wait()
				local ok, clone = pcall(function()
					char.Archivable = true
					return char:Clone()
				end)
				if ok and clone then
					for _, d in clone:GetDescendants() do
						if d:IsA("Script") or d:IsA("LocalScript") then
							d:Destroy()
						end
					end
					clone:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(180), 0))
					clone.Parent = vp
					cam.CFrame = CFrame.new(Vector3.new(0, 0.5, -10.5), Vector3.new(0, 0.3, 0))
				end
			end)
			-- 2D overlays like an ESP draws them
			local esp = Util.New("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.new(0, 96, 0.78, 0), Parent = box })
			local rect = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = esp })
			local rectStroke = Util.Stroke(rect, state.Color, 1.5, 0)
			local name = Util.Label({ Text = LP.DisplayName, FontFace = Theme.Fonts.SemiBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 40, 0, 14), Position = UDim2.new(0, -20, 0, -16), Parent = esp })
			local dist = Util.Label({ Text = "12m", FontFace = Theme.Fonts.Mono, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, 3), Parent = esp })
			local hpBack = Util.New("Frame", { Size = UDim2.new(0, 3, 1, 0), Position = UDim2.fromOffset(-7, 0), BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0), Parent = esp })
			local hp = Util.New("Frame", { AnchorPoint = Vector2.new(0, 1), Size = UDim2.fromScale(1, 0.72), Position = UDim2.fromScale(0, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(120, 220, 160), Parent = hpBack })
			local tracer = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.new(0, 1, 0.12, 0), Position = UDim2.new(0.5, 0, 0.88, 0), BorderSizePixel = 0, BackgroundColor3 = state.Color, Parent = box })
			parts.rect, parts.rectStroke, parts.name, parts.dist, parts.hpBack, parts.tracer = rect, rectStroke, name, dist, hpBack, tracer
			render()
		end })
		local preview = {}
		function preview:Set(key, value)
			state[key] = value
			render()
			return self
		end
		function preview:Get(key)
			return state[key]
		end
		render()
		return preview
	end

	-- ═══ Discord card ══════════════════════════════════════════════════════
	function Section:Discord(options)
		options = options or {}
		local code = tostring(options.Invite or ""):gsub("^https?://", ""):gsub("^discord%.gg/", ""):gsub("^discord%.com/invite/", "")
		local link = "https://discord.gg/" .. code
		return self:Button({ Name = options.Name or "Discord", Icon = "message", Hint = "discord.gg/" .. code, Callback = function()
			Env.Clipboard(link)
			Lib:Notify({ Title = "Discord", Content = T("InviteCopied"), Duration = 3 })
		end })
	end

	-- ═══ Code editor ═══════════════════════════════════════════════════════
	local keywords = { "local", "function", "end", "if", "then", "else", "elseif", "for", "in", "do", "while", "return", "not", "and", "or", "nil", "true", "false", "repeat", "until", "break", "continue" }
	local function highlight(src)
		src = src:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
		src = src:gsub("(%-%-[^\n]*)", '<font color="#5f5f68">%1</font>')
		src = src:gsub('("[^"\n]*")', '<font color="#9fd8b5">%1</font>')
		for _, k in keywords do
			src = src:gsub("%f[%w_]" .. k .. "%f[^%w_]", '<font color="#ffffff"><b>' .. k .. "</b></font>")
		end
		src = src:gsub("%f[%w_](%d+%.?%d*)%f[^%w_]", '<font color="#f1c878">%1</font>')
		return src
	end
	function Section:CodeEditor(options)
		options = options or {}
		local text = options.Default or ""
		local input
		self:Canvas({ Height = options.Height or 180, Build = function(frame)
			local box = Util.New("Frame", { Size = UDim2.new(1, -16, 1, -4), Position = UDim2.fromOffset(8, 2), ClipsDescendants = true, Parent = frame })
			Util.Corner(7, box)
			Theme.Paint(box, { BackgroundColor3 = "Bg" })
			Theme.Paint(Util.Stroke(box), { Color = "Stroke" })
			local scroll = Util.New("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.XY, ScrollBarThickness = 2, Parent = box })
			local shown = Util.Label({ Text = "", RichText = true, FontFace = Theme.Fonts.Mono, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.fromScale(1, 1), Position = UDim2.fromOffset(8, 6), Parent = scroll })
			Theme.Paint(shown, { TextColor3 = "TextDim" })
			input = Util.New("TextBox", { Text = text, MultiLine = true, ClearTextOnFocus = false, TextTransparency = 1, BackgroundTransparency = 1, FontFace = Theme.Fonts.Mono, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.fromScale(1, 1), Position = UDim2.fromOffset(8, 6), ZIndex = 2, Parent = scroll })
			Theme.Paint(input, { TextColor3 = "Text" })
			local function refresh()
				text = input.Text
				shown.Text = highlight(input.Text)
			end
			input:GetPropertyChangedSignal("Text"):Connect(refresh)
			refresh()
		end })
		local editor = {}
		function editor:Get()
			return input and input.Text or text
		end
		function editor:Set(value)
			text = value
			if input then
				input.Text = value
			end
			return self
		end
		if options.Run ~= false then
			self:ButtonGroup({
				{ Name = T("Run"), Callback = function()
					local chunk, err = loadstring and loadstring(editor:Get())
					if not chunk then
						Lib:Notify({ Title = T("Run"), Content = tostring(err), Type = "error", Duration = 5 })
						return
					end
					local ok, runErr = pcall(chunk)
					if not ok then
						Lib:Notify({ Title = T("Run"), Content = tostring(runErr), Type = "error", Duration = 5 })
					end
				end },
				{ Name = T("Clear"), Callback = function()
					editor:Set("")
				end },
				{ Name = T("Copy"), Callback = function()
					Env.Clipboard(editor:Get())
				end },
			})
		end
		return editor
	end

	-- ═══ Player priority ═══════════════════════════════════════════════════
	Lib.PriorityChanged = Signal.new()
	Lib.Priorities = {}
	function Lib:SetPriority(player, level)
		local id = typeof(player) == "Instance" and player.UserId or player
		self.Priorities[id] = level ~= "Neutral" and level or nil
		self.PriorityChanged:Fire(player, level or "Neutral")
		return self
	end
	function Lib:GetPriority(player)
		local id = typeof(player) == "Instance" and player.UserId or player
		return self.Priorities[id] or "Neutral"
	end

	-- ═══ Themes from other libraries ═══════════════════════════════════════
	local maps = {
		Rayfield = { Background = "Bg", Topbar = "Bg2", ElementBackground = "Surface", ElementBackgroundHover = "Surface2", SecondaryElementBackground = "Surface3", ElementStroke = "Stroke", SecondaryElementStroke = "StrokeHi", TextColor = "Text", PlaceholderColor = "TextMute", ToggleEnabled = "Accent", SliderProgress = "Accent", NotificationBackground = "Elevated" },
		Linoria = { BackgroundColor = "Bg", MainColor = "Surface", OutlineColor = "Stroke", FontColor = "Text", AccentColor = "Accent" },
		Orion = { Main = "Bg", Second = "Surface", Stroke = "Stroke", Divider = "StrokeHi", Text = "Text", TextDark = "TextDim" },
	}
	function Lib:ImportTheme(theme, source, name)
		local map = maps[source or "Rayfield"] or maps.Rayfield
		local tokens = {}
		for key, token in map do
			local color = Util.ToColor(theme[key])
			if color then
				tokens[token] = color
			end
		end
		if tokens.Text and not tokens.TextDim then
			tokens.TextDim = tokens.Text:Lerp(tokens.Bg or Color3.new(0, 0, 0), 0.38)
			tokens.TextMute = tokens.Text:Lerp(tokens.Bg or Color3.new(0, 0, 0), 0.6)
		end
		if tokens.Accent then
			local h, s, v = tokens.Accent:ToHSV()
			tokens.AccentInk = v > 0.6 and Color3.new(0.03, 0.03, 0.04) or Color3.new(1, 1, 1)
		end
		name = name or ((source or "Imported") .. " theme")
		self:AddTheme(name, tokens)
		self:SetTheme(name)
		return name
	end

	-- ═══ Beginner hints ════════════════════════════════════════════════════
	function Lib:SetHints(on)
		self:SetSetting("Hints", on and true or false)
		if Shared.Overlay then
			Shared.Overlay.HoverDelay = on and 0.05 or 0.45
		end
		return self
	end
	task.defer(function()
		if Lib:GetSetting("Hints", false) then
			Lib:SetHints(true)
		end
	end)
end
