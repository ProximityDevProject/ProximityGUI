--!nocheck
--[[
	Proximity · Core/Env
	Everything that differs between Roblox Studio and executors lives here.
	Each capability is probed once; every call has a safe fallback, so the
	library also runs where file or clipboard APIs do not exist.
]]

local Env = {}

local function global(name: string): any
	local ok, value = pcall(function()
		local genv = getgenv and getgenv()
		if genv and genv[name] ~= nil then
			return genv[name]
		end
		return getfenv(0)[name]
	end)
	return ok and value or nil
end
Env.Global = global

local cloneref = global("cloneref") or function(x)
	return x
end
Env.cloneref = cloneref

local services = {}
function Env.Service(name: string): Instance
	local svc = services[name]
	if not svc then
		svc = cloneref(game:GetService(name))
		services[name] = svc
	end
	return svc
end

local fs = {
	write = global("writefile"),
	read = global("readfile"),
	isfile = global("isfile"),
	isfolder = global("isfolder"),
	makefolder = global("makefolder"),
	list = global("listfiles"),
	delete = global("delfile"),
}

Env.Caps = {
	Files = fs.write ~= nil and fs.read ~= nil and fs.isfile ~= nil and fs.makefolder ~= nil,
	ListFiles = fs.list ~= nil,
	Clipboard = global("setclipboard") ~= nil or global("toclipboard") ~= nil,
	CustomAsset = global("getcustomasset") ~= nil or global("getsynasset") ~= nil,
	Request = global("request") ~= nil or global("http_request") ~= nil,
	Hwid = global("gethwid") ~= nil,
	HiddenUi = global("gethui") ~= nil,
	Executor = global("identifyexecutor") ~= nil,
	Studio = (function()
		local ok, studio = pcall(function()
			return game:GetService("RunService"):IsStudio()
		end)
		return ok and studio or false
	end)(),
}

function Env.ExecutorName(): string
	local identify = global("identifyexecutor") or global("getexecutorname")
	if identify then
		local ok, name, version = pcall(identify)
		if ok and name then
			return version and (tostring(name) .. " " .. tostring(version)) or tostring(name)
		end
	end
	return Env.Caps.Studio and "Studio" or "Unknown"
end

-- ─── GUI parenting ────────────────────────────────────────────────────────

function Env.GuiParent(): Instance
	local gethui = global("gethui")
	if gethui then
		local ok, hui = pcall(gethui)
		if ok and hui then
			return hui
		end
	end
	local ok = pcall(function()
		local probe = Instance.new("Folder")
		probe.Parent = Env.Service("CoreGui")
		probe:Destroy()
	end)
	if ok then
		return Env.Service("CoreGui")
	end
	local players = Env.Service("Players")
	local player = players.LocalPlayer or players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	return player:WaitForChild("PlayerGui")
end

function Env.Protect(gui: Instance)
	pcall(function()
		local syn = global("syn")
		if syn and syn.protect_gui then
			syn.protect_gui(gui)
		elseif global("protectgui") then
			global("protectgui")(gui)
		end
	end)
end

-- ─── Files (with in-memory fallback) ─────────────────────────────────────

local memory = {}
Env.Memory = memory

local function norm(path: string): string
	return (string.gsub(path, "\\", "/"))
end

function Env.IsFile(path: string): boolean
	path = norm(path)
	if Env.Caps.Files then
		local ok, result = pcall(fs.isfile, path)
		return ok and result == true
	end
	return memory[path] ~= nil
end

function Env.IsFolder(path: string): boolean
	path = norm(path)
	if Env.Caps.Files and fs.isfolder then
		local ok, result = pcall(fs.isfolder, path)
		return ok and result == true
	end
	return true
end

function Env.MakeFolder(path: string)
	path = norm(path)
	if not Env.Caps.Files then
		return
	end
	local current = ""
	for part in string.gmatch(path, "[^/]+") do
		current = current == "" and part or (current .. "/" .. part)
		if not Env.IsFolder(current) then
			pcall(fs.makefolder, current)
		end
	end
end

function Env.Write(path: string, data: string): boolean
	path = norm(path)
	if Env.Caps.Files then
		local folder = string.match(path, "^(.*)/[^/]+$")
		if folder then
			Env.MakeFolder(folder)
		end
		return (pcall(fs.write, path, data))
	end
	memory[path] = data
	return true
end

function Env.Read(path: string): string?
	path = norm(path)
	if Env.Caps.Files then
		if not Env.IsFile(path) then
			return nil
		end
		local ok, data = pcall(fs.read, path)
		return ok and data or nil
	end
	return memory[path]
end

function Env.Delete(path: string): boolean
	path = norm(path)
	if Env.Caps.Files and fs.delete then
		return (pcall(fs.delete, path))
	end
	memory[path] = nil
	return true
end

-- Returns file names (not paths) inside folder, sorted.
function Env.List(folder: string): { string }
	folder = norm(folder)
	local out = {}
	if Env.Caps.Files and fs.list then
		local ok, items = pcall(fs.list, folder)
		if ok and type(items) == "table" then
			for _, item in items do
				local name = string.match(norm(item), "([^/]+)$")
				if name then
					table.insert(out, name)
				end
			end
		end
	else
		for path in memory do
			local dir, name = string.match(path, "^(.*)/([^/]+)$")
			if dir == folder then
				table.insert(out, name)
			end
		end
	end
	table.sort(out)
	return out
end

-- ─── Misc ─────────────────────────────────────────────────────────────────

function Env.Clipboard(text: string): boolean
	local set = global("setclipboard") or global("toclipboard")
	if set then
		return (pcall(set, tostring(text)))
	end
	return false
end

function Env.HttpGet(url: string): string?
	local ok, body = pcall(function()
		return game:HttpGet(url)
	end)
	if ok and type(body) == "string" then
		return body
	end
	local req = global("request") or global("http_request")
	if req then
		local ok2, response = pcall(req, { Url = url, Method = "GET" })
		if ok2 and response and response.Body then
			return response.Body
		end
	end
	return nil
end

function Env.CustomAsset(path: string): string?
	local get = global("getcustomasset") or global("getsynasset")
	if not get then
		return nil
	end
	local ok, asset = pcall(get, path)
	return ok and asset or nil
end

function Env.Hwid(): string
	local get = global("gethwid")
	if get then
		local ok, id = pcall(get)
		if ok and id then
			return tostring(id)
		end
	end
	local ok, id = pcall(function()
		return game:GetService("RbxAnalyticsService"):GetClientId()
	end)
	return ok and tostring(id) or "unknown"
end

-- Shared table that survives re-execution: lets a new load unload the old one.
function Env.Shared(): { [string]: any }
	local genv = global("getgenv")
	local root = genv and genv() or _G
	root.__ProximityUI = root.__ProximityUI or {}
	return root.__ProximityUI
end

return Env
