--!nocheck
--[[
	Proximity · Core/Util
	Small, dependency-free helpers shared by every module.
]]

local HttpService = game:GetService("HttpService")

local Util = {}

-- ─── Instances ────────────────────────────────────────────────────────────

--[[
	Util.New("Frame", { Size = ..., Parent = ... }, { child1, child2 })
	Parent is assigned last so the instance is fully configured before it
	enters the DataModel (one layout pass instead of many).
]]
function Util.New(class: string, props: { [string]: any }?, children: { Instance }?): Instance
	local inst = Instance.new(class)
	local parent
	if props then
		for key, value in props do
			if key == "Parent" then
				parent = value
			else
				inst[key] = value
			end
		end
	end
	if children then
		for _, child in children do
			child.Parent = inst
		end
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

function Util.Corner(radius: number, parent: Instance?)
	return Util.New("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent })
end

function Util.Round(parent: Instance?)
	return Util.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = parent })
end

function Util.Stroke(parent: Instance?, color: Color3?, thickness: number?, transparency: number?)
	return Util.New("UIStroke", {
		Color = color or Color3.new(1, 1, 1),
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

function Util.Padding(parent: Instance?, top: number, right: number?, bottom: number?, left: number?)
	right = right or top
	bottom = bottom or top
	left = left or right
	return Util.New("UIPadding", {
		PaddingTop = UDim.new(0, top),
		PaddingRight = UDim.new(0, right),
		PaddingBottom = UDim.new(0, bottom),
		PaddingLeft = UDim.new(0, left),
		Parent = parent,
	})
end

function Util.List(parent: Instance?, padding: number?, direction: Enum.FillDirection?, halign: Enum.HorizontalAlignment?, valign: Enum.VerticalAlignment?)
	return Util.New("UIListLayout", {
		Padding = UDim.new(0, padding or 0),
		FillDirection = direction or Enum.FillDirection.Vertical,
		HorizontalAlignment = halign or Enum.HorizontalAlignment.Left,
		VerticalAlignment = valign or Enum.VerticalAlignment.Top,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = parent,
	})
end

function Util.Gradient(parent: Instance?, color: ColorSequence?, transparency: NumberSequence?, rotation: number?)
	return Util.New("UIGradient", {
		Color = color or ColorSequence.new(Color3.new(1, 1, 1)),
		Transparency = transparency or NumberSequence.new(0),
		Rotation = rotation or 0,
		Parent = parent,
	})
end

function Util.Label(props: { [string]: any }): TextLabel
	local base = {
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		RichText = false,
		TextSize = 13,
		Size = UDim2.new(1, 0, 0, 16),
		BorderSizePixel = 0,
	}
	for k, v in props do
		base[k] = v
	end
	return Util.New("TextLabel", base)
end

-- Invisible full-size click catcher.
function Util.Hitbox(parent: Instance, zindex: number?): TextButton
	return Util.New("TextButton", {
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.fromScale(1, 1),
		ZIndex = zindex or 1,
		AutoButtonColor = false,
		Parent = parent,
	})
end

-- ─── Tables ───────────────────────────────────────────────────────────────

function Util.Merge(defaults: { [any]: any }, overrides: { [any]: any }?): { [any]: any }
	local out = table.clone(defaults)
	if overrides then
		for k, v in overrides do
			out[k] = v
		end
	end
	return out
end

function Util.DeepCopy(value: any): any
	if type(value) ~= "table" then
		return value
	end
	local out = {}
	for k, v in value do
		out[Util.DeepCopy(k)] = Util.DeepCopy(v)
	end
	return out
end

function Util.Equal(a: any, b: any): boolean
	if a == b then
		return true
	end
	if type(a) ~= "table" or type(b) ~= "table" then
		return false
	end
	for k, v in a do
		if not Util.Equal(v, b[k]) then
			return false
		end
	end
	for k in b do
		if a[k] == nil then
			return false
		end
	end
	return true
end

function Util.Count(t: { [any]: any }): number
	local n = 0
	for _ in t do
		n += 1
	end
	return n
end

function Util.Find(list: { any }, value: any): number?
	return table.find(list, value)
end

function Util.Keys(t: { [any]: any }): { any }
	local out = {}
	for k in t do
		table.insert(out, k)
	end
	return out
end

-- Pick the first non-nil option among aliases: Util.Opt(opts, "Default", "Value").
function Util.Opt(opts: { [string]: any }, ...: string): any
	for i = 1, select("#", ...) do
		local v = opts[select(i, ...)]
		if v ~= nil then
			return v
		end
	end
	return nil
end

-- ─── Math ─────────────────────────────────────────────────────────────────

function Util.Clamp(n: number, min: number, max: number): number
	if min > max then
		min, max = max, min
	end
	return math.clamp(n, min, max)
end

function Util.Snap(n: number, step: number?, origin: number?): number
	if not step or step <= 0 then
		return n
	end
	origin = origin or 0
	local snapped = math.floor((n - origin) / step + 0.5) * step + origin
	-- kill floating point dust (0.30000000004)
	local decimals = Util.Decimals(step)
	return tonumber(string.format("%." .. decimals .. "f", snapped))
end

function Util.Decimals(step: number): number
	local s = tostring(step)
	local dot = string.find(s, "%.")
	if not dot then
		return 0
	end
	return math.min(#s - dot, 6)
end

function Util.Lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

function Util.FormatNumber(n: number, decimals: number?): string
	decimals = decimals or 0
	local s = string.format("%." .. decimals .. "f", n)
	if decimals > 0 then
		s = string.gsub(s, "%.?0+$", "")
	end
	if s == "-0" then
		s = "0"
	end
	return s
end

function Util.Abbreviate(n: number): string
	local abs = math.abs(n)
	if abs >= 1e9 then
		return Util.FormatNumber(n / 1e9, 1) .. "B"
	elseif abs >= 1e6 then
		return Util.FormatNumber(n / 1e6, 1) .. "M"
	elseif abs >= 1e3 then
		return Util.FormatNumber(n / 1e3, 1) .. "K"
	end
	return Util.FormatNumber(n, 0)
end

-- ─── Colors ───────────────────────────────────────────────────────────────

function Util.ToHex(color: Color3): string
	return string.format("#%02X%02X%02X", math.round(color.R * 255), math.round(color.G * 255), math.round(color.B * 255))
end

function Util.FromHex(hex: string): Color3?
	hex = string.gsub(tostring(hex), "[#%s]", "")
	if #hex == 3 then
		hex = string.gsub(hex, ".", "%0%0")
	end
	if #hex ~= 6 or string.find(hex, "[^%x]") then
		return nil
	end
	return Color3.fromRGB(tonumber(string.sub(hex, 1, 2), 16), tonumber(string.sub(hex, 3, 4), 16), tonumber(string.sub(hex, 5, 6), 16))
end

-- Accepts Color3, "#hex", {r,g,b} (0-255) or {R=,G=,B=}.
function Util.ToColor(value: any): Color3?
	local t = typeof(value)
	if t == "Color3" then
		return value
	elseif t == "string" then
		return Util.FromHex(value)
	elseif t == "table" then
		local r, g, b = value[1] or value.R or value.r, value[2] or value.G or value.g, value[3] or value.B or value.b
		if r and g and b then
			return Color3.fromRGB(r, g, b)
		end
	end
	return nil
end

function Util.Luminance(c: Color3): number
	return 0.2126 * c.R + 0.7152 * c.G + 0.0722 * c.B
end

function Util.Mix(a: Color3, b: Color3, t: number): Color3
	return a:Lerp(b, t)
end

-- ─── Strings ──────────────────────────────────────────────────────────────

function Util.Trim(s: string): string
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function Util.Truncate(s: string, max: number): string
	if utf8.len(s) and utf8.len(s) > max then
		return string.sub(s, 1, utf8.offset(s, max) - 1) .. "…"
	end
	return s
end

function Util.Escape(s: string): string
	return (string.gsub(s, "[<>&\"']", {
		["<"] = "&lt;",
		[">"] = "&gt;",
		["&"] = "&amp;",
		['"'] = "&quot;",
		["'"] = "&apos;",
	}))
end

function Util.SafeName(s: string): string
	s = Util.Trim(tostring(s))
	s = string.gsub(s, "%.%.", "_")
	s = string.gsub(s, "[^%w%s%-%_%.]", "_")
	return string.sub(s, 1, 64)
end

--[[
	Fuzzy score: every query char must appear in order. Consecutive matches,
	word starts and prefix matches score higher. Returns nil when no match.
]]
local function fuzzyCore(query: string, text: string): number?
	query = string.lower(query)
	text = string.lower(text)
	if query == "" then
		return 0
	end
	local direct = string.find(text, query, 1, true)
	if direct then
		return 1000 - direct * 2 - #text * 0.1
	end
	local score, ti, streak, skipped = 0, 1, 0, 0
	for qi = 1, #query do
		local ch = string.sub(query, qi, qi)
		local found = string.find(text, ch, ti, true)
		if not found then
			return nil
		end
		if qi > 1 then
			skipped += found - ti
		end
		if found == ti then
			streak += 1
			score += 5 * streak
		else
			streak = 0
		end
		local prev = string.sub(text, found - 1, found - 1)
		if found == 1 or prev == " " or prev == "-" or prev == "_" or prev == "." then
			score += 8
		end
		ti = found + 1
	end
	-- letters scattered across the whole text are not a match
	if skipped > #query * 3 then
		return nil
	end
	return score - skipped * 2 - #text * 0.1
end

-- keyboard layout swap: "ghbdtn" <-> "привет"
local EN = "qwertyuiop[]asdfghjkl;'zxcvbnm,."
local RU = { "й", "ц", "у", "к", "е", "н", "г", "ш", "щ", "з", "х", "ъ", "ф", "ы", "в", "а", "п", "р", "о", "л", "д", "ж", "э", "я", "ч", "с", "м", "и", "т", "ь", "б", "ю" }
local enToRu, ruToEn = {}, {}
for i = 1, #EN do
	enToRu[string.sub(EN, i, i)] = RU[i]
	ruToEn[RU[i]] = string.sub(EN, i, i)
end
local upperRu = { ["Й"] = "й", ["Ц"] = "ц", ["У"] = "у", ["К"] = "к", ["Е"] = "е", ["Н"] = "н", ["Г"] = "г", ["Ш"] = "ш", ["Щ"] = "щ", ["З"] = "з", ["Х"] = "х", ["Ъ"] = "ъ", ["Ф"] = "ф", ["Ы"] = "ы", ["В"] = "в", ["А"] = "а", ["П"] = "п", ["Р"] = "р", ["О"] = "о", ["Л"] = "л", ["Д"] = "д", ["Ж"] = "ж", ["Э"] = "э", ["Я"] = "я", ["Ч"] = "ч", ["С"] = "с", ["М"] = "м", ["И"] = "и", ["Т"] = "т", ["Ь"] = "ь", ["Б"] = "б", ["Ю"] = "ю", ["Ё"] = "е", ["ё"] = "е" }

-- lower case that also knows Cyrillic
function Util.Lower(text: string): string
	text = string.lower(text)
	return (string.gsub(text, utf8.charpattern, function(ch)
		return upperRu[ch] or ch
	end))
end

function Util.SwapLayout(text: string): string
	local out, changed = {}, false
	for _, code in utf8.codes(text) do
		local ch = utf8.char(code)
		local swapped = enToRu[ch] or ruToEn[ch]
		if swapped then
			changed = true
		end
		table.insert(out, swapped or ch)
	end
	return changed and table.concat(out) or text
end

local function chars(text)
	local list = {}
	for _, code in utf8.codes(text) do
		table.insert(list, code)
	end
	return list
end

-- edit distance with an early exit once it goes over the limit
local function distance(a, b, limit)
	local n, m = #a, #b
	if math.abs(n - m) > limit then
		return limit + 1
	end
	local prev = {}
	for j = 0, m do
		prev[j] = j
	end
	for i = 1, n do
		local cur, best = { [0] = i }, i
		for j = 1, m do
			cur[j] = math.min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (a[i] == b[j] and 0 or 1))
			best = math.min(best, cur[j])
		end
		if best > limit then
			return limit + 1
		end
		prev = cur
	end
	return prev[m]
end

--[[
	Fuzzy score: every query char must appear in order. Consecutive matches,
	word starts and prefix matches score higher. If nothing matches it tries
	the other keyboard layout ("ghbdtn" -> "привет") and then small typos
	(one wrong letter in short words, two in long ones). nil = no match.
]]
function Util.Fuzzy(query: string, text: string): number?
	query, text = Util.Lower(query), Util.Lower(text)
	local score = fuzzyCore(query, text)
	if score then
		return score
	end
	local swapped = Util.SwapLayout(query)
	if swapped ~= query then
		score = fuzzyCore(swapped, text)
		if score then
			return score - 5
		end
	end
	if utf8.len(query) and utf8.len(query) >= 4 then
		local limit = utf8.len(query) >= 7 and 2 or 1
		local q = chars(query)
		for word in string.gmatch(text, "[^%s%-_%.]+") do
			local w = chars(word)
			-- compare with the word, and with its start of the same length
			local head = { table.unpack(w, 1, math.min(#w, #q)) }
			local d = math.min(distance(q, w, limit), distance(q, head, limit))
			if d <= limit then
				return 40 - d * 15 - #text * 0.1
			end
		end
	end
	return nil
end

function Util.Uid(): string
	return string.sub(string.gsub(HttpService:GenerateGUID(false), "-", ""), 1, 12)
end

-- ─── Base64 (for config export strings) ──────────────────────────────────

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

function Util.Base64Encode(data: string): string
	return (
		(string.gsub(data, ".", function(x)
			local r, b = "", string.byte(x)
			for i = 8, 1, -1 do
				r ..= (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
			end
			return r
		end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
			if #x < 6 then
				return ""
			end
			local c = 0
			for i = 1, 6 do
				c += (string.sub(x, i, i) == "1" and 2 ^ (6 - i) or 0)
			end
			return string.sub(B64, c + 1, c + 1)
		end) .. ({ "", "==", "=" })[#data % 3 + 1]
	)
end

function Util.Base64Decode(data: string): string
	data = string.gsub(data, "[^" .. B64 .. "=]", "")
	return (
		string.gsub(data, ".", function(x)
			if x == "=" then
				return ""
			end
			local r, f = "", (string.find(B64, x, 1, true) - 1)
			for i = 6, 1, -1 do
				r ..= (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0")
			end
			return r
		end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
			if #x ~= 8 then
				return ""
			end
			local c = 0
			for i = 1, 8 do
				c += (string.sub(x, i, i) == "1" and 2 ^ (8 - i) or 0)
			end
			return string.char(c)
		end)
	)
end

-- Tiny non-cryptographic checksum (Adler-32) used to detect broken pastes.
function Util.Checksum(s: string): string
	local a, b = 1, 0
	for i = 1, #s do
		a = (a + string.byte(s, i)) % 65521
		b = (b + a) % 65521
	end
	return string.format("%08x", b * 65536 + a)
end

-- ─── Calls ────────────────────────────────────────────────────────────────

Util.ErrorHandler = function(message: string, trace: string)
	warn("[Proximity] callback error: " .. tostring(message) .. "\n" .. trace)
end

-- Runs fn and never lets an error escape; reports through Util.ErrorHandler.
function Util.SafeCall(fn: ((...any) -> ...any)?, ...: any): (boolean, ...any)
	if type(fn) ~= "function" then
		return false
	end
	return xpcall(fn, function(err)
		local trace = debug.traceback(nil, 2)
		task.spawn(Util.ErrorHandler, err, trace)
		return err
	end, ...)
end

function Util.Debounce(seconds: number, fn: (...any) -> ()): (...any) -> ()
	local token = 0
	return function(...)
		token += 1
		local mine = token
		local args = table.pack(...)
		task.delay(seconds, function()
			if mine == token then
				fn(table.unpack(args, 1, args.n))
			end
		end)
	end
end

function Util.Throttle(seconds: number, fn: (...any) -> ()): (...any) -> ()
	local last = 0
	return function(...)
		local now = os.clock()
		if now - last >= seconds then
			last = now
			fn(...)
		end
	end
end

return Util
