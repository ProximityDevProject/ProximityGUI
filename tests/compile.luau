-- Compiles every source file and the bundle with the Luau compiler (syntax gate).
local fs = require("@lune/fs")
local luau = require("@lune/luau")
local failed = 0
local function check(path)
	local ok, err = pcall(luau.compile, fs.readFile(path))
	if not ok then
		failed += 1
		print("FAIL " .. path .. "\n  " .. tostring(err))
	end
end
local function walk(dir)
	for _, name in fs.readDir(dir) do
		local p = dir .. "/" .. name
		if fs.isDir(p) then
			walk(p)
		elseif string.match(name, "%.luau$") then
			check(p)
		end
	end
end
walk("src")
check("dist/Proximity.luau")
print(failed == 0 and "compile: ok" or ("compile: " .. failed .. " failed"))
if failed > 0 then
	error("compile failed")
end
