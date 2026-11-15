--!nocheck
--[[
	Proximity · Elements/PlayerList
	Every player on the server with avatar, display name, distance and quick
	actions. Updates itself when players join, leave or move.

	Section:PlayerList({
		Height = 260, ExcludeSelf = true, Search = true,
		Actions = { "Spectate", "Teleport", "Copy" }        -- built-in
		         or { { Icon = "user-x", Tooltip = "Kick", Callback = fn(player) } },
		OnSelect = fn(player),
	})
	list:GetSelected() list:Refresh() list:StopSpectating()
]]

local Util = require("../Core/Util")
local Env = require("../Core/Env")
local Theme = require("../Theme")
local Icons = require("../Icons")
local Locale = require("../Locale")
local Shared = require("../Shared")
local Base = require("./Base")

local Players = Env.Service("Players")

local PlayerList = Base.extend("PlayerList")

local builtIn = {
	Spectate = { Icon = "eye", Tooltip = "Spectate", Callback = function(player, list)
		local cam = workspace.CurrentCamera
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if list._spectating == player then
			list:StopSpectating()
		elseif hum then
			list._spectating = player
			cam.CameraSubject = hum
		end
	end },
	Teleport = { Icon = "map-pin", Tooltip = "Teleport", Callback = function(player)
		local me = Players.LocalPlayer.Character
		local root = me and me:FindFirstChild("HumanoidRootPart")
		local target = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root and target then
			root.CFrame = target.CFrame * CFrame.new(0, 0, 3)
		end
	end },
	Copy = { Icon = "copy", Tooltip = "Copy name", Callback = function(player)
		Env.Clipboard(player.Name)
		Shared.Lib:Notify({ Content = Locale.T("Copied") .. ": " .. player.Name, Type = "success", Duration = 2 })
	end },
}

function PlayerList.new(section, options)
	local self = Base.new(PlayerList, section, options)
	self.Height = options.Height or 260
	self.ExcludeSelf = options.ExcludeSelf ~= false
	self.SearchEnabled = options.Search ~= false
	self.OnSelect = options.OnSelect
	self.Actions = {}
	for _, a in options.Actions or { "Spectate", "Teleport", "Copy" } do
		table.insert(self.Actions, type(a) == "string" and builtIn[a] or a)
	end
	self.Query = ""
	self.Value = nil
	self:_register()
	self.Maid:Connect(Players.PlayerAdded, function()
		self:Refresh()
	end)
	self.Maid:Connect(Players.PlayerRemoving, function(p)
		if self._spectating == p then
			self:StopSpectating()
		end
		task.defer(function()
			self:Refresh()
		end)
	end)
	return self
end

function PlayerList:GetSelected()
	return self.Value
end

function PlayerList:StopSpectating()
	self._spectating = nil
	local me = Players.LocalPlayer.Character
	local hum = me and me:FindFirstChildOfClass("Humanoid")
	if hum then
		workspace.CurrentCamera.CameraSubject = hum
	end
	return self
end

function PlayerList:_contextItems()
	return {}
end

function PlayerList:_applyState()
	if self.Frame then
		self.Frame.Visible = self.Visible and self._depsOk ~= false
	end
end

