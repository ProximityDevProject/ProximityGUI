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

-- Accepts Enum.KeyCode, Enum.UserInputType, "E", "LeftShift", "LShift", "MB2", nil.
function Keys.Normalize(value: any): string
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
