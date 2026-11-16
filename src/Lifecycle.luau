--!nocheck
--[[
	Proximity · Lifecycle
	Everything your script does can go through the library, so Unload takes
	all of it back - not only the menu.

	  Library:Connect(signal, fn)                 -> connection, disconnected on unload
	  Library:Spawn(fn, ...)                      -> thread, cancelled on unload
	  Library:Loop(fn, interval?)                 -> runs until unload (interval nil = every frame)
	  Library:Create(className, props)            -> instance, destroyed on unload
	  Library:SetProperty(instance, prop, value)  -> original value is put back on unload
	  Library:HookFunction(target, replacement)   -> original restored on unload (hookfunction)
	  Library:HookMetamethod(object, name, fn)    -> original restored on unload (hookmetamethod)
	  Library:Track(thing)                        -> any connection / instance / thread / function / {Destroy}
	  Library:OnUnload(fn)                        -> runs during unload, newest first
	  Library:Bind(flag, fn)                      -> fn(value) now and on every change; fn(false) on unload

	Also here:
	  Library:Batch(fn)                -> many :Set calls, one redraw at the end
	  Library:Use(plugin)              -> plugin(Library) or { Name, Init = fn(Library) }
	  Library:Element(name, class)     -> same as RegisterElement
	  Library:GetElement(id)           -> by flag, by Id option or by "Window/Tab/Section/Type/Name"
	  Library:Deprecated(old, new)     -> one warning per name
	  Library:ExportFlags("json" | "lua")
	  Library.Profile                  -> callback timings (Settings > Developer shows them)
]]

local Util = require("./Core/Util")
local Env = require("./Core/Env")
local Shared = require("./Shared")

local HttpService = Env.Service("HttpService")

