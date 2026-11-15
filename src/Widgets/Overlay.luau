--!nocheck
--[[
	Proximity · Widgets/Overlay
	The top layer: anchored popups (dropdown lists, color pickers, option
	panels, context menus) and the tooltip. Popups are created lazily and
	stacked; a click outside closes everything above the clicked popup,
	Escape closes the top one.
]]

local Util = require("../Core/Util")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")
local Theme = require("../Theme")
local Icons = require("../Icons")
local Shared = require("../Shared")

local UIS = Env.Service("UserInputService")
local RunService = Env.Service("RunService")

local Overlay = {}
Overlay.Stack = {}

local root, scale

function Overlay.Init(parent: Instance)
	root = Util.New("Frame", {
		Name = "Overlay",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 50,
		Parent = parent,
	})
	scale = Util.New("UIScale", { Scale = 1, Parent = root })
	Overlay.Root = root

	Shared.Maid:Connect(UIS.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Overlay._outside(Vector2.new(input.Position.X, input.Position.Y))
		elseif input.KeyCode == Enum.KeyCode.Escape then
			local top = Overlay.Stack[#Overlay.Stack]
			if top then
				top:Close()
			end
		end
	end)

	Shared.Maid:Connect(RunService.RenderStepped, function()
		for _, popup in Overlay.Stack do
			if popup.Follow then
				popup:Reposition()
			end
		end
		Overlay._tooltipStep()
	end)

	Overlay._buildTooltip()
end

function Overlay.SetScale(value: number)
	if scale then
		scale.Scale = value
		root.Size = UDim2.fromScale(1 / value, 1 / value)
	end
end

local function inside(gui: GuiObject?, point: Vector2): boolean
	if not gui or not gui.Parent or not gui.Visible then
		return false
	end
	local pos, size = gui.AbsolutePosition, gui.AbsoluteSize
	return point.X >= pos.X and point.X <= pos.X + size.X and point.Y >= pos.Y and point.Y <= pos.Y + size.Y
end

function Overlay._outside(point: Vector2)
	for i = #Overlay.Stack, 1, -1 do
		local popup = Overlay.Stack[i]
		if inside(popup.Frame, point) or inside(popup.Anchor, point) then
			return
		end
		if popup.Sticky then
			return
		end
		popup:Close()
	end
end

-- ─── Popup ────────────────────────────────────────────────────────────────

local Popup = {}
Popup.__index = Popup

--[[
	Overlay.Popup({
		Anchor = guiObject,       -- popup sits next to it
		Width = 220,              -- px (height follows content up to MaxHeight)
		MaxHeight = 300,
		Side = "Bottom" | "Right" | "Top" | "Left",
		Align = "Start" | "End" | "Center",
		Gap = 6,
		OnClose = fn,
	})
]]
function Overlay.Popup(options: { [string]: any })
	local self = setmetatable({}, Popup)
	self.Anchor = options.Anchor
	self.Side = options.Side or "Bottom"
	self.Align = options.Align or "Start"
	self.Gap = options.Gap or 6
	self.Width = options.Width or 220
	self.MaxHeight = options.MaxHeight or 320
	self.OnClose = options.OnClose
	self.Follow = options.Follow ~= false
	self.Open = true

	local frame = Util.New("Frame", {
		Name = "Popup",
		Size = UDim2.fromOffset(self.Width, 10),
		AutomaticSize = Enum.AutomaticSize.None,
		ZIndex = 60 + #Overlay.Stack * 5,
		Active = true,
		ClipsDescendants = true,
		Parent = root,
	})
	Theme.Paint(frame, { BackgroundColor3 = "Elevated" })
	Util.Corner(8, frame)
	local stroke = Util.Stroke(frame)
	Theme.Paint(stroke, { Color = "StrokeHi" })
	Overlay.Shadow(frame, 0.55)

	local content = Util.New("ScrollingFrame", {
		Name = "Content",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ZIndex = frame.ZIndex,
		Parent = frame,
	})
	Theme.Paint(content, { ScrollBarImageColor3 = "StrokeHi" })
	local layout = Util.List(content, options.Spacing or 2)
	Util.Padding(content, options.Padding or 6)

	self.Frame = frame
	self.Content = content
	self.Layout = layout
	self.Stroke = stroke

	local function fit()
		local h = layout.AbsoluteContentSize.Y + (options.Padding or 6) * 2
		self.Height = math.min(h, self.MaxHeight)
		frame.Size = UDim2.fromOffset(self.Width, self.Height)
		self:Reposition()
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fit)
	self.Fit = fit

	table.insert(Overlay.Stack, self)

	-- entrance
	frame.BackgroundTransparency = 1
	stroke.Transparency = 1
	task.defer(function()
		fit()
		Tween.Play(frame, { BackgroundTransparency = 0 }, 0.16)
		Tween.Play(stroke, { Transparency = 0 }, 0.16)
	end)
	return self
