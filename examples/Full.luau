--[[
	Proximity UI · full showcase
	Every element, the loading skeleton with your own tasks, section toggles,
	tabs inside sections, option panels, the dashboard, settings and configs.
]]

local Proximity = loadstring(game:HttpGet("https://raw.githubusercontent.com/ProximityDevProject/ProximityGUI/main/dist/Proximity.luau"))()

local Window = Proximity:Window({
	Title = "Proximity",
	Subtitle = "Showcase · v" .. Proximity.Version,
	Keybind = Enum.KeyCode.RightShift,
	Folder = "Proximity-Showcase",
	Loading = { MinTime = 1.2 },          -- the planet intro; Style = "Skeleton" for the old shell
	KeySystem = false,                    -- true or { Keys = { "demo" }, GetKey = "https://..." }
	Changelog = { Version = "1.2.0", Notes = { "Planet intro", "Player list", "Share codes" } },
})

-- Your own loading work appears in the skeleton as a stage with progress.
Window:Step("Fetching remote data", function(step)
	for i = 1, 5 do
		step:Progress(i / 5)
		task.wait(0.12)
	end
end)

Window:Home({ Status = "Premium", Welcome = "Everything below is live data." })

Window:Category("Main")

-- ─── Combat ──────────────────────────────────────────────────────────────
local Combat = Window:Tab({ Name = "Combat", Icon = "crosshair", Description = "Aim assistance and weapon behaviour" })

local Aim = Combat:Section({ Name = "Aim", Icon = "target", Toggle = true, Flag = "aim.enabled", Enabled = true })
local Silent, Lock, Rage = Aim:Tabs({ "Silent", "Lock", "Rage" }, { Flag = "aim.mode", Icons = { "eye-off", "lock", "flame" } })

Silent:Slider({ Name = "Hit chance", Min = 0, Max = 100, Default = 100, Suffix = "%", Flag = "aim.silent.chance" })
Silent:Toggle({ Name = "All pellets", Flag = "aim.silent.pellets", Default = true })
local trigger = Silent:Toggle({ Name = "Triggerbot", Flag = "aim.silent.trigger", Tooltip = "Fires when the crosshair is on a target" })
trigger:Keybind({ Default = "Ctrl+X", Mode = "Hold", Flag = "aim.silent.trigger.key" })
trigger:Options(function(o)
	o:Slider({ Name = "Delay", Min = 0, Max = 300, Default = 40, Suffix = " ms", Flag = "aim.silent.trigger.delay" })
	o:Toggle({ Name = "Only when scoped", Flag = "aim.silent.trigger.scoped" })
end)

Lock:Dropdown({ Name = "Activation", Values = { "Hold", "Toggle", "Always" }, Default = "Hold", Flag = "aim.lock.activation" })
Lock:Keybind({ Name = "Key", Default = "MB2", Flag = "aim.lock.key" })
Lock:TextSlider({ Name = "Smoothness", Labels = { "Instant", "Fast", "Medium", "Slow" }, Default = "Medium", Flag = "aim.lock.smooth" })

Rage:Toggle({ Name = "Inside FOV only", Default = true, Flag = "aim.rage.fov" })
Rage:Toggle({ Name = "Spin bot", Risky = true, Flag = "aim.rage.spin", Badge = "RISKY" })

local Targeting = Combat:Section({ Name = "Targeting", Icon = "users" })
Targeting:Slider({ Name = "FOV radius", Min = 10, Max = 500, Default = 135, Icon = "circle", Flag = "aim.fov" })
	:ColorPicker({ Default = Color3.fromRGB(255, 255, 255), Alpha = 0.3, Flag = "aim.fov.color" })
Targeting:RangeSlider({ Name = "Distance", Min = 0, Max = 1000, Default = { 10, 250 }, Suffix = " st", Flag = "aim.distance" })
Targeting:MultiDropdown({ Name = "Body parts", Values = { "Head", "Torso", "Arms", "Legs" }, Default = { "Head", "Torso" }, Flag = "aim.parts" })
Targeting:PlayerDropdown({ Name = "Whitelist", Multi = true, Flag = "aim.whitelist" })

local Weapon = Combat:Section({ Name = "Weapon", Icon = "sword", Side = "Right" })
Weapon:Toggle({ Name = "Auto reload", Default = true, Flag = "weapon.reload" })
Weapon:Slider({ Name = "Recoil", Min = 0, Max = 100, Default = 30, Suffix = "%", Presets = { Off = 0, Low = 25, Mid = 50, Full = 100 }, Flag = "weapon.recoil" })
local tuning = Combat:SubPage({ Name = "Weapon tuning", Hidden = true, Description = "Per-weapon overrides" })
Weapon:Navigate({ Name = "Weapon tuning", Value = "12 weapons", Page = tuning })
tuning:Section({ Name = "Rifles" }):Slider({ Name = "Fire rate", Min = 0.5, Max = 2, Step = 0.05, Default = 1, Suffix = "×", Flag = "weapon.rifle.rate" })
tuning:Section({ Name = "Shotguns", Side = "Right" }):Slider({ Name = "Spread", Min = 0, Max = 100, Default = 60, Suffix = "%", Flag = "weapon.shotgun.spread" })

-- ─── Visuals with sub tabs ───────────────────────────────────────────────
local Visuals = Window:Tab({ Name = "Visuals", Icon = "eye" })
local Players = Visuals:SubTab({ Name = "Players", Icon = "user" })
local World = Visuals:SubTab({ Name = "World", Icon = "globe" })

