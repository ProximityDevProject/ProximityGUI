--!nocheck
--[[
	╭───────────────────────────────────────────────────────────╮
	│  Proximity UI                                             │
	│  A black & white interface library for Roblox.            │
	│  https://github.com/ProximityDevProject/ProximityGUI      │
	╰───────────────────────────────────────────────────────────╯

	local Proximity = loadstring(game:HttpGet(
	    "https://raw.githubusercontent.com/ProximityDevProject/ProximityGUI/main/dist/Proximity.luau"))()

	MIT License. Lucide icons (ISC). Ideas and parts of the asset map come
	from CompKiller (MIT), Neverlose Reloaded (MIT) and MugiHub Gen 2 (MIT).
]]

local Util = require("./Core/Util")
local Signal = require("./Core/Signal")
local Maid = require("./Core/Maid")
local Tween = require("./Core/Tween")
local Env = require("./Core/Env")
local Keys = require("./Core/Keys")
local Theme = require("./Theme")
local Icons = require("./Icons")
local Locale = require("./Locale")
local Shared = require("./Shared")
local Overlay = require("./Widgets/Overlay")

-- Re-running the script replaces the previous instance cleanly.
local shared = Env.Shared()
local previousVersion = nil
if shared.Library and shared.Library.Unload then
	previousVersion = shared.Library.Version
	pcall(shared.Library.Unload, shared.Library, true)
end

local Library = {
	Version = "1.2.7",
	VersionUrl = "https://raw.githubusercontent.com/ProximityDevProject/ProximityGUI/main/VERSION",
	ToggleStyle = "Switch",
	DensityName = "Normal",
	Flags = {},
	Elements = {},
	AllElements = {},
	Windows = {},
	Debug = false,
	Unloaded = false,
	Anonymous = false,
	_classes = {},
	_custom = {},
	_autoSaveArmed = false,
	-- signals
	FlagChanged = Signal.new(),
	KeybindsChanged = Signal.new(),
	IdentityChanged = Signal.new(),
	WindowReady = Signal.new(),
	DirtyChanged = Signal.new(),
	Unloading = Signal.new(),
	FavoritesChanged = Signal.new(),
	NotificationsChanged = Signal.new(),
	ErrorOccurred = Signal.new(),
	-- toolkit for script authors
	Util = Util,
	Signal = Signal,
	Maid = Maid,
	Tween = Tween,
	Theme = Theme,
	Icons = Icons,
	Keys = Keys,
	Env = Env,
	Locale = Locale,
}
Library.__index = Library
shared.Library = Library
Shared.Lib = Library
Shared.Maid = Maid.new()
Shared.Scale = 1

-- ═══ Screen layers ═══════════════════════════════════════════════════════
do
	local root = Util.New("ScreenGui", {
		Name = Util.Uid(),
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 9999,
	})
	Env.Protect(root)
	root.Parent = Env.GuiParent()
	local windows = Util.New("Frame", { Name = "Windows", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 10, Parent = root })
	local widgets = Util.New("Frame", { Name = "Widgets", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 20, Parent = root })
	Shared.Gui = { Root = root, Windows = windows, Widgets = widgets }
	Shared.Maid:Give(root)
	Overlay.Init(root)
	Shared.Overlay = Overlay
	Library.Gui = root
end

-- ═══ Modules ═════════════════════════════════════════════════════════════
require("./Config")(Library)

for _, module in {
	require("./Elements/Basic"),
	require("./Elements/Slider"),
	require("./Elements/Choice"),
	require("./Elements/Pickers"),
	require("./Elements/Data"),
	require("./Elements/PlayerList"),
} do
	for name, class in module do
		Library._classes[name] = class
	end
end
local Section = require("./Window/Section")
Library._classes.Section = Section
Library.Base = require("./Elements/Base")

local Window = require("./Window")
require("./Window/Dialogs")(Window)
require("./Window/Builtins")(Window)
require("./Widgets/Widgets")(Library)
require("./Widgets/Extras")(Library)
require("./Widgets/KeySystem")(Library)
Library._drawLogo = Window._drawLogo

-- ═══ Element bookkeeping ═════════════════════════════════════════════════