end

function Popup:Reposition()
	if not self.Open or not self.Anchor or not self.Anchor.Parent then
		return
	end
	local s = scale.Scale
	-- work in the overlay's own space: AbsolutePosition excludes the topbar
	-- inset while this layer ignores it, so subtract the root's origin.
	local origin = root.AbsolutePosition
	local view = root.AbsoluteSize
	local apos, asize = self.Anchor.AbsolutePosition - origin, self.Anchor.AbsoluteSize
	local w, h = self.Width * s, (self.Height or 40) * s
	local gap = self.Gap * s
	local x, y
	if self.Side == "Right" or self.Side == "Left" then
		x = self.Side == "Right" and apos.X + asize.X + gap or apos.X - w - gap
		y = apos.Y
		if x + w > view.X - 4 then
			x = apos.X - w - gap
		elseif x < 4 then
			x = apos.X + asize.X + gap
		end
	else
		y = self.Side == "Top" and apos.Y - h - gap or apos.Y + asize.Y + gap
		if self.Align == "End" then
			x = apos.X + asize.X - w
		elseif self.Align == "Center" then
			x = apos.X + asize.X / 2 - w / 2
		else
			x = apos.X
		end
		-- flip when there is no room
		if y + h > view.Y - 4 then
			y = apos.Y - h - gap
		elseif y < 4 then
			y = apos.Y + asize.Y + gap
		end
	end
	x = math.clamp(x, 4, math.max(4, view.X - w - 4))
	y = math.clamp(y, 4, math.max(4, view.Y - h - 4))
	self.Frame.Position = UDim2.fromOffset(x / s, y / s)
end

function Popup:Close()
	if not self.Open then
		return
	end
	self.Open = false
	local index = table.find(Overlay.Stack, self)
	if index then
		-- closing a popup also closes everything opened from it
		for i = #Overlay.Stack, index + 1, -1 do
			Overlay.Stack[i]:Close()
		end
		table.remove(Overlay.Stack, table.find(Overlay.Stack, self))
	end
	local frame = self.Frame
	Tween.Play(frame, { BackgroundTransparency = 1 }, 0.12)
	Tween.Play(self.Stroke, { Transparency = 1 }, 0.12)
	for _, d in frame:GetDescendants() do
		if d:IsA("GuiObject") then
			d.Visible = false
		end
	end
	task.delay(0.13, function()
		frame:Destroy()
	end)
	if self.OnClose then
		Util.SafeCall(self.OnClose)
	end
end
Popup.Destroy = Popup.Close

function Overlay.CloseAll()
	for i = #Overlay.Stack, 1, -1 do
		Overlay.Stack[i]:Close()
	end
end

-- ─── Soft shadow ─────────────────────────────────────────────────────────

local hasUIShadow = pcall(function()
	Instance.new("UIShadow"):Destroy()
end)
Overlay.HasUIShadow = hasUIShadow

