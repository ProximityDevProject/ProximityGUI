-- Run in Roblox after every release build: creates a window, runs the
-- library self test and prints the result (paste the dist bundle first,
-- or use the loadstring).
local Proximity = loadstring(game:HttpGet("https://proximitydevproject.github.io/ProximityGUI/Proximity.lua"))()
local Window = Proximity:Window({ Title = "Self test", Loading = false })
Window:Tab({ Name = "Main" }):Section({ Name = "Main" }):Label("Running the self test...")
task.wait(1)
local ok, problems = Proximity:SelfTest()
print("[Proximity self test]", ok and "PASSED" or "FAILED")
for _, p in problems do
	warn("  " .. p)
end
