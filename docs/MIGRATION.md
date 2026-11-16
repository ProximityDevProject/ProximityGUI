# Migration

Proximity accepts the most common names from other libraries, so many scripts move over by changing the loader line and a few options. Guides below: CompKiller, Neverlose Reloaded, MugiHub Gen 2, Rayfield, Orion, Linoria.

## From CompKiller

| CompKiller | Proximity |
|---|---|
| `Compkiller.new({ Name, Keybind, Logo })` | `Proximity:Window({ Title, Keybind, Logo })` (`Name` also works) |
| `Window:DrawCategory({ Name })` | same (`Window:Category(name)`) |
| `Window:DrawTab({ Name, Icon, Type = "Single" })` | `Window:Tab({ Name, Icon })` - sections pick `Side`; one column with `Side = "Full"` |
| `Window:DrawContainerTab` + `:DrawTab` | `Window:Tab` + `Tab:SubTab` |
| `Tab:DrawSection({ Name, Position = "left" })` | same (`Position` → `Side`) |
| `Section:AddToggle/AddSlider/AddDropdown/AddKeybind/AddColorPicker/AddButton/AddParagraph/AddTextBox` | same names work |
| `Toggle.Link:AddKeybind/AddColorPicker` | `toggle:Keybind{}` / `toggle:ColorPicker{}` |
| `Toggle.Link:AddOption()` | `toggle:Options()` |
| `Toggle.Link:AddHelper({ Text })` | `Tooltip = "…"` |
| `Round = 0` | `Step = 1` (or `Decimals = 0`) |
| `Compkiller.newNotify().new({ … })` | `Proximity:Notify({ … })` |
| `Window:DrawConfig({ Config = ConfigManager }):Init()` | `Window:ConfigTab()` (or `Window:SettingsTab()`) |
| `Compkiller:SetTheme(name)` | `Proximity:SetTheme(name)` |
| `Window:Watermark():AddText({ Icon, Text })` | `Proximity:Watermark():AddItem({ Text })` |

## From Neverlose Reloaded

| Neverlose | Proximity |
|---|---|
| `Library:Window({ Name, SubName, Logo })` | `Proximity:Window({ Title, Subtitle, Logo })` (`Name`, `SubName` also work) |
| `Window:Group("Main")` | `Window:Category("Main")` (`Group` works) |
| `Window:Page({ Name, Icon })` | `Window:Tab` (`Page` works) |
| `Page:SubPage({ Name })` | `Tab:SubTab` (`SubPage` works) |
| `SubPage:Section({ Name, Side = 1 \| 2 })` | same |
| `Section:Toggle/Slider/Dropdown/Button/Label/Textbox/Keybind` | same |
| `Section:TextSlider({ TextProps })` | same (`Labels` preferred) |
| `Section:RangedSlider` | same (`RangeSlider`) |
| `Toggle:Colorpicker` / `Toggle:Keybind` / `Toggle:Settings()` | same |
| `IsFirstElement / IsLastElement` | not needed - rounding is automatic |
| `Library:Notification(text, icon, color, time)` | `Proximity:Notify({ Content, Duration })` |
| `Library:CreateSettingsPage(Window, …)` | `Window:SettingsTab()` |

## From MugiHub Gen 2

| MugiHub | Proximity |
|---|---|
| `MugiHub.Library:CreateWindow({ Title, Description, Keybind, Icon })` | `Proximity:CreateWindow({ Title, Subtitle, Keybind, Logo })` |
| `Window:AddTab({ Name, Icon, Description })` | same |
| `Tab:AddSection("Name")` | same |
| `Section:AddToggle({ "Name", false, fn })` (positional) | use named fields: `{ Name = "…", Default = false, Callback = fn }` |
| `Section:AddInput` | same |
| `Window:Dialog({ Title, Content, Buttons })` | same |
| `Library:SetNotification({ Type, Content, Delay })` | same (`Notify`) |
| `Section:AddConfigManager({})` | `Window:ConfigTab()` |
| `Section:AddAppearance()` | `Window:SettingsTab()` |
| `Window:CreatePopup` | `element:Options()` |

## From Rayfield

Rayfield option names are read as they are (`CurrentValue`, `CurrentOption`, `MultipleOptions`, `Range`, `Increment`, `Options`), so most element calls only need a section to live in.

