# Proximity UI · справочник API

<sub><a href="API.md">English</a> · <b>Русский</b></sub>

> Все параметры необязательны, если не помечены как **обязательные**. У каждого элемента есть ещё и [общий API элементов](#общий-api-элементов).
> Имена в `коде` - основное написание; синонимы перечислены в [MIGRATION.md](MIGRATION.md).

- [Библиотека](#библиотека)
- [Окно](#окно)
- [Скелет загрузки](#скелет-загрузки)
- [Вкладки, страницы, секции](#вкладки-страницы-секции)
- [Общий API элементов](#общий-api-элементов)
- [Элементы](#элементы)
- [Диалоги, поиск, обучение](#диалоги-поиск-обучение)
- [Встроенные вкладки](#встроенные-вкладки)
- [Конфиги](#конфиги)
- [Темы](#темы)
- [Уведомления и виджеты](#уведомления-и-виджеты)
- [Языки](#языки)
- [Иконки](#иконки)
- [Жизненный цикл скрипта](#жизненный-цикл-скрипта)
- [Ещё элементы](#ещё-элементы)
- [Звуки, медиа, экран](#звуки-медиа-экран)
- [Виджеты-инструменты](#виджеты-инструменты)
- [Внешний вид и доступность](#внешний-вид-и-доступность)
- [Меню по правому клику и быстрые бинды](#меню-по-правому-клику-и-быстрые-бинды)
- [События](#события)
- [Расширение](#расширение)
- [Инструменты](#инструменты)

---

## Библиотека

```lua
local Proximity = loadstring(game:HttpGet("https://proximitydevproject.github.io/ProximityGUI/Proximity.lua"))()
```

| Член | Описание |
|---|---|
| `Proximity:Window(options)` | создать окно, см. [Окно](#окно). Синонимы: `CreateWindow`, `Proximity.new(options)` |
| `Proximity.Version` · `:GetVersion()` | `"1.3.0"` |
| `Proximity.Flags` | `флаг → текущее значение` для каждого элемента с флагом |
| `Proximity.Elements` | `флаг → элемент` |
| `:GetFlag(flag)` · `:SetFlag(flag, value)` · `:GetElement(flag)` | чтение и запись по флагу |
| `:OnFlag(flag, fn(new, old))` | следить за одним флагом, возвращает подключение |
| `.FlagChanged` | сигнал `(flag, new, old)` для любого флага |
| `:Undo()` · `:Redo()` · `:ClearHistory()` | история изменений (только действия игрока, 100 шагов) |
| `:IsFavorite(el)` · `:ToggleFavorite(el)` · `:GetFavorites()` · `.FavoritesChanged` | избранное |
| `:GetIdentity()` | `{ Name, DisplayName, UserId, Avatar, Anonymous? }`, учитывает анонимный режим |
| `:SetAnonymous(on, { Name })` · `.IdentityChanged` | скрыть имя, аватар и ID везде |
| `Proximity.Providers.*` | `FPS, Ping, Session, Players, Device, Resolution, AccountAge, UserId, Executor, PlaceId, JobId, ServerUptime, GameName` - функции, которые возвращают значения для показа |
| `:SetTheme(name)` · `:GetTheme()` · `:GetThemes()` · `:AddTheme(name, tokens)` · `:SetAccent(color)` · `:OnThemeChanged(fn)` | темы |
| `:SetLanguage(code)` · `:AddLanguage(code, strings, displayName)` · `:T(key, ...)` | языки |
| `:SetReducedMotion(on)` | отключить анимации |
| `:GetIcon(name)` · `:RegisterIcon(name, source)` | иконки |
| `:RegisterElement(name, class)` | добавить свой тип элемента |
| `:Notify(options)` · `:Success` · `:Error` · `:Warn` · `:Info` · `:ClearNotifications()` · `:SetNotifyPosition(pos)` · `.NotificationHistory` | уведомления |
| `:Watermark(options)` · `:KeybindList(options)` · `:Dock(frame, key, default)` | виджеты |
| `:QuickSave(window?)` | сохранить в текущий конфиг (в первый раз спросит имя) |
| `:OnUnload(fn)` · `.Unloading` · `:Unload()` · `.Unloaded` | выгрузка. Сначала выключает все тогглы, чтобы твои колбэки успели прибраться |
| `:SetDebug(on)` | полный стек ошибок в колбэках, предупреждения о повторных флагах |
| `.WindowReady` · `.KeybindsChanged` · `.DirtyChanged` | сигналы |

## Окно

```lua
local Window = Proximity:Window({
	Title = "Proximity",               -- заголовок в боковой панели, он же ключ для сохранения состояния окна
	Subtitle = "v1.0",
	Logo = nil,                        -- nil = планета Proximity, false = только векторная планета, или имя иконки / rbxassetid / ссылка на картинку
	Decoration = true,                 -- бледная планета в правом нижнем углу
	Keybind = Enum.KeyCode.RightShift, -- KeyCode, "RightShift", "MB3"…
	Size = Vector2.new(740, 500),      -- или UDim2.fromOffset; на телефоне по умолчанию 600×380
	MinSize = Vector2.new(560, 360),
	Scale = "Auto",                    -- или 0.5 - 2
	Folder = "Proximity",              -- где лежат конфиги и настройки
	Theme = "Eclipse", Accent = Color3.new(1, 1, 1),
	Language = "en",
	Loading = { Enabled = true, MinTime = 0.6, Skip = true, Budget = 0.004 },
	AutoReady = true,                  -- показать окно, когда объявления затихнут
	AutoLoad = true,                   -- применить автоконфиг до показа
	Watermark = true, KeybindList = true,
	Profile = true, Status = "Premium",
	ConfigButton = true,               -- кнопка конфига в шапке
	Animation = "Planet",              -- анимация открытия и скрытия: Rise, Zoom, Drop, Slide, Swing, Wipe, Unfold, Scan, Glitch, Fade, None
	ToggleButton = nil,                -- по умолчанию плавающая кнопка только на телефонах; "Bubble", "Topbar" или false
	Resizable = true, Draggable = true,
	UnlockMouse = true,                -- освобождает курсор в играх от первого лица, пока меню открыто
	Backdrop = "Stars",                -- "Stars" | "Grid" | "Dots" | "Nebula" | "Aurora" | "Comets" | "None"
	HiddenHint = true,                 -- одноразовая подсказка «нажми X, чтобы открыть»
	SidebarWidth = 196,
	Navigation = nil,                  -- "Sidebar", "Rail" или "Bottom" (на телефонах по умолчанию "Bottom")
})
```

| Метод | Описание |
|---|---|
| `:Tab(options)` | новая вкладка (`Name`, `Icon`, `Description`, `Badge`, `Visible`, `Order`). Синонимы `AddTab`, `DrawTab`, `CreateTab`, `Page` |
| `:Category(name)` | подпись между вкладками. Синонимы `Divider`, `Group`, `DrawCategory`, `AddTabDivider` |
| `:SelectTab(tab \| name \| index)` · `:GetTab(name)` · `:GetTabs()` · `:Back()` | навигация |
| `:Open()` · `:Close()` · `:Toggle()` · `:SetOpen(bool)` · `:IsOpen()` | видимость (`Show`, `Hide`, `Minimize`) |
| `:SetScale(n \| "Auto")` · `:GetScale()` | масштаб |
| `:SetSize(v2)` · `:GetSize()` · `:SetPosition(udim2 \| v2)` · `:Center()` | размер и положение (запоминаются) |
| `:SetTitle(text)` · `:SetSubtitle(text)` | текст в шапке |
| `:SetKeybind(key)` · `:GetKeybind()` | клавиша меню (`SetMenuKey`) |
| `:SetTransparency(0 - 0.4)` | стекло |
| `:SetRim(bool)` | анимированная кайма затмения |
| `:SetBackdrop(name)` | фон окна |
| `:SetDecoration(bool)` | планета в углу |
| `:SetDraggable(bool)` | |
| `:Command({ Name, Icon, Hint, Callback })` | действие в палитре `Ctrl+K` |
| `:OpenSearch(query?)` | открыть палитру |
| `:Dialog` · `:Confirm` · `:Prompt` · `:Tour` | см. [Диалоги](#диалоги-поиск-обучение) |
| `:Home` · `:SettingsTab` · `:ConfigTab` · `:Favorites` | см. [Встроенные вкладки](#встроенные-вкладки) |
| `:Notify(options)` | то же, что у библиотеки |
| `:GetElements()` · `:Find(nameOrFlag)` | поиск |
| `:Destroy()` | удалить это окно |
| Сигналы | `.Ready`, `.Opened`, `.Closed`, `.TabChanged(tab, old)`, `.PageChanged(page, old)` |

Размер меняется за любой из четырёх углов.

## Скелет загрузки

Окно сразу создаётся как скелет. Объявленные элементы сохраняются мгновенно, а строит их планировщик, который тратит не больше `Loading.Budget` секунд за кадр. Скелет показывает:

- все вкладки в боковой панели, у каждой свой прогресс, спиннер во время сборки и галочка в конце
- крупный процент, текущий этап (`Building · Combat 34/120`, `Applying config · legit`, твои шаги) и прошедшее время
- мерцающие карточки-заглушки в форме настоящих секций
- кнопку **Показать сейчас** через 2.5 с (отключается `Loading.Skip = false`)

Окно становится **Ready**, когда очередь пуста, все задачи завершены, объявления затихли на 0.2 с (или ты вызвал `:SetReady()`) и автоконфиг применён. Скелет не мелькает: он держится минимум `Loading.MinTime` секунд.

Вместо скелета можно выбрать экран загрузки: `Loading = { Style = "Planet" | "Orbit" | "Eclipse" | "Constellation" | "Terminal" | "Skeleton" | "None" }`. Игрок может поменять его в настройках.

| Метод | Описание |
|---|---|
| `:Task(name, weight = 10)` | возвращает `{ :Progress(0-1), :SetText(text), :Done(), :Fail(reason) }` |
| `:Step(name, fn(task), weight?)` | запускает `fn` в своём потоке как задачу и сам её завершает |
| `:SetReady()` | явное «я всё объявил» (вместе с `AutoReady = false`). Синонимы `Finish`, `Init` |
| `:IsReady()` · `:OnReady(fn)` · `:WaitUntilReady(timeout?)` | готовность |
| `:GetLoadProgress()` | 0-1 |

## Вкладки, страницы, секции

```lua
local Combat = Window:Tab({ Name = "Бой", Icon = "crosshair", Description = "Аим и оружие", Badge = "NEW" })
local Players = Visuals:SubTab({ Name = "Игроки", Icon = "user" })           -- таблетка под заголовком
local Tuning  = Combat:SubPage({ Name = "Тонкая настройка", Hidden = true }) -- открывается через Navigate, со стрелкой назад

local Aim = Combat:Section({
	Name = "Аим", Icon = "target",
	Side = "Left",            -- "Left" | "Right" | "Full"
	Toggle = true, Flag = "aim.enabled", Enabled = true, Callback = fn,   -- галочка в заголовке
	Collapsible = false, Collapsed = false,
})
local Silent, Lock = Aim:Tabs({ "Silent", "Lock" }, { Flag = "aim.mode", Icons = { "eye-off", "lock" }, Default = "Silent" })
```

**Вкладка** · `:Section` (`AddSection`, `DrawSection`), `:LeftSection`, `:RightSection`, `:FullSection`, `:SubTab` (`SubPage`, `AddSubTab`, `Page`), `:GetPage(name)`, `:Select()`, `:IsSelected()`, `:SetName`, `:SetIcon`, `:SetDescription`, `:SetBadge(text?)`, `:SetVisible`, `:GetSections()`, `:GetElements()`, `:Destroy()`, `.Selected`.

**Страница** · те же методы для секций, `:Select()`, `:IsSelected()`, `:ScrollTo(gui)`, `:GetSections()`, `.Selected`. На узком окне страница сама переходит в одну колонку (`Columns = 1` включает это всегда).

**Секция** · все конструкторы элементов (ниже, каждый ещё и как `AddX` и `CreateX`), `:Tabs(names, options)`, `:SelectTab(nameOrIndex)`, `:GetTab()`, `:SetEnabled(bool)`, `:IsEnabled()`, `:IsDisabled()`, `:SetCollapsed(bool)`, `:Collapse()`, `:Expand()`, `:SetName`, `:SetVisible`, `:GetElements()`, `:AllElements()`, `:Find(nameOrFlag)`, `:Clear()`, `:Destroy()`, `:Custom(name, options)`, `.Changed`.

## Общий API элементов

Это есть у каждого элемента (кроме чисто разметочных, где сказано отдельно):

| Член | Описание |
|---|---|
| `Name`, `Icon`, `Description`, `Tooltip`, `Flag`, `Default`, `Callback`, `Risky`, `Badge`, `Visible`, `Locked` (`true` или причина строкой), `Save = false`, `New = true \| дни`, `Sound` | общие параметры. `Icon` ставит иконку перед названием любой строки. `Badge` принимает текст или вид: `"risky"`, `"beta"`, `"vip"`, `"new"`. `New` показывает значок NEW, который пропадает после просмотра (по умолчанию через 7 дней). `Sound` у тоггла проигрывает хитсаунд при включении |
| `:Get()` · `:Set(value, silent?)` · `:Reset()` · `:GetDefault()` · `:SetDefault(v)` · `:IsDefault()` | значение (`GetValue`, `SetValue`) |
| `.Changed` · `:OnChanged(fn(new, old))` | срабатывает при любом изменении, даже тихом |
| `:SetCallback(fn)` · `:AddCallback(fn)` · `:Fire()` | колбэки идут только на нетихие изменения; ошибки в них не ломают интерфейс |
| `:SetName` · `:GetName` · `:SetDescription` · `:SetTooltip` · `:SetBadge(text?)` · `:SetRisky(bool)` | текст и оформление |
| `:SetVisible` · `:Show` · `:Hide` · `:IsVisible` | видимость |
| `:SetLocked(bool, reason?)` · `:Lock(reason?)` · `:Unlock()` · `:IsLocked()` | затемнён, ввод заблокирован, причина в подсказке |
| `:DependsOn(flagOrElement, predicate?, "Hide" \| "Lock")` | показывать или блокировать по условию |
| `:Keybind(options)` · `:ColorPicker(options)` | прицепить к строке компактный бинд или цвет |
| `:Options(fn \| nil)` | шестерёнка, открывающая плавающую панель; возвращает эту панель (секцию). Синонимы `Settings`, `AddOption` |
| `:Highlight()` · `:Focus()` · `:GetPath()` | навигация (`Focus` открывает вкладку, прокручивает и подсвечивает строку) |
| `:Copy()` · `:Paste(text?)` · `:OpenContextMenu()` | буфер обмена (и через правый клик) |
| `:SetQuickBind(key \| nil)` · `:GetQuickBind()` | быстрый бинд, см. [правый клик](#меню-по-правому-клику-и-быстрые-бинды) |
| `:Destroy()` · `.Destroyed` | удаление |

## Элементы

### Toggle
`Section:Toggle({ Name, Default = false, Style = "Switch" | "Checkbox", Risky, Confirm = false | "text", Callback(bool) })`
Методы `:Toggle()`, `:On()`, `:Off()`, `:IsOn()`, `:SetStyle()`. `Section:Checkbox{}` - тоггл со `Style = "Checkbox"`. Рискованный тоггл один раз переспрашивает перед включением.

### Button
`Section:Button({ Name, Callback, Icon, Hint, Style = "Secondary" | "Primary" | "Ghost" | "Danger", Confirm = false | "text", DoubleClick = false, Cooldown = 0, Hold = false | секунды })`
`Hold = 1` делает кнопку, которую надо удерживать: она заполняется, пока её держат. Методы `:Press()` (`Click`), `:SetStyle`, `:SetIcon`, `:SetHint`, `:SetCooldown`. Бинд, прицепленный к кнопке, нажимает её.

### ButtonGroup
`Section:ButtonGroup({ { Name, Callback, Style }, ... })` - кнопки в ряд.

### Slider · RangeSlider · TextSlider
```lua
Section:Slider({ Name, Min = 0, Max = 100, Default, Step = 1, Suffix, Prefix, Format = fn(v), Icon, Presets = { Low = 10, High = 90 },
                 Danger = 400, Marks = { 0, 50, 100 }, Throttle = 0.05 })
Section:RangeSlider({ Name, Min, Max, Default = { 10, 250 } })        -- значение { Min =, Max = }
Section:TextSlider({ Name, Labels = { "Медленно", "Средне", "Быстро" }, Default = "Средне" })   -- callback(label, index)
```
Методы `:SetMin`, `:SetMax`, `:SetLimits(min, max)` (`SetRange`), `:SetStep`, `:Increment(n?)`, `:Decrement(n?)`, `:GetPercent()`, `:GetText()`. Двойной клик по значению - ввод с клавиатуры, стрелки двигают значение при наведении (Shift ×10). С зажатым Shift ползунок двигается мелким шагом. `Danger` красит заливку в красный дальше этого значения, `Marks` рисует деления, `Throttle` ограничивает, как часто вызывается колбэк во время перетаскивания (последнее значение приходит всегда). `Decimals = n` работает как `Step = 10^-n`.

### Dropdown · MultiDropdown · PlayerDropdown
```lua
Section:Dropdown({ Name, Values, Default, Multi = false, Max, Min = 0, Search = авто, Placeholder,
                   AllowNone = true, Deletable = false, OnDelete = fn(value) → false отменяет,
                   Icons = { value = icon }, Prefixes = { value = "🇷🇺" }, Display = fn(value) → text })
Section:MultiDropdown({ ... })                  -- Multi = true
Section:PlayerDropdown({ Name, Multi, ExcludeSelf = true })   -- синхронизируется с сервером, :GetPlayer()
```
Методы `:SetValues(list, keep?)` (`Refresh`), `:AddValue` (`Add`), `:RemoveValue` (`Remove`), `:Clear()`, `:Open()`, `:Close()`, `:IsOpen()`, `:Select(v)`, `:Deselect(v)`, `:IsSelected(v)`, `:GetValues()`, `:GetText()`. Поиск появляется сам, если вариантов больше 7, и прощает опечатки.

### Input
`Section:Input({ Name, Default, Placeholder, Numeric = false, Min, Max, MaxLength, Finished = false, ClearOnFocus, Wide = false, Validate = fn(text) → ok, message })`
Методы `:Focus()`, `:Blur()`, `:Clear()`, `:SetPlaceholder()`. Синонимы `TextBox`, `Textbox`.

### Keybind
`Section:Keybind({ Name, Default = "E" | Enum.KeyCode | "MB2", Mode = "Toggle" | "Hold" | "Always" | "Release" | "Press", Modes, Blacklist, ShowInList = true, OnPress, OnRelease, OnToggle(active) })`
Методы `:SetKey`, `:GetKey`, `:GetKeyCode`, `:SetMode`, `:GetMode`, `:IsActive`, `:Listen()`, `:Clear()`, `:Press()`, `:OpenModeMenu()`, сигнал `.StateChanged(active)`. Клик по чипу - переназначить (Backspace очищает, Esc отменяет), правый клик - сменить режим. Прицепленный к тогглу, бинд управляет им по выбранному режиму.

### ColorPicker
`Section:ColorPicker({ Name, Default = Color3 | "#hex" | {r,g,b}, Alpha = nil | 0-1, Presets = { Color3 … } })` - колбэк `(color, alpha)`.
Методы `:SetColor`, `:GetColor`, `:SetAlpha`, `:GetAlpha`, `:GetHex`, `:SetHex`, `:Open`, `:Close`, `:SetRainbow(on, speed?)`. В окне есть насыщенность и яркость, оттенок, прозрачность, hex, сравнение старого и нового цвета (клик по старому возвращает его), пресеты и недавние цвета.

### Label · Paragraph · Divider · Spacer
`Section:Label("текст" | { Text, Color = токен | Color3, Icon, Center, RichText })` - может держать бинды и цвета, как любая строка. `:SetColor()`.
`Section:Paragraph({ Title, Content, RichText = true })` - `:SetContent` (`Set`), `:SetTitle`.
`Section:Divider("Дополнительно"?)` (`Separator`) · `Section:Spacer(8)`.

### Navigate
`Section:Navigate({ Name, Page = subPage, Value = "текст справа", Icon, Callback })` - строка со стрелкой; открывает скрытую подстраницу (со стрелкой назад) и/или вызывает колбэк. `:SetValue(text)`.

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
	Columns = { { Key = "name", Name = "Карта", Width = 0.5, Align = "Left" | "Center" | "Right" } },
	Rows = { ... }, SortBy = "players", Descending = true, Filter = fn(row) → bool,
	Actions = { { Icon = "log-in", Tooltip = "Зайти", Callback = fn(row) } },
	OnSelect = fn(row),
})
```
Методы `:SetRows`, `:AddRow`, `:RemoveRow(index | row | fn)`, `:Clear`, `:GetRows`, `:GetSelected`, `:SortBy(key, desc)`, `:SetFilter(fn)`, `:SetQuery(text)`, `:SetLoading(bool)` (мерцающие строки-заглушки). Клик по заголовку сортирует. Существуют только видимые строки (они переиспользуются), поэтому тысячи строк не тормозят. Синонимы `Catalog`, `List`.

### Card · Image · Console · Code
```lua
Section:Card({ Title, Subtitle, Body, Image, Model = instance, Progress = { 3, 13 }, Badge, Height = 96, Callback })   -- 3D-модель через ViewportFrame
Section:Image({ Image, Height = 120, ScaleType, Caption })
Section:Console({ Name, Height = 160, MaxLines = 200 })   -- :Log(text, level), :Info, :Warn, :Error, :Success, :Clear, :GetLines
Section:Code({ Title, Code })                             -- моноширинный блок с кнопкой копирования
```

## Диалоги, поиск, обучение

```lua
local index = Window:Dialog({ Title, Content, Buttons = { { Text = "Отмена" }, { Text = "Удалить", Style = "Danger", Callback = fn } }, Dismissable = true })
local ok = Window:Confirm({ Title, Content, Danger = true, ConfirmText, CancelText })   -- возвращает boolean, ждёт ответа
local text = Window:Prompt({ Title, Content, Placeholder, Default })                   -- возвращает строку или nil
Window:OpenSearch("aim")
Window:Tour({ { Target = element | gui | "search" | "config", Title, Text } }, { Key = "intro-v1", Force = false })
```
Диалоги ждут ответа, поэтому вызывай их из колбэка или `task.spawn`. Обучение с `Key` показывается один раз.

## Встроенные вкладки

| Метод | Что внутри |
|---|---|
| `Window:Home({ Name, Icon, Status, Welcome, Badge, Version })` | карточка профиля, живые плитки сессии с графиками FPS и пинга, аккаунт, сервер. Добавляет кнопку «домой» в шапку |
| `Window:SettingsTab({ Name, Icon, Configs = true, Tour })` | тема, акцент, стекло, масштаб, размер текста, фон, кайма, меньше анимаций, клавиша меню, язык (с флагами), вотермарка, список биндов, место уведомлений, анонимный режим, редактор тем (экспорт и импорт), звуки, экран, сервер, вывод, виджеты, горячие клавиши, выгрузка. Добавляет кнопку настроек в шапку |
| `Window:ConfigTab({ Name, Icon, Tab })` | имя, список (с удалением), сохранение (спросит перед перезаписью), загрузка (сначала покажет разницу), экспорт и импорт в JSON и Lua, сравнение, профиль для этой игры, автозагрузка, автосохранение |
| `Window:Favorites({ Name, Icon })` | ярлыки на избранные функции (правый клик → ☆) |

Настройки хранятся в `<Folder>/settings.json` и никогда не смешиваются с конфигами.

## Конфиги

```lua
Proximity:SaveConfig("legit", { Author = "me", Note = "без рейджа" })
Proximity:LoadConfig("legit")
Proximity:DeleteConfig("legit")
Proximity:RenameConfig("legit", "legit-v2")
Proximity:DuplicateConfig("legit", "legit-copy")
Proximity:ListConfigs()                 -- { "legit", ... }
Proximity:ConfigExists("legit")
Proximity:GetConfigInfo("legit")        -- { Name, Created, Updated, Author, Note, Version, Schema, Count }
Proximity:DiffConfig("legit")           -- { { Flag, From, To } } что изменится
Proximity:ExportConfig("legit" | nil)   -- "PRX1.<base64>.<checksum>" (nil = текущее состояние)
Proximity:ImportConfig(text, saveAs?)   -- применить сразу или сохранить под именем
Proximity:SetAutoLoad("legit" | nil) · Proximity:GetAutoLoad()
Proximity:SetAutoSave("legit" | nil) · Proximity:GetAutoSave()
Proximity:GetState() · Proximity:ApplyState(state, { Silent, Budget, OnProgress })
Proximity:SetFolder("MyHub")
Proximity:GetSetting(key, default) · Proximity:SetSetting(key, value)
Proximity.SchemaVersion = 2
Proximity.Migrations[1] = function(flags) flags["new.name"] = flags["old.name"]; return flags end
```
Сигналы: `ConfigsChanged`, `ConfigLoaded(name, applied, total)`, `ConfigSaved(name)`. Повреждённые файлы сохраняются как `.broken` и не теряются; загрузка применяет значения за несколько кадров; автосохранение ждёт 1.5 с после последнего изменения и включается только когда окно готово. Без файловых функций всё работает в памяти.

## Темы

Пресеты: `Eclipse` (по умолчанию), `OLED`, `Graphite`, `Moon`, `Ash`, `Steel`, `Paper`, `Midnight`, `Graphite Blue`, `Mono Glass`.
Токены: `Bg, Bg2, Surface, Surface2, Surface3, Elevated, Stroke, StrokeHi, Text, TextDim, TextMute, Accent, AccentInk, Risky, Success, Warning, Error, Info, Shadow`.

```lua
Proximity:SetTheme("Moon")
Proximity:SetAccent(Color3.fromRGB(255, 244, 230))
Proximity:AddTheme("Paper Moon", { Accent = "#E8F0FF", Stroke = "#20242C" })
Proximity.Theme.SetToken("Risky", "#FF5A5A")
Proximity.Theme.Paint(myFrame, { BackgroundColor3 = "Surface", TextColor3 = "Text" })   -- твои объекты меняются вместе с темой
print(Proximity.Theme.Export())   -- JSON, Theme.Import(json) применяет его
```

## Уведомления и виджеты

```lua
local n = Proximity:Notify({ Title = "Сохранено", Content = "legit", Type = "success", Duration = 4,
	Actions = { { Text = "Отменить", Callback = function() Proximity:Undo() end } }, Persistent = false })
n:SetContent("…") n:SetProgress(0.5) n:Extend(3) n:Close()
Proximity:SetNotifyPosition("TopRight")    -- TopRight, BottomRight, TopLeft, BottomLeft, TopCenter
```
Пока курсор над уведомлением, его таймер стоит. Одновременно видно не больше пяти, последние 50 хранятся в `NotificationHistory`. Уведомление можно смахнуть в сторону.

```lua
local wm = Proximity:Watermark({ Text = "Proximity", Items = { "FPS", "Ping", "Time", "Game", "Player" } })
wm:AddItem({ Text = function() return "убийств " .. kills end, Interval = 1 })
wm:SetVisible(false)

local binds = Proximity:KeybindList({ ShowInactive = false })
Proximity:Dock(myFrame, "MyWidget", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 12) })
```
Виджеты перетаскиваются и прилипают к углам и краям; положение запоминается.

## Языки

Английский и русский встроены. Каждая встроенная строка идёт через `Proximity:T(key)`.
```lua
Proximity:AddLanguage("de", { Search = "Suchen", Settings = "Einstellungen" }, "Deutsch")
Proximity:SetLanguage("de")
```

## Иконки

818 иконок [Lucide](https://lucide.dev/icons) по имени (`"crosshair"`, `"lucide-crosshair"`), набор Proximity из 86 своих иконок (`"px:aimbot"`), плюс 130+ понятных имён для типичных функций скриптов: `aimbot`, `silent`, `triggerbot`, `esp`, `chams`, `tracer`, `fly`, `noclip`, `speed`, `teleport`, `farm`, `loot`, `quest`, `boss`, `shop`, `server`, `rejoin`, `serverhop`, `webhook`, `premium`, `anonymous`, `planet` и другие (см. `src/Icons/init.luau`). Подходит и что угодно ещё: `rbxassetid://…`, число, `rbxthumb://…` или ссылка на картинку (скачивается один раз, кэшируется, нужен `getcustomasset`). `Proximity:RegisterIcon("logo", "https://…/logo.png")`.

## Жизненный цикл скрипта

Всё, что скрипт делает через эти вызовы, `Proximity:Unload()` откатывает - игрок может выгрузить скрипт и получить игру такой, какой она была.

```lua
Proximity:Connect(RunService.Heartbeat, fn)          -- отключится при выгрузке
Proximity:Spawn(fn, ...)                             -- поток отменится при выгрузке
Proximity:Loop(fn, 0.5)                              -- каждые 0.5 с до выгрузки
Proximity:Create("Highlight", { Parent = char })     -- удалится при выгрузке
Proximity:SetProperty(camera, "FieldOfView", 100)    -- старое значение вернётся при выгрузке
Proximity:HookFunction(target, replacement)          -- хук снимется при выгрузке (нужен hookfunction)
Proximity:HookMetamethod(game, "__namecall", fn)     -- снимется при выгрузке
Proximity:Track(thing)                               -- что угодно с Destroy, Disconnect или функция
Proximity:OnUnload(fn)
Proximity:Bind("aim.silent", function(on) end)       -- сразу, при каждом изменении и с false при выгрузке
```

| Член | Описание |
|---|---|
| `:Batch(fn)` | много вызовов `:Set` внутри `fn`, одна перерисовка в конце |
| `:Use(plugin)` | плагин - функция `(Proximity)` или таблица с `Init(Proximity)`; может добавлять элементы, темы, команды |
| `:Element(name, class)` | короткий `RegisterElement` |
| `:GetElement(id)` | найти элемент по флагу, по параметру `Id` или по пути `"Window/Tab/Section/Type/Name"` |
| `:Deprecated(old, new)` | оставить старое имя метода рабочим с одним предупреждением |
| `:ExportFlags("json" \| "lua")` | все значения флагов текстом, чтобы поделиться или отладить |
| `:GameProfileName()` | имя профиля этой игры; с включёнными профилями автозагрузка берёт конфиг, сохранённый для этого плейса |
| `:GetProfile(limit?)` | самые медленные колбэки: `{ { Name, Calls, Total, Max } }` |
| `:Localize({ en = { ... } })` · `:T(key, ...)` | перевод твоих строк; меню следует за языком игрока |
| `:ErrorReport()` | текст с версией, экзекутором, настройками и последними ошибками, готовый для issue |
| `:SelfTest()` | собирает и проверяет каждый тип элемента в скрытом окне, возвращает `ok, report` |

## Ещё элементы

```lua
Section:Segmented({ Name = "Режим", Values = { "Легит", "Рейдж", "Выкл" }, Default = "Легит" })   -- :SetValues(list)
Section:Stepper({ Name = "Пули", Min = 1, Max = 10, Step = 1, Default = 3, Suffix = "x" })
Section:Gallery({ Name = "Нож", Columns = 3, Height = 220, Items = {
	{ Name = "Обычный", Image = 10734898934 },
	{ Name = "Fade", Image = 10734919691, Rarity = "Rare", Badge = "NEW", Description = "Прямо с завода" },
} })                                                    -- :GetItem(), :SetItems(list), :Open(), :Close()
Section:Canvas({ Height = 120, Build = function(frame) end })   -- пустая рамка, в которой рисуешь сам
```

Галерея показывает текущий вариант крупно сверху. Клик по нему открывает все варианты сеткой с поиском и полосками редкости.

Готовые блоки собирают группу элементов одним вызовом:

| Метод | Описание |
|---|---|
| `Section:CrosshairEditor({ Flag })` | стиль, размер, зазор, толщина, цвет, обводка и вращение с живым превью; управляет `Proximity:SetCrosshair` |
| `Section:EspPreview({ Box, Name, Health, Distance, Tracer })` | манекен, на котором видно настройки ESP, `preview:Set(key, value)` |
| `Section:MusicPlayer({ Songs = { { Name, Id } } })` | воспроизведение, пауза, следующий трек, громкость |
| `Section:Discord({ Invite, Name })` | карточка сервера с кнопками «скопировать» и «зайти» |
| `Section:CodeEditor({ Name, Default, Height, Run })` | моноширинный редактор с номерами строк и кнопкой запуска |

## Звуки, медиа, экран

```lua
Proximity:PlaySound("wood", 0.5)                     -- default, experience, halloween, pride, wood, notification, warning
Proximity.Media:Play("hitsounds", "neverlose", { Volume = 0.8 })
Proximity.Media:Get("hitmarkers", "outline_cross")   -- content id для ImageLabel
Proximity.Media:Preload("hitsounds")
```

Медиа скачивается один раз из этого репозитория в `Proximity/media/` и загружается через `getcustomasset`. Виды: `ui`, `hitsounds` (16), `hitmarkers` (12), `images`. Игрок сам выбирает звуки кликов, уведомлений и тогглов в настройках.

| Метод | Описание |
|---|---|
| `:SetMenuBlur(size)` | размыть игру за открытым меню (0 выключает) |
| `:SetFpsCap(n)` | `setfpscap`, если экзекутор его даёт |
| `:SetCursor("Default" \| "Proximity" \| "Dot" \| "Crosshair")` | курсор, пока меню открыто |
| `:SetSnap(on)` | окна прилипают к краям и углам экрана после перетаскивания |
| `:SetCrosshair({ Enabled, Style = "Cross" \| "Dot" \| "Circle" \| "T", Size, Gap, Thickness, Color, Outline, Spin })` | прицел поверх экрана |

## Виджеты-инструменты

Каждый - перетаскиваемая панель, которая помнит своё место. Игрок может включить их в настройках.

`:SessionData()` · `:EventFeed()` (заходы, выходы, смерти) · `:ChatLog()` · `:FriendsHere()` · `:LookingAtMe()` · `:InventoryViewer()` · `:MusicPlayer({ Songs })`

`:SetPriority(player, "Friendly" | "Neutral" | "Enemy")` · `:GetPriority(player)` · `.PriorityChanged` - одно место для меток игроков, которое читают все функции.

## Внешний вид и доступность

| Метод | Описание |
|---|---|
| `:SetTheme(name)` | 10 пресетов, см. [Темы](#темы) |
| `:ImportTheme(theme, "Rayfield" \| "Linoria" \| "Orion", name?)` | превратить таблицу темы другой библиотеки в тему Proximity |
| `:SetHighContrast(on)` | контрастнее обводки и текст |
| `:SetRoundness("Sharp" \| "Soft" \| "Round")` | форма углов везде |
| `:AccentFromAvatar()` | взять акцент из цветов персонажа |
| `:SetTextSize(11 - 16)` | весь текст меню масштабируется вместе с ним |
| `:SetLargeDescriptions(on)` | крупнее описания под строками |
| `:SetHints(on)` | режим новичка: описания появляются сразу при наведении |

На телефоне вкладки переезжают в панель снизу, строки становятся выше, а окно не залезает под вырез экрана. Геймпад слегка вибрирует при изменениях (настройка «Вибрация»).

## Меню по правому клику и быстрые бинды

Правый клик (или долгое нажатие) по любому элементу позволяет:

- ввести точное значение
- открыть его настройки
- добавить, сменить или убрать клавишу, даже если скрипт её не дал

Привязанный тоггл переключается, кнопка нажимается, список перебирает значения, а слайдер прыгает к значению, которое было при привязке, и обратно.

Быстрые бинды хранятся у игрока в настройках, а не в конфигах. В коде: `element:SetQuickBind("Ctrl+E")`, `element:GetQuickBind()`, `element:SetQuickBind(nil)`.

## События

| Где | Сигналы |
|---|---|
| Библиотека | `FlagChanged(flag, new, old)`, `FavoritesChanged`, `IdentityChanged`, `KeybindsChanged`, `DirtyChanged`, `WindowReady(window)`, `ConfigsChanged`, `ConfigLoaded(name, applied, total)`, `ConfigSaved(name)`, `PriorityChanged`, `Unloading`, `Unloaded` |
| Окно | `Ready`, `Opened`, `Closed`, `TabChanged(tab, old)`, `PageChanged(page, old)` |
| Вкладка, страница | `Selected` |
| Секция | `Changed` (переключатель в заголовке) |
| Элемент | `Changed(new, old)`, `Destroyed`; у Keybind ещё `StateChanged(active)` |

У каждого сигнала есть `:Connect(fn)`, `:Once(fn)` и `:Wait(timeout?)`. Подключай через `Proximity:Connect(signal, fn)` - и при выгрузке оно отключится само.

## Расширение

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
	-- положи свои элементы управления в self._right, на ввод вызывай self:_userSet(v)
end
function Rating:_render() -- обнови вид по self.Value
end

Proximity:RegisterElement("Rating", Rating)
Section:Rating({ Name = "Качество", Flag = "quality" })
```
Твой элемент сразу получает флаги, конфиги, поиск, подсказки, блокировку, зависимости, контекстное меню, быстрые бинды и отмену.

## Инструменты

Строительные блоки доступны для твоего собственного интерфейса: `Proximity.Util` (`New`, `Corner`, `Stroke`, `Padding`, `List`, `Gradient`, `Label`, `Fuzzy`, `ToHex`, `FromHex`, `Base64Encode`, `SafeCall`, `Debounce`, `Throttle`, …), `Proximity.Signal`, `Proximity.Maid`, `Proximity.Tween` (`Play`, `Await`, `Value`, `Speed`), `Proximity.Theme`, `Proximity.Icons`, `Proximity.Keys`, `Proximity.Media`, `Proximity.Env` (`Caps`, `Write`, `Read`, `List`, `Clipboard`, `HttpGet`, `CustomAsset`, `ExecutorName`).
