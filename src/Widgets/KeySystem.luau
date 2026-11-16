--!nocheck
--[[
	Proximity · Widgets/KeySystem
	A key gate in the Proximity look, shown before the window is built.
	Turn it on or off with one option:

	  Proximity:Window({ KeySystem = false })            -- off (default)
	  Proximity:Window({ KeySystem = {
	      Keys = { "alpha-123", "beta-456" },          -- accepted keys, or:
	      Check = function(key) return key == "x" end, -- your own check (can yield, e.g. HttpGet)
	      Url = "https://my.site/check?key={key}&hwid={hwid}", -- or: GET this, "true"/"valid"/"ok" in the body = valid
	                                                  -- {hwid} ties a key to one device (old "%s" still works)
	      GetKey = "https://my.site/getkey",          -- copied by the "Get key" button
	      Discord = "https://discord.gg/...",         -- optional second link
	      Attempts = 5, Cooldown = 30,                -- lock after 5 misses for 30 s
	      Remember = true,                            -- remember a valid key on this device
	      Title = "My Hub", Note = "Keys reset every 24 h",
	  } })

	Proximity:KeySystem(options) runs it standalone and returns true/false.
]]

local HttpService = game:GetService("HttpService")

local Util = require("../Core/Util")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")
local Theme = require("../Theme")
local Icons = require("../Icons")
local Locale = require("../Locale")
local Shared = require("../Shared")

