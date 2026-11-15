--!nocheck
--[[
	Proximity · Config
	Flags → JSON files, export strings, auto save, auto load, diffs and
	schema migrations. Installed onto the Library table by init.luau.

	Files (inside Library.Folder, "Proximity" by default):
	  configs/<name>.json   one config
	  settings.json         auto load / auto save pointers + UI preferences
]]

local HttpService = game:GetService("HttpService")

local Util = require("./Core/Util")
local Env = require("./Core/Env")
local Signal = require("./Core/Signal")
local Locale = require("./Locale")

return function(Lib)
	Lib.Folder = "Proximity"
	Lib.SchemaVersion = 1
	Lib.Migrations = {}
	Lib.ConfigsChanged = Signal.new()
	Lib.ConfigLoaded = Signal.new()
	Lib.ConfigSaved = Signal.new()
	Lib.Loading = false

	local settingsCache = nil

	local function configDir()
		return Lib.Folder .. "/configs"
	end

	local function configPath(name: string)
		return configDir() .. "/" .. Util.SafeName(name) .. ".json"
	end

	local function encode(t)
		return HttpService:JSONEncode(t)
	end

	-- Config files are stored scrambled with a checksum ("PRXC1.") so a
	-- hand-edited file is detected instead of silently loading garbage.
	-- Plain JSON files from older versions still load.
	Lib.EncryptConfigs = true
	local SECRET = "proximity-planet"

	local function xor(data)
		local out = table.create(#data)
		local n = #SECRET
		for i = 1, #data do
			out[i] = string.char(bit32.bxor(string.byte(data, i), string.byte(SECRET, (i - 1) % n + 1)))
		end
		return table.concat(out)
	end

	local function protect(json)
		if not Lib.EncryptConfigs then
			return json
		end
		local body = Util.Base64Encode(xor(json))
		return "PRXC1." .. body .. "." .. Util.Checksum(body)
	end

	local function unprotect(raw)
		local body, sum = string.match(raw, "^PRXC1%.([%w%+/=]+)%.(%x+)%s*$")
		if not body then
			return raw
		end
		if Util.Checksum(body) ~= sum then
			return nil
		end
		return xor(Util.Base64Decode(body))
	end

	local function decode(s)
		if type(s) ~= "string" then
			return nil
		end
		s = unprotect(s)
		if not s then
			return nil
		end
		local ok, result = pcall(HttpService.JSONDecode, HttpService, s)
		if ok and type(result) == "table" then
			return result
		end
		return nil
	end

	-- ─── Settings (small persistent key/value store) ─────────────────────

	local function loadSettings()
		if settingsCache then
			return settingsCache
		end
		local raw = Env.Read(Lib.Folder .. "/settings.json")
		settingsCache = raw and decode(raw) or {}
		return settingsCache
	end

	local flushSettings = Util.Debounce(0.6, function()
		if settingsCache then
			Env.Write(Lib.Folder .. "/settings.json", encode(settingsCache))
		end
	end)

	function Lib:GetSetting(key: string, default: any?): any
		local value = loadSettings()[key]
		if value == nil then
			return default
		end
		return value
	end

	function Lib:SetSetting(key: string, value: any)
		loadSettings()[key] = value
		flushSettings()
	end

	function Lib:SetFolder(folder: string)
		Lib.Folder = Util.SafeName(folder)
		settingsCache = nil
		Env.MakeFolder(configDir())
	end

	-- ─── State ────────────────────────────────────────────────────────────

	-- Snapshot of every flagged element as JSON-safe values.
	function Lib:GetState(): { [string]: any }
		local state = {}
		for flag, element in Lib.Elements do
			if element.Save ~= false then
				local ok, value = pcall(element._serialize, element)
				if ok and value ~= nil then
					state[flag] = value
				end
			end
		end
		return state
	end

	--[[
		Applies a state table. Values are validated by each element, a broken
		value is skipped instead of failing the whole load. Large configs are
		spread over frames (2 ms budget) so the game never hitches.
	]]
	function Lib:ApplyState(state: { [string]: any }, options: { Silent: boolean?, Budget: number?, OnProgress: ((number, number) -> ())? }?)
		options = options or {}
		local budget = options.Budget or 0.002
		local items = {}
		for flag, value in state do
			local element = Lib.Elements[flag]
			if element and element.Save ~= false then
				table.insert(items, { element, value })
			end
		end
		Lib.Loading = true
		local applied, start = 0, os.clock()
		for i, item in items do
			local ok = pcall(item[1]._deserialize, item[1], item[2], options.Silent)
			if ok then
				applied += 1
			end
			if options.OnProgress then
				options.OnProgress(i, #items)
			end
			if budget > 0 and os.clock() - start > budget then
				task.wait()
				start = os.clock()
			end
		end
		Lib.Loading = false
		return applied, #items
	end

	-- ─── Files ────────────────────────────────────────────────────────────

	function Lib:SaveConfig(name: string, meta: { [string]: any }?): (boolean, string?)
		name = Util.SafeName(name or "")
		if name == "" then
			return false, "invalid name"
		end
		local path = configPath(name)
		local previous = Env.Read(path)
		local created = os.time()
		if previous then
			local old = decode(previous)
			if old and old.Created then
				created = old.Created
			end
		end
		local data = {
			Proximity = Lib.Version,
			Schema = Lib.SchemaVersion,
			Name = name,
			Created = created,
			Updated = os.time(),
			PlaceId = game.PlaceId,
			Author = meta and meta.Author or nil,
			Note = meta and meta.Note or nil,
			Flags = Lib:GetState(),
		}
		if previous then
			-- keep one backup of what we are about to overwrite
			Env.Write(path .. ".bak", previous)
		end
		local ok = Env.Write(path, protect(encode(data)))
		if ok then
			Lib.ConfigSaved:Fire(name)
			Lib.ConfigsChanged:Fire()
		end
		return ok, ok and name or "write failed"
	end

	local function migrate(data)
		local schema = tonumber(data.Schema) or 1
		while schema < Lib.SchemaVersion do
			local step = Lib.Migrations[schema]
			if step then
				local ok, result = pcall(step, data.Flags or {})
				if ok and type(result) == "table" then
					data.Flags = result
				end
			end
			schema += 1
		end
		return data
	end

	function Lib:ReadConfig(name: string): { [string]: any }?
		local raw = Env.Read(configPath(name))
		if not raw then
			return nil
		end
		local data = decode(raw)
		if not data then
			-- keep the broken file for the user instead of silently losing it
			Env.Write(configPath(name) .. ".broken", raw)
			return nil
		end
		return migrate(data)
	end

	function Lib:LoadConfig(name: string, options: { [string]: any }?): (boolean, string?)
		local data = Lib:ReadConfig(name)
		if not data then
			return false, "config not found or broken"
		end
		local applied, total = Lib:ApplyState(data.Flags or {}, options)
		Lib.ConfigLoaded:Fire(name, applied, total)
		return true, string.format("%d/%d", applied, total)
	end

	-- Restores the version saved before the last overwrite.
	function Lib:RestoreBackup(name: string): boolean
		local raw = Env.Read(configPath(name) .. ".bak")
		if not raw then
			return false
		end
		Env.Write(configPath(name), raw)
		Lib.ConfigsChanged:Fire()
		return true
	end

	function Lib:DeleteConfig(name: string, quiet: boolean?): boolean
		local raw = Env.Read(configPath(name))
		local ok = Env.Delete(configPath(name))
		if ok and raw and not quiet and Lib.Notify then
			-- soft delete: five seconds to bring it back
			Lib:Notify({ Title = Locale.T("Deleted"), Content = Locale.T("DeletedHint", name), Type = "info", Duration = 5, Actions = { { Text = Locale.T("Restore"), Callback = function()
				Env.Write(configPath(name), raw)
				Lib.ConfigsChanged:Fire()
			end } } })
		end
		if ok then
			if Lib:GetAutoLoad() == Util.SafeName(name) then
				Lib:SetAutoLoad(nil)
			end
			Lib.ConfigsChanged:Fire()
		end
		return ok
	end

	function Lib:ListConfigs(): { string }
		local out = {}
		for _, file in Env.List(configDir()) do
			local name = string.match(file, "^(.+)%.json$")
			if name then
				table.insert(out, name)
			end
		end
		return out
	end

	function Lib:ConfigExists(name: string): boolean
		return Env.IsFile(configPath(name))
	end

	function Lib:GetConfigInfo(name: string): { [string]: any }?
		local data = Lib:ReadConfig(name)
		if not data then
			return nil
		end
		return {
			Name = data.Name or name,
			Created = data.Created,
			Updated = data.Updated,
			Author = data.Author,
			Note = data.Note,
			Version = data.Proximity,
			Schema = data.Schema,
			Count = Util.Count(data.Flags or {}),
		}
	end

	function Lib:RenameConfig(from: string, to: string): boolean
		local raw = Env.Read(configPath(from))
		if not raw then
			return false
		end
		local ok = Env.Write(configPath(to), raw)
		if ok then
			Env.Delete(configPath(from))
			if Lib:GetAutoLoad() == Util.SafeName(from) then
				Lib:SetAutoLoad(to)
			end
			Lib.ConfigsChanged:Fire()
		end
		return ok
	end

	function Lib:DuplicateConfig(from: string, to: string): boolean
		local raw = Env.Read(configPath(from))
		if not raw then
			return false
		end
		local ok = Env.Write(configPath(to), raw)
		Lib.ConfigsChanged:Fire()
		return ok
	end

	-- What would change if `name` were loaded now.
	function Lib:DiffConfig(name: string): { { Flag: string, From: any, To: any } }
		local data = Lib:ReadConfig(name)
		local out = {}
		if not data then
			return out
		end
		local current = Lib:GetState()
		for flag, value in data.Flags or {} do
			if Lib.Elements[flag] and not Util.Equal(current[flag], value) then
				table.insert(out, { Flag = flag, From = current[flag], To = value })
			end
		end
		table.sort(out, function(a, b)
			return a.Flag < b.Flag
		end)
		return out
	end

	-- ─── Export / import strings ─────────────────────────────────────────
	-- Format: PRX1.<base64 json>.<checksum>

	function Lib:ExportConfig(name: string?): string?
		local flags
		if name then
			local data = Lib:ReadConfig(name)
			if not data then
				return nil
			end
			flags = data.Flags
		else
			flags = Lib:GetState()
		end
		local body = Util.Base64Encode(encode({ Schema = Lib.SchemaVersion, Flags = flags }))
		return "PRX1." .. body .. "." .. Util.Checksum(body)
	end

	function Lib:ImportConfig(text: string, saveAs: string?): (boolean, string?)
		text = Util.Trim(tostring(text or ""))
		local body, sum = string.match(text, "^PRX1%.([%w%+/=]+)%.(%x+)$")
		if not body then
			return false, "format"
		end
		if Util.Checksum(body) ~= sum then
			return false, "checksum"
		end
		local data = decode(Util.Base64Decode(body))
		if not data or type(data.Flags) ~= "table" then
			return false, "decode"
		end
		data = migrate(data)
		if saveAs then
			local ok = Env.Write(configPath(saveAs), encode({
				Proximity = Lib.Version,
				Schema = Lib.SchemaVersion,
				Name = Util.SafeName(saveAs),
				Created = os.time(),
				Updated = os.time(),
				Flags = data.Flags,
			}))
			Lib.ConfigsChanged:Fire()
			return ok, saveAs
		end
		Lib:ApplyState(data.Flags)
		return true
	end

	-- ─── Short share codes ───────────────────────────────────────────────
	-- The export string goes to a paste service and the friend only needs
	-- the short id. Needs the executor's `request` function.
	Lib.ShareService = {
		Upload = function(text)
			local req = Env.Global("request") or Env.Global("http_request")
			if not req then
				return nil
			end
			local ok, res = pcall(req, { Url = "https://paste.rs/", Method = "POST", Body = text, Headers = { ["Content-Type"] = "text/plain" } })
			if ok and res and (res.StatusCode == 201 or res.StatusCode == 206 or res.StatusCode == 200) and res.Body then
				return string.match(res.Body, "paste%.rs/([%w]+)")
			end
			return nil
		end,
		Download = function(code)
			return Env.HttpGet("https://paste.rs/" .. code)
		end,
	}

	function Lib:ShareConfig(name: string?): (string?, string?)
		local text = Lib:ExportConfig(name)
		if not text then
			return nil, "export"
		end
		local code = Lib.ShareService.Upload(text)
		if not code then
			return nil, "upload"
		end
		return code
	end

	function Lib:ImportCode(code: string, saveAs: string?): (boolean, string?)
		code = Util.Trim(tostring(code or ""))
		code = string.match(code, "([%w]+)$") or code
		if code == "" then
			return false, "empty"
		end
		local text = Lib.ShareService.Download(code)
		if not text then
			return false, "download"
		end
		return Lib:ImportConfig(text, saveAs)
	end

	-- ─── Auto load / auto save ───────────────────────────────────────────

	function Lib:SetAutoLoad(name: string?)
		Lib:SetSetting("AutoLoad", name and Util.SafeName(name) or false)
	end

	function Lib:GetAutoLoad(): string?
		local name = Lib:GetSetting("AutoLoad")
		return type(name) == "string" and name or nil
	end

	function Lib:SetAutoSave(name: string?)
		Lib:SetSetting("AutoSave", name and Util.SafeName(name) or false)
	end

	function Lib:GetAutoSave(): string?
		local name = Lib:GetSetting("AutoSave")
		return type(name) == "string" and name or nil
	end

	local autoSave = Util.Debounce(1.5, function()
		local name = Lib:GetAutoSave()
		if name and not Lib.Unloaded then
			Lib:SaveConfig(name)
		end
	end)

	-- Called by elements after every value change.
	function Lib:_scheduleAutoSave()
		if Lib.Loading or not Lib._autoSaveArmed then
			return
		end
		if Lib:GetAutoSave() then
			autoSave()
		end
	end

	-- Loads the auto-load config if one is set. Returns the name or nil.
	function Lib:LoadAutoConfig(options: { [string]: any }?): string?
		local name = Lib:GetAutoLoad()
		if name and Lib:ConfigExists(name) then
			Lib:LoadConfig(name, options)
			return name
		end
		return nil
	end
end
