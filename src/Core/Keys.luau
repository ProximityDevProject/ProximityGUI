--!nocheck
--[[
	Proximity · Core/Keys
	Keyboard + mouse names. One canonical string per input ("E", "LeftShift",
	"MB2"), used for display, configs and matching.
]]

local Keys = {}

local short = {
	LeftShift = "LShift",
	RightShift = "RShift",
	LeftControl = "LCtrl",
	RightControl = "RCtrl",
	LeftAlt = "LAlt",
	RightAlt = "RAlt",
	LeftSuper = "LWin",
	RightSuper = "RWin",
	Backspace = "Bksp",
	Return = "Enter",
	Escape = "Esc",
	CapsLock = "Caps",
	PageUp = "PgUp",
	PageDown = "PgDn",
	Insert = "Ins",
	Delete = "Del",
	Zero = "0",
	One = "1",
	Two = "2",
	Three = "3",
	Four = "4",
	Five = "5",
	Six = "6",
	Seven = "7",
	Eight = "8",
	Nine = "9",
	KeypadZero = "Num0",
	KeypadOne = "Num1",
	KeypadTwo = "Num2",
	KeypadThree = "Num3",
	KeypadFour = "Num4",
	KeypadFive = "Num5",
	KeypadSix = "Num6",
	KeypadSeven = "Num7",
	KeypadEight = "Num8",
	KeypadNine = "Num9",
	KeypadPeriod = "Num.",
	KeypadDivide = "Num/",
	KeypadMultiply = "Num*",
	KeypadMinus = "Num-",
	KeypadPlus = "Num+",
	KeypadEnter = "NumEnter",
	KeypadEquals = "Num=",
	Minus = "-",
	Equals = "=",
	LeftBracket = "[",
	RightBracket = "]",
	BackSlash = "\\",
	Semicolon = ";",
	Quote = "'",
	Comma = ",",
	Period = ".",
	Slash = "/",
	Backquote = "`",
	Tilde = "~",
}

local mouse = {
	[Enum.UserInputType.MouseButton1] = "MB1",
	[Enum.UserInputType.MouseButton2] = "MB2",
	[Enum.UserInputType.MouseButton3] = "MB3",
}
local mouseReverse = {}
for k, v in mouse do
	mouseReverse[v] = k
end

-- Canonical name from an InputObject (nil when the input is not bindable).
function Keys.FromInput(input: InputObject): string?
	if mouse[input.UserInputType] then
		return mouse[input.UserInputType]
	end
	if input.KeyCode ~= Enum.KeyCode.Unknown then
		local t = input.UserInputType
		if t == Enum.UserInputType.Keyboard or t == Enum.UserInputType.Gamepad1 then
			return input.KeyCode.Name
		end
	end
	return nil
end

-- ─── Combos: "Ctrl+Shift+X" ───────────────────────────────────────────
-- Modifiers are stored by side-less name so either Ctrl works.
local modifierOf = {
	LeftControl = "Ctrl",
	RightControl = "Ctrl",
	LeftShift = "Shift",
	RightShift = "Shift",
	LeftAlt = "Alt",
	RightAlt = "Alt",
}
local modifierKeys = {
	Ctrl = { Enum.KeyCode.LeftControl, Enum.KeyCode.RightControl },
	Shift = { Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift },
	Alt = { Enum.KeyCode.LeftAlt, Enum.KeyCode.RightAlt },
}
local modifierOrder = { "Ctrl", "Shift", "Alt" }

function Keys.IsModifier(name: string): boolean
	return modifierOf[name] ~= nil
end

local function held(mod)
	local UIS = game:GetService("UserInputService")
	for _, code in modifierKeys[mod] do
		if UIS:IsKeyDown(code) then
			return true
		end
	end
	return false
end

-- "X" pressed while Ctrl and Shift are held -> "Ctrl+Shift+X"
function Keys.Combo(main: string): string
	if modifierOf[main] then
		return main
	end
	local parts = {}
	for _, mod in modifierOrder do
		if held(mod) then
			table.insert(parts, mod)
		end
	end
	table.insert(parts, main)
	return table.concat(parts, "+")
end

function Keys.MainKey(value: string): string
	return string.match(value or "", "([^+]+)$") or "None"
end

-- Does a stored bind fire for this pressed key? Extra modifiers held by the
-- player do not block a plain bind; a combo needs all of its modifiers.
function Keys.MatchesCombo(value: string, pressed: string): boolean
	if not value or value == "None" then
		return false
	end
	if Keys.MainKey(value) ~= pressed then
		return false
	end
	for mod in string.gmatch(value, "([^+]+)%+") do
		if modifierKeys[mod] and not held(mod) then
			return false
		end
	end
	return true
end

-- Accepts Enum.KeyCode, Enum.UserInputType, "E", "LeftShift", "LShift", "MB2", "Ctrl+Shift+X", nil.
function Keys.Normalize(value: any): string
	if type(value) == "string" and string.find(value, "+", 2, true) then
		local parts = string.split(value, "+")
		local main = Keys.Normalize(parts[#parts])
		if main == "None" then
			return "None"
		end
		local mods = {}
		for i = 1, #parts - 1 do
			local m = string.lower(parts[i])
			if m == "ctrl" or m == "control" then
				mods.Ctrl = true
			elseif m == "shift" then
				mods.Shift = true
			elseif m == "alt" then
				mods.Alt = true
			end
		end
		local out = {}
		for _, mod in modifierOrder do
			if mods[mod] then
				table.insert(out, mod)
			end
		end
		table.insert(out, main)
		return table.concat(out, "+")
	end
	return Keys.NormalizeSingle(value)
end

function Keys.NormalizeSingle(value: any): string
	if value == nil or value == false or value == "" or value == "None" or value == "-" then
		return "None"
	end
	if typeof(value) == "EnumItem" then
		if value.EnumType == Enum.UserInputType then
			return mouse[value] or "None"
		end
		return value.Name
	end
	value = tostring(value)
	if mouseReverse[value] then
		return value
	end
	local ok, code = pcall(function()
		return Enum.KeyCode[value]
	end)
	if ok and code then
		return code.Name
	end
	for long, s in short do
		if string.lower(s) == string.lower(value) then
			return long
		end
	end
	return "None"
end

function Keys.Display(name: string?): string
	if not name or name == "None" then
		return "None"
	end
	if string.find(name, "+", 2, true) then
		local parts = string.split(name, "+")
		parts[#parts] = short[parts[#parts]] or parts[#parts]
		return table.concat(parts, "+")
	end
	return short[name] or name
end

function Keys.Matches(name: string, input: InputObject): boolean
	return name ~= "None" and Keys.FromInput(input) == name
end

function Keys.ToEnum(name: string): EnumItem?
	if mouseReverse[name] then
		return mouseReverse[name]
	end
	local ok, code = pcall(function()
		return Enum.KeyCode[name]
	end)
	return ok and code or nil
end

return Keys