function Library:_setDirty(value)
	if self.Dirty ~= value then
		self.Dirty = value
		self.DirtyChanged:Fire(value)
	end
end

function Library:_onElementChanged(element, new, old)
	if element.Flag then
		self.FlagChanged:Fire(element.Flag, new, old)
		if not self.Loading and self._autoSaveArmed and element.Save ~= false then
			self:_setDirty(true)
			self:_scheduleAutoSave()
		end
	end
	if element.Type == "Toggle" and #element.Links > 0 then
		self.KeybindsChanged:Fire()
	end
end

function Library:GetFlag(flag)
	return self.Flags[flag]
end

function Library:SetFlag(flag, value)
	local el = self.Elements[flag]
	if el then
		el:Set(value)
		return true
	end
	return false
end

function Library:OnFlag(flag, fn)
	return self.FlagChanged:Connect(function(f, new, old)
		if f == flag then
			fn(new, old)
		end
	end)
end

function Library:GetElement(flag)
	return self.Elements[flag]
end

-- ═══ Undo / redo ═════════════════════════════════════════════════════════
local undoStack, redoStack = {}, {}

function Library:_pushHistory(element, old, new)
	table.insert(undoStack, { element, old, new })
	if #undoStack > 100 then
		table.remove(undoStack, 1)
	end
	table.clear(redoStack)
end

function Library:Undo()
	local step = table.remove(undoStack)
	if step and not step[1]._destroyed then
		step[1]:Set(step[2])
		table.insert(redoStack, step)
		step[1]:Highlight()
		return true
	end
	return false
end

function Library:Redo()
	local step = table.remove(redoStack)
	if step and not step[1]._destroyed then
		step[1]:Set(step[3])
		table.insert(undoStack, step)
		step[1]:Highlight()
		return true
	end
	return false
end

function Library:ClearHistory()
	table.clear(undoStack)
	table.clear(redoStack)
end

-- ═══ Favorites ═══════════════════════════════════════════════════════════
local function favKey(el)
	return el.Flag or (el:GetPath() .. "/" .. el.Name)
end

function Library:IsFavorite(el)
	local list = self:GetSetting("Favorites", {})
	return table.find(list, favKey(el)) ~= nil
end

function Library:ToggleFavorite(el)
	local list = table.clone(self:GetSetting("Favorites", {}))
	local key = favKey(el)
	local i = table.find(list, key)
	if i then
		table.remove(list, i)
	else
		table.insert(list, key)
	end
	self:SetSetting("Favorites", list)
	self.FavoritesChanged:Fire()
	return i == nil
end

function Library:GetFavorites()
	local out = {}
	local list = self:GetSetting("Favorites", {})
	for _, el in self.AllElements do
		if el.Section and not el.Parent and table.find(list, favKey(el)) then
			table.insert(out, el)
		end
	end
	return out
end