return function(Lib)
	local function verify(options, key)
		key = Util.Trim(key or "")
		if key == "" then
			return false
		end
		if options.Keys then
			for _, k in options.Keys do
				if k == key then
					return true
				end
			end
		end
		if options.Check then
			local ok, result = pcall(options.Check, key)
			if ok and result then
				return true
			end
		end
		if options.Url then
			-- {key} and {hwid} placeholders (or the old %s for the key); the hwid
			-- lets your server tie a key to one device
			local url = options.Url
			local hwid = HttpService:UrlEncode(Env.Hwid())
			if string.find(url, "{key}", 1, true) or string.find(url, "{hwid}", 1, true) then
				url = string.gsub(string.gsub(url, "{key}", HttpService:UrlEncode(key)), "{hwid}", hwid)
			else
				url = string.format(url, HttpService:UrlEncode(key))
			end
			local body = Env.HttpGet(url)
			if body then
				local b = string.lower(Util.Trim(body))
				if b == "true" or b == "valid" or b == "ok" or b == "1" or string.find(b, '"valid"%s*:%s*true') then
					return true
				end
			end
		end
		return false
	end

	function Lib:KeySystem(options)
		options = options or {}
		local storeKey = "Key." .. Util.SafeName(options.Title or "default")
		if options.Remember ~= false then
			local saved = Lib:GetSetting(storeKey)
			if type(saved) == "string" and verify(options, saved) then
				return true
			end
		end
		local attempts, maxAttempts = 0, options.Attempts or 5
		local lockedUntil = 0
		local result = nil
		local thread = coroutine.running()

		local root = Util.New("Frame", { Name = "ProximityKey", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 400, Parent = Shared.Gui.Root })
		local dim = Util.New("Frame", { BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 400, Parent = root })
		Tween.Play(dim, { BackgroundTransparency = 0.35 }, 0.4)
		local card = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.53), Size = UDim2.fromOffset(380, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 401, Parent = root })
		Util.Corner(12, card)
		Theme.Paint(card, { BackgroundColor3 = "Bg" })
		Theme.Paint(Util.Stroke(card), { Color = "StrokeHi" })
		Shared.Overlay.Shadow(card, 0.3, 30)
		Util.Padding(card, 22, 22, 20, 22)
		Util.List(card, 12)
		local scale = Util.New("UIScale", { Scale = 0.94, Parent = card })
		Tween.Play(scale, { Scale = 1 }, 0.35, Enum.EasingStyle.Back)
		Tween.Play(card, { Position = UDim2.fromScale(0.5, 0.5) }, 0.35)

		local head = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 1, ZIndex = 401, Parent = card })
		local fakeWindow = { Logo = options.Logo, Title = options.Title }
		local logo = Lib._drawLogo(fakeWindow, head, 36)
		logo.ZIndex = 402
		local title = Util.Label({ Text = options.Title or (Locale.T("KeyTitle")), FontFace = Theme.Fonts.Bold, TextSize = 17, Position = UDim2.fromOffset(50, 2), Size = UDim2.new(1, -50, 0, 20), ZIndex = 402, Parent = head })
		Theme.Paint(title, { TextColor3 = "Text" })
		local sub = Util.Label({ Text = options.Subtitle or Locale.T("KeySubtitle"), FontFace = Theme.Fonts.Regular, TextSize = 12, Position = UDim2.fromOffset(50, 22), Size = UDim2.new(1, -50, 0, 16), ZIndex = 402, Parent = head })
		Theme.Paint(sub, { TextColor3 = "TextMute" })

		local box = Util.New("TextBox", { Text = "", PlaceholderText = Locale.T("KeyPlaceholder"), ClearTextOnFocus = false, FontFace = Theme.Fonts.Mono, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 2, ZIndex = 402, Parent = card })
		Util.Corner(8, box)
		Util.Padding(box, 0, 12, 0, 40)
		Theme.Paint(box, { BackgroundColor3 = "Surface2", TextColor3 = "Text", PlaceholderColor3 = "TextMute" })
		local boxStroke = Util.Stroke(box)
		Theme.Paint(boxStroke, { Color = "Stroke" })
		local keyIcon = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get("key") or "", Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, -28, 0.5, -8), ZIndex = 403, Parent = box })
		Theme.Paint(keyIcon, { ImageColor3 = "TextDim" })
		box.Focused:Connect(function()
			Theme.Paint(boxStroke, { Color = "Accent" }, 0.15)
		end)
		box.FocusLost:Connect(function()
			Theme.Paint(boxStroke, { Color = "Stroke" }, 0.15)
		end)

		local status = Util.Label({ Text = options.Note or "", FontFace = Theme.Fonts.Regular, TextSize = 12, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 3, Visible = options.Note ~= nil, ZIndex = 402, Parent = card })
		Theme.Paint(status, { TextColor3 = "TextDim" })

		local row = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = 4, ZIndex = 402, Parent = card })
		local function button(text, icon, primary, x, w)
			local b = Util.New("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.new(w, -4, 1, 0), Position = UDim2.new(x, x > 0 and 4 or 0, 0, 0), ZIndex = 402, Parent = row })
			Util.Corner(8, b)
			Theme.Paint(b, { BackgroundColor3 = primary and "Accent" or "Surface3" })
			Theme.Paint(Util.Stroke(b), { Color = primary and "Accent" or "Stroke" })
			local inner = Util.New("Frame", { BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromScale(0, 1), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0), ZIndex = 403, Parent = b })
			Util.List(inner, 6, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)
			local img = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = Icons.Get(icon) or "", Size = UDim2.fromOffset(14, 14), ZIndex = 403, Parent = inner })
			Theme.Paint(img, { ImageColor3 = primary and "AccentInk" or "Text" })
			local l = Util.Label({ Text = text, FontFace = Theme.Fonts.SemiBold, TextSize = 13, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromScale(0, 1), LayoutOrder = 2, ZIndex = 403, Parent = inner })
			Theme.Paint(l, { TextColor3 = primary and "AccentInk" or "Text" })
			return b, l
		end
		local hasLink = options.GetKey ~= nil
		local getBtn = hasLink and button(Locale.T("GetKey"), "link", false, 0, 0.5)
		local checkBtn, checkLabel = button(Locale.T("CheckKey"), "check", true, hasLink and 0.5 or 0, hasLink and 0.5 or 1)

		if options.Discord then
			local d = Util.New("TextButton", { Text = Locale.T("JoinDiscord"), FontFace = Theme.Fonts.Medium, TextSize = 12, BackgroundTransparency = 1, AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 5, ZIndex = 402, Parent = card })
			Theme.Paint(d, { TextColor3 = "TextDim" })
			d.Activated:Connect(function()
				Env.Clipboard(options.Discord)
				status.Visible = true
				status.Text = Locale.T("LinkCopied")
			end)
		end

		local function shake()
			for _, dx in { 8, -8, 5, -5, 0 } do
				Tween.Await(card, { Position = UDim2.new(0.5, dx, 0.5, 0) }, 0.05, Enum.EasingStyle.Sine)
			end
		end

		local busy = false
		local function submit()
			if busy or result ~= nil then
				return
			end
			if os.clock() < lockedUntil then
				status.Visible = true
				status.Text = Locale.T("KeyWait", math.ceil(lockedUntil - os.clock()))
				return
			end
			busy = true
			checkLabel.Text = Locale.T("Checking")
			local ok = verify(options, box.Text)
			busy = false
			checkLabel.Text = Locale.T("CheckKey")
			if ok then
				result = true
				if options.Remember ~= false then
					Lib:SetSetting(storeKey, Util.Trim(box.Text))
				end
				Theme.Paint(boxStroke, { Color = "Success" }, 0.15)
				status.Visible = true
				status.Text = Locale.T("KeyOk")
				Theme.Paint(status, { TextColor3 = "Success" })
				task.wait(0.45)
				Tween.Play(dim, { BackgroundTransparency = 1 }, 0.3)
				Tween.Play(scale, { Scale = 0.96 }, 0.25)
				card.Visible = false
				task.delay(0.3, function()
					root:Destroy()
				end)
				if coroutine.status(thread) == "suspended" then
					task.spawn(thread, true)
				end
				return
			end
			attempts += 1
			Theme.Paint(boxStroke, { Color = "Risky" }, 0.1)
			Theme.Paint(status, { TextColor3 = "Risky" })
			status.Visible = true
			if attempts >= maxAttempts then
				attempts = 0
				lockedUntil = os.clock() + (options.Cooldown or 30)
				status.Text = Locale.T("KeyLocked", options.Cooldown or 30)
			else
				status.Text = Locale.T("KeyBad", maxAttempts - attempts)
			end
			task.spawn(shake)
		end
		checkBtn.Activated:Connect(submit)
		box.FocusLost:Connect(function(enter)
			if enter then
				submit()
			end
		end)
		if getBtn then
			getBtn.Activated:Connect(function()
				local copied = Env.Clipboard(options.GetKey)
				status.Visible = true
				Theme.Paint(status, { TextColor3 = "TextDim" })
				status.Text = copied and Locale.T("LinkCopied") or options.GetKey
			end)
		end
		return coroutine.yield()
	end
end
