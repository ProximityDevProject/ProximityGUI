--!nocheck
--[[
	Proximity · Theme
	Design tokens and the binder that keeps every instance in sync with them.

	Theme.Paint(frame, { BackgroundColor3 = "Surface", TextColor3 = "Text" }, 0.15)
	   → sets the colors now and remembers the binding; Theme.Set() later
	     re-paints every bound property (with a cross-fade).
]]

local Util = require("./Core/Util")
local Signal = require("./Core/Signal")
local Tween = require("./Core/Tween")

local Theme = {}

local rgb = Color3.fromRGB

-- The base never changes between presets: black. Presets tune the accent
-- (always a near-white) and the grey ramp.
local base = {
	Bg = rgb(6, 6, 7),
	Bg2 = rgb(9, 9, 10),
	Surface = rgb(12, 12, 13),
	Surface2 = rgb(17, 17, 19),
	Surface3 = rgb(23, 23, 26),
	Elevated = rgb(20, 20, 22),
	Stroke = rgb(30, 30, 34),
	StrokeHi = rgb(48, 48, 54),
	Text = rgb(240, 240, 242),
	TextDim = rgb(152, 152, 160),
	TextMute = rgb(92, 92, 100),
	Accent = rgb(255, 255, 255),
	AccentInk = rgb(8, 8, 9),
	Risky = rgb(232, 76, 84),
	Success = rgb(120, 220, 160),
	Warning = rgb(240, 196, 110),
	Error = rgb(232, 76, 84),
	Info = rgb(200, 210, 230),
	Shadow = rgb(0, 0, 0),
}

Theme.Presets = {
	Eclipse = {},
	OLED = {
		Bg = rgb(0, 0, 0),
		Bg2 = rgb(2, 2, 2),
		Surface = rgb(6, 6, 6),
		Surface2 = rgb(12, 12, 12),
		Surface3 = rgb(18, 18, 18),
		Elevated = rgb(12, 12, 12),
		Stroke = rgb(24, 24, 24),
	},
	Graphite = {
		Bg = rgb(12, 12, 14),
		Bg2 = rgb(15, 15, 17),
		Surface = rgb(18, 18, 21),
		Surface2 = rgb(24, 24, 28),
		Surface3 = rgb(31, 31, 36),
		Elevated = rgb(27, 27, 31),
		Stroke = rgb(38, 38, 44),
		StrokeHi = rgb(58, 58, 66),
		Accent = rgb(214, 214, 220),
	},
	Moon = {
		Accent = rgb(226, 236, 255),
		Text = rgb(236, 241, 250),
		TextDim = rgb(146, 154, 172),
		Stroke = rgb(28, 31, 38),
		StrokeHi = rgb(46, 52, 64),
	},
	Ash = {
		Accent = rgb(255, 244, 230),
		Text = rgb(246, 242, 236),
		TextDim = rgb(160, 154, 146),
		Stroke = rgb(34, 31, 29),
		StrokeHi = rgb(54, 50, 46),
	},
	Steel = {
		Bg = rgb(7, 8, 10),
		Surface = rgb(12, 14, 17),
		Surface2 = rgb(17, 20, 24),
		Surface3 = rgb(23, 27, 32),
		Elevated = rgb(19, 22, 26),
		Stroke = rgb(29, 34, 40),
		StrokeHi = rgb(46, 54, 64),
		Accent = rgb(205, 222, 240),
	},
}
Theme.Order = { "Eclipse", "OLED", "Graphite", "Moon", "Ash", "Steel" }

Theme.Current = "Eclipse"
Theme.Tokens = table.clone(base)
Theme.Changed = Signal.new()

-- ─── Fonts ────────────────────────────────────────────────────────────────

local SANS = "rbxasset://fonts/families/BuilderSans.json"
local MONO = "rbxasset://fonts/families/RobotoMono.json"

Theme.Fonts = {
	Regular = Font.new(SANS, Enum.FontWeight.Regular),
	Medium = Font.new(SANS, Enum.FontWeight.Medium),
	SemiBold = Font.new(SANS, Enum.FontWeight.SemiBold),
	Bold = Font.new(SANS, Enum.FontWeight.Bold),
	Heavy = Font.new(SANS, Enum.FontWeight.ExtraBold),
	Mono = Font.new(MONO, Enum.FontWeight.Regular),
	MonoBold = Font.new(MONO, Enum.FontWeight.Medium),
}

