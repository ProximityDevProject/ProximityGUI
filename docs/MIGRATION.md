# Migration

Proximity accepts the most common names from other libraries, so many scripts move over by changing the loader line and a few options.

## From CompKiller

| CompKiller | Proximity |
|---|---|
| `Compkiller.new({ Name, Keybind, Logo })` | `Proximity:Window({ Title, Keybind, Logo })` (`Name` also works) |
| `Window:DrawCategory({ Name })` | same (`Window:Category(name)`) |
| `Window:DrawTab({ Name, Icon, Type = "Single" })` | `Window:Tab({ Name, Icon })` — sections pick `Side`; one column with `Side = "Full"` |
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
| `IsFirstElement / IsLastElement` | not needed — rounding is automatic |
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
