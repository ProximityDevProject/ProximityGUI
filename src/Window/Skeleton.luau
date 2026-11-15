--!nocheck
--[[
	Proximity · Window/Skeleton
	The loading shell shown the moment a window is created - before a single
	element is built. It mirrors the real layout (sidebar + two columns), so
	the reveal feels like the UI "developing" rather than popping in.

	  • every declared tab appears in the sidebar with its own progress bar,
	    a spinner while it builds and a check when done
	  • a large mono percentage + stage line ("Building · Combat 34/120")
	  • developer tasks (Window:Task / Window:Step) are listed as stages
	  • shimmer runs on one shared Heartbeat loop (cheap)
	  • "Show now" appears after 2.5 s for slow scripts
	  • reveal = cross-fade of the shell + the real content rising 6 px
]]

local Util = require("../Core/Util")
local Tween = require("../Core/Tween")
local Env = require("../Core/Env")
local Theme = require("../Theme")
local Locale = require("../Locale")

local RunService = Env.Service("RunService")

local Skeleton = {}
Skeleton.__index = Skeleton

local function ghost(parent, size, position, radius)
	local frame = Util.New("Frame", { Size = size, Position = position or UDim2.new(), BorderSizePixel = 0, Parent = parent })
	Util.Corner(radius or 4, frame)
	Theme.Paint(frame, { BackgroundColor3 = "Surface3" })
	local shine = Util.Gradient(frame, ColorSequence.new(Color3.new(1, 1, 1)), NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.4, 0),
		NumberSequenceKeypoint.new(0.5, 0.55),
		NumberSequenceKeypoint.new(0.6, 0),
		NumberSequenceKeypoint.new(1, 0),
	}))
	shine.Offset = Vector2.new(-1, 0)
	return frame, shine
end

