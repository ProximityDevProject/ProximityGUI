-- Leak test: create and destroy a window 100 times, compare memory and
-- instance counts at the start and at the end.
local Proximity = Proximity or loadstring(game:HttpGet("https://raw.githubusercontent.com/ProximityDevProject/ProximityGUI/main/dist/Proximity.luau"))()
local function snapshot()
	collectgarbage("collect")
	task.wait(0.5)
	return gcinfo(), #Proximity.Gui:GetDescendants()
end
local mem0, inst0 = snapshot()
for i = 1, 100 do
	local W = Proximity:Window({ Title = "Leak " .. i, Folder = "Proximity-Leak", Loading = false, Watermark = false, KeybindList = false, ToggleButton = false })
	local tab = W:Tab({ Name = "Main" })
	local sec = tab:Section({ Name = "S" })
	for j = 1, 20 do
		sec:Toggle({ Name = "T" .. j })
		sec:Slider({ Name = "S" .. j, Min = 0, Max = 10 })
	end
	task.wait()
	W:Destroy()
end
local mem1, inst1 = snapshot()
print(("[leak] 100 windows | memory %.1f -> %.1f MB | instances %d -> %d"):format(mem0 / 1024, mem1 / 1024, inst0, inst1))