function Theme.SetFont(family: string)
	for name, font in Theme.Fonts do
		if not string.find(name, "Mono") then
			Theme.Fonts[name] = Font.new(family, font.Weight)
		end
	end
end

-- ─── Font library ─────────────────────────────────────────────────────────
-- Every family Roblox ships (read from Enum.Font, so the list is always
-- valid) plus open-licence fonts hosted with Proximity and loaded through
-- getcustomasset, including Monocraft for a Minecraft look.

Theme.FontFolder = "Proximity/Fonts"
Theme.FontBaseUrl = "https://raw.githubusercontent.com/ProximityDevProject/ProximityGUI/main/assets/fonts/"
Theme.CustomFonts = {
	["Minecraft (Monocraft)"] = { "Monocraft.ttf", "Monocraft-Bold.ttf" },
	["VT323 (terminal)"] = { "VT323-Regular.ttf" },
	["Silkscreen (pixel)"] = { "Silkscreen-Regular.ttf" },
	["Russo One"] = { "RussoOne-Regular.ttf" },
	["Space Mono"] = { "SpaceMono-Regular.ttf" },
	["Audiowide"] = { "Audiowide-Regular.ttf" },
	["Rajdhani"] = { "Rajdhani-SemiBold.ttf" },
	["Share Tech Mono"] = { "ShareTechMono-Regular.ttf" },
	["Righteous"] = { "Righteous-Regular.ttf" },
}

local builtinFamilies = nil
local function scanBuiltins()
	if builtinFamilies then
		return builtinFamilies
	end
	builtinFamilies = {}
	-- families that ship with Roblox but have no Enum.Font item
	for nice, file in { ["Press Start 2P"] = "PressStart2P", ["Builder Sans"] = "BuilderSans", ["Builder Mono"] = "BuilderMono" } do
		builtinFamilies[nice] = "rbxasset://fonts/families/" .. file .. ".json"
	end
	for _, item in Enum.Font:GetEnumItems() do
		local ok, font = pcall(Font.fromEnum, item)
		if ok and font then
			local family = font.Family
			local file = string.match(family, "families/(.-)%.json$")
			if file and not string.find(file, "Legacy") and file ~= "Unknown" then
				-- "SourceSansPro" -> "Source Sans Pro"
				local nice = string.gsub(file, "(%l)(%u)", "%1 %2")
				builtinFamilies[nice] = family
			end
		end
	end
	return builtinFamilies
end

function Theme.FontList(): { string }
	local out = {}
	for name in scanBuiltins() do
		table.insert(out, name)
	end
	for name in Theme.CustomFonts do
		table.insert(out, name)
	end
	table.sort(out)
	return out
end

local resolved = {}

-- Returns a family path usable in Font.new, downloading custom fonts once.
function Theme.ResolveFamily(name: string): string?
	if resolved[name] then
		return resolved[name]
	end
	local builtin = scanBuiltins()[name]
	if builtin then
		resolved[name] = builtin
		return builtin
	end
	local files = Theme.CustomFonts[name]
	local Env = require("./Core/Env")
	if not files or not Env.Caps.CustomAsset then
		return nil
	end
	local faces = {}
	for i, file in files do
		local path = Theme.FontFolder .. "/" .. file
		if not Env.IsFile(path) then
			local body
			for attempt = 1, 3 do
				body = Env.HttpGet(Theme.FontBaseUrl .. file)
				if body and #body > 1000 then
					break
				end
				task.wait(attempt)
			end
			if not body or #body < 1000 then
				return nil
			end
			Env.Write(path, body)
		end
		local asset = Env.CustomAsset(path)
		if not asset then
			return nil
		end
		if i == 1 then
			for _, w in { { "Regular", 400 }, { "Medium", 500 }, { "SemiBold", 600 } } do
				table.insert(faces, { name = w[1], weight = w[2], style = "normal", assetId = asset })
			end
			if not files[2] then
				table.insert(faces, { name = "Bold", weight = 700, style = "normal", assetId = asset })
				table.insert(faces, { name = "ExtraBold", weight = 800, style = "normal", assetId = asset })
			end
		else
			table.insert(faces, { name = "Bold", weight = 700, style = "normal", assetId = asset })
			table.insert(faces, { name = "ExtraBold", weight = 800, style = "normal", assetId = asset })
		end
	end
	local jsonPath = Theme.FontFolder .. "/" .. string.gsub(name, "[^%w]", "") .. ".json"
	Env.Write(jsonPath, game:GetService("HttpService"):JSONEncode({ name = name, faces = faces }))
	local family = Env.CustomAsset(jsonPath)
	resolved[name] = family
	return family