-- Adds a soft drop shadow behind `frame` (UIShadow when the engine has it,
-- otherwise a 9-slice image).
function Overlay.Shadow(frame: GuiObject, transparency: number?, size: number?)
	if hasUIShadow then
		local ok, shadow = pcall(function()
			local s = Instance.new("UIShadow")
			s.Color = Color3.new(0, 0, 0)
			pcall(function()
				s.Transparency = transparency or 0.5
			end)
			pcall(function()
				s.BlurRadius = UDim.new(0, size or 18)
			end)
			s.Parent = frame
			return s
		end)
		if ok then
			return shadow
		end
	end
	local image = Util.New("ImageLabel", {
		Name = "Shadow",
		BackgroundTransparency = 1,
		Image = "rbxassetid://6015897843",
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = transparency or 0.5,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, (size or 18) * 2, 1, (size or 18) * 2),
		ZIndex = math.max(0, frame.ZIndex - 1),
		Parent = frame.Parent,
	})
	-- follow the frame
	local function sync()
		image.Position = UDim2.new(frame.Position.X.Scale, frame.Position.X.Offset + frame.AbsoluteSize.X * (0.5 - frame.AnchorPoint.X) / math.max(scale and scale.Scale or 1, 0.01), frame.Position.Y.Scale, frame.Position.Y.Offset + frame.AbsoluteSize.Y * (0.5 - frame.AnchorPoint.Y) / math.max(scale and scale.Scale or 1, 0.01))
		image.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset + (size or 18) * 2, frame.Size.Y.Scale, frame.Size.Y.Offset + (size or 18) * 2)
		image.Visible = frame.Visible
	end
	frame:GetPropertyChangedSignal("Position"):Connect(sync)
	frame:GetPropertyChangedSignal("Size"):Connect(sync)
	frame:GetPropertyChangedSignal("Visible"):Connect(sync)
	frame.Destroying:Connect(function()
		image:Destroy()
	end)
	sync()
	return image
end

-- ─── Menu (context menu / simple action list) ────────────────────────────

--[[
	Overlay.Menu({
		{ Text = "Reset", Icon = "rotate-ccw", Callback = fn },
		{ Separator = true },
		{ Text = "Delete", Danger = true, Callback = fn },
	}, { Anchor = gui } or { At = Vector2 })
]]
function Overlay.Menu(items: { { [string]: any } }, options: { [string]: any })
	options = options or {}
	local anchor = options.Anchor
	if not anchor and options.At then
		anchor = Util.New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(1, 1),
			Position = UDim2.fromOffset((options.At.X - root.AbsolutePosition.X) / scale.Scale, (options.At.Y - root.AbsolutePosition.Y) / scale.Scale),
			Parent = root,
		})
	end
	local popup = Overlay.Popup({
		Anchor = anchor,
		Width = options.Width or 190,
		Side = options.Side or "Bottom",
		Align = options.Align or "Start",
		Gap = options.At and 0 or 6,
		Padding = 4,
		OnClose = function()
			if options.At and anchor then
				anchor:Destroy()
			end
			if options.OnClose then
				options.OnClose()
			end
		end,
	})
	for i, item in items do
		if item.Separator then
			local line = Util.New("Frame", {
				Size = UDim2.new(1, -8, 0, 1),
				Position = UDim2.fromOffset(4, 0),
				BorderSizePixel = 0,
				LayoutOrder = i,
				ZIndex = popup.Frame.ZIndex,
				Parent = popup.Content,
			})
			Theme.Paint(line, { BackgroundColor3 = "Stroke" })
		else
			local button = Util.New("TextButton", {
				Text = "",
				AutoButtonColor = false,
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundTransparency = 1,
				LayoutOrder = i,
				ZIndex = popup.Frame.ZIndex,
				Parent = popup.Content,
			})
			Theme.Paint(button, { BackgroundColor3 = "Surface3" })
			Util.Corner(6, button)
			local x = 10
			local icon = Icons.Get(item.Icon)
			if icon then
				local img = Util.New("ImageLabel", {
					BackgroundTransparency = 1,
					Image = icon,
					Size = UDim2.fromOffset(14, 14),
					Position = UDim2.new(0, 9, 0.5, -7),
					ZIndex = button.ZIndex,
					Parent = button,
				})
				Theme.Paint(img, { ImageColor3 = item.Danger and "Risky" or "TextDim" })
				x = 30
			end
			local label = Util.Label({
				Text = item.Text or "",
				FontFace = Theme.Fonts.Medium,
				TextSize = 13,
				Position = UDim2.fromOffset(x, 0),
				Size = UDim2.new(1, -x - 8, 1, 0),
				ZIndex = button.ZIndex,
				Parent = button,
			})
			Theme.Paint(label, { TextColor3 = item.Danger and "Risky" or "Text" })
			if item.Hint then
				local hint = Util.Label({
					Text = item.Hint,
					FontFace = Theme.Fonts.Mono,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Right,
					Size = UDim2.new(1, -10, 1, 0),
					ZIndex = button.ZIndex,
					Parent = button,
				})
				Theme.Paint(hint, { TextColor3 = "TextMute" })
			end
			button.MouseEnter:Connect(function()
				Tween.Play(button, { BackgroundTransparency = 0 }, 0.1)
			end)
			button.MouseLeave:Connect(function()
				Tween.Play(button, { BackgroundTransparency = 1 }, 0.1)
			end)
			button.Activated:Connect(function()
				popup:Close()
				if item.Callback then
					Util.SafeCall(item.Callback)
				end
			end)
		end
	end
	return popup
