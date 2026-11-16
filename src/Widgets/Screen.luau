--!nocheck
--[[
	Proximity · Widgets/Screen
	Screen-level options (taken from the menu settings players already know
	and reworked): a soft blur behind the open menu, an FPS cap, a custom
	cursor while the menu is open, and window snapping to the screen edges.

	  Library:SetMenuBlur(0..24)                 0 = off
	  Library:SetFpsCap(n)                       0 = unlimited (needs setfpscap)
	  Library:SetCursor("Default" | "Proximity" | "Dot" | "Crosshair")
	  Library:SetSnap(true / false)              drag a window to an edge to dock it
]]

local Util = require("../Core/Util")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")
local Theme = require("../Theme")
local Shared = require("../Shared")

local RunService = Env.Service("RunService")
local UIS = Env.Service("UserInputService")
local Lighting = Env.Service("Lighting")

return function(Lib)
	-- ─── blur behind the menu ─────────────────────────────────────────────
	local blur
	local function anyOpen()
		for _, w in Lib.Windows do
			if w._isOpen then
				return true
			end
		end
		return false
	end
	function Lib:_refreshBlur()
		local size = self:GetSetting("MenuBlur", 0) or 0
		local want = (size > 0 and anyOpen()) and size or 0
		if want > 0 and not blur then
			local ok, effect = pcall(function()
				local b = Instance.new("BlurEffect")
				b.Name = Util.Uid()
				b.Size = 0
				b.Parent = Lighting
				return b
			end)
			if ok then
				blur = effect
				Shared.Maid:Give(blur)
			end
		end
		if blur then
			Tween.Play(blur, { Size = want }, 0.35, Enum.EasingStyle.Sine)
		end
	end
	function Lib:SetMenuBlur(size)
		self:SetSetting("MenuBlur", math.clamp(tonumber(size) or 0, 0, 24))
		self:_refreshBlur()
		return self
	end

	-- ─── FPS cap ──────────────────────────────────────────────────────────
	function Lib:SetFpsCap(n)
		n = tonumber(n) or 0
		self:SetSetting("FpsCap", n)
		local env = (getgenv and getgenv()) or {}
		local cap = env.setfpscap or rawget(getfenv and getfenv(0) or {}, "setfpscap")
		if cap then
			pcall(cap, n <= 0 and 1e6 or n)
			return true
		end
		return false
	end

	-- ─── custom cursor while a menu is open ───────────────────────────────
	local cursor, cursorConn
	local function buildCursor(style)
		if cursor then
			cursor:Destroy()
			cursor = nil
		end
		local root = Util.New("Frame", { Name = "ProximityCursor", BackgroundTransparency = 1, Size = UDim2.fromOffset(32, 32), AnchorPoint = Vector2.new(0, 0), ZIndex = 10000, Visible = false, Parent = Shared.Gui.Root })
		if style == "Proximity" then
			local image = Lib.Media and Lib.Media:Get("images", "pointer")
			Util.New("ImageLabel", { BackgroundTransparency = 1, Image = image or "", Size = UDim2.fromOffset(22, 22), ZIndex = 10000, Parent = root })
			if not image then
				style = "Dot"
			end
		end
		if style == "Dot" then
			local dot = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(7, 7), BorderSizePixel = 0, ZIndex = 10000, Parent = root })
			Util.Round(dot)
			Theme.Paint(dot, { BackgroundColor3 = "Accent" })
			Util.Stroke(dot, Color3.new(0, 0, 0), 1, 0.4)
		elseif style == "Crosshair" then
			for _, spec in { { 0, -7, 2, 6 }, { 0, 7, 2, 6 }, { -7, 0, 6, 2 }, { 7, 0, 6, 2 } } do
				local bar = Util.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(spec[1], spec[2]), Size = UDim2.fromOffset(spec[3], spec[4]), BorderSizePixel = 0, ZIndex = 10000, Parent = root })
				Theme.Paint(bar, { BackgroundColor3 = "Accent" })
			end
		end
		cursor = root
	end
	function Lib:SetCursor(style)
		style = style or "Default"
		self:SetSetting("Cursor", style)
		if cursorConn then
			cursorConn:Disconnect()
			cursorConn = nil
		end
		if cursor then
			cursor:Destroy()
			cursor = nil
		end
		pcall(function()
			UIS.MouseIconEnabled = true
		end)
		if style == "Default" then
			return self
		end
		buildCursor(style)
		cursorConn = RunService.RenderStepped:Connect(function()
			local open = anyOpen() and UIS.MouseEnabled
			if cursor then
				cursor.Visible = open
				if open then
					local m = UIS:GetMouseLocation() - Shared.Gui.Root.AbsolutePosition
					cursor.Position = UDim2.fromOffset(m.X, m.Y)
				end
			end
			pcall(function()
				UIS.MouseIconEnabled = not open
			end)
		end)
		Shared.Maid:Give(cursorConn)
		Shared.Maid:Give(function()
			pcall(function()
				UIS.MouseIconEnabled = true
			end)
		end)
		return self
	end

	-- ─── snapping to the screen edges ─────────────────────────────────────
	function Lib:SetSnap(on)
		self:SetSetting("Snap", on and true or false)
		return self
	end
	-- called by a window when a drag ends: dock it to the nearest edge it
	-- was pushed against (left, right or top), smoothly
	function Lib:_snapWindow(window)
		if not self:GetSetting("Snap", true) then
			return
		end
		local holder = window.Holder
		local parent = holder.Parent
		if not parent then
			return
		end
		local view = parent.AbsoluteSize
		local pos = holder.AbsolutePosition - parent.AbsolutePosition
		local size = holder.AbsoluteSize
		local margin, reach = 12, 24
		local target
		if pos.X < reach then
			target = Vector2.new(margin + size.X / 2, math.clamp(pos.Y + size.Y / 2, size.Y / 2 + margin, view.Y - size.Y / 2 - margin))
		elseif pos.X + size.X > view.X - reach then
			target = Vector2.new(view.X - margin - size.X / 2, math.clamp(pos.Y + size.Y / 2, size.Y / 2 + margin, view.Y - size.Y / 2 - margin))
		elseif pos.Y < reach then
			target = Vector2.new(pos.X + size.X / 2, margin + size.Y / 2)
		end
		if target then
			Tween.Play(holder, { Position = UDim2.fromOffset(target.X, target.Y) }, 0.35, Enum.EasingStyle.Back)
			task.delay(0.4, function()
				window._restPosition = holder.Position
				window:_saveState()
			end)
		end
	end

	-- a window tells us when it opens and closes (blur, cursor)
	function Lib:_attachScreen(window)
		window.Opened:Connect(function()
			self:_refreshBlur()
		end)
		window.Closed:Connect(function()
			self:_refreshBlur()
		end)
	end

	-- restore saved choices
	task.defer(function()
		local cap = Lib:GetSetting("FpsCap", 0)
		if cap and cap > 0 then
			Lib:SetFpsCap(cap)
		end
		local style = Lib:GetSetting("Cursor", "Default")
		if style ~= "Default" then
			Lib:SetCursor(style)
		end
	end)
end
