--!nocheck
--[[
	Proximity · Widgets/Extras
	  Library:Widget({ Title, Icon, Width })      your own HUD panel with Proximity elements
	  Library:PlayerPanel()                       3D character, health, speed, state
	  Library:PerfGraph()                         live FPS and ping lines
	  Library:Stopwatch()                         session time + stopwatch
	  Library:SetDebug(true)                      debug overlay
	  Library:CheckForUpdates()                   quiet "new version" notice
	  Library:SetEconomy(on) / auto mode          fewer effects when FPS drops
	  topbar button with the planet next to the Roblox menu
]]

local Util = require("../Core/Util")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")
local Theme = require("../Theme")
local Icons = require("../Icons")
local Locale = require("../Locale")
local Shared = require("../Shared")

local Players = Env.Service("Players")
local RunService = Env.Service("RunService")
local GuiService = Env.Service("GuiService")

return function(Lib)
	local function panel(name, width, key, default)
		local frame = Util.New("Frame", { Name = name, Size = UDim2.fromOffset(width, 0), AutomaticSize = Enum.AutomaticSize.Y, Active = true, Parent = Shared.Gui.Widgets })
		Util.Corner(10, frame)
		Theme.Paint(frame, { BackgroundColor3 = "Bg" })
		frame.BackgroundTransparency = 0.06
		Theme.Paint(Util.Stroke(frame), { Color = "Stroke" })
		Shared.Overlay.Shadow(frame, 0.55, 18)
		Util.Padding(frame, 10, 12, 12, 12)
		Util.List(frame, 6)
		Lib:Dock(frame, key, default)
		return frame
	end

	local function header(frame, title, icon)
		local head = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 0, Parent = frame })
		local img = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get(icon) or "", Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(0, 2), Parent = head })
		Theme.Paint(img, { ImageColor3 = "TextDim" })
		local label = Util.Label({ Text = title, FontFace = Theme.Fonts.Bold, TextSize = 12, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(20, 0), Parent = head })
		Theme.Paint(label, { TextColor3 = "Text" })
		return head, label
	end

	-- ═══ Custom HUD widget ════════════════════════════════════════════════
	--[[
		local hud = Proximity:Widget({ Title = "Farm", Icon = "farm", Width = 220 })
		hud:Toggle({ Name = "Auto farm", Flag = "farm" })     -- any element works
		hud:SetVisible(false)  hud:Destroy()
	]]
	function Lib:Widget(options)
		options = options or {}
		local frame = panel("Widget_" .. (options.Title or "HUD"), options.Width or 230, "Widget." .. (options.Title or "HUD"), options.Position and { AnchorPoint = options.AnchorPoint or Vector2.new(0, 0), Position = options.Position } or { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0) })
		header(frame, options.Title or "HUD", options.Icon or "layout-dashboard")
		local body = Util.New("Frame", { BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 1, Parent = frame })
		Util.List(body, 2)
		local section = Lib._classes.Section.new(nil, { Name = options.Title or "HUD" })
		section.Floating = true
		section.Window = Lib.Windows[1]
		section.Body = body
		section._mounted = true
		section.Frame = frame
		function section:SetVisible(v)
			frame.Visible = v
			return self
		end
		function section:Destroy()
			self:Clear()
			frame:Destroy()
		end
		return section
	end
	Lib.HUD = Lib.Widget

	-- ═══ Player panel ═════════════════════════════════════════════════════
	function Lib:PlayerPanel(options)
		options = options or {}
		if Lib.PlayerPanelWidget then
			return Lib.PlayerPanelWidget
		end
		local frame = panel("PlayerPanel", 190, "PlayerPanel", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0) })
		header(frame, Locale.T("PlayerPanel"), "user")
		local vp = Util.New("ViewportFrame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 170), LayoutOrder = 1, Ambient = Color3.fromRGB(150, 150, 160), LightColor = Color3.new(1, 1, 1), LightDirection = Vector3.new(-1, -1, -1), Parent = frame })
		Util.Corner(8, vp)
		local function stat(order, name)
			local row = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = order, Parent = frame })
			local l = Util.Label({ Text = name, FontFace = Theme.Fonts.Medium, TextSize = 11, Size = UDim2.fromScale(0.5, 1), Parent = row })
			Theme.Paint(l, { TextColor3 = "TextMute" })
			local v = Util.Label({ Text = "-", FontFace = Theme.Fonts.MonoBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.fromScale(1, 1), Parent = row })
			Theme.Paint(v, { TextColor3 = "Text" })
			return v
		end
		local barTrack = Util.New("Frame", { Size = UDim2.new(1, 0, 0, 4), LayoutOrder = 2, Parent = frame })
		Util.Round(barTrack)
		Theme.Paint(barTrack, { BackgroundColor3 = "Surface3" })
		local bar = Util.New("Frame", { Size = UDim2.fromScale(1, 1), Parent = barTrack })
		Util.Round(bar)
		Theme.Paint(bar, { BackgroundColor3 = "Accent" })
		local hp, speed, state, pos = stat(3, Locale.T("Health")), stat(4, Locale.T("Speed")), stat(5, Locale.T("State")), stat(6, Locale.T("Position"))
		local model, camera, angle = nil, nil, 0
		local function rebuild()
			vp:ClearAllChildren()
			Util.Corner(8, vp)
			local char = Players.LocalPlayer.Character
			if not char then
				return
			end
			local ok = Lib:_fillViewport(vp, char)
			if ok then
				camera = vp.CurrentCamera
				model = vp:FindFirstChildWhichIsA("WorldModel") and vp:FindFirstChildWhichIsA("WorldModel"):FindFirstChildWhichIsA("Model")
			end
		end
		rebuild()
		local conns = {}
		table.insert(conns, Players.LocalPlayer.CharacterAdded:Connect(function()
			task.wait(1)
			rebuild()
		end))
		local last = 0
		table.insert(conns, RunService.Heartbeat:Connect(function(dt)
			if not frame.Visible then
				return
			end
			angle += dt * 0.6
			if model and camera then
				local cf, size = model:GetBoundingBox()
				local d = size.Magnitude * 1.05
				camera.CFrame = CFrame.lookAt(cf.Position + Vector3.new(math.sin(angle) * d, size.Y * 0.05, math.cos(angle) * d), cf.Position)
			end
			if os.clock() - last < 0.25 then
				return
			end
			last = os.clock()
			local char = Players.LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if hum then
				hp.Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
				Tween.Play(bar, { Size = UDim2.fromScale(math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1), 1) }, 0.2)
				state.Text = hum:GetState().Name
			end
			if root then
				speed.Text = string.format("%.1f", root.AssemblyLinearVelocity.Magnitude)
				local p = root.Position
				pos.Text = Lib.Anonymous and "hidden" or string.format("%d, %d, %d", p.X, p.Y, p.Z)
			end
		end))
		local widget = { Frame = frame }
		function widget:SetVisible(v)
			frame.Visible = v
			return self
		end
		function widget:Destroy()
			for _, c in conns do
				c:Disconnect()
			end
			frame:Destroy()
			Lib.PlayerPanelWidget = nil
		end
		Shared.Maid:Give(widget)
		Lib.PlayerPanelWidget = widget
		return widget
	end

	-- ═══ Performance graph ════════════════════════════════════════════════
	function Lib:PerfGraph(options)
		options = options or {}
		if Lib.PerfGraphWidget then
			return Lib.PerfGraphWidget
		end
		local frame = panel("PerfGraph", 210, "PerfGraph", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -12, 1, -12) })
		header(frame, Locale.T("Performance"), "activity")
		local function graph(order, name)
			local row = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = order, Parent = frame })
			local l = Util.Label({ Text = name, FontFace = Theme.Fonts.Medium, TextSize = 11, Size = UDim2.new(0.4, 0, 0, 14), Parent = row })
			Theme.Paint(l, { TextColor3 = "TextMute" })
			local v = Util.Label({ Text = "", FontFace = Theme.Fonts.MonoBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, 0, 0, 14), Parent = row })
			Theme.Paint(v, { TextColor3 = "Text" })
			local area = Util.New("Frame", { Size = UDim2.new(1, 0, 0, 22), Position = UDim2.fromOffset(0, 17), ClipsDescendants = true, Parent = row })
			Util.Corner(4, area)
			Theme.Paint(area, { BackgroundColor3 = "Surface2" })
			return v, area
		end
		local fpsLabel, fpsArea = graph(1, "FPS")
		local pingLabel, pingArea = graph(2, Locale.T("Ping"))
		local fps, ping = {}, {}
		local alive = true
		task.spawn(function()
			while alive and not Lib.Unloaded do
				local f = Lib.Providers.FPS()
				local p = tonumber(string.match(Lib.Providers.Ping(), "%d+")) or 0
				table.insert(fps, f)
				table.insert(ping, p)
				if #fps > 40 then
					table.remove(fps, 1)
					table.remove(ping, 1)
				end
				if frame.Visible then
					fpsLabel.Text = tostring(f)
					pingLabel.Text = p .. " ms"
					Lib._drawSpark(fpsArea, fps)
					Lib._drawSpark(pingArea, ping)
				end
				task.wait(0.5)
			end
		end)
		local widget = { Frame = frame }
		function widget:SetVisible(v)
			frame.Visible = v
			return self
		end
		function widget:Destroy()
			alive = false
			frame:Destroy()
			Lib.PerfGraphWidget = nil
		end
		Shared.Maid:Give(widget)
		Lib.PerfGraphWidget = widget
		return widget
	end

	-- ═══ Stopwatch ════════════════════════════════════════════════════════
	function Lib:Stopwatch(options)
		options = options or {}
		if Lib.StopwatchWidget then
			return Lib.StopwatchWidget
		end
		local frame = panel("Stopwatch", 200, "Stopwatch", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 12, 1, -12) })
		header(frame, Locale.T("Stopwatch"), "timer")
		local time = Util.Label({ Text = "00:00.0", FontFace = Theme.Fonts.MonoBold, TextSize = 24, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 1, Parent = frame })
		Theme.Paint(time, { TextColor3 = "Text" })
		local session = Util.Label({ Text = "", FontFace = Theme.Fonts.Mono, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 2, Parent = frame })
		Theme.Paint(session, { TextColor3 = "TextMute" })
		local row = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), LayoutOrder = 3, Parent = frame })
		Util.List(row, 6, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center)
		local running, startAt, acc = false, 0, 0
		local function btn(icon, fn)
			local b = Util.New("ImageButton", { Size = UDim2.fromOffset(40, 28), AutoButtonColor = false, Parent = row })
			Util.Corner(6, b)
			Theme.Paint(b, { BackgroundColor3 = "Surface3" })
			local img = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get(icon) or "", Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Parent = b })
			Theme.Paint(img, { ImageColor3 = "Text" })
			b.Activated:Connect(fn)
			return img
		end
		local playIcon
		playIcon = btn("play", function()
			if running then
				acc += os.clock() - startAt
				running = false
			else
				startAt = os.clock()
				running = true
			end
			playIcon.Image = Icons.Get(running and "pause" or "play") or ""
		end)
		btn("rotate-ccw", function()
			acc, startAt = 0, os.clock()
		end)
		local alive = true
		task.spawn(function()
			while alive and not Lib.Unloaded do
				local t = acc + (running and (os.clock() - startAt) or 0)
				time.Text = string.format("%02d:%02d.%d", t // 60, t % 60, (t * 10) % 10)
				session.Text = Locale.T("InGame") .. " " .. Lib.Providers.Session()
				task.wait(0.1)
			end
		end)
		local widget = { Frame = frame }
		function widget:SetVisible(v)
			frame.Visible = v
			return self
		end
		function widget:Destroy()
			alive = false
			frame:Destroy()
			Lib.StopwatchWidget = nil
		end
		Shared.Maid:Give(widget)
		Lib.StopwatchWidget = widget
		return widget
	end

	-- ═══ Topbar button (next to the Roblox menu) ═════════════════════════
	function Lib:_topbarButton(window)
		local button = Util.New("TextButton", { Name = "ProximityTopbar", Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(44, 44), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.3, ZIndex = 250, Parent = Shared.Gui.Root })
		Util.Round(button)
		local stroke = Util.Stroke(button, Color3.new(1, 1, 1), 1, 1)
		local logo = window:_drawLogo(button, 26)
		logo.AnchorPoint = Vector2.new(0.5, 0.5)
		logo.Position = UDim2.fromScale(0.5, 0.5)
		-- Games and other scripts put their own buttons into the topbar too
		-- (TopbarPlus icons, "options" buttons...). Find the rightmost visible
		-- button inside the topbar strip and sit after it, rechecking now and
		-- then because those buttons appear late.
		local function occupiedUntil(left, top, bottom)
			local edge = left
			local guiInset = 0
			pcall(function()
				guiInset = GuiService:GetGuiInset().Y
			end)
			local roots = {}
			local player = Players.LocalPlayer
			local pg = player and player:FindFirstChildOfClass("PlayerGui")
			if pg then
				table.insert(roots, pg)
			end
			pcall(function()
				table.insert(roots, game:GetService("CoreGui"))
			end)
			for _, root in roots do
				for _, gui in root:GetChildren() do
					if gui:IsA("ScreenGui") and gui.Enabled and gui ~= Shared.Gui.Root and gui.Name ~= "RobloxGui" and gui.Name ~= "TopBarApp" then
						local shift = gui.IgnoreGuiInset and 0 or guiInset
						for _, obj in gui:GetDescendants() do
							if obj:IsA("GuiButton") and obj.Visible and obj ~= button then
								local pos, size = obj.AbsolutePosition, obj.AbsoluteSize
								local y = pos.Y + shift
								if size.X > 8 and size.X < 260 and size.Y > 8 and size.Y < 80 and y >= top - 4 and y + size.Y <= bottom + 6 and pos.X + size.X > left and pos.X < left + 600 then
									local visible = true
									local p = obj.Parent
									while p and p ~= gui do
										if p:IsA("GuiObject") and not p.Visible then
											visible = false
											break
										end
										p = p.Parent
									end
									if visible then
										edge = math.max(edge, pos.X + size.X)
									end
								end
							end
						end
					end
				end
			end
			return edge
		end
		local function place()
			local inset = GuiService.TopbarInset
			local x, y = 164, 4
			local left, top, bottom = 160, 0, 52
			if inset and inset.Width > 0 then
				left, top, bottom = inset.Min.X, inset.Min.Y, inset.Max.Y
				y = inset.Min.Y + math.max(0, (inset.Height - 44) / 2)
			end
			local ok, edge = pcall(occupiedUntil, left, top, bottom)
			x = (ok and edge or left) + 8
			local origin = Shared.Gui.Root.AbsolutePosition
			button.Position = UDim2.fromOffset(x - origin.X, y - origin.Y)
		end
		place()
		pcall(function()
			Shared.Maid:Connect(GuiService:GetPropertyChangedSignal("TopbarInset"), place)
		end)
		task.spawn(function()
			-- late joiners: a few quick checks, then a slow one
			for i = 1, 40 do
				task.wait(i < 6 and 1 or 5)
				if not button.Parent then
					return
				end
				place()
			end
		end)
		button.Activated:Connect(function()
			window:Toggle()
		end)
		local function paint()
			Tween.Play(stroke, { Transparency = window:IsOpen() and 0.55 or 1 }, 0.2)
			Tween.Play(button, { BackgroundTransparency = window:IsOpen() and 0.15 or 0.3 }, 0.2)
		end
		window.Opened:Connect(paint)
		window.Closed:Connect(paint)
		Shared.Overlay.Hover(button, function()
			return window.Title
		end)
		window.Maid:Give(button)
		return button
	end

	-- ═══ Update check ═════════════════════════════════════════════════════
	local function newer(a, b)
		local pa, pb = {}, {}
		for n in string.gmatch(a, "%d+") do
			table.insert(pa, tonumber(n))
		end
		for n in string.gmatch(b, "%d+") do
			table.insert(pb, tonumber(n))
		end
		for i = 1, math.max(#pa, #pb) do
			if (pa[i] or 0) ~= (pb[i] or 0) then
				return (pa[i] or 0) > (pb[i] or 0)
			end
		end
		return false
	end
	Lib._newer = newer

	-- Library:CheckForUpdates() for Proximity itself; window options
	-- Version + VersionUrl do the same for your script.
	function Lib:CheckForUpdates(url, current, name)
		task.spawn(function()
			local body = Env.HttpGet((url or Lib.VersionUrl) .. "?t=" .. os.time())
			local latest = body and string.match(body, "%d+%.%d+[%.%d]*")
			current = current or Lib.Version
			if latest and newer(latest, current) then
				Lib:Notify({ Title = Locale.T("UpdateTitle", name or "Proximity"), Content = Locale.T("UpdateBody", current, latest), Type = "info", Duration = 8 })
			end
		end)
	end

	-- ═══ Economy mode ═════════════════════════════════════════════════════
	function Lib:SetEconomy(on, auto)
		Lib.Economy = on and true or false
		for _, w in Lib.Windows do
			w:_applyEconomy()
		end
		if on and auto and not Lib._economyNoticed then
			Lib._economyNoticed = true
			Lib:Notify({ Title = Locale.T("EconomyTitle"), Content = Locale.T("EconomyBody"), Type = "info", Duration = 6 })
		end
		return self
	end

	task.spawn(function()
		local low = 0
		while not Lib.Unloaded do
			task.wait(1)
			if Lib:GetSetting("AutoEconomy", true) and not Lib.Economy and #Lib.Windows > 0 then
				local fps = Lib.Providers.FPS()
				low = fps < 30 and low + 1 or 0
				if low >= 6 then
					Lib:SetEconomy(true, true)
				end
			end
		end
	end)

	-- ═══ Debug overlay ════════════════════════════════════════════════════
	function Lib:SetDebug(on)
		Lib.Debug = on and true or false
		if Lib._debugPanel then
			Lib._debugPanel:Destroy()
			Lib._debugPanel = nil
		end
		if not on then
			return self
		end
		local frame = panel("Debug", 240, "Debug", { AnchorPoint = Vector2.new(0, 0), Position = UDim2.new(0, 12, 0, 70) })
		header(frame, "Debug", "bug")
		local text = Util.Label({ Text = "", FontFace = Theme.Fonts.Mono, TextSize = 11, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 1, Parent = frame })
		Theme.Paint(text, { TextColor3 = "TextDim" })
		local alive = true
		task.spawn(function()
			while alive and not Lib.Unloaded do
				local lines = {
					"version   " .. Lib.Version,
					"elements  " .. #Lib.AllElements,
					"flags     " .. Util.Count(Lib.Elements),
					"instances " .. #Shared.Gui.Root:GetDescendants(),
					"memory    " .. math.floor(gcinfo() / 1024 * 10) / 10 .. " MB",
					"fps       " .. Lib.Providers.FPS(),
				}
				for _, w in Lib.Windows do
					table.insert(lines, "")
					table.insert(lines, w.Title .. " - " .. w.State)
					for _, tab in w.Tabs do
						table.insert(lines, string.format("  %-12s %3d el  %4.0f ms", string.sub(tab.Name, 1, 12), tab._total, (tab._buildTime or 0) * 1000))
					end
				end
				text.Text = table.concat(lines, "\n")
				task.wait(0.5)
			end
		end)
		Lib._debugPanel = { Destroy = function()
			alive = false
			frame:Destroy()
		end }
		return self
	end
end