end

-- ─── Tooltip ─────────────────────────────────────────────────────────────

local tip = {}

function Overlay._buildTooltip()
	tip.Frame = Util.New("Frame", {
		Name = "Tooltip",
		Visible = false,
		AutomaticSize = Enum.AutomaticSize.XY,
		ZIndex = 200,
		Parent = root,
	})
	Theme.Paint(tip.Frame, { BackgroundColor3 = "Elevated" })
	Util.Corner(6, tip.Frame)
	Theme.Paint(Util.Stroke(tip.Frame), { Color = "StrokeHi" })
	Util.Padding(tip.Frame, 6, 9, 6, 9)
	Util.New("UISizeConstraint", { MaxSize = Vector2.new(280, 400), Parent = tip.Frame })
	tip.Label = Util.Label({
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.new(),
		TextWrapped = true,
		RichText = true,
		FontFace = Theme.Fonts.Regular,
		TextSize = 12,
		ZIndex = 201,
		Parent = tip.Frame,
	})
	Theme.Paint(tip.Label, { TextColor3 = "Text" })
end

--[[
	Overlay.Hover(guiObject, function() return "text" end)
	Shows the tooltip after a short delay while the pointer rests on the object.
]]
function Overlay.Hover(gui: GuiObject, getText: () -> string?)
	local token = 0
	gui.MouseEnter:Connect(function()
		token += 1
		local mine = token
		task.delay(0.45, function()
			if mine == token and Overlay.Root then
				local text = getText()
				if text and text ~= "" then
					tip.Owner = gui
					tip.Label.Text = text
					tip.Frame.Visible = true
				end
			end
		end)
	end)
	gui.MouseLeave:Connect(function()
		token += 1
		if tip.Owner == gui then
			tip.Frame.Visible = false
			tip.Owner = nil
		end
	end)
end

function Overlay.HideTooltip()
	if tip.Frame then
		tip.Frame.Visible = false
		tip.Owner = nil
	end
end

function Overlay._tooltipStep()
	if tip.Frame and tip.Frame.Visible then
		if not tip.Owner or not tip.Owner.Parent or not tip.Owner.Visible then
			tip.Frame.Visible = false
			return
		end
		local mouse = UIS:GetMouseLocation()
		local s = scale.Scale
		local view = workspace.CurrentCamera.ViewportSize
		local size = tip.Frame.AbsoluteSize
		local x = math.clamp(mouse.X + 14, 4, view.X - size.X - 4)
		local y = mouse.Y + 18
		if y + size.Y > view.Y - 4 then
			y = mouse.Y - size.Y - 8
		end
		tip.Frame.Position = UDim2.fromOffset(x / s, y / s)
	end
end

return Overlay