-- Window:Favorites() - a tab with shortcuts to starred features.
function Window:Favorites(options)
	options = options or {}
	local Lib = self.Library
	local tab = self:Tab({ Name = options.Name or Locale.T("Favorites"), Icon = options.Icon or "star", Order = options.Order })
	local section = tab:FullSection({ Name = Locale.T("Favorites") })
	local rows = {}
	local function refresh()
		for _, r in rows do
			r:Destroy()
		end
		rows = {}
		local favs = Lib:GetFavorites()
		if #favs == 0 then
			table.insert(rows, section:Label({ Text = Locale.T("FavoritesHint"), Color = "TextMute", Icon = "star" }))
		end
		for _, el in favs do
			table.insert(rows, section:Navigate({ Name = el.Name, Value = el:GetPath(), Callback = function()
				el:Focus()
			end }))
		end
		tab:SetBadge(#favs > 0 and #favs or nil)
	end
	Lib.FavoritesChanged:Connect(refresh)
	self:OnReady(refresh)
	return tab
end

-- ═══ Identity / anonymous mode ═══════════════════════════════════════════
local Players = Env.Service("Players")

function Library:GetIdentity()
	local player = Players.LocalPlayer
	if self.Anonymous then
		return {
			Name = "hidden",
			DisplayName = self.AnonymousName or "Hidden",
			UserId = 0,
			Avatar = nil,
			Anonymous = true,
		}
	end
	return {
		Name = player and player.Name or "Player",
		DisplayName = player and player.DisplayName or "Player",
		UserId = player and player.UserId or 0,
		Avatar = player and ("rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150") or nil,
	}
end

function Library:SetAnonymous(enabled, options)
	self.Anonymous = enabled and true or false
	if options and options.Name then
		self.AnonymousName = options.Name
	end
	self.IdentityChanged:Fire(self:GetIdentity())
	return self
end

-- ═══ Data providers (dashboard, watermark) ═══════════════════════════════
do
	local RunService = Env.Service("RunService")
	local Stats = Env.Service("Stats")
	local UIS = Env.Service("UserInputService")
	local started = os.clock()
	local frames, fps = 0, 60
	local last = os.clock()
	Shared.Maid:Connect(RunService.RenderStepped, function()
		frames += 1
		local now = os.clock()
		if now - last >= 0.5 then
			fps = math.floor(frames / (now - last) + 0.5)
			frames, last = 0, now
		end
	end)
	local function duration(seconds)
		seconds = math.floor(seconds)
		local h, m, s = seconds // 3600, (seconds % 3600) // 60, seconds % 60
		if h > 0 then
			return string.format("%dh %02dm", h, m)
		end
		return string.format("%dm %02ds", m, s)
	end
	local gameName
	Library.Providers = {
		FPS = function()
			return fps
		end,
		Ping = function()
			local ok, ping = pcall(function()
				return math.floor(Players.LocalPlayer:GetNetworkPing() * 1000 + 0.5)
			end)
			if not ok or not ping or ping == 0 then
				ok, ping = pcall(function()
					return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
				end)
			end
			return ok and (ping .. " ms") or "-"
		end,
		Session = function()
			return duration(os.clock() - started)
		end,
		Players = function()
			return #Players:GetPlayers() .. " / " .. Players.MaxPlayers
		end,
		Device = function()
			if UIS.TouchEnabled and not UIS.KeyboardEnabled then
				return "Mobile"
			elseif UIS.GamepadEnabled and not UIS.KeyboardEnabled then
				return "Console"
			end
			return "PC"
		end,
		Resolution = function()
			local v = workspace.CurrentCamera.ViewportSize
			return math.floor(v.X) .. " × " .. math.floor(v.Y)
		end,
		AccountAge = function()
			if Library.Anonymous then
				return "-"
			end
			return Players.LocalPlayer.AccountAge .. " d"
		end,
		UserId = function()
			if Library.Anonymous then
				return "hidden"
			end
			return tostring(Players.LocalPlayer.UserId)
		end,
		Executor = function()
			return Env.ExecutorName()
		end,
		PlaceId = function()
			return tostring(game.PlaceId)
		end,
		JobId = function()
			if Library.Anonymous then
				return "hidden"
			end
			return game.JobId ~= "" and string.sub(game.JobId, 1, 18) .. "…" or "studio"
		end,
		ServerUptime = function()
			return duration(workspace.DistributedGameTime)
		end,
		Memory = function()
			local ok, mb = pcall(function()
				return Stats:GetTotalMemoryUsageMb()
			end)
			return ok and (math.floor(mb) .. " MB") or (math.floor(gcinfo() / 1024) .. " MB")
		end,
		Position = function()
			if Library.Anonymous then
				return "hidden"
			end
			local root = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not root then
				return "-"
			end
			local p = root.Position
			return string.format("%d %d %d", p.X, p.Y, p.Z)
		end,
		Speed = function()
			local root = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			return root and string.format("%.1f st/s", root.AssemblyLinearVelocity.Magnitude) or "-"
		end,
		GameName = function()
			if not gameName then
				local ok, info = pcall(function()
					return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
				end)
				gameName = ok and info and info.Name or "Roblox"
			end
			return gameName
		end,
	}
end

-- ═══ Drawing helpers shared by elements ══════════════════════════════════

-- Line chart made of rotated 1-px frames (no images needed).
function Library._drawSpark(frame, data, fixedMin, fixedMax)
	if not frame or not frame.Parent then
		return
	end
	for _, c in frame:GetChildren() do
		if c.Name == "Seg" then
			c:Destroy()
		end
	end
	local n = #data
	if n < 2 then
		return
	end
	local s = Shared.Scale or 1
	local w, h = frame.AbsoluteSize.X / s, frame.AbsoluteSize.Y / s
	if w <= 0 or h <= 0 then
		task.delay(0.1, function()
			Library._drawSpark(frame, data, fixedMin, fixedMax)
		end)
		return
	end
	local min, max = fixedMin or math.huge, fixedMax or -math.huge
	if not fixedMin or not fixedMax then
		for _, v in data do
			min = fixedMin or math.min(min, v)
			max = fixedMax or math.max(max, v)
		end
	end
	if max - min < 1e-6 then
		max = min + 1
	end
	local pad = 3
	local function point(i)
		local x = (i - 1) / (n - 1) * (w - pad * 2) + pad
		local y = h - pad - (data[i] - min) / (max - min) * (h - pad * 2)
		return Vector2.new(x, y)
	end
	for i = 1, n - 1 do
		local a, b = point(i), point(i + 1)
		local d = b - a
		local seg = Util.New("Frame", {
			Name = "Seg",
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(d.Magnitude + 1, 1.5),
			Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2),
			Rotation = math.deg(math.atan2(d.Y, d.X)),
			BackgroundTransparency = 0.15 + 0.6 * (1 - i / (n - 1)),
			ZIndex = frame.ZIndex + 1,
			Parent = frame,
		})
		Theme.Paint(seg, { BackgroundColor3 = "Accent" })
	end
