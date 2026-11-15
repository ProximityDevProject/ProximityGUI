--!nocheck
--[[
	Proximity · Window/Builtins
	Ready-made tabs, one line each:
	  Window:Home({ ... })          dashboard: profile, live session stats with
	                                sparklines, account, server
	  Window:SettingsTab({ ... })   theme, accent, glass, scale, backdrop, motion,
	                                menu key, language, widgets, anonymous mode,
	                                theme editor, unload
	  Window:ConfigTab({ ... })     save / load / delete / export / import,
	                                auto load, auto save, diff preview
	Settings are stored in settings.json, never inside configs.
]]

local Util = require("../Core/Util")
local Env = require("../Core/Env")
local Keys = require("../Core/Keys")
local Theme = require("../Theme")
local Tween = require("../Core/Tween")
local Locale = require("../Locale")
local Shared = require("../Shared")

local Players = Env.Service("Players")
local Stats = Env.Service("Stats")
local UIS = Env.Service("UserInputService")

return function(Window)
	local T = Locale.T

	-- ═══ Home ═════════════════════════════════════════════════════════════
	function Window:Home(options)
		options = options or {}
		local Lib = self.Library
		local tab = self:Tab({ Name = options.Name or "Home", Icon = options.Icon or "home", Description = options.Description, Order = -100 })
		tab.Button.LayoutOrder = -100
		self.HomeTab = tab
		self._homeButton.Visible = true
		self:SelectTab(tab)

		local identity = tab:FullSection({ Name = "" })
		local id = Lib:GetIdentity()
		identity:Card({
			Title = id.DisplayName,
			Subtitle = "@" .. id.Name .. (options.Status and ("  ·  " .. options.Status) or ""),
			Body = options.Welcome or ("Proximity " .. Lib.Version .. "  ·  " .. Env.ExecutorName()),
			Image = id.Avatar,
			Badge = options.Badge,
			Height = 72,
		})

		local P = Lib.Providers
		local session = tab:LeftSection({ Name = "Session", Icon = "activity" })
		session:StatGrid({
			Columns = 2,
			Items = {
				{ Name = "FPS", Value = P.FPS, Interval = 0.5, Sparkline = true, Accent = true },
				{ Name = "Ping", Value = P.Ping, Interval = 0.5, Sparkline = true },
				{ Name = "Session", Value = P.Session, Interval = 1 },
				{ Name = "Players", Value = P.Players, Interval = 2 },
				{ Name = "Device", Value = P.Device, Interval = 30 },
				{ Name = "Resolution", Value = P.Resolution, Interval = 5 },
			},
		})
		local account = tab:RightSection({ Name = "Account", Icon = "user" })
		account:StatGrid({
			Columns = 2,
			Items = {
				{ Name = "Account age", Value = P.AccountAge, Interval = 60 },
				{ Name = "User ID", Value = P.UserId, Interval = 60 },
				{ Name = "Executor", Value = P.Executor, Interval = 60 },
				{ Name = "Version", Value = function()
					return options.Version or Lib.Version
				end, Interval = 60 },
			},
		})
		local server = tab:RightSection({ Name = "Server", Icon = "server" })
		server:StatGrid({
			Columns = 2,
			Items = {
				{ Name = "Place", Value = P.PlaceId, Interval = 60 },
				{ Name = "Uptime", Value = P.ServerUptime, Interval = 1 },
			},
		})
		server:Stat({ Name = "Job ID", Value = P.JobId, Interval = 60 })
		return tab
	end
	Window.Dashboard = Window.Home

	-- ═══ Settings ═════════════════════════════════════════════════════════
	function Window:SettingsTab(options)
		options = options or {}
		local Lib = self.Library
		local window = self
		local tab = self:Tab({ Name = options.Name or T("Settings"), Icon = options.Icon or "settings", Description = options.Description, Order = 1000 })
		tab.Button.LayoutOrder = 1000
		self.SettingsTabRef = tab
		self._settingsButton.Visible = true

		-- Appearance
		local look = tab:LeftSection({ Name = T("Appearance"), Icon = "palette" })
		look:Dropdown({
			Name = T("Theme"),
			Values = Theme.List(),
			Default = Lib:GetSetting("Theme", Theme.Current),
			Save = false,
			Callback = function(v)
				if v then
					Lib:SetTheme(v)
				end
			end,
		})
		look:ColorPicker({
			Name = T("Accent"),
			Default = Util.FromHex(Lib:GetSetting("Accent", "")) or Theme.Get("Accent"),
			Save = false,
			Presets = {
				Color3.fromRGB(255, 255, 255),
				Color3.fromRGB(226, 236, 255),
				Color3.fromRGB(255, 244, 230),
				Color3.fromRGB(214, 214, 220),
				Color3.fromRGB(205, 222, 240),
				Color3.fromRGB(200, 255, 230),
				Color3.fromRGB(255, 220, 235),
				Color3.fromRGB(230, 220, 255),
			},
			Callback = function(c)
				Lib:SetAccent(c)
			end,
		})
		look:Slider({
			Name = T("Transparency"),
			Min = 0,
			Max = 40,
			Default = Lib:GetSetting("Glass", 0),
			Suffix = "%",
			Save = false,
			Callback = function(v)
				Lib:SetSetting("Glass", v)
				window:SetTransparency(v / 100)
			end,
		})
		look:Dropdown({
			Name = T("Scale"),
			Values = { "Auto", "75%", "90%", "100%", "110%", "125%", "150%" },
			Default = (function()
				local s = Lib:GetSetting("Scale", "Auto")
				return s == "Auto" and "Auto" or (math.floor(tonumber(s) * 100 + 0.5) .. "%")
			end)(),
			Save = false,
			Callback = function(v)
				if not v then
					return
				end
				local value = v == "Auto" and "Auto" or tonumber(string.match(v, "%d+")) / 100
				Lib:SetSetting("Scale", value)
				window:SetScale(value)
			end,
		})
		look:Dropdown({
			Name = "Backdrop",
			Values = { "Stars", "Grid", "Dots", "None" },
			Default = Lib:GetSetting("Backdrop", "Stars"),
			Save = false,
			Callback = function(v)
				Lib:SetSetting("Backdrop", v)
				window:SetBackdrop(v or "None")
			end,
		})
		look:Toggle({
			Name = T("EclipseRim"),
			Default = Lib:GetSetting("Rim", true),
			Save = false,
			Callback = function(v)
				Lib:SetSetting("Rim", v)
				window:SetRim(v)
			end,
		})
		look:Toggle({
			Name = T("ReducedMotion"),
			Default = Lib:GetSetting("ReducedMotion", false),
			Save = false,
			Callback = function(v)
				Lib:SetSetting("ReducedMotion", v)
				Tween.Speed = v and 0 or 1
			end,
		})

		-- Interface
		local ui = tab:LeftSection({ Name = T("Interface"), Icon = "layout-dashboard" })
		ui:Keybind({
			Name = T("MenuKey"),
			Default = window.Keybind,
			Modes = { "Press" },
			Mode = "Press",
			ShowInList = false,
			Save = false,
			Callback = function(key)
				Lib:SetSetting("MenuKey", key)
				window:SetKeybind(key)
			end,
		})
		local langs, flags = {}, { en = "🇬🇧", ru = "🇷🇺", de = "🇩🇪", es = "🇪🇸", fr = "🇫🇷", uk = "🇺🇦", pt = "🇧🇷", tr = "🇹🇷" }
		local codeByName = {}
		for _, code in Locale.List() do
			local name = Locale.Names[code] or code
			codeByName[name] = code
			table.insert(langs, name)
		end
		local prefixes = {}
		for name, code in codeByName do
			prefixes[name] = flags[code]
		end
		ui:Dropdown({
			Name = T("Language"),
			Values = langs,
			Prefixes = prefixes,
			Default = Locale.Names[Locale.Current],
			Save = false,
			Callback = function(v)
				if v and codeByName[v] then
					Lib:SetLanguage(codeByName[v])
				end
			end,
		})
		ui:Toggle({
			Name = T("Watermark"),
			Default = Lib:GetSetting("Watermark", true),
			Save = false,
			Callback = function(v)
				Lib:SetSetting("Watermark", v)
				if Lib.WatermarkWidget then
					Lib.WatermarkWidget:SetVisible(v)
				end
			end,
		})
		ui:Toggle({
			Name = T("KeybindList"),
			Default = Lib:GetSetting("KeybindList", true),
			Save = false,
			Callback = function(v)
				Lib:SetSetting("KeybindList", v)
				if Lib.KeybindListWidget then
					Lib.KeybindListWidget:SetVisible(v)
				end
			end,
		})
		ui:Dropdown({
			Name = T("NotifyPosition"),
			Values = { "TopRight", "BottomRight", "TopLeft", "BottomLeft", "TopCenter" },
			Default = Lib:GetSetting("NotifyPosition", "BottomRight"),
			Save = false,
			Callback = function(v)
				if v then
					Lib:SetSetting("NotifyPosition", v)
					Lib:SetNotifyPosition(v)
				end
			end,
		})
		local anon = ui:Toggle({
			Name = "Anonymous mode",
			Description = "Hide name, avatar and IDs on screen",
			Default = Lib:GetSetting("Anonymous", false),
			Save = false,
			Callback = function(v)
				Lib:SetSetting("Anonymous", v)
				Lib:SetAnonymous(v)
			end,
		})
		anon:Options(function(o)
			o:Input({
				Name = "Shown name",
				Default = Lib:GetSetting("AnonymousName", "Hidden"),
				Finished = true,
				Save = false,
				Callback = function(v)
					Lib:SetSetting("AnonymousName", v)
					Lib:SetAnonymous(Lib.Anonymous, { Name = v })
				end,
			})
		end)

		-- Theme editor
		local editor = tab:RightSection({ Name = "Theme editor", Icon = "paintbrush", Collapsible = true, Collapsed = true })
		for _, token in { "Bg", "Surface", "Surface2", "Stroke", "StrokeHi", "Text", "TextDim", "TextMute", "Accent", "AccentInk", "Risky" } do
			editor:ColorPicker({
				Name = token,
				Default = Theme.Get(token),
				Save = false,
				Callback = function(c)
					Theme.SetToken(token, c, false)
				end,
			})
		end
		editor:ButtonGroup({
			{ Name = T("Export"), Callback = function()
				Env.Clipboard(Theme.Export())
				Lib:Notify({ Content = T("Copied"), Type = "success", Duration = 2 })
			end },
			{ Name = T("Import"), Callback = function()
				task.spawn(function()
					local text = window:Prompt({ Title = T("Import"), Placeholder = "{ … }" })
					if text and Theme.Import(text) then
						Lib:Notify({ Content = T("Imported"), Type = "success", Duration = 2 })
					end
				end)
			end },
		})

		-- Danger zone
		local misc = tab:RightSection({ Name = "Proximity", Icon = "disc" })
		misc:Paragraph({ Title = "Proximity " .. Lib.Version, Content = "Ctrl+K — search  ·  Ctrl+Z / Ctrl+Y — undo / redo  ·  Ctrl+S — save config  ·  RMB on any row — reset, copy, paste, favorite" })
		if options.Tour then
			misc:Button({ Name = "Replay tour", Icon = "map", Callback = function()
				window:Tour(options.Tour, { Force = true })
			end })
		end
		misc:Button({
			Name = T("Unload"),
			Style = "Danger",
			Icon = "power",
			Confirm = T("UnloadConfirm"),
			Callback = function()
				Lib:Unload()
			end,
		})
		if options.Configs ~= false then
			self:ConfigTab({ Tab = tab })
		end
		return tab
	end

	-- ═══ Configs ══════════════════════════════════════════════════════════
	function Window:ConfigTab(options)
		options = options or {}
		local Lib = self.Library
		local window = self
		local tab = options.Tab or self:Tab({ Name = options.Name or T("Configs"), Icon = options.Icon or "folder", Order = 999 })
		local section = tab:RightSection({ Name = T("Configs"), Icon = "folder" })
		local nameInput = section:Input({ Name = T("ConfigName"), Placeholder = "legit", Save = false, Finished = true })
		local list
		list = section:Dropdown({
			Name = T("ConfigList"),
			Values = Lib:ListConfigs(),
			Save = false,
			Deletable = true,
			Search = true,
			OnDelete = function(name)
				Lib:DeleteConfig(name)
				Lib:Notify({ Title = T("Deleted"), Content = name, Type = "info", Duration = 2 })
			end,
			Callback = function(v)
				if v then
					nameInput:Set(v, true)
				end
			end,
		})
		local function selected()
			local n = Util.Trim(nameInput:Get() or "")
			if n == "" then
				n = list:Get()
			end
			return n
		end
		Lib.ConfigsChanged:Connect(function()
			list:SetValues(Lib:ListConfigs(), true)
		end)
		section:ButtonGroup({
			{ Name = T("Save"), Style = "Primary", Callback = function()
				local name = selected()
				if not name or name == "" then
					return
				end
				task.spawn(function()
					if Lib:ConfigExists(name) and not window:Confirm({ Title = T("Save"), Content = "Overwrite “" .. name .. "”?" }) then
						return
					end
					local ok = Lib:SaveConfig(name)
					if ok then
						Lib.CurrentConfig = Util.SafeName(name)
						Lib:_setDirty(false)
						list:Set(Util.SafeName(name), true)
						Lib:Notify({ Title = T("Saved"), Content = name, Type = "success", Duration = 2.5 })
					end
				end)
			end },
			{ Name = T("Load"), Callback = function()
				local name = selected()
				if not name or not Lib:ConfigExists(name) then
					return
				end
				task.spawn(function()
					local diff = Lib:DiffConfig(name)
					if #diff > 0 then
						local lines = {}
						for i = 1, math.min(#diff, 8) do
							table.insert(lines, "• " .. diff[i].Flag)
						end
						if #diff > 8 then
							table.insert(lines, "… +" .. (#diff - 8))
						end
						if not window:Confirm({ Title = T("Load") .. " “" .. name .. "”", Content = #diff .. " changes:\n" .. table.concat(lines, "\n") }) then
							return
						end
					end
					Lib:LoadConfig(name)
					Lib.CurrentConfig = Util.SafeName(name)
					Lib:_setDirty(false)
					Lib:Notify({ Title = T("Loaded"), Content = name, Type = "success", Duration = 2.5 })
				end)
			end },
		})
		section:ButtonGroup({
			{ Name = T("Export"), Callback = function()
				local text = Lib:ExportConfig(list:Get())
				if text then
					Env.Clipboard(text)
					Lib:Notify({ Content = T("Copied"), Type = "success", Duration = 2 })
				end
			end },
			{ Name = T("Import"), Callback = function()
				task.spawn(function()
					local text = window:Prompt({ Title = T("Import"), Placeholder = "PRX1.…" })
					if not text then
						return
					end
					local ok = Lib:ImportConfig(text, selected() ~= "" and selected() or nil)
					Lib:Notify({ Content = ok and T("Imported") or T("InvalidConfig"), Type = ok and "success" or "error", Duration = 3 })
				end)
			end },
		})
		section:Toggle({
			Name = T("AutoLoad"),
			Default = Lib:GetAutoLoad() ~= nil,
			Save = false,
			Callback = function(v)
				Lib:SetAutoLoad(v and (list:Get() or Lib.CurrentConfig) or nil)
			end,
		})
		section:Toggle({
			Name = T("AutoSave"),
			Default = Lib:GetAutoSave() ~= nil,
			Save = false,
			Callback = function(v)
				Lib:SetAutoSave(v and (list:Get() or Lib.CurrentConfig) or nil)
			end,
		})
		section:Label({ Text = "Folder: " .. Lib.Folder .. "/configs", Color = "TextMute" })
		return tab
	end
end