| Rayfield | Proximity |
|---|---|
| `Rayfield:CreateWindow({ Name, LoadingTitle, ConfigurationSaving })` | `Proximity:Window({ Title, Loading = { Style = "Planet" } })` - configs are always on, `Window:ConfigTab()` shows them |
| `Window:CreateTab("Main", 4483362458)` | `Window:Tab({ Name = "Main", Icon = 4483362458 })` |
| `Tab:CreateSection("Aim")` then `Tab:CreateToggle{}` | `local Aim = Tab:Section("Aim")` then `Aim:Toggle{}` - elements always live in a section |
| `Tab:CreateToggle({ Name, CurrentValue, Flag, Callback })` | `Aim:Toggle({ Name, CurrentValue, Flag, Callback })` (`Default` is the usual name) |
| `Tab:CreateSlider({ Name, Range = { 0, 100 }, Increment, Suffix, CurrentValue })` | `Aim:Slider({ ... })` - same fields work |
| `Tab:CreateDropdown({ Options, CurrentOption = { "A" }, MultipleOptions })` | `Aim:Dropdown({ ... })` - same fields work |
| `Tab:CreateInput({ Name, PlaceholderText, RemoveTextAfterFocusLost })` | `Aim:Input({ Name, Placeholder, ClearOnFocus })` |
| `Tab:CreateKeybind({ CurrentKeybind = "Q", HoldToInteract })` | `Aim:Keybind({ Default = "Q", Mode = "Hold" })` |
| `Tab:CreateColorPicker({ Color })` | `Aim:ColorPicker({ Default = color })` |
| `Tab:CreateLabel(text)` · `Tab:CreateParagraph({ Title, Content })` | `Aim:Label(text)` · `Aim:Paragraph({ Title, Content })` |
| `Rayfield:Notify({ Title, Content, Duration, Image })` | `Proximity:Notify({ Title, Content, Duration, Icon })` |
| `Rayfield.Flags.Name.CurrentValue` | `Proximity.Flags.Name` |
| `Rayfield:LoadConfiguration()` | nothing - auto load runs by itself |
| `Rayfield:Destroy()` | `Proximity:Unload()` |
| a Rayfield theme table | `Proximity:ImportTheme(theme, "Rayfield")` |

## From Orion

| Orion | Proximity |
|---|---|
| `OrionLib:MakeWindow({ Name, SaveConfig, ConfigFolder, IntroEnabled })` | `Proximity:Window({ Title, Folder })` |
| `Window:MakeTab({ Name, Icon })` | `Window:Tab({ Name, Icon })` |
| `Tab:AddSection({ Name })` | `Tab:Section({ Name })` - add elements to it, not to the tab |
| `Tab:AddToggle({ Name, Default, Save, Flag, Callback })` | `Section:Toggle({ ... })` - same fields; `Save = false` keeps it out of configs |
| `Tab:AddSlider({ Name, Min, Max, Default, Increment, ValueName })` | `Section:Slider({ ... })` - same fields work |
| `Tab:AddDropdown({ Options })` · `Tab:AddBind({ Default, Hold })` · `Tab:AddColorpicker` · `Tab:AddTextbox` | `Section:Dropdown` · `Section:Keybind({ Default, Mode = "Hold" })` · `Section:ColorPicker` · `Section:Input` |
| `OrionLib:MakeNotification({ Name, Content, Time })` | `Proximity:Notify({ Title, Content, Duration })` |
| `OrionLib:Init()` | nothing - the window shows itself when your script is done |
| `OrionLib:Destroy()` | `Proximity:Unload()` |
| `OrionLib.Flags[flag].Value` | `Proximity.Flags[flag]` |

## From Linoria

| Linoria | Proximity |
|---|---|
| `Library:CreateWindow({ Title, Center, AutoShow })` | `Proximity:Window({ Title })` |
| `Window:AddTab("Main")` | `Window:Tab("Main")` |
| `Tab:AddLeftGroupbox("Aim")` · `Tab:AddRightGroupbox` | `Tab:LeftSection("Aim")` · `Tab:RightSection` |
| `Tab:AddLeftTabbox()` then `Tabbox:AddTab("A")` | `Section:Tabs({ "A", "B" })` |
| `Groupbox:AddToggle("Idx", { Text, Default, Callback })` | `Section:Toggle({ Name, Default, Flag = "Idx", Callback })` (`Text` works for `Name`) |
| `Groupbox:AddSlider("Idx", { Min, Max, Default, Rounding, Suffix })` | `Section:Slider({ Flag = "Idx", ... })` - same fields work |
| `Toggles.Idx:OnChanged(fn)` · `Options.Idx.Value` | `Proximity.Elements.Idx:OnChanged(fn)` · `Proximity.Flags.Idx` |
| `:AddKeyPicker("Idx", { Default, Mode })` · `:AddColorPicker("Idx", { Default })` | `toggle:Keybind({ Default, Mode })` · `toggle:ColorPicker({ Default })` |
| `ThemeManager`, `SaveManager` | `Window:SettingsTab()` - themes and configs are built in |
| `Library:Notify(text, time)` | `Proximity:Notify({ Content = text, Duration = time })` |
| `Library:Unload()` · `Library:OnUnload(fn)` | same |