function PlayerList:_build(parent)
	local frame = Util.New("Frame", { Name = "PlayerList", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, self.Height), Parent = parent })
	self.Frame = frame
	local y = 0
	if self.SearchEnabled then
		local search = Util.New("TextBox", { Text = "", PlaceholderText = Locale.T("Search") .. "…", ClearTextOnFocus = false, FontFace = Theme.Fonts.Regular, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -8, 0, 26), Position = UDim2.fromOffset(4, 0), Parent = frame })
		Util.Corner(6, search)
		Util.Padding(search, 0, 8, 0, 26)
		Theme.Paint(search, { BackgroundColor3 = "Surface2", TextColor3 = "Text", PlaceholderColor3 = "TextMute" })
		local icon = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get("search") or "", Size = UDim2.fromOffset(13, 13), Position = UDim2.new(0, -19, 0.5, -6), Parent = search })
		Theme.Paint(icon, { ImageColor3 = "TextMute" })
		search:GetPropertyChangedSignal("Text"):Connect(function()
			self.Query = search.Text
			self:Refresh()
		end)
		y = 32
	end
	local list = Util.New("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, -y), Position = UDim2.fromOffset(0, y), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, Parent = frame })
	Theme.Paint(list, { ScrollBarImageColor3 = "StrokeHi" })
	Util.List(list, 4)
	Util.Padding(list, 0, 4, 0, 4)
	self._list = list
	self._rows = {}
	-- distances refresh twice a second
	task.spawn(function()
		while self.Frame and not self._destroyed do
			self:_updateDistances()
			task.wait(0.5)
		end
	end)
	self:Refresh()
end

function PlayerList:_updateDistances()
	local me = Players.LocalPlayer.Character
	local root = me and me:FindFirstChild("HumanoidRootPart")
	for player, row in self._rows or {} do
		local target = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		row.Distance.Text = (root and target) and (math.floor((root.Position - target.Position).Magnitude) .. " st") or "-"
		row.Eye.Visible = self._spectating == player
	end
end

function PlayerList:Refresh()
	if not self._list then
		return self
	end
	for _, row in self._rows do
		row.Frame:Destroy()
	end
	self._rows = {}
	local players = Players:GetPlayers()
	table.sort(players, function(a, b)
		return string.lower(a.DisplayName) < string.lower(b.DisplayName)
	end)
	for i, player in players do
		if not (self.ExcludeSelf and player == Players.LocalPlayer) and Util.Fuzzy(self.Query, player.DisplayName .. " " .. player.Name) then
			local row = Util.New("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = i, Parent = self._list })
			Util.Corner(7, row)
			Theme.Paint(row, { BackgroundColor3 = self.Value == player and "Surface3" or "Surface2" })
			local avatar = Util.New("ImageLabel", { Image = Shared.Lib.Anonymous and "" or ("rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=48&h=48"), Size = UDim2.fromOffset(28, 28), Position = UDim2.new(0, 7, 0.5, -14), Parent = row })
			Util.Round(avatar)
			Theme.Paint(avatar, { BackgroundColor3 = "Surface3" })
			local name = Util.Label({ Text = player.DisplayName, FontFace = Theme.Fonts.SemiBold, TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -150, 0, 15), Position = UDim2.fromOffset(43, 5), Parent = row })
			Theme.Paint(name, { TextColor3 = "Text" })
			local user = Util.Label({ Text = "@" .. player.Name, FontFace = Theme.Fonts.Regular, TextSize = 10, TextTruncate = Enum.TextTruncate.AtEnd, Size = UDim2.new(1, -150, 0, 13), Position = UDim2.fromOffset(43, 21), Parent = row })
			Theme.Paint(user, { TextColor3 = "TextMute" })
			local eye = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get("eye") or "", Size = UDim2.fromOffset(11, 11), Position = UDim2.new(0, 27, 0, 4), Visible = false, Parent = row })
			Theme.Paint(eye, { ImageColor3 = "Accent" })
			local dist = Util.Label({ Text = "", FontFace = Theme.Fonts.Mono, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(0, 60, 1, 0), Position = UDim2.new(1, -60 - #self.Actions * 24, 0, 0), Parent = row })
			Theme.Paint(dist, { TextColor3 = "TextDim" })
			for a, action in self.Actions do
				local b = Util.New("ImageButton", { BackgroundTransparency = 1, Image = Icons.Get(action.Icon) or "", Size = UDim2.fromOffset(15, 15), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10 - (#self.Actions - a) * 24, 0.5, 0), ZIndex = 2, Parent = row })
				Theme.Paint(b, { ImageColor3 = "TextDim" })
				b.MouseEnter:Connect(function()
					Theme.Paint(b, { ImageColor3 = "Text" }, 0.1)
				end)
				b.MouseLeave:Connect(function()
					Theme.Paint(b, { ImageColor3 = "TextDim" }, 0.1)
				end)
				if action.Tooltip then
					Shared.Overlay.Hover(b, function()
						return action.Tooltip
					end)
				end
				b.Activated:Connect(function()
					Util.SafeCall(action.Callback, player, self)
					self:_updateDistances()
				end)
			end
			row.Activated:Connect(function()
				self.Value = player
				for p, r in self._rows do
					Theme.Paint(r.Frame, { BackgroundColor3 = p == player and "Surface3" or "Surface2" }, 0.1)
				end
				self.Changed:Fire(player)
				if self.OnSelect then
					Util.SafeCall(self.OnSelect, player)
				end
				self:_fireCallbacks()
			end)
			self._rows[player] = { Frame = row, Distance = dist, Eye = eye }
		end
	end
	self:_updateDistances()
	return self
end

function PlayerList:_callbackArgs()
	return self.Value
end

return { PlayerList = PlayerList }