end

-- Puts a copy of `model` into a ViewportFrame and frames it with a camera.
function Library:_fillViewport(viewport, model)
	local ok = pcall(function()
		local archivable = model.Archivable
		model.Archivable = true
		local copy = model:Clone()
		model.Archivable = archivable
		if not copy then
			return
		end
		for _, d in copy:GetDescendants() do
			if d:IsA("Script") or d:IsA("LocalScript") then
				d:Destroy()
			end
		end
		local world = Instance.new("WorldModel")
		world.Parent = viewport
		copy.Parent = world
		local cf, size
		if copy:IsA("Model") then
			cf, size = copy:GetBoundingBox()
		else
			cf, size = copy.CFrame, copy.Size
		end
		local camera = Instance.new("Camera")
		camera.FieldOfView = 40
		local distance = size.Magnitude * 1.15
		camera.CFrame = CFrame.lookAt(cf.Position + cf.LookVector * distance + Vector3.new(0, size.Y * 0.1, 0), cf.Position)
		camera.Parent = viewport
		viewport.CurrentCamera = camera
	end)
	return ok
end

-- ═══ Public API ══════════════════════════════════════════════════════════

--[[
	local Window = Proximity:Window({
		Title = "Proximity", Subtitle = "v1.0", Logo = nil (drawn eclipse) | icon | url,
		Keybind = Enum.KeyCode.RightShift, Size = Vector2/UDim2, Scale = "Auto",
		Folder = "Proximity", Theme = "Eclipse", Accent = Color3,
		Loading = { Enabled = true, MinTime = 0.6, Skip = true, Budget = 0.004 },
		AutoReady = true, AutoLoad = true, Watermark = true, KeybindList = true,
		Profile = true, ConfigButton = true, ToggleButton = auto (touch),
		Resizable = true, Draggable = true, UnlockMouse = true, Backdrop = "Stars",
	})
]]
function Library:Window(options)
	options = options or {}
	if options.Folder then
		self:SetFolder(options.Folder)
	end
	-- persisted preferences win over script defaults
	local theme = self:GetSetting("Theme", options.Theme)
	if theme and Theme.Presets[theme] then
		Theme.Set(theme, false)
	end
	local accent = Util.FromHex(self:GetSetting("Accent", "")) or Util.ToColor(options.Accent)
	if accent then
		Theme.SetToken("Accent", accent, false)
	end
	if self:GetSetting("ReducedMotion", options.ReducedMotion == true) then
		Tween.Speed = 0
	end
	local lang = self:GetSetting("Language", options.Language)
	if lang then
		Locale.Set(lang)
	end
	self.AnonymousName = self:GetSetting("AnonymousName", "Hidden")
	if self:GetSetting("Anonymous", false) then
		self.Anonymous = true
	end
	local savedKey = self:GetSetting("MenuKey")
	if savedKey then
		options.Keybind = savedKey
	end
	-- key gate first: nothing is built until the key is accepted
	local key = options.KeySystem
	if key and key ~= false then
		local spec = type(key) == "table" and key or {}
		spec.Title = spec.Title or options.Title
		spec.Logo = spec.Logo or options.Logo
		if not self:KeySystem(spec) then
			return nil
		end
	end
	Shared.Density = self.Densities[self:GetSetting("Density", options.Density or "Normal")] or 1
	self.DensityName = self:GetSetting("Density", options.Density or "Normal")
	self.ToggleStyle = self:GetSetting("ToggleStyle", options.ToggleStyle or "Switch")
	local font = self:GetSetting("Font", options.Font)
	if font then
		task.spawn(function()
			self:SetFont(font)
		end)
	end
	local window = Window.new(self, options)
	table.insert(self.Windows, window)
	if previousVersion and previousVersion ~= self.Version then
		window:OnReady(function()
			self:Notify({ Title = "Proximity", Content = Locale.T("Replaced", previousVersion, self.Version), Type = "info", Duration = 5 })
		end)
	end
	window:SetTransparency((self:GetSetting("Glass", 0) or 0) / 100)
	if options.Watermark ~= false then
		self:Watermark(type(options.Watermark) == "table" and options.Watermark or nil)
	end
	if options.KeybindList ~= false then
		self:KeybindList()
	end
	return window