function Skeleton.new(window)
	local self = setmetatable({}, Skeleton)
	self.Window = window
	self.Rows = {}
	self.Shines = {}
	self.Started = os.clock()
	self.Display = 0

	local root = Util.New("CanvasGroup", {
		Name = "Skeleton",
		Size = UDim2.fromScale(1, 1),
		ZIndex = 40,
		Parent = window.Canvas,
	})
	Theme.Paint(root, { BackgroundColor3 = "Bg" })
	Util.Corner(10, root)
	self.Root = root

	-- sidebar ghost
	local side = Util.New("Frame", { Name = "Side", Size = UDim2.new(0, window.SidebarWidth, 1, 0), BorderSizePixel = 0, Parent = root })
	Theme.Paint(side, { BackgroundColor3 = "Bg2" })
	local divider = Util.New("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BorderSizePixel = 0, Parent = side })
	Theme.Paint(divider, { BackgroundColor3 = "Stroke" })
	local logo = window:_drawLogo(side, 26)
	logo.Position = UDim2.fromOffset(16, 19)
	local title = Util.Label({ Text = window.Title, FontFace = Theme.Fonts.Bold, TextSize = 15, Size = UDim2.new(1, -60, 0, 18), Position = UDim2.fromOffset(52, 17), TextTruncate = Enum.TextTruncate.AtEnd, Parent = side })
	Theme.Paint(title, { TextColor3 = "Text" })
	local sub = Util.Label({ Text = Locale.T("Loading") .. "…", FontFace = Theme.Fonts.Regular, TextSize = 11, Size = UDim2.new(1, -60, 0, 14), Position = UDim2.fromOffset(52, 35), Parent = side })
	Theme.Paint(sub, { TextColor3 = "TextMute" })
	local list = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -16, 1, -80), Position = UDim2.fromOffset(8, 70), Parent = side })
	Util.List(list, 4)
	self.List = list

	-- main ghost
	local main = Util.New("Frame", { Name = "Main", BackgroundTransparency = 1, Size = UDim2.new(1, -window.SidebarWidth, 1, 0), Position = UDim2.fromOffset(window.SidebarWidth, 0), Parent = root })
	local percent = Util.Label({ Text = "0%", FontFace = Theme.Fonts.MonoBold, TextSize = 30, Size = UDim2.new(0, 140, 0, 34), Position = UDim2.fromOffset(20, 16), Parent = main })
	Theme.Paint(percent, { TextColor3 = "Text" })
	local stage = Util.Label({ Text = Locale.T("Preparing"), FontFace = Theme.Fonts.Medium, TextSize = 12, Size = UDim2.new(1, -180, 0, 16), Position = UDim2.fromOffset(150, 20), TextTruncate = Enum.TextTruncate.AtEnd, Parent = main })
	Theme.Paint(stage, { TextColor3 = "TextDim" })
	local elapsed = Util.Label({ Text = "0.00s", FontFace = Theme.Fonts.Mono, TextSize = 11, Size = UDim2.new(1, -180, 0, 14), Position = UDim2.fromOffset(150, 37), Parent = main })
	Theme.Paint(elapsed, { TextColor3 = "TextMute" })
	local bar = Util.New("Frame", { Size = UDim2.new(1, -40, 0, 3), Position = UDim2.fromOffset(20, 60), BorderSizePixel = 0, Parent = main })
	Util.Round(bar)
	Theme.Paint(bar, { BackgroundColor3 = "Surface3" })
	local fill = Util.New("Frame", { Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, Parent = bar })
	Util.Round(fill)
	Theme.Paint(fill, { BackgroundColor3 = "Accent" })
	-- glow head on the bar
	local head = Util.New("Frame", { Size = UDim2.fromOffset(18, 7), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(1, 0.5), BackgroundTransparency = 0.6, BorderSizePixel = 0, Parent = fill })
	Util.Round(head)
	Theme.Paint(head, { BackgroundColor3 = "Accent" })
	self.Percent, self.Stage, self.Elapsed, self.Fill = percent, stage, elapsed, fill

	-- ghost section cards
	local cards = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, -96), Position = UDim2.fromOffset(20, 80), ClipsDescendants = true, Parent = main })
	local plan = { { 0, 0, 150 }, { 0, 160, 120 }, { 1, 0, 110 }, { 1, 120, 170 } }
	for _, p in plan do
		local card = Util.New("Frame", { Size = UDim2.new(0.5, -5, 0, p[3]), Position = UDim2.new(p[1] * 0.5, p[1] * 5, 0, p[2]), BorderSizePixel = 0, Parent = cards })
		Util.Corner(8, card)
		Theme.Paint(card, { BackgroundColor3 = "Surface" })
		Theme.Paint(Util.Stroke(card), { Color = "Stroke" })
		local _, s1 = ghost(card, UDim2.new(0.35, 0, 0, 8), UDim2.fromOffset(12, 13))
		table.insert(self.Shines, s1)
		local y = 36
		while y + 22 < p[3] do
			local _, s2 = ghost(card, UDim2.new(0.55, -12, 0, 9), UDim2.fromOffset(12, y + 4))
			local _, s3 = ghost(card, UDim2.fromOffset(28, 14), UDim2.new(1, -40, 0, y + 1), 7)
			table.insert(self.Shines, s2)
			table.insert(self.Shines, s3)
			y += 28
		end
	end

	-- "Show now"
	local skip = Util.New("TextButton", { Text = Locale.T("ShowNow"), FontFace = Theme.Fonts.SemiBold, TextSize = 12, AutoButtonColor = false, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 26), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -20, 0, 22), Visible = false, Parent = main })
	Util.Corner(6, skip)
	Util.Padding(skip, 0, 12, 0, 12)
	Theme.Paint(skip, { BackgroundColor3 = "Surface3", TextColor3 = "Text" })
	Theme.Paint(Util.Stroke(skip), { Color = "StrokeHi" })
	skip.Activated:Connect(function()
		window:_reveal(true)
	end)
	self.Skip = skip

	self.Conn = RunService.Heartbeat:Connect(function()
		local t = os.clock() - self.Started
		local offset = (t * 0.9) % 2.4 - 1.2
		for _, s in self.Shines do
			s.Offset = Vector2.new(offset, 0)
		end
		for _, row in self.Rows do
			if row.Spinner.Visible then
				row.Spinner.Rotation = (t * 360) % 360
			end
		end
		self.Elapsed.Text = string.format("%.2fs", t)
		if t > 2.5 and not skip.Visible and window.Loading.Skip ~= false then
			skip.Visible = true
		end
	end)
	return self
end