return function(Lib)
	local tracked = {}
	local restores = {}
	local unloaders = {}

	local function cleanup(thing)
		local t = typeof(thing)
		if t == "RBXScriptConnection" then
			if thing.Connected then
				thing:Disconnect()
			end
		elseif t == "Instance" then
			thing:Destroy()
		elseif t == "thread" then
			pcall(task.cancel, thing)
		elseif t == "function" then
			Util.SafeCall(thing)
		elseif t == "table" then
			if thing.Disconnect then
				pcall(thing.Disconnect, thing)
			elseif thing.Destroy then
				pcall(thing.Destroy, thing)
			end
		end
	end

	function Lib:Track(thing)
		table.insert(tracked, thing)
		return thing
	end

	function Lib:Connect(signal, fn)
		return self:Track(signal:Connect(function(...)
			Util.SafeCall(fn, ...)
		end))
	end

	function Lib:Spawn(fn, ...)
		return self:Track(task.spawn(fn, ...))
	end

	function Lib:Loop(fn, interval)
		local alive = true
		self:Track(function()
			alive = false
		end)
		return self:Track(task.spawn(function()
			while alive do
				Util.SafeCall(fn)
				if interval then
					task.wait(interval)
				else
					game:GetService("RunService").Heartbeat:Wait()
				end
			end
		end))
	end

	function Lib:Create(className, props)
		local inst = Util.New(className, props or {})
		return self:Track(inst)
	end

	-- remembers the first original value only, so many changes still restore the real one
	function Lib:SetProperty(instance, prop, value)
		if typeof(instance) ~= "Instance" then
			return false
		end
		local key = instance
		restores[key] = restores[key] or {}
		if restores[key][prop] == nil then
			local ok, original = pcall(function()
				return instance[prop]
			end)
			if not ok then
				return false
			end
			restores[key][prop] = { original }
		end
		return pcall(function()
			instance[prop] = value
		end)
	end

	function Lib:HookFunction(target, replacement)
		local hook = (getgenv and getgenv().hookfunction) or rawget(getfenv and getfenv(0) or {}, "hookfunction")
		if not hook then
			return nil
		end
		local original = hook(target, replacement)
		self:Track(function()
			pcall(hook, target, original)
		end)
		return original
	end

	function Lib:HookMetamethod(object, name, fn)
		local hook = (getgenv and getgenv().hookmetamethod) or rawget(getfenv and getfenv(0) or {}, "hookmetamethod")
		if not hook then
			return nil
		end
		local original = hook(object, name, fn)
		self:Track(function()
			pcall(hook, object, name, original)
		end)
		return original
	end

	function Lib:OnUnload(fn)
		table.insert(unloaders, fn)
		return self
	end

	-- flag -> function: now, on every change, and switched off on unload
	function Lib:Bind(flag, fn)
		Util.SafeCall(fn, self.Flags[flag])
		local conn = self.FlagChanged:Connect(function(changed, value)
			if changed == flag then
				Util.SafeCall(fn, value)
			end
		end)
		self:Track(conn)
		self:OnUnload(function()
			Util.SafeCall(fn, false)
		end)
		return conn
	end

	-- runs during Library:Unload, after the toggles have been switched off
	Lib.Unloading:Connect(function()
		for i = #unloaders, 1, -1 do
			Util.SafeCall(unloaders[i])
		end
		for instance, props in restores do
			for prop, holder in props do
				pcall(function()
					if instance.Parent ~= nil or prop == "Parent" then
						instance[prop] = holder[1]
					end
				end)
			end
		end
		for i = #tracked, 1, -1 do
			cleanup(tracked[i])
		end
		table.clear(tracked)
		table.clear(restores)
		table.clear(unloaders)
	end)

	-- ─── batching ─────────────────────────────────────────────────────────
	function Lib:Batch(fn)
		local outer = self._batch == nil
		self._batch = self._batch or {}
		Util.SafeCall(fn)
		if outer then
			local touched = self._batch
			self._batch = nil
			for element in touched do
				if element._mounted and not element._destroyed then
					pcall(element._render, element, false)
				end
			end
		end
		return self
	end

	-- ─── plugins and custom elements ──────────────────────────────────────
	Lib.Plugins = {}
	function Lib:Use(plugin)
		if type(plugin) == "function" then
			Util.SafeCall(plugin, self)
		elseif type(plugin) == "table" then
			if plugin.Name and self.Plugins[plugin.Name] then
				return self
			end
			if plugin.Init then
				Util.SafeCall(plugin.Init, self)
			end
			if plugin.Name then
				self.Plugins[plugin.Name] = plugin
			end
			for name, class in plugin.Elements or {} do
				self:RegisterElement(name, class)
			end
			for name, tokens in plugin.Themes or {} do
				self:AddTheme(name, tokens)
			end
		elseif type(plugin) == "string" then
			-- a URL to a plugin script
			local body = Env.HttpGet(plugin)
			local chunk = body and loadstring and loadstring(body)
			if chunk then
				local ok, result = pcall(chunk)
				if ok and result then
					return self:Use(result)
				end
			end
		end
		return self
	end

	function Lib:Element(name, class)
		return self:RegisterElement(name, class)
	end

	-- ─── stable ids ───────────────────────────────────────────────────────
	function Lib:GetElement(id)
		if self.Elements[id] then
			return self.Elements[id]
		end
		for _, el in self.AllElements do
			if (el.Opts and el.Opts.Id == id) or (el._quickId and el:_quickId() == id) then
				return el
			end
		end
		return nil
	end

	-- ─── deprecation ──────────────────────────────────────────────────────
	local warned = {}
	function Lib:Deprecated(old, new)
		if warned[old] then
			return
		end
		warned[old] = true
		warn(("[Proximity] %s is deprecated%s"):format(old, new and (", use " .. new) or ""))
	end

	-- ─── export the current flags as JSON or as Lua code ─────────────────
	local function luaValue(v, indent)
		local t = typeof(v)
		if t == "string" then
			return string.format("%q", v)
		elseif t == "number" or t == "boolean" then
			return tostring(v)
		elseif t == "Color3" then
			return ("Color3.fromRGB(%d, %d, %d)"):format(v.R * 255, v.G * 255, v.B * 255)
		elseif t == "table" then
			local parts = {}
			for k, item in v do
				local key = type(k) == "number" and "" or (string.match(tostring(k), "^[%a_][%w_]*$") and (k .. " = ") or ("[" .. string.format("%q", tostring(k)) .. "] = "))
				table.insert(parts, key .. luaValue(item, (indent or "") .. "\t"))
			end
			return "{ " .. table.concat(parts, ", ") .. " }"
		end
		return "nil"
	end
	function Lib:ExportFlags(format)
		local state = self:GetState()
		if format == "lua" then
			local keys = {}
			for k in state do
				table.insert(keys, k)
			end
			table.sort(keys)
			local lines = { "-- Proximity config (" .. os.date("%Y-%m-%d") .. ")", "local flags = {" }
			for _, k in keys do
				table.insert(lines, ("\t[%q] = %s,"):format(k, luaValue(state[k])))
			end
			table.insert(lines, "}")
			table.insert(lines, "for flag, value in flags do Library.Elements[flag]:Set(value) end")
			return table.concat(lines, "\n")
		end
		local ok, json = pcall(function()
			return HttpService:JSONEncode(state)
		end)
		return ok and json or "{}"
	end

	-- ─── per-game profiles ────────────────────────────────────────────────
	function Lib:GameProfileName()
		return "game-" .. tostring(game.PlaceId)
	end
	local loadAuto = Lib.LoadAutoConfig
	function Lib:LoadAutoConfig(options)
		if self:GetSetting("GameProfiles", false) then
			local name = self:GameProfileName()
			if self:ConfigExists(name) then
				self:LoadConfig(name, options)
				return name
			end
		end
		return loadAuto(self, options)
	end

	-- ─── profiler: how long callbacks take ────────────────────────────────
	Lib.Profile = {}
	function Lib:_profile(element, seconds)
		local key = (element.Flag or element.Name or element.Type or "?")
		local p = self.Profile[key]
		if not p then
			p = { Calls = 0, Total = 0, Max = 0 }
			self.Profile[key] = p
		end
		p.Calls += 1
		p.Total += seconds
		p.Max = math.max(p.Max, seconds)
		if seconds > 0.05 and self.Debug then
			warn(("[Proximity] slow callback '%s': %.0f ms"):format(key, seconds * 1000))
		end
	end
	function Lib:GetProfile(limit)
		local list = {}
		for key, p in self.Profile do
			table.insert(list, { Name = key, Calls = p.Calls, Average = p.Total / math.max(p.Calls, 1), Max = p.Max, Total = p.Total })
		end
		table.sort(list, function(a, b)
			return a.Total > b.Total
		end)
		if limit then
			while #list > limit do
				table.remove(list)
			end
		end
		return list
	end
end
