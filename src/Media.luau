--!nocheck
--[[
	Proximity · Media
	Sounds, hit sounds, hit markers and images hosted in the Proximity repo
	(assets/media). Each file is downloaded once into the executor's folder
	(Proximity/media/...) and loaded with getcustomasset, so it works on any
	executor that has file functions. Without them every call returns nil and
	nothing breaks.

	  Library.Media:Get("hitsounds", "neverlose")      -> "rbxasset://..." or nil
	  Library.Media:Play("ui", "wood", { Volume = 0.5 })
	  Library.Media:Preload("hitsounds")               -- in the background
	  Library.Media.Lists.hitsounds                    -- names for a dropdown
	  Library:PlaySound(name, volume)                  -- interface sounds
]]

local Env = require("./Core/Env")

local Media = {}
Media.Base = "https://raw.githubusercontent.com/ProximityDevProject/ProximityGUI/main/assets/media/"
Media.Folder = "Proximity/media"

-- name -> file extension
Media.Files = {
	ui = { default = ".mp3", experience = ".mp3", halloween = ".mp3", pride = ".mp3", wood = ".mp3", notification = ".mp3", warning = ".mp3" },
	hitsounds = {
		amongus = ".mp3", ara = ".mp3", cod = ".mp3", coin = ".mp3", csgo = ".mp3", fatality = ".mp3", gamesense = ".mp3", landing = ".mp3",
		neverlose = ".mp3", noname = ".mp3", parry = ".mp3", pop = ".ogg", rifk7 = ".mp3", rust = ".mp3", snap = ".mp3", uwu = ".mp3",
	},
	hitmarkers = {
		arrow = ".png", outline_arrow = ".png", box = ".png", outline_box = ".png", cross = ".png", outline_cross = ".png",
		diamond = ".png", outline_diamond = ".png", heart = ".png", outline_heart = ".png", plus = ".png", outline_plus = ".png",
	},
	images = {
		pointer = ".png", glow = ".png", glow4 = ".png", bglow = ".png", fov_glow = ".png", logo = ".png", main = ".png", style = ".png",
		configurations = ".png", output = ".png", playerlist = ".png", scroll = ".png", transparency = ".png", exit = ".png", body = ".png", item = ".png",
	},
}

-- sorted name lists, handy for dropdowns
Media.Lists = {}
for kind, files in Media.Files do
	local names = {}
	for name in files do
		table.insert(names, name)
	end
	table.sort(names)
	Media.Lists[kind] = names
end

local cache = {}

local function pretty(name)
	return (string.gsub(string.gsub(name, "_", " "), "^%l", string.upper))
end
Media.Pretty = pretty

-- the cached asset for a file, downloading it the first time
function Media:Get(kind: string, name: string): string?
	name = string.lower(string.gsub(tostring(name), " ", "_"))
	local ext = Media.Files[kind] and Media.Files[kind][name]
	if not ext or not Env.Caps.CustomAsset or not Env.Caps.Files then
		return nil
	end
	local key = kind .. "/" .. name
	if cache[key] ~= nil then
		return cache[key] or nil
	end
	local folder = Media.Folder .. "/" .. kind
	local path = folder .. "/" .. name .. ext
	if not Env.IsFile(path) then
		Env.MakeFolder(Media.Folder)
		Env.MakeFolder(folder)
		local body = Env.HttpGet(Media.Base .. kind .. "/" .. name .. ext)
		if not body or #body < 32 or string.find(string.sub(body, 1, 32), "404: Not Found", 1, true) then
			cache[key] = false
			return nil
		end
		Env.Write(path, body)
	end
	local asset = Env.CustomAsset(path)
	cache[key] = asset or false
	return asset
end

-- download a whole kind in the background so the first play has no delay
function Media:Preload(kind: string)
	task.spawn(function()
		for _, name in Media.Lists[kind] or {} do
			self:Get(kind, name)
			task.wait(0.05)
		end
	end)
end

-- play a sound file; options: Volume, Pitch (PlaybackSpeed), Parent
function Media:Play(kind: string, name: string, options): Sound?
	options = options or {}
	local asset = self:Get(kind, name)
	if not asset then
		return nil
	end
	local ok, sound = pcall(function()
		local s = Instance.new("Sound")
		s.SoundId = asset
		s.Volume = options.Volume or 0.5
		s.PlaybackSpeed = options.Pitch or 1
		s.Parent = options.Parent or Env.Service("SoundService")
		s.Ended:Once(function()
			s:Destroy()
		end)
		s:Play()
		task.delay(8, function()
			if s.Parent then
				s:Destroy()
			end
		end)
		return s
	end)
	return ok and sound or nil
end

return Media
