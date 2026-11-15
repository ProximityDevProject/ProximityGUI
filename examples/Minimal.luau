local Proximity = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProximityDevProject/ProximityGUI/main/dist/Proximity.luau"))()

local Window = Proximity:Window({ Title = "My Script" })
local Main = Window:Tab({ Name = "Main", Icon = "home" })
local Section = Main:Section({ Name = "General" })

Section:Toggle({ Name = "Auto farm", Flag = "farm", Callback = function(on)
	print("auto farm:", on)
end })

Section:Slider({ Name = "Walk speed", Min = 16, Max = 100, Default = 16, Flag = "speed", Callback = function(v)
	local h = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if h then
		h.WalkSpeed = v
	end
end })

Window:SettingsTab()
