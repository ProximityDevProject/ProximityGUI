# Changelog

## 1.1.0 - the planet

- The logo is the Proximity planet: drawn instantly, then the real artwork fades in (cached, needs getcustomasset)
- A large faint planet rests in the bottom-right corner of the window (Settings > Planet in the corner, or `Decoration = false`)
- `Icon` works on every row: toggles, dropdowns, inputs, keybinds, color pickers, navigate rows
- 130+ readable icon names for script features: `aimbot`, `esp`, `fly`, `farm`, `teleport`, `rejoin`, `anonymous` and more
- Sections show how many of their toggles are on, toggle icons light up when on
- Settings got icons on every row, an About block instead of the shortcut cheat sheet, and natural wording in English and Russian
- Header buttons have tooltips, bottom notifications stack from the bottom up
- Plain hyphens everywhere instead of long dashes

## 1.0.1 - first in-game test pass

- Popups, context menus, window drag and widget docking no longer shift by the Roblox topbar height
- `element:Options()` works (an internal field shadowed the method)
- Range slider value label, loading task progress and notification sizing fixed
- Unloading no longer switches off settings toggles (rim, watermark, keybind list)
- Keybind list has a fixed width; search ranks real matches first and shows full paths
- Theme dropdown and accent picker follow theme changes made from code

## 1.0.0 - first release

- Window with sidebar, categories, tabs, sub tabs, hidden sub pages with back navigation
- Loading skeleton with per-tab progress, developer tasks/steps, "Show now", minimum display time
- 30+ elements: toggle, checkbox, button, button group, slider, range slider, text slider, dropdown, multi dropdown, player dropdown, input, keybind, color picker with alpha, label, paragraph, divider, spacer, navigate, progress, stat, stat grid, graph, table, card, image, console, code
- Section toggle header, tabs inside sections, collapsible sections, floating option panels
- Configs: save, load, delete, rename, duplicate, diff, export/import strings, auto load, auto save, migrations
- Themes: six monochrome presets, custom accent, theme editor, export/import
- Ctrl+K palette, undo/redo, context menu, favorites, tour, anonymous mode, RU/EN locale
- Notifications with actions, watermark, keybind list, corner docking
