# Proximity UI · API reference

<sub><b>English</b> · <a href="API.ru.md">Русский</a></sub>

> Every option is optional unless marked **required**. Every element also has the [shared element API](#shared-element-api).
> Names in `Code` are the canonical spelling; aliases are listed in [MIGRATION.md](MIGRATION.md).

- [Library](#library)
- [Window](#window)
- [Loading skeleton](#loading-skeleton)
- [Tabs, pages, sections](#tabs-pages-sections)
- [Shared element API](#shared-element-api)
- [Elements](#elements)
- [Dialogs, palette, tour](#dialogs-palette-tour)
- [Built-in tabs](#built-in-tabs)
- [Configs](#configs)
- [Themes](#themes)
- [Notifications and widgets](#notifications-and-widgets)
- [Locale](#locale)
- [Icons](#icons)
- [Script lifecycle](#script-lifecycle)
- [More elements](#more-elements)
- [Sounds, media, screen](#sounds-media-screen)
- [Tool widgets](#tool-widgets)
- [Looks and accessibility](#looks-and-accessibility)
- [Right-click menu and quick binds](#right-click-menu-and-quick-binds)
- [Events](#events)
- [Extending](#extending)
- [Toolkit](#toolkit)

---

## Library

```lua
local Proximity = loadstring(game:HttpGet("https://proximitydevproject.github.io/ProximityGUI/Proximity.lua"))()
```

| Member | Description |
|---|---|
| `Proximity:Window(options)` | Create a window. See [Window](#window). Aliases: `CreateWindow`, `Proximity.new(options)` |
| `Proximity.Version` · `:GetVersion()` | `"1.3.0"` |
| `Proximity.Flags` | `flag → live value` of every flagged element |
| `Proximity.Elements` | `flag → element` |
| `:GetFlag(flag)` · `:SetFlag(flag, value)` · `:GetElement(flag)` | read / write by flag |
| `:OnFlag(flag, fn(new, old))` | listen to one flag, returns a connection |
| `.FlagChanged` | signal `(flag, new, old)` for every flag |
| `:Undo()` · `:Redo()` · `:ClearHistory()` | change history (user changes only, 100 steps) |
| `:IsFavorite(el)` · `:ToggleFavorite(el)` · `:GetFavorites()` · `.FavoritesChanged` | favorites |
| `:GetIdentity()` | `{ Name, DisplayName, UserId, Avatar, Anonymous? }`, respects anonymous mode |
| `:SetAnonymous(on, { Name })` · `.IdentityChanged` | hide name, avatar and IDs everywhere |
| `Proximity.Providers.*` | `FPS, Ping, Session, Players, Device, Resolution, AccountAge, UserId, Executor, PlaceId, JobId, ServerUptime, GameName` - functions returning display values |
| `:SetTheme(name)` · `:GetTheme()` · `:GetThemes()` · `:AddTheme(name, tokens)` · `:SetAccent(color)` · `:OnThemeChanged(fn)` | themes |
| `:SetLanguage(code)` · `:AddLanguage(code, strings, displayName)` · `:T(key, ...)` | locale |
| `:SetReducedMotion(on)` | disable animations |
| `:GetIcon(name)` · `:RegisterIcon(name, source)` | icons |
| `:RegisterElement(name, class)` | add your own element type |
| `:Notify(options)` · `:Success` · `:Error` · `:Warn` · `:Info` · `:ClearNotifications()` · `:SetNotifyPosition(pos)` · `.NotificationHistory` | notifications |
| `:Watermark(options)` · `:KeybindList(options)` · `:Dock(frame, key, default)` | widgets |
| `:QuickSave(window?)` | save to the current config (asks for a name the first time) |
| `:OnUnload(fn)` · `.Unloading` · `:Unload()` · `.Unloaded` | lifecycle. Unload switches every toggle off first so your callbacks clean up |
| `:SetDebug(on)` | full stack traces for callback errors, duplicate flag warnings |
| `.WindowReady` · `.KeybindsChanged` · `.DirtyChanged` | signals |

## Window

```lua
local Window = Proximity:Window({
	Title = "Proximity",               -- sidebar title, also the config key for window state
	Subtitle = "v1.0",
	Logo = nil,                        -- nil = Proximity planet, false = vector planet only, or icon name / rbxassetid / image URL
	Decoration = true,                 -- faint planet in the bottom-right corner
	Keybind = Enum.KeyCode.RightShift, -- KeyCode, "RightShift", "MB3"…
	Size = Vector2.new(740, 500),      -- or UDim2.fromOffset; mobile default 600×380
	MinSize = Vector2.new(560, 360),
	Scale = "Auto",                    -- or 0.5 - 2
	Folder = "Proximity",              -- where configs and settings live
	Theme = "Eclipse", Accent = Color3.new(1, 1, 1),
	Language = "en",
	Loading = { Enabled = true, MinTime = 0.6, Skip = true, Budget = 0.004 },
	AutoReady = true,                  -- reveal when declarations go quiet
	AutoLoad = true,                   -- apply the auto-load config before reveal
	Watermark = true, KeybindList = true,
	Profile = true, Status = "Premium",
	ConfigButton = true,               -- config chip in the header
	Animation = "Planet",              -- open / hide motion: Rise, Zoom, Drop, Slide, Swing, Wipe, Unfold, Scan, Glitch, Fade, None
	ToggleButton = nil,                -- default: floating bubble on phones only, none on PC; "Bubble", "Topbar" or false
	Resizable = true, Draggable = true,
	UnlockMouse = true,                -- frees the cursor in first-person games while open
	Backdrop = "Stars",                -- "Stars" | "Grid" | "Dots" | "Nebula" | "Aurora" | "Comets" | "None"
	HiddenHint = true,                 -- one-time "press X to show" toast
	SidebarWidth = 196,
	Navigation = nil,                  -- "Sidebar", "Rail" or "Bottom" (phones default to "Bottom")
})
```

| Method | Description |
|---|---|
| `:Tab(options)` | new sidebar tab (`Name`, `Icon`, `Description`, `Badge`, `Visible`, `Order`). Aliases `AddTab`, `DrawTab`, `CreateTab`, `Page` |
| `:Category(name)` | label between tabs. Aliases `Divider`, `Group`, `DrawCategory`, `AddTabDivider` |
| `:SelectTab(tab \| name \| index)` · `:GetTab(name)` · `:GetTabs()` · `:Back()` | navigation |
| `:Open()` · `:Close()` · `:Toggle()` · `:SetOpen(bool)` · `:IsOpen()` | visibility (`Show`, `Hide`, `Minimize`) |
| `:SetScale(n \| "Auto")` · `:GetScale()` | UI scale |
| `:SetSize(v2)` · `:GetSize()` · `:SetPosition(udim2 \| v2)` · `:Center()` | geometry (size and position are remembered) |
| `:SetTitle(text)` · `:SetSubtitle(text)` | header text |
| `:SetKeybind(key)` · `:GetKeybind()` | menu key (`SetMenuKey`) |
| `:SetTransparency(0 - 0.4)` | glass |
| `:SetRim(bool)` | animated eclipse rim |
| `:SetBackdrop(name)` | background pattern |
| `:SetDecoration(bool)` | planet in the corner |
| `:SetDraggable(bool)` | |
| `:Command({ Name, Icon, Hint, Callback })` | action in the `Ctrl+K` palette |
| `:OpenSearch(query?)` | open the palette |
| `:Dialog` · `:Confirm` · `:Prompt` · `:Tour` | see [Dialogs](#dialogs-palette-tour) |
| `:Home` · `:SettingsTab` · `:ConfigTab` · `:Favorites` | see [Built-in tabs](#built-in-tabs) |
| `:Notify(options)` | shortcut to the library |
| `:GetElements()` · `:Find(nameOrFlag)` | lookup |
| `:Destroy()` | remove this window |
| Signals | `.Ready`, `.Opened`, `.Closed`, `.TabChanged(tab, old)`, `.PageChanged(page, old)` |

The window resizes from any of its four corners.

## Loading skeleton

The window is created as a skeleton immediately. Elements you declare are stored instantly and built by a scheduler that spends at most `Loading.Budget` seconds per frame. The skeleton shows:

- every tab in the sidebar with its own progress bar, a spinner while it builds and a check when done
- a large percentage, the current stage (`Building · Combat 34/120`, `Applying config · legit`, your step names) and elapsed time
- shimmering placeholder cards in the shape of real sections
- a **Show now** button after 2.5 s (disable with `Loading.Skip = false`)

The window becomes **Ready** when the queue is empty, every task is done, declarations have been quiet for 0.2 s (or you called `:SetReady()`), and the auto-load config is applied. The skeleton never flashes: it stays at least `Loading.MinTime` seconds.

Instead of the skeleton you can pick a loading screen: `Loading = { Style = "Planet" | "Orbit" | "Eclipse" | "Constellation" | "Terminal" | "Skeleton" | "None" }`. Players can change it in Settings.

| Method | Description |
|---|---|
| `:Task(name, weight = 10)` | returns `{ :Progress(0-1), :SetText(text), :Done(), :Fail(reason) }` |
| `:Step(name, fn(task), weight?)` | runs `fn` in its own thread as a task, finishes it automatically |
| `:SetReady()` | explicit "I'm done declaring" (use with `AutoReady = false`). Aliases `Finish`, `Init` |
| `:IsReady()` · `:OnReady(fn)` · `:WaitUntilReady(timeout?)` | lifecycle |
| `:GetLoadProgress()` | 0-1 |

## Tabs, pages, sections

```lua
local Combat = Window:Tab({ Name = "Combat", Icon = "crosshair", Description = "Aim and weapons", Badge = "NEW" })
local Players = Visuals:SubTab({ Name = "Players", Icon = "user" })          -- pill under the title
local Tuning  = Combat:SubPage({ Name = "Tuning", Hidden = true })           -- reached via Navigate, has a back arrow

local Aim = Combat:Section({
	Name = "Aim", Icon = "target",
	Side = "Left",            -- "Left" | "Right" | "Full"
	Toggle = true, Flag = "aim.enabled", Enabled = true, Callback = fn,   -- checkbox in the header
	Collapsible = false, Collapsed = false,
})
local Silent, Lock = Aim:Tabs({ "Silent", "Lock" }, { Flag = "aim.mode", Icons = { "eye-off", "lock" }, Default = "Silent" })
```

**Tab** · `:Section` (`AddSection`, `DrawSection`), `:LeftSection`, `:RightSection`, `:FullSection`, `:SubTab` (`SubPage`, `AddSubTab`, `Page`), `:GetPage(name)`, `:Select()`, `:IsSelected()`, `:SetName`, `:SetIcon`, `:SetDescription`, `:SetBadge(text?)`, `:SetVisible`, `:GetSections()`, `:GetElements()`, `:Destroy()`, `.Selected`.

**Page** · same section helpers, `:Select()`, `:IsSelected()`, `:ScrollTo(gui)`, `:GetSections()`, `.Selected`. Pages switch to one column automatically on narrow windows (`Columns = 1` forces it).

**Section** · every element constructor (below, each also as `AddX` and `CreateX`), `:Tabs(names, options)`, `:SelectTab(nameOrIndex)`, `:GetTab()`, `:SetEnabled(bool)`, `:IsEnabled()`, `:IsDisabled()`, `:SetCollapsed(bool)`, `:Collapse()`, `:Expand()`, `:SetName`, `:SetVisible`, `:GetElements()`, `:AllElements()`, `:Find(nameOrFlag)`, `:Clear()`, `:Destroy()`, `:Custom(name, options)`, `.Changed`.

## Shared element API

Every element (except pure layout ones where noted) supports:

| Member | Description |
|---|---|
| `Name`, `Icon`, `Description`, `Tooltip`, `Flag`, `Default`, `Callback`, `Risky`, `Badge`, `Visible`, `Locked` (`true` or reason string), `Save = false`, `New = true \| days`, `Sound` | common options. `Icon` puts an icon before the title of any row. `Badge` takes text or a kind: `"risky"`, `"beta"`, `"vip"`, `"new"`. `New` shows a NEW badge that goes away once seen (7 days by default). `Sound` on a toggle plays a hit sound when it turns on |
| `:Get()` · `:Set(value, silent?)` · `:Reset()` · `:GetDefault()` · `:SetDefault(v)` · `:IsDefault()` | value (`GetValue`, `SetValue`) |
| `.Changed` · `:OnChanged(fn(new, old))` | fires on every change, also silent ones |
| `:SetCallback(fn)` · `:AddCallback(fn)` · `:Fire()` | callbacks run only for non-silent changes; errors never break the UI |
| `:SetName` · `:GetName` · `:SetDescription` · `:SetTooltip` · `:SetBadge(text?)` · `:SetRisky(bool)` | text and decoration |
| `:SetVisible` · `:Show` · `:Hide` · `:IsVisible` | visibility |
| `:SetLocked(bool, reason?)` · `:Lock(reason?)` · `:Unlock()` · `:IsLocked()` | dimmed, input blocked, reason in tooltip |
| `:DependsOn(flagOrElement, predicate?, "Hide" \| "Lock")` | conditional visibility / lock |
| `:Keybind(options)` · `:ColorPicker(options)` | attach a compact keybind chip / color swatch to the row |
| `:Options(fn \| nil)` | gear button that opens a floating panel; returns that panel (a Section). Aliases `Settings`, `AddOption` |
| `:Highlight()` · `:Focus()` · `:GetPath()` | navigation (`Focus` opens the tab, scrolls and flashes the row) |
| `:Copy()` · `:Paste(text?)` · `:OpenContextMenu()` | clipboard (also from right click) |
| `:SetQuickBind(key \| nil)` · `:GetQuickBind()` | quick bind, see [right click](#right-click-menu-and-quick-binds) |
| `:Destroy()` · `.Destroyed` | removal |

## Elements

### Toggle
`Section:Toggle({ Name, Default = false, Style = "Switch" | "Checkbox", Risky, Confirm = false | "text", Callback(bool) })`
Methods `:Toggle()`, `:On()`, `:Off()`, `:IsOn()`, `:SetStyle()`. `Section:Checkbox{}` is a toggle with `Style = "Checkbox"`. Risky toggles ask once before turning on.

### Button
`Section:Button({ Name, Callback, Icon, Hint, Style = "Secondary" | "Primary" | "Ghost" | "Danger", Confirm = false | "text", DoubleClick = false, Cooldown = 0, Hold = false | seconds })`
`Hold = 1` makes a hold-to-confirm button that fills while pressed. Methods `:Press()` (`Click`), `:SetStyle`, `:SetIcon`, `:SetHint`, `:SetCooldown`. A keybind attached to a button presses it.

### ButtonGroup
`Section:ButtonGroup({ { Name, Callback, Style }, ... })` - buttons side by side.

### Slider · RangeSlider · TextSlider
```lua
Section:Slider({ Name, Min = 0, Max = 100, Default, Step = 1, Suffix, Prefix, Format = fn(v), Icon, Presets = { Low = 10, High = 90 },
                 Danger = 400, Marks = { 0, 50, 100 }, Throttle = 0.05 })
Section:RangeSlider({ Name, Min, Max, Default = { 10, 250 } })        -- value { Min =, Max = }
Section:TextSlider({ Name, Labels = { "Slow", "Medium", "Fast" }, Default = "Medium" })   -- callback(label, index)
```
Methods `:SetMin`, `:SetMax`, `:SetLimits(min, max)` (`SetRange`), `:SetStep`, `:Increment(n?)`, `:Decrement(n?)`, `:GetPercent()`, `:GetText()`. Double click the value to type; arrow keys nudge while hovered (Shift ×10). Hold Shift while dragging for fine steps. `Danger` paints the fill red past that value, `Marks` draws ticks, `Throttle` limits how often the callback runs while dragging (the last value always arrives). `Decimals = n` works as `Step = 10^-n`.

### Dropdown · MultiDropdown · PlayerDropdown
```lua
Section:Dropdown({ Name, Values, Default, Multi = false, Max, Min = 0, Search = auto, Placeholder,
                   AllowNone = true, Deletable = false, OnDelete = fn(value) → false cancels,
                   Icons = { value = icon }, Prefixes = { value = "🇷🇺" }, Display = fn(value) → text })
Section:MultiDropdown({ ... })                  -- Multi = true
Section:PlayerDropdown({ Name, Multi, ExcludeSelf = true })   -- kept in sync with the server, :GetPlayer()
```
Methods `:SetValues(list, keep?)` (`Refresh`), `:AddValue` (`Add`), `:RemoveValue` (`Remove`), `:Clear()`, `:Open()`, `:Close()`, `:IsOpen()`, `:Select(v)`, `:Deselect(v)`, `:IsSelected(v)`, `:GetValues()`, `:GetText()`. Search appears automatically above 7 values (fuzzy).

### Input
`Section:Input({ Name, Default, Placeholder, Numeric = false, Min, Max, MaxLength, Finished = false, ClearOnFocus, Wide = false, Validate = fn(text) → ok, message })`
Methods `:Focus()`, `:Blur()`, `:Clear()`, `:SetPlaceholder()`. Aliases `TextBox`, `Textbox`.

### Keybind
`Section:Keybind({ Name, Default = "E" | Enum.KeyCode | "MB2", Mode = "Toggle" | "Hold" | "Always" | "Release" | "Press", Modes, Blacklist, ShowInList = true, OnPress, OnRelease, OnToggle(active) })`
Methods `:SetKey`, `:GetKey`, `:GetKeyCode`, `:SetMode`, `:GetMode`, `:IsActive`, `:Listen()`, `:Clear()`, `:Press()`, `:OpenModeMenu()`, signal `.StateChanged(active)`. Click the chip to rebind (Backspace clears, Esc cancels), right click to change the mode. Attached to a toggle, the key drives the toggle according to the mode.

### ColorPicker
`Section:ColorPicker({ Name, Default = Color3 | "#hex" | {r,g,b}, Alpha = nil | 0-1, Presets = { Color3 … } })` - callback `(color, alpha)`.
Methods `:SetColor`, `:GetColor`, `:SetAlpha`, `:GetAlpha`, `:GetHex`, `:SetHex`, `:Open`, `:Close`, `:SetRainbow(on, speed?)`. The popup has saturation/value, hue, alpha, hex, old/new compare (click old to revert), presets and recent colors.

### Label · Paragraph · Divider · Spacer
`Section:Label("text" | { Text, Color = token | Color3, Icon, Center, RichText })` - hosts links like any row. `:SetColor()`.
`Section:Paragraph({ Title, Content, RichText = true })` - `:SetContent` (`Set`), `:SetTitle`.
`Section:Divider("Advanced"?)` (`Separator`) · `Section:Spacer(8)`.

### Navigate
`Section:Navigate({ Name, Page = subPage, Value = "right text", Icon, Callback })` - row with a chevron; opens a hidden sub page (with back arrow) and/or runs the callback. `:SetValue(text)`.

### Progress · Stat · StatGrid · Graph
```lua
Section:Progress({ Name, Value = 0, Max = 100, Suffix = "%" })                 -- :Set(v), :SetMax(n)
Section:Stat({ Name, Value = value | fn, Interval = 1, Icon, Suffix })
Section:StatGrid({ Columns = 3, Items = { { Name, Value = fn, Interval, Sparkline = true, Accent = true } } })   -- :SetItem(key, value)
Section:Graph({ Name, Source = fn, Interval = 0.5, Points = 40, Height = 64, Min, MaxValue, Suffix })           -- :Push(v), :SetData(list), :Clear()
```

### Table
```lua
Section:Table({
	Height = 240, RowHeight = 30, Search = true,
	Columns = { { Key = "name", Name = "Map", Width = 0.5, Align = "Left" | "Center" | "Right" } },
	Rows = { ... }, SortBy = "players", Descending = true, Filter = fn(row) → bool,
	Actions = { { Icon = "log-in", Tooltip = "Join", Callback = fn(row) } },
	OnSelect = fn(row),
})
```
Methods `:SetRows`, `:AddRow`, `:RemoveRow(index | row | fn)`, `:Clear`, `:GetRows`, `:GetSelected`, `:SortBy(key, desc)`, `:SetFilter(fn)`, `:SetQuery(text)`, `:SetLoading(bool)` (shimmering placeholder rows). Click a header to sort. Only visible rows exist (pooled), so thousands of rows stay smooth. Aliases `Catalog`, `List`.

### Card · Image · Console · Code
```lua
Section:Card({ Title, Subtitle, Body, Image, Model = instance, Progress = { 3, 13 }, Badge, Height = 96, Callback })   -- 3D model via ViewportFrame
Section:Image({ Image, Height = 120, ScaleType, Caption })
Section:Console({ Name, Height = 160, MaxLines = 200 })   -- :Log(text, level), :Info, :Warn, :Error, :Success, :Clear, :GetLines
Section:Code({ Title, Code })                             -- monospaced block with a copy button
```

## Dialogs, palette, tour

```lua
local index = Window:Dialog({ Title, Content, Buttons = { { Text = "Cancel" }, { Text = "Delete", Style = "Danger", Callback = fn } }, Dismissable = true })
local ok = Window:Confirm({ Title, Content, Danger = true, ConfirmText, CancelText })   -- yields boolean
local text = Window:Prompt({ Title, Content, Placeholder, Default })                   -- yields string | nil
Window:OpenSearch("aim")
Window:Tour({ { Target = element | gui | "search" | "config", Title, Text } }, { Key = "intro-v1", Force = false })
```
Dialogs yield, so call them from a callback or `task.spawn`. A tour with a `Key` shows once.

## Built-in tabs

| Method | Contents |
|---|---|
| `Window:Home({ Name, Icon, Status, Welcome, Badge, Version })` | profile card, live session tiles with FPS/ping sparklines, account, server. Adds a home button to the header |
| `Window:SettingsTab({ Name, Icon, Configs = true, Tour })` | theme, accent, glass, scale, backdrop, rim, reduced motion, menu key, language (with flags), watermark, keybind list, notification position, anonymous mode, theme editor (export / import), sounds, screen, server, output, widgets, shortcuts, unload. Adds a settings button to the header |
| `Window:ConfigTab({ Name, Icon, Tab })` | name, list (with delete), save (asks before overwriting), load (shows the diff first), export / import as JSON and Lua, compare, a profile for this game, auto load, auto save |
| `Window:Favorites({ Name, Icon })` | shortcuts to starred features (right click → ☆) |

Settings are stored in `<Folder>/settings.json` and never mixed into configs.

## Configs

```lua
Proximity:SaveConfig("legit", { Author = "me", Note = "rage off" })
Proximity:LoadConfig("legit")
Proximity:DeleteConfig("legit")
Proximity:RenameConfig("legit", "legit-v2")
Proximity:DuplicateConfig("legit", "legit-copy")
Proximity:ListConfigs()                 -- { "legit", ... }
Proximity:ConfigExists("legit")
Proximity:GetConfigInfo("legit")        -- { Name, Created, Updated, Author, Note, Version, Schema, Count }
Proximity:DiffConfig("legit")           -- { { Flag, From, To } } what would change
Proximity:ExportConfig("legit" | nil)   -- "PRX1.<base64>.<checksum>" (nil = current state)
Proximity:ImportConfig(text, saveAs?)   -- apply now, or save under a name
Proximity:SetAutoLoad("legit" | nil) · Proximity:GetAutoLoad()
Proximity:SetAutoSave("legit" | nil) · Proximity:GetAutoSave()
Proximity:GetState() · Proximity:ApplyState(state, { Silent, Budget, OnProgress })
Proximity:SetFolder("MyHub")
Proximity:GetSetting(key, default) · Proximity:SetSetting(key, value)
Proximity.SchemaVersion = 2
Proximity.Migrations[1] = function(flags) flags["new.name"] = flags["old.name"]; return flags end
```
Signals: `ConfigsChanged`, `ConfigLoaded(name, applied, total)`, `ConfigSaved(name)`. Broken files are kept as `.broken` instead of being lost; loading applies values over several frames; auto save waits 1.5 s after the last change and is armed only after the window is ready. Without file APIs everything works in memory.

## Themes

Presets: `Eclipse` (default), `OLED`, `Graphite`, `Moon`, `Ash`, `Steel`, `Paper`, `Midnight`, `Graphite Blue`, `Mono Glass`.
Tokens: `Bg, Bg2, Surface, Surface2, Surface3, Elevated, Stroke, StrokeHi, Text, TextDim, TextMute, Accent, AccentInk, Risky, Success, Warning, Error, Info, Shadow`.

```lua
Proximity:SetTheme("Moon")
Proximity:SetAccent(Color3.fromRGB(255, 244, 230))
Proximity:AddTheme("Paper Moon", { Accent = "#E8F0FF", Stroke = "#20242C" })
Proximity.Theme.SetToken("Risky", "#FF5A5A")
Proximity.Theme.Paint(myFrame, { BackgroundColor3 = "Surface", TextColor3 = "Text" })   -- your instances follow theme changes
print(Proximity.Theme.Export())   -- JSON, Theme.Import(json) to apply
```

## Notifications and widgets

```lua
local n = Proximity:Notify({ Title = "Saved", Content = "legit", Type = "success", Duration = 4,
	Actions = { { Text = "Undo", Callback = function() Proximity:Undo() end } }, Persistent = false })
n:SetContent("…") n:SetProgress(0.5) n:Extend(3) n:Close()
Proximity:SetNotifyPosition("TopRight")    -- TopRight, BottomRight, TopLeft, BottomLeft, TopCenter
```
Hovering a notification pauses its timer, and a swipe sideways dismisses it. At most five are shown; the last 50 are kept in `NotificationHistory`.

```lua
local wm = Proximity:Watermark({ Text = "Proximity", Items = { "FPS", "Ping", "Time", "Game", "Player" } })
wm:AddItem({ Text = function() return "kills " .. kills end, Interval = 1 })
wm:SetVisible(false)

local binds = Proximity:KeybindList({ ShowInactive = false })
Proximity:Dock(myFrame, "MyWidget", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 12) })
```
Widgets are draggable and snap to corners and edges; positions are remembered.

## Locale

English and Russian are built in. Every built-in string goes through `Proximity:T(key)`.
```lua
Proximity:AddLanguage("de", { Search = "Suchen", Settings = "Einstellungen" }, "Deutsch")
Proximity:SetLanguage("de")
```

## Icons

818 [Lucide](https://lucide.dev/icons) icons by name (`"crosshair"`, `"lucide-crosshair"`), the Proximity set of 86 own icons (`"px:aimbot"`), plus 130+ names for typical script features: `aimbot`, `silent`, `triggerbot`, `esp`, `chams`, `tracer`, `fly`, `noclip`, `speed`, `teleport`, `farm`, `loot`, `quest`, `boss`, `shop`, `server`, `rejoin`, `serverhop`, `webhook`, `premium`, `anonymous`, `planet` and more (see `src/Icons/init.luau`). Anything else works too: `rbxassetid://…`, a number, `rbxthumb://…`, or an image URL (downloaded once, cached, needs `getcustomasset`). `Proximity:RegisterIcon("logo", "https://…/logo.png")`.

## Script lifecycle

Everything your script does through these calls is undone by `Proximity:Unload()`, so a player can remove the script and get the game back as it was.

```lua
Proximity:Connect(RunService.Heartbeat, fn)          -- disconnected on unload
Proximity:Spawn(fn, ...)                             -- thread cancelled on unload
Proximity:Loop(fn, 0.5)                              -- runs every 0.5 s until unload
Proximity:Create("Highlight", { Parent = char })     -- destroyed on unload
Proximity:SetProperty(camera, "FieldOfView", 100)    -- the old value comes back on unload
Proximity:HookFunction(target, replacement)          -- restored on unload (needs hookfunction)
Proximity:HookMetamethod(game, "__namecall", fn)     -- restored on unload
Proximity:Track(thing)                               -- anything with Destroy, Disconnect, or a function
Proximity:OnUnload(fn)
Proximity:Bind("aim.silent", function(on) end)       -- runs now, on every change and with false on unload
```

| Member | Description |
|---|---|
| `:Batch(fn)` | many `:Set` calls inside `fn`, one redraw at the end |
| `:Use(plugin)` | a plugin is a function `(Proximity)` or a table with `Init(Proximity)`; it can add elements, themes, commands |
| `:Element(name, class)` | shorter `RegisterElement` |
| `:GetElement(id)` | find an element by flag, by its `Id` option or by `"Window/Tab/Section/Type/Name"` |
| `:Deprecated(old, new)` | keep an old method name working with a one-time warning |
| `:ExportFlags("json" \| "lua")` | every flag value as text, for sharing or debugging |
| `:GameProfileName()` | the profile name for this game; with game profiles on, auto load picks the config saved for this place |
| `:GetProfile(limit?)` | the slowest callbacks: `{ { Name, Calls, Total, Max } }` |
| `:Localize({ ru = { ... } })` · `:T(key, ...)` | translate your own strings; the menu follows the player's language |
| `:ErrorReport()` | text with the version, executor, settings and the last errors, ready to paste into an issue |
| `:SelfTest()` | builds and checks every element type in a hidden window, returns `ok, report` |

## More elements

```lua
Section:Segmented({ Name = "Mode", Values = { "Legit", "Rage", "Off" }, Default = "Legit" })   -- :SetValues(list)
Section:Stepper({ Name = "Bullets", Min = 1, Max = 10, Step = 1, Default = 3, Suffix = "x" })
Section:Gallery({ Name = "Knife", Columns = 3, Height = 220, Items = {
	{ Name = "Default", Image = 10734898934 },
	{ Name = "Fade", Image = 10734919691, Rarity = "Rare", Badge = "NEW", Description = "Factory new" },
} })                                                    -- :GetItem(), :SetItems(list), :Open(), :Close()
Section:Canvas({ Height = 120, Build = function(frame) end })   -- an empty frame you draw into
```

The gallery shows the current item large at the top. Click it to open every item in a grid with search and rarity stripes.

Section blocks build a group of elements in one call:

| Method | Description |
|---|---|
| `Section:CrosshairEditor({ Flag })` | style, size, gap, thickness, colour, outline and spin with a live preview; drives `Proximity:SetCrosshair` |
| `Section:EspPreview({ Box, Name, Health, Distance, Tracer })` | a dummy figure that shows your ESP settings, `preview:Set(key, value)` |
| `Section:MusicPlayer({ Songs = { { Name, Id } } })` | play, pause, next, volume |
| `Section:Discord({ Invite, Name })` | a server card with copy and join buttons |
| `Section:CodeEditor({ Name, Default, Height, Run })` | a monospaced editor with line numbers and a Run button |

## Sounds, media, screen

```lua
Proximity:PlaySound("wood", 0.5)                     -- default, experience, halloween, pride, wood, notification, warning
Proximity.Media:Play("hitsounds", "neverlose", { Volume = 0.8 })
Proximity.Media:Get("hitmarkers", "outline_cross")   -- a content id for an ImageLabel
Proximity.Media:Preload("hitsounds")
```

Media is downloaded once from this repository into `Proximity/media/` and loaded with `getcustomasset`. Kinds: `ui`, `hitsounds` (16), `hitmarkers` (12), `images`. Players pick click, notification and toggle sounds in Settings.

| Method | Description |
|---|---|
| `:SetMenuBlur(size)` | blur the game behind the open menu (0 turns it off) |
| `:SetFpsCap(n)` | `setfpscap` when the executor has it |
| `:SetCursor("Default" \| "Proximity" \| "Dot" \| "Crosshair")` | cursor while the menu is open |
| `:SetSnap(on)` | windows snap to screen edges and corners after a drag |
| `:SetCrosshair({ Enabled, Style = "Cross" \| "Dot" \| "Circle" \| "T", Size, Gap, Thickness, Color, Outline, Spin })` | a crosshair overlay |

## Tool widgets

Each is a draggable panel that remembers its place. Players can turn them on in Settings.

`:SessionData()` · `:EventFeed()` (joins, leaves, deaths) · `:ChatLog()` · `:FriendsHere()` · `:LookingAtMe()` · `:InventoryViewer()` · `:MusicPlayer({ Songs })`

`:SetPriority(player, "Friendly" | "Neutral" | "Enemy")` · `:GetPriority(player)` · `.PriorityChanged` - one place for player tags that every feature can read.

## Looks and accessibility

| Method | Description |
|---|---|
| `:SetTheme(name)` | 10 presets: `Eclipse`, `OLED`, `Graphite`, `Moon`, `Ash`, `Steel`, `Paper`, `Midnight`, `Graphite Blue`, `Mono Glass` |
| `:ImportTheme(theme, "Rayfield" \| "Linoria" \| "Orion", name?)` | turn another library's theme table into a Proximity theme |
| `:SetHighContrast(on)` | stronger strokes and text |
| `:SetRoundness("Sharp" \| "Soft" \| "Round")` | corner style everywhere |
| `:AccentFromAvatar()` | take the accent from your character's colours |
| `:SetTextSize(11 - 16)` | every text in the menu scales with it |
| `:SetLargeDescriptions(on)` | bigger description text under rows |
| `:SetHints(on)` | beginner mode: descriptions show right away on hover |

On phones the tabs move to a bar at the bottom, rows get taller and the window keeps clear of the notch. Gamepads vibrate lightly on changes (setting "Vibration").

## Right-click menu and quick binds

Right-click (or long press) any element to:

- type an exact value
- open its options
- add, change or remove a key for it, even when the script gave none

A bound toggle flips, a button presses, a dropdown steps through its values, and a slider jumps to the value it had when you bound it and back.

Quick binds are saved per player in settings, not in configs. In code: `element:SetQuickBind("Ctrl+E")`, `element:GetQuickBind()`, `element:SetQuickBind(nil)`.

## Events

| Where | Signals |
|---|---|
| Library | `FlagChanged(flag, new, old)`, `FavoritesChanged`, `IdentityChanged`, `KeybindsChanged`, `DirtyChanged`, `WindowReady(window)`, `ConfigsChanged`, `ConfigLoaded(name, applied, total)`, `ConfigSaved(name)`, `PriorityChanged`, `Unloading`, `Unloaded` |
| Window | `Ready`, `Opened`, `Closed`, `TabChanged(tab, old)`, `PageChanged(page, old)` |
| Tab, page | `Selected` |
| Section | `Changed` (the header toggle) |
| Element | `Changed(new, old)`, `Destroyed`; Keybind also has `StateChanged(active)` |

Every signal has `:Connect(fn)`, `:Once(fn)` and `:Wait(timeout?)`. Connect through `Proximity:Connect(signal, fn)` and it is cleaned up on unload.

## Extending

```lua
local Base = Proximity.Base
local Rating = Base.extend("Rating")

function Rating.new(section, options)
	local self = Base.new(Rating, section, options)
	self.Default = options.Default or 3
	self.Value = self.Default
	return self:_register()
end
function Rating:_normalize(v) v = tonumber(v) return v and math.clamp(math.round(v), 1, 5) end
function Rating:_build(parent)
	self:_row(parent)
	-- put your controls into self._right, call self:_userSet(v) on input
end
function Rating:_render() -- refresh visuals from self.Value
end

Proximity:RegisterElement("Rating", Rating)
Section:Rating({ Name = "Quality", Flag = "quality" })
```
Your element gets flags, configs, search, tooltips, locking, dependencies, context menu, quick binds and undo for free.

## Toolkit

The building blocks are exported for your own UI: `Proximity.Util` (`New`, `Corner`, `Stroke`, `Padding`, `List`, `Gradient`, `Label`, `Fuzzy`, `ToHex`, `FromHex`, `Base64Encode`, `SafeCall`, `Debounce`, `Throttle`, …), `Proximity.Signal`, `Proximity.Maid`, `Proximity.Tween` (`Play`, `Await`, `Value`, `Speed`), `Proximity.Theme`, `Proximity.Icons`, `Proximity.Keys`, `Proximity.Media`, `Proximity.Env` (`Caps`, `Write`, `Read`, `List`, `Clipboard`, `HttpGet`, `CustomAsset`, `ExecutorName`).