end

Theme.FontName = "Builder Sans"

-- Swaps the interface font everywhere, live. Monospace numbers stay mono.
function Theme.ApplyFont(name: string, root: Instance?): boolean
	local family = Theme.ResolveFamily(name)
	if not family then
		return false
	end
	local old = Theme.Fonts.Regular.Family
	Theme.SetFont(family)
	Theme.FontName = name
	if root then
		for _, d in root:GetDescendants() do
			if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
				local f = d.FontFace
				if f.Family == old then
					d.FontFace = Font.new(family, f.Weight, f.Style)
				end
			end
		end
	end
	return true
end

-- Text sizes (px). Mobile bumps them in Window.
Theme.Size = {
	Tiny = 10,
	Small = 11,
	Body = 13,
	Title = 14,
	Header = 16,
	Display = 22,
}

-- ─── Binding ──────────────────────────────────────────────────────────────

-- instance → { property → tokenName }   (weak so destroyed UI is collected)
local bindings = setmetatable({}, { __mode = "k" })

function Theme.Get(token: string): Color3
	return Theme.Tokens[token] or base[token] or Color3.new(1, 0, 1)
end

--[[
	Paint and remember. `map` values are token names, or Color3 for fixed
	colors (which also clears a previous binding for that property).
]]
function Theme.Paint(instance: Instance, map: { [string]: string | Color3 }, time: number?)
	local current = bindings[instance]
	if not current then
		current = {}
		bindings[instance] = current
	end
	local goal = {}
	for prop, token in map do
		if typeof(token) == "Color3" then
			current[prop] = nil
			goal[prop] = token
		else
			current[prop] = token
			goal[prop] = Theme.Get(token)
		end
	end
	if time and time > 0 then
		Tween.Play(instance, goal, time)
	else
		for prop, value in goal do
			instance[prop] = value
		end
	end
	return instance
end

function Theme.Unbind(instance: Instance)
	bindings[instance] = nil
end

local function repaint(time: number)
	for instance, map in bindings do
		if instance.Parent ~= nil then
			local goal = {}
			for prop, token in map do
				goal[prop] = Theme.Get(token)
			end
			if time > 0 then
				Tween.Play(instance, goal, time, Enum.EasingStyle.Sine)
			else
				for prop, value in goal do
					instance[prop] = value
				end
			end
		end
	end
end

--[[
	Theme.Set("Moon")
	Theme.Set({ Accent = Color3.fromRGB(255, 240, 220) })   -- partial override
	Theme.Set("OLED", false)                                  -- no cross-fade
]]
function Theme.Set(spec: string | { [string]: any }, animate: boolean?)
	local tokens = table.clone(base)
	if type(spec) == "string" then
		local preset = Theme.Presets[spec]
		if not preset then
			warn("[Proximity] unknown theme '" .. spec .. "'")
			return false
		end
		for k, v in preset do
			tokens[k] = v
		end
		Theme.Current = spec
	elseif type(spec) == "table" then
		for k, v in Theme.Tokens do
			tokens[k] = v
		end
		for k, v in spec do
			local color = Util.ToColor(v)
			if color then
				tokens[k] = color
			end
		end
		Theme.Current = spec.Name or "Custom"
	end
	Theme.Tokens = tokens
	repaint(animate == false and 0 or 0.35)
	Theme.Changed:Fire(Theme.Current, Theme.Tokens)
	return true
end

function Theme.SetToken(token: string, color: any, animate: boolean?)
	return Theme.Set({ [token] = color, Name = Theme.Current }, animate)
end

function Theme.Register(name: string, tokens: { [string]: any })
	local preset = {}
	for k, v in tokens do
		preset[k] = Util.ToColor(v)
	end
	Theme.Presets[name] = preset
	if not table.find(Theme.Order, name) then
		table.insert(Theme.Order, name)
	end
end

function Theme.Export(): string
	local out = {}
	for k, v in Theme.Tokens do
		out[k] = Util.ToHex(v)
	end
	return game:GetService("HttpService"):JSONEncode(out)
end

function Theme.Import(json: string): boolean
	local ok, data = pcall(function()
		return game:GetService("HttpService"):JSONDecode(json)
	end)
	if not ok or type(data) ~= "table" then
		return false
	end
	return Theme.Set(data)
end

function Theme.List(): { string }
	return table.clone(Theme.Order)
end

return Theme
