--!nocheck
--[[
	Proximity · Locale
	Built-in strings in English and Russian. Add your own language with
	Library:AddLanguage("de", { Search = "Suchen", ... }); missing keys fall
	back to English, then to the key itself.
]]

local Signal = require("./Core/Signal")

local Locale = {
	Current = "en",
	Changed = Signal.new(),
}

local packs = {
	en = {
		Search = "Search",
		SearchHint = "Search features, tabs, actions…",
		NoResults = "Nothing found",
		Settings = "Settings",
		Configs = "Configs",
		Appearance = "Appearance",
		Interface = "Interface",
		Theme = "Theme",
		Accent = "Accent",
		Transparency = "Transparency",
		Scale = "Scale",
		Language = "Language",
		MenuKey = "Menu key",
		Watermark = "Watermark",
		KeybindList = "Keybind list",
		ReducedMotion = "Reduced motion",
		EclipseRim = "Eclipse rim",
		Notifications = "Notifications",
		NotifyPosition = "Notification position",
		ConfigName = "Config name",
		ConfigList = "Saved configs",
		Save = "Save",
		Load = "Load",
		Delete = "Delete",
		Refresh = "Refresh",
		Export = "Copy to clipboard",
		Import = "Import from text",
		AutoLoad = "Load on start",
		AutoSave = "Auto save",
		Unload = "Unload",
		UnloadConfirm = "Unload the interface? Every feature will be switched off.",
		Cancel = "Cancel",
		Confirm = "Confirm",
		Ok = "OK",
		Reset = "Reset to default",
		Copy = "Copy value",
		Paste = "Paste value",
		CopyFlag = "Copy flag name",
		BindKey = "Bind key",
		Loading = "Loading",
		Preparing = "Preparing interface",
		Building = "Building",
		ApplyingConfig = "Applying config",
		Ready = "Ready",
		ShowNow = "Show now",
		Risky = "Risky feature",
		RiskyConfirm = "This feature is marked as risky. Enable it anyway?",
		Locked = "Locked",
		None = "None",
		Selected = "selected",
		Press = "Press a key…",
		Saved = "Config saved",
		Loaded = "Config loaded",
		Deleted = "Config deleted",
		Copied = "Copied to clipboard",
		Imported = "Config imported",
		InvalidConfig = "That text is not a valid config",
		Toggle = "Toggle",
		Hold = "Hold",
		Always = "Always",
		Release = "Release",
		Mode = "Mode",
		Undo = "Undo",
		Redo = "Redo",
		Favorites = "Favorites",
		Commands = "Actions",
		Elements = "Features",
		Tabs = "Tabs",
		Hidden = "Interface hidden — press %s to show",
		Empty = "Nothing here yet",
	},
	ru = {
		Search = "Поиск",
		SearchHint = "Поиск функций, вкладок, действий…",
		NoResults = "Ничего не найдено",
		Settings = "Настройки",
		Configs = "Конфиги",
		Appearance = "Внешний вид",
		Interface = "Интерфейс",
		Theme = "Тема",
		Accent = "Акцент",
		Transparency = "Прозрачность",
		Scale = "Масштаб",
		Language = "Язык",
		MenuKey = "Клавиша меню",
		Watermark = "Вотермарка",
		KeybindList = "Список биндов",
		ReducedMotion = "Меньше анимаций",
		EclipseRim = "Обод затмения",
		Notifications = "Уведомления",
		NotifyPosition = "Позиция уведомлений",
		ConfigName = "Имя конфига",
		ConfigList = "Сохранённые конфиги",
		Save = "Сохранить",
		Load = "Загрузить",
		Delete = "Удалить",
		Refresh = "Обновить",
		Export = "Скопировать в буфер",
		Import = "Импорт из текста",
		AutoLoad = "Загружать при старте",
		AutoSave = "Автосохранение",
		Unload = "Выгрузить",
		UnloadConfirm = "Выгрузить интерфейс? Все функции будут выключены.",
		Cancel = "Отмена",
		Confirm = "Подтвердить",
		Ok = "ОК",
		Reset = "Сбросить",
		Copy = "Копировать значение",
		Paste = "Вставить значение",
		CopyFlag = "Копировать имя флага",
		BindKey = "Назначить клавишу",
		Loading = "Загрузка",
		Preparing = "Подготовка интерфейса",
		Building = "Сборка",
		ApplyingConfig = "Применение конфига",
		Ready = "Готово",
		ShowNow = "Показать сейчас",
		Risky = "Рискованная функция",
		RiskyConfirm = "Функция помечена как рискованная. Всё равно включить?",
		Locked = "Заблокировано",
		None = "Нет",
		Selected = "выбрано",
		Press = "Нажмите клавишу…",
		Saved = "Конфиг сохранён",
		Loaded = "Конфиг загружен",
		Deleted = "Конфиг удалён",
		Copied = "Скопировано",
		Imported = "Конфиг импортирован",
		InvalidConfig = "Этот текст не является конфигом",
		Toggle = "Переключение",
		Hold = "Удержание",
		Always = "Всегда",
		Release = "Отпускание",
		Mode = "Режим",
		Undo = "Отменить",
		Redo = "Повторить",
		Favorites = "Избранное",
		Commands = "Действия",
		Elements = "Функции",
		Tabs = "Вкладки",
		Hidden = "Интерфейс скрыт — нажмите %s",
		Empty = "Здесь пока пусто",
	},
}

Locale.Names = { en = "English", ru = "Русский" }

function Locale.T(key: string, ...: any): string
	local pack = packs[Locale.Current]
	local text = (pack and pack[key]) or packs.en[key] or key
	if select("#", ...) > 0 then
		return string.format(text, ...)
	end
	return text
end

function Locale.Set(code: string): boolean
	if not packs[code] then
		return false
	end
	Locale.Current = code
	Locale.Changed:Fire(code)
	return true
end

function Locale.Add(code: string, strings: { [string]: string }, displayName: string?)
	packs[code] = packs[code] or {}
	for k, v in strings do
		packs[code][k] = v
	end
	Locale.Names[code] = displayName or Locale.Names[code] or code
end

function Locale.List(): { string }
	local out = {}
	for code in packs do
		table.insert(out, code)
	end
	table.sort(out)
	return out
end

return Locale
