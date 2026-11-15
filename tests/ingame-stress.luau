-- Stress test: 1000 elements across 10 tabs. Prints build time, instance
-- count and FPS before/after. Run the in-game build (build/ingame-*.luau
-- prefix) or after the loadstring line.
local Proximity = Proximity or loadstring(game:HttpGet("https://raw.githubusercontent.com/ProximityDevProject/ProximityGUI/main/dist/Proximity.luau"))()
local fpsBefore = Proximity.Providers.FPS()
local memBefore = gcinfo()
local t0 = os.clock()
local W = Proximity:Window({ Title = "Stress", Folder = "Proximity-Stress", Loading = { MinTime = 0 }, Watermark = false, KeybindList = false })
for t = 1, 10 do
	local tab = W:Tab({ Name = "Tab " .. t, Icon = "layers" })
	for s = 1, 4 do
		local sec = tab:Section({ Name = "Section " .. s, Side = s % 2 == 0 and "Right" or "Left" })
		for i = 1, 25 do
			if i % 5 == 0 then
				sec:Slider({ Name = "Slider " .. i, Min = 0, Max = 100, Default = i, Flag = ("s%d_%d_%d"):format(t, s, i) })
			elseif i % 7 == 0 then
				sec:Dropdown({ Name = "Dropdown " .. i, Values = { "A", "B", "C" }, Default = "A" })
			else
				sec:Toggle({ Name = "Toggle " .. i, Flag = ("t%d_%d_%d"):format(t, s, i) })
			end
		end
	end
end
W:WaitUntilReady(60)
local built = os.clock() - t0
task.wait(3)
print(("[stress] 1000 elements ready in %.2f s | instances %d | memory +%.1f MB | fps %d -> %d"):format(built, #Proximity.Gui:GetDescendants(), (gcinfo() - memBefore) / 1024, fpsBefore, Proximity.Providers.FPS()))