end
Library.CreateWindow = Library.Window
Library.new = function(options)
	return Library:Window(options)
end

function Library:SetTheme(name, animate)
	local ok = Theme.Set(name, animate)
	if ok and type(name) == "string" then
		self:SetSetting("Theme", name)
		local accent = Util.FromHex(self:GetSetting("Accent", ""))
		if accent then
			Theme.SetToken("Accent", accent, false)
		end
	end
	return ok
end

function Library:GetTheme()
	return Theme.Current
end

function Library:GetThemes()
	return Theme.List()
end

function Library:AddTheme(name, tokens)
	Theme.Register(name, tokens)
	return self
end
Library.RegisterTheme = Library.AddTheme

function Library:SetAccent(color)
	color = Util.ToColor(color)
	if not color then
		return self
	end
	self:SetSetting("Accent", Util.ToHex(color))
	Theme.SetToken("Accent", color)
	-- ink flips to white on dark accents so text on accent stays readable
	Theme.SetToken("AccentInk", Util.Luminance(color) > 0.5 and Color3.fromRGB(8, 8, 9) or Color3.fromRGB(250, 250, 250), false)
	return self
end

function Library:OnThemeChanged(fn)
	return Theme.Changed:Connect(fn)
end

function Library:SetLanguage(code)
	local ok = Locale.Set(code)
	if ok then
		self:SetSetting("Language", code)
	end
	return ok
end

function Library:AddLanguage(code, strings, displayName)
	Locale.Add(code, strings, displayName)
	return self
end

function Library:T(key, ...)
	return Locale.T(key, ...)
end

function Library:SetReducedMotion(on)
	Tween.Speed = on and 0 or 1
	self:SetSetting("ReducedMotion", on and true or false)
	return self
end

function Library:GetIcon(name)
	return Icons.Get(name)
end
Library._GetIcon = Library.GetIcon

function Library:RegisterIcon(name, source)
	Icons.Register(name, source)
	return self
end

--[[
	Library:RegisterElement("Rating", MyClass)  - MyClass = Library.Base.extend("Rating")
	with MyClass.new(section, options) calling Base.new(...) and :_register().
	Afterwards: Section:Rating({...}) and Section:Custom("Rating", {...}).
]]
function Library:RegisterElement(name, class)
	self._custom[name] = class
	self._classes[name] = class
	if not Section[name] then
		Section[name] = function(section, options)
			return class.new(section, options or {})
		end
		Section["Add" .. name] = Section[name]
	end
	return self
end