function Skeleton:AddTab(tab)
	if self.Rows[tab] then
		return
	end
	local row = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = #self.List:GetChildren(), Parent = self.List })
	local iconGhost, shine = ghost(row, UDim2.fromOffset(14, 14), UDim2.new(0, 8, 0, 4), 4)
	table.insert(self.Shines, shine)
	local name = Util.Label({ Text = tab.Name, FontFace = Theme.Fonts.Medium, TextSize = 12, Size = UDim2.new(1, -60, 0, 14), Position = UDim2.fromOffset(30, 4), TextTruncate = Enum.TextTruncate.AtEnd, Parent = row })
	Theme.Paint(name, { TextColor3 = "TextMute" })
	local pct = Util.Label({ Text = "", FontFace = Theme.Fonts.Mono, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, -8, 0, 14), Position = UDim2.fromOffset(0, 4), Parent = row })
	Theme.Paint(pct, { TextColor3 = "TextMute" })
	local track = Util.New("Frame", { Size = UDim2.new(1, -38, 0, 2), Position = UDim2.fromOffset(30, 22), BorderSizePixel = 0, Parent = row })
	Util.Round(track)
	Theme.Paint(track, { BackgroundColor3 = "Surface3" })
	local fill = Util.New("Frame", { Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, Parent = track })
	Util.Round(fill)
	Theme.Paint(fill, { BackgroundColor3 = "Accent" })
	-- spinner: a ring with a gradient gap
	local spinner = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(12, 12), Position = UDim2.fromOffset(9, 5), Visible = false, Parent = row })
	Util.Round(spinner)
	local ring = Util.Stroke(spinner, nil, 1.5)
	Theme.Paint(ring, { Color = "Accent" })
	Util.Gradient(ring, nil, NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.7, 0.2), NumberSequenceKeypoint.new(1, 1) }))
	local check = Util.New("ImageLabel", { BackgroundTransparency = 1, Image = require("../Icons").Get("check") or "", Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(8, 4), Visible = false, Parent = row })
	Theme.Paint(check, { ImageColor3 = "Accent" })
	self.Rows[tab] = { Frame = row, Name = name, Pct = pct, Fill = fill, Spinner = spinner, Check = check, Ghost = iconGhost }
end

function Skeleton:Update(stage)
	local window = self.Window
	for tab, row in self.Rows do
		local total, done = tab._total, tab._done
		local p = total > 0 and done / total or (window._declaring and 0 or 1)
		Tween.Play(row.Fill, { Size = UDim2.fromScale(p, 1) }, 0.15)
		local building = window._buildingTab == tab
		local finished = total > 0 and done >= total
		row.Spinner.Visible = building and not finished
		row.Check.Visible = finished
		row.Ghost.Visible = not building and not finished
		row.Pct.Text = total > 0 and (done .. "/" .. total) or ""
		Theme.Paint(row.Name, { TextColor3 = (building or finished) and "Text" or "TextMute" })
	end
	local actual = window:GetLoadProgress()
	-- never go backwards even if new work is declared mid-load
	self.Display = math.max(self.Display, math.min(actual, window.State == "Ready" and 1 or 0.99))
	self.Percent.Text = math.floor(self.Display * 100 + 0.5) .. "%"
	Tween.Play(self.Fill, { Size = UDim2.fromScale(self.Display, 1) }, 0.2)
	if stage then
		self.Stage.Text = stage
	end
end

function Skeleton:Finish(callback)
	if self._finishing then
		return
	end
	self._finishing = true
	self.Display = 1
	self.Percent.Text = "100%"
	self.Stage.Text = Locale.T("Ready")
	Tween.Play(self.Fill, { Size = UDim2.fromScale(1, 1) }, 0.15)
	task.delay(Tween.Speed > 0 and 0.18 or 0, function()
		Tween.Play(self.Root, { GroupTransparency = 1 }, 0.35, Enum.EasingStyle.Sine)
		if callback then
			callback()
		end
		task.delay(0.4, function()
			self:Destroy()
		end)
	end)
end

function Skeleton:Destroy()
	if self.Conn then
		self.Conn:Disconnect()
		self.Conn = nil
	end
	if self.Root then
		self.Root:Destroy()
		self.Root = nil
	end
end

return Skeleton
