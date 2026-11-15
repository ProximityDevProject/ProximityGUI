--!nocheck
--[[
	Proximity · Icons
	Resolves any icon source to something an ImageLabel can show:
	  "settings"                 → Lucide icon (818 bundled)
	  "lucide-settings"          → same
	  "rbxassetid://123" / 123   → Roblox asset
	  "https://…/x.png"          → downloaded once, cached, getcustomasset()
	  custom names registered with Icons.Register
	Unknown names resolve to nil (never an error).
]]

local Env = require("../Core/Env")
local Util = require("../Core/Util")
local Lucide = require("./Lucide")

local Icons = {
	CacheFolder = "Proximity/Cache",
}

local custom = {}
local urlCache = {}

local aliases = {
	gear = "settings",
	cog = "settings",
	combat = "swords",
	aim = "crosshair",
	visuals = "eye",
	esp = "eye",
	player = "user",
	world = "globe",
	misc = "layers",
	config = "folder",
	configs = "folder",
	theme = "palette",
	info = "info",
	home = "home",
	search = "search",
	close = "x",
	minimize = "minus",
	check = "check",
	warning = "alert-triangle",
	error = "x-circle",
	success = "check-circle",
	keyboard = "keyboard",
	lock = "lock",
	star = "star",
	trash = "trash-2",
	copy = "copy",
	paste = "clipboard",
	reset = "rotate-ccw",
	auto = "refresh-cw",
}

local function fromUrl(url: string): string?
	if urlCache[url] then
		return urlCache[url]
	end
	if not Env.Caps.CustomAsset then
		return nil
	end
	local ext = string.match(url, "%.(%a+)$") or "png"
	if ext ~= "png" and ext ~= "jpg" and ext ~= "jpeg" then
		ext = "png"
	end
	local path = Icons.CacheFolder .. "/" .. Util.Checksum(url) .. "." .. ext
	if not Env.IsFile(path) then
		local body = Env.HttpGet(url)
		if not body or #body < 16 then
			return nil
		end
		Env.Write(path, body)
	end
	local asset = Env.CustomAsset(path)
	urlCache[url] = asset
	return asset
end

function Icons.Get(source: any): string?
	if source == nil or source == false or source == "" then
		return nil
	end
	if type(source) == "number" then
		return "rbxassetid://" .. source
	end
	source = tostring(source)
	if custom[source] then
		return Icons.Get(custom[source])
	end
	if string.find(source, "^rbxasset") or string.find(source, "^rbxthumb") or string.find(source, "^http://www.roblox.com") then
		return source
	end
	if string.find(source, "^%d+$") then
		return "rbxassetid://" .. source
	end
	if string.find(source, "^https?://") then
		return fromUrl(source)
	end
	local name = string.lower(string.gsub(source, "^lucide%-", ""))
	name = aliases[name] or name
	local id = Lucide[name]
	if id then
		return "rbxassetid://" .. id
	end
	return nil
end

function Icons.Register(name: string, source: any)
	custom[name] = source
end

function Icons.Has(name: string): boolean
	return Icons.Get(name) ~= nil
end

function Icons.List(): { string }
	local out = Util.Keys(Lucide)
	for k in custom do
		table.insert(out, k)
	end
	table.sort(out)
	return out
end

-- Async preload so first paint does not pop.
function Icons.Preload(names: { any })
	local list = {}
	for _, name in names do
		local id = Icons.Get(name)
		if id then
			local img = Instance.new("ImageLabel")
			img.Image = id
			table.insert(list, img)
		end
	end
	task.spawn(function()
		pcall(function()
			game:GetService("ContentProvider"):PreloadAsync(list)
		end)
		for _, img in list do
			img:Destroy()
		end
	end)
end

return Icons