function Library:QuickSave(window)
	local name = self.CurrentConfig
	if not name then
		task.spawn(function()
			local w = window or self.Windows[1]
			if not w then
				return
			end
			local input = w:Prompt({ Title = Locale.T("Save"), Placeholder = Locale.T("ConfigName") })
			if input and input ~= "" then
				self:SaveConfig(input)
				self.CurrentConfig = Util.SafeName(input)
				self:_setDirty(false)
				self:Notify({ Title = Locale.T("Saved"), Content = self.CurrentConfig, Type = "success", Duration = 2.5 })
			end
		end)
		return
	end
	self:SaveConfig(name)
	self:_setDirty(false)
	self:Notify({ Title = Locale.T("Saved"), Content = name, Type = "success", Duration = 2 })
end

function Library:OnUnload(fn)
	return self.Unloading:Connect(fn)
end

-- Switches every toggle off (so feature callbacks clean up), then removes all UI.
function Library:Unload(silent)
	if self.Unloaded then
		return
	end
	if not silent and self.Dirty and self.CurrentConfig and self.Windows[1] and coroutine.isyieldable() then
		local index = self.Windows[1]:Dialog({
			Title = Locale.T("Unsaved"),
			Content = Locale.T("SaveBeforeUnload", self.CurrentConfig),
			Buttons = { { Text = Locale.T("Cancel") }, { Text = Locale.T("DontSave") }, { Text = Locale.T("Save"), Style = "Primary" } },
		})
		if index == 0 or index == 1 then
			return
		elseif index == 3 then
			self:SaveConfig(self.CurrentConfig)
		end
	end
	self.Unloading:Fire()
	for _, el in table.clone(self.AllElements) do
		if el.Type == "Toggle" and el.Value == true and el.Save ~= false then
			pcall(el.Set, el, false)
		end
	end
	for _, w in table.clone(self.Windows) do
		pcall(w.Destroy, w)
	end
	Overlay.CloseAll()
	Shared.Maid:Clean()
	self.Unloaded = true
	if shared.Library == self then
		shared.Library = nil
	end
end
Library.Destroy = Library.Unload

function Library:GetVersion()
	return self.Version
end


Util.ErrorHandler = function(message, trace)
	warn("[Proximity] callback error: " .. tostring(message) .. (Library.Debug and ("\n" .. trace) or ""))
	Library.ErrorOccurred:Fire(tostring(message), trace)
end

--[[
	Library:OnError(function(message, trace) ... end)
	Every error thrown inside your callbacks lands here (the UI keeps working).
]]
function Library:OnError(fn)
	return self.ErrorOccurred:Connect(fn)
end

-- Clear messages about wrong options instead of silent breakage.
function Library:_optionWarning(kind, name, message)
	warn(string.format("[Proximity] %s \"%s\": %s", tostring(kind), tostring(name), message))
end

-- ═══ Density, toggle style, font ═════════════════════════════════════════
Library.Densities = { Compact = 0.86, Normal = 1, Comfortable = 1.14, Touch = 1.32 }

function Library:SetDensity(name)
	local factor = self.Densities[name] or 1
	self.DensityName = self.Densities[name] and name or "Normal"
	Shared.Density = factor
	self:SetSetting("Density", self.DensityName)
	for _, el in self.AllElements do
		local frame = el.Frame
		local base = frame and frame:GetAttribute("BaseH")
		if base then
			frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, math.floor(base * factor + 0.5))
		end
	end
	for _, d in Shared.Gui.Root:GetDescendants() do
		if d:IsA("UIListLayout") and d:GetAttribute("BaseGap") then
			d.Padding = UDim.new(0, math.floor(d:GetAttribute("BaseGap") * factor * 2 + 0.5))
		end
	end
	return self
end

function Library:SetToggleStyle(name)
	self.ToggleStyle = name
	self:SetSetting("ToggleStyle", name)
	for _, el in self.AllElements do
		if el.Type == "Toggle" and not el.Style and el._mounted then
			el:_buildControl()
			el:_render(false)
		end
	end
	return self
end

function Library:SetFont(name)
	local ok = Theme.ApplyFont(name, Shared.Gui.Root)
	if ok then
		self:SetSetting("Font", name)
	end
	return ok
end

function Library:GetFonts()
	return Theme.FontList()
end

return Library