local esp = Players:Section({ Name = "ESP" })
esp:Toggle({ Name = "Boxes", Default = true, Flag = "esp.box" }):ColorPicker({ Default = Color3.new(1, 1, 1), Flag = "esp.box.color" })
esp:Toggle({ Name = "Names", Flag = "esp.name" })
esp:Toggle({ Name = "Health bar", Flag = "esp.health", Style = "Checkbox" })
local dist = esp:Slider({ Name = "Max distance", Min = 50, Max = 2000, Step = 50, Default = 800, Suffix = " st", Flag = "esp.distance" })
dist:DependsOn("esp.box")

local chams = Players:Section({ Name = "Chams", Side = "Right" })
chams:Dropdown({ Name = "Material", Values = { "Flat", "Glass", "Neon", "ForceField" }, Default = "Flat", Flag = "chams.material" })
chams:ColorPicker({ Name = "Visible", Default = Color3.fromRGB(255, 255, 255), Flag = "chams.visible" })
chams:ColorPicker({ Name = "Hidden", Default = Color3.fromRGB(120, 120, 130), Alpha = 0.5, Flag = "chams.hidden" })

local lighting = World:Section({ Name = "Lighting", Toggle = true, Flag = "world.lighting", Enabled = false })
lighting:Slider({ Name = "Brightness", Min = 0, Max = 5, Step = 0.1, Default = 2, Flag = "world.brightness" })
lighting:Slider({ Name = "Clock time", Min = 0, Max = 24, Step = 0.5, Default = 14, Format = function(v)
	return string.format("%02d:%02d", math.floor(v), (v % 1) * 60)
end, Flag = "world.clock" })

-- ─── Misc: data elements ─────────────────────────────────────────────────
Window:Category("Tools")
local Misc = Window:Tab({ Name = "Misc", Icon = "layers", Badge = "NEW" })
local data = Misc:Section({ Name = "Live data" })
data:Graph({ Name = "FPS", Source = Proximity.Providers.FPS, Interval = 0.25, Points = 50, Height = 56 })
data:Progress({ Name = "Daily quest", Value = 62 })
data:Stat({ Name = "Server uptime", Value = Proximity.Providers.ServerUptime, Interval = 1, Icon = "clock" })

local players = Misc:Section({ Name = "Players", Icon = "players", Side = "Right" })
players:PlayerList({ Height = 200 })

local servers = Misc:Section({ Name = "Servers", Side = "Right" })
servers:Table({
	Filters = {
		{ Key = "players", Name = "Players", Type = "Range" },
		{ Key = "ping", Name = "Ping", Type = "Range" },
		{ Key = "name", Name = "Map", Type = "Select", Values = { "Estonian Border", "Lighthouse", "Factory" } },
	},
	Height = 220,
	Columns = { { Key = "name", Name = "Map", Width = 0.5 }, { Key = "players", Name = "Players", Width = 0.25, Align = "Center" }, { Key = "ping", Name = "Ping", Width = 0.25, Align = "Center" } },
	Rows = {
		{ name = "Estonian Border", players = 28, ping = 41 },
		{ name = "Estonian Border", players = 24, ping = 67 },
		{ name = "Lighthouse", players = 12, ping = 88 },
		{ name = "Factory", players = 30, ping = 35 },
	},
	SortBy = "players",
	Descending = true,
	Actions = { { Icon = "log-in", Tooltip = "Join", Callback = function(row)
		Proximity:Notify({ Title = "Join", Content = row.name, Type = "info" })
	end } },
})

local utils = Misc:Section({ Name = "Utilities" })
utils:Input({ Name = "Webhook", Placeholder = "https://…", Finished = true, Flag = "misc.webhook" })
utils:ButtonGroup({
	{ Name = "Rejoin", Callback = function()
		game:GetService("TeleportService"):Teleport(game.PlaceId)
	end },
	{ Name = "Copy job id", Callback = function()
		setclipboard(game.JobId)
	end },
})
utils:Button({ Name = "Reset character", Icon = "rotate-ccw", Confirm = "Your character will respawn.", Callback = function()
	local h = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if h then
		h.Health = 0
	end
end })
local log = utils:Console({ Name = "Log", Height = 110 })
log:Info("Proximity loaded")
utils:Code({ Title = "Loader", Code = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/ProximityDevProject/ProximityGUI/main/dist/Proximity.luau"))()' })

-- ─── Built-ins ───────────────────────────────────────────────────────────
Window:Favorites()
Window:SettingsTab({
	Tour = {
		{ Target = "search", Title = "Search", Text = "Press Ctrl+K to find any feature." },
		{ Target = "config", Title = "Configs", Text = "Click the name for quick load, the disk to save." },
	},
})

-- your own HUD panel with Proximity elements inside
local hud = Proximity:Widget({ Title = "Quick", Icon = "aimbot", Width = 200 })
hud:Toggle({ Name = "Triggerbot", Icon = "triggerbot" })
hud:Slider({ Name = "FOV", Min = 10, Max = 500, Default = 135 })
hud:SetVisible(false)

Proximity:OnError(function(message)
	log:Error(message)
end)

Window:Command({ Name = "Unload", Icon = "power", Callback = function()
	Proximity:Unload()
end })

Window:OnReady(function()
	Proximity:Notify({ Title = "Proximity", Content = "Ready. Press <b>RightShift</b> to hide.", Type = "success" })
end)
