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
local toProximity = {}
local urlCache = {}

local aliases = {
	-- semantic names for common script features (the Proximity icon vocabulary)
	["home"] = "home",
	["main"] = "home",
	["dashboard"] = "layout-dashboard",
	["combat"] = "swords",
	["aimbot"] = "crosshair",
	["aim"] = "crosshair",
	["silent"] = "eye-off",
	["triggerbot"] = "mouse-pointer-click",
	["fov"] = "circle-dot",
	["target"] = "target",
	["targeting"] = "users",
	["weapon"] = "sword",
	["gun"] = "crosshair",
	["melee"] = "axe",
	["knife"] = "sword",
	["recoil"] = "move-vertical",
	["spread"] = "focus",
	["visuals"] = "eye",
	["visual"] = "eye",
	["esp"] = "scan",
	["chams"] = "person-standing",
	["box"] = "square",
	["tracer"] = "move-diagonal",
	["tracers"] = "move-diagonal",
	["skeleton"] = "bone",
	["name"] = "type",
	["health"] = "heart",
	["distance"] = "ruler",
	["radar"] = "radio",
	["world"] = "globe",
	["lighting"] = "sun",
	["fog"] = "cloud-fog",
	["time"] = "clock",
	["weather"] = "cloud-rain",
	["fullbright"] = "sun-medium",
	["player"] = "user",
	["players"] = "users",
	["movement"] = "wind",
	["speed"] = "gauge",
	["walkspeed"] = "gauge",
	["jump"] = "arrow-up",
	["fly"] = "plane",
	["noclip"] = "ghost",
	["teleport"] = "map-pin",
	["tp"] = "map-pin",
	["spectate"] = "eye",
	["camera"] = "video",
	["freecam"] = "camera",
	["godmode"] = "shield",
	["antiafk"] = "coffee",
	["respawn"] = "rotate-ccw",
	["farm"] = "sprout",
	["autofarm"] = "sprout",
	["auto"] = "refresh-cw",
	["loot"] = "package",
	["chest"] = "package-open",
	["items"] = "boxes",
	["inventory"] = "backpack",
	["shop"] = "shopping-cart",
	["merchant"] = "shopping-bag",
	["quest"] = "scroll",
	["quests"] = "scroll",
	["boss"] = "skull",
	["npc"] = "bot",
	["pet"] = "heart",
	["fishing"] = "anchor",
	["mining"] = "hammer",
	["server"] = "server",
	["servers"] = "server",
	["rejoin"] = "refresh-ccw",
	["serverhop"] = "shuffle",
	["hop"] = "shuffle",
	["friends"] = "user-plus",
	["chat"] = "message-square",
	["webhook"] = "link",
	["discord"] = "message-circle",
	["link"] = "link",
	["misc"] = "layers",
	["utility"] = "wrench",
	["tools"] = "wrench",
	["script"] = "code",
	["scripts"] = "file-code",
	["console"] = "terminal",
	["log"] = "terminal",
	["debug"] = "bug",
	["settings"] = "settings",
	["gear"] = "settings",
	["cog"] = "settings",
	["config"] = "folder",
	["configs"] = "folder",
	["save"] = "save",
	["load"] = "folder-open",
	["theme"] = "palette",
	["appearance"] = "palette",
	["keyboard"] = "keyboard",
	["keybind"] = "keyboard",
	["keybinds"] = "keyboard",
	["language"] = "languages",
	["about"] = "info",
	["info"] = "info",
	["credits"] = "heart-handshake",
	["premium"] = "crown",
	["vip"] = "crown",
	["key"] = "key",
	["lock"] = "lock",
	["unlock"] = "unlock",
	["favorite"] = "star",
	["favorites"] = "star",
	["search"] = "search",
	["close"] = "x",
	["minimize"] = "minus",
	["check"] = "check",
	["warning"] = "alert-triangle",
	["error"] = "x-circle",
	["success"] = "check-circle",
	["trash"] = "trash-2",
	["copy"] = "copy",
	["paste"] = "clipboard",
	["reset"] = "rotate-ccw",
	["power"] = "power",
	["unload"] = "power",
	["planet"] = "globe-2",
	["proximity"] = "globe-2",
	["backdrop"] = "star",
	["rim"] = "circle",
	["motion"] = "activity",
	["scale"] = "scaling",
	["transparency"] = "droplet",
	["accent"] = "pipette",
	["notifications"] = "bell",
	["watermark"] = "type",
	["anonymous"] = "venetian-mask",
	["editor"] = "paintbrush",
	["tour"] = "map",
	["export"] = "upload",
	["import"] = "download",
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
	local raw = string.lower(source)
	if string.find(raw, "^px:") then
		return Icons.Proximity[string.sub(raw, 4)]
	end
	local name = string.lower(string.gsub(source, "^lucide%-", ""))
	name = aliases[name] or name
	-- the Proximity set wins when it is loaded and has a drawing for this name
	if Icons.UseProximity then
		local px = Icons.Proximity[name] or Icons.Proximity[toProximity[name] or ""] or Icons.Proximity[toProximity[raw] or ""]
		if px then
			return px
		end
	end
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

-- ═══ The Proximity icon set ════════════════════════════════════════════════
--[[
	86 icons drawn for Proximity in one line style (assets/icons). They come
	as one packed file, downloaded once and unpacked into the executor's
	folder, so later runs load them instantly. Wherever a name has a
	Proximity drawing it is used; everything else stays Lucide.
	  Icons.Get("settings")      -> the Proximity gear (when loaded)
	  Icons.Get("px:planet")     -> only the Proximity drawing
	  Icons.UseProximity = false -> Lucide everywhere
]]
Icons.Proximity = {}
Icons.UseProximity = true
Icons.PackUrl = "https://raw.githubusercontent.com/ProximityDevProject/ProximityGUI/main/assets/icons/proximity-icons.txt"
Icons.PackVersion = "1"

-- Lucide names the library uses -> the Proximity drawing for them
toProximity = {
	["sliders-horizontal"] = "sliders", ["sliders-vertical"] = "sliders", ["settings-2"] = "settings", ["cog"] = "settings",
	["volume-2"] = "volume", ["volume-1"] = "volume", ["volume-x"] = "volume-off", ["trash-2"] = "trash",
	["rotate-ccw"] = "refresh", ["rotate-cw"] = "refresh", ["refresh-cw"] = "refresh", ["refresh-ccw"] = "refresh",
	["alert-triangle"] = "warning", ["triangle-alert"] = "warning", ["circle-alert"] = "info", ["bar-chart-2"] = "bar-chart",
	["bar-chart-3"] = "bar-chart", ["chart-bar"] = "bar-chart", ["swords"] = "sword", ["locate-fixed"] = "target", ["scan"] = "target",
	["keyboard"] = "keyboard", ["mouse-pointer"] = "mouse", ["circle-user"] = "user", ["user-round"] = "user",
	["users-round"] = "users", ["folder-open"] = "folder", ["save"] = "save", ["log-out"] = "power", ["circle-power"] = "power",
	["message-square"] = "message", ["message-circle"] = "message", ["map"] = "compass", ["navigation"] = "compass",
	["layout-grid"] = "grid", ["list-filter"] = "filter", ["paintbrush"] = "brush", ["brush"] = "brush",
	["case-sensitive"] = "type", ["text"] = "type", ["timer"] = "clock", ["clock-3"] = "clock", ["sparkles"] = "star",
	["shield-alert"] = "shield", ["badge-check"] = "shield-check", ["box"] = "inventory", ["package"] = "inventory",
	["backpack"] = "inventory", ["plane"] = "fly", ["wind"] = "fly", ["arrow-up"] = "jump", ["fast-forward"] = "speed",
	["move-up"] = "jump", ["skull"] = "skull", ["ghost"] = "ghost", ["eye-off"] = "eye-off", ["image"] = "image",
	["app-window"] = "layers", ["globe-2"] = "globe", ["earth"] = "globe", ["satellite"] = "orbit", ["orbit"] = "orbit",
	["circle-dot"] = "target", ["radio"] = "radar", ["radar"] = "radar", ["music-2"] = "music", ["file-code"] = "code",
	["square-terminal"] = "terminal", ["cpu"] = "cpu", ["server"] = "server", ["wifi"] = "wifi", ["link-2"] = "link",
	["clipboard-copy"] = "clipboard", ["pencil-line"] = "pencil", ["edit"] = "pencil", ["plus-circle"] = "plus",
	["circle-check"] = "check", ["check-circle"] = "check", ["x-circle"] = "x", ["circle-x"] = "x", ["bell-ring"] = "bell",
	["moon-star"] = "moon", ["sun-medium"] = "sun", ["zap"] = "zap", ["flame"] = "flame", ["snowflake"] = "snowflake",
}

function Icons.LoadPack()
	if not (Env.Caps.Files and Env.Caps.CustomAsset) then
		return false
	end
	local folder = "Proximity/icons"
	local packPath = folder .. "/pack-v" .. Icons.PackVersion .. ".txt"
	pcall(Env.MakeFolder, "Proximity")
	pcall(Env.MakeFolder, folder)
	local body = Env.Read(packPath)
	if not body or #body < 100 then
		body = Env.HttpGet(Icons.PackUrl .. "?v=" .. Icons.PackVersion)
		if not body or not string.find(string.sub(body, 1, 40), "^[%w%-]+:") then
			return false
		end
		Env.Write(packPath, body)
	end
	local count = 0
	for name, data in string.gmatch(body, "([%w%-]+):([^\n]+)") do
		local path = folder .. "/" .. name .. ".png"
		if not Env.IsFile(path) then
			local ok, png = pcall(Util.Base64Decode, data)
			if ok and png then
				Env.Write(path, png)
			end
		end
		local asset = Env.CustomAsset(path)
		if asset then
			Icons.Proximity[name] = asset
			count += 1
		end
	end
	return count > 0
end

pcall(Icons.LoadPack)

return Icons
