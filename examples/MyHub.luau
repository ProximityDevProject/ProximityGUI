--[[
	Proximity · hub template

	Copy this file, rename the hub, and fill the tabs with your features.
	Everything a player expects is already here: a home tab, settings with
	themes and configs, a watermark, a keybind list, and an unload that
	takes back every change your script made.

	Rules that keep unload clean:
	  * connect through Proximity:Connect, not signal:Connect
	  * change game properties through Proximity:SetProperty
	  * make instances with Proximity:Create
	  * react to toggles with Proximity:Bind (it gets false on unload)
]]

local Proximity = loadstring(game:HttpGet("https://proximitydevproject.github.io/ProximityGUI/Proximity.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Window = Proximity:Window({
	Title = "My Hub",
	Subtitle = "v1.0",
	Folder = "MyHub", -- configs and settings live in workspace/MyHub
	Animation = "Planet",
	Loading = { Style = "Planet" },
})

Window:Home({ Welcome = "Welcome back", Status = "Free" })

-- ═══ Player ══════════════════════════════════════════════════════════════
local PlayerTab = Window:Tab({ Name = "Player", Icon = "user" })
local Movement = PlayerTab:Section({ Name = "Movement", Icon = "speed" })

Movement:Slider({ Name = "Walk speed", Flag = "player.speed", Min = 16, Max = 120, Default = 16, Danger = 80 })
Movement:Toggle({ Name = "Apply walk speed", Flag = "player.speed.on" })
	:Keybind({ Default = "V", Mode = "Toggle" })

-- runs right away, on every change and with false on unload
Proximity:Bind("player.speed.on", function(on)
	local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		-- SetProperty remembers the old value and puts it back on unload
		Proximity:SetProperty(humanoid, "WalkSpeed", on and Proximity.Flags["player.speed"] or 16)
	end
end)
Proximity:OnFlag("player.speed", function(value)
	local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if humanoid and Proximity.Flags["player.speed.on"] then
		Proximity:SetProperty(humanoid, "WalkSpeed", value)
	end
end)

local Camera = PlayerTab:Section({ Name = "Camera", Icon = "camera", Side = "Right" })
Camera:Slider({ Name = "Field of view", Flag = "camera.fov", Min = 50, Max = 120, Default = 70, Suffix = "°" })
Proximity:Bind("camera.fov", function(fov)
	Proximity:SetProperty(workspace.CurrentCamera, "FieldOfView", fov or 70)
end)

-- ═══ Visuals ═════════════════════════════════════════════════════════════
local Visuals = Window:Tab({ Name = "Visuals", Icon = "esp" })
local Esp = Visuals:Section({ Name = "Highlight players", Toggle = true, Flag = "esp" })
Esp:ColorPicker({ Name = "Colour", Flag = "esp.color", Default = Color3.new(1, 1, 1) })

local highlights = {}
local function clearHighlights()
	for _, h in highlights do
		h:Destroy()
	end
	table.clear(highlights)
end
Proximity:Loop(function()
	if not Proximity.Flags["esp"] then
		clearHighlights()
		return
	end
	for _, player in Players:GetPlayers() do
		if player ~= LocalPlayer and player.Character and not highlights[player] then
			-- Create makes an instance that unload destroys for you
			highlights[player] = Proximity:Create("Highlight", { Parent = player.Character, FillTransparency = 1 })
		end
		local h = highlights[player]
		if h then
			h.OutlineColor = Proximity.Flags["esp.color"]
		end
	end
end, 0.5)
Proximity:Connect(Players.PlayerRemoving, function(player)
	if highlights[player] then
		highlights[player]:Destroy()
		highlights[player] = nil
	end
end)

-- ═══ Misc ════════════════════════════════════════════════════════════════
local Misc = Window:Tab({ Name = "Misc", Icon = "settings-2" })
local Server = Misc:Section({ Name = "Server" })
Server:Button({ Name = "Rejoin", Icon = "rejoin", Callback = function()
	game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end })

local frames = 0
Proximity:Connect(RunService.RenderStepped, function()
	frames += 1
end)

-- ═══ Settings ════════════════════════════════════════════════════════════
Window:SettingsTab() -- themes, sounds, configs, screen, server, output and the unload button

Proximity:OnUnload(function()
	clearHighlights()
	print("My Hub unloaded after " .. frames .. " frames")
end)
