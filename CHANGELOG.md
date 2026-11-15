# Changelog

## 1.0.1 — first in-game test pass

- Popups, context menus, window drag and widget docking no longer shift by the Roblox topbar height
- `element:Options()` works (an internal field shadowed the method)
- Range slider value label, loading task progress and notification sizing fixed
- Unloading no longer switches off settings toggles (rim, watermark, keybind list)
- Keybind list has a fixed width; search ranks real matches first and shows full paths
- Theme dropdown and accent picker follow theme changes made from code

## 1.0.0 — first release

- Window with sidebar, categories, tabs, sub tabs, hidden sub pages with back navigation
- Loading skeleton with per-tab progress, developer tasks/steps, "Show now", minimum display time
- 30+ elements: toggle, checkbox, button, button group, slider, range slider, text slider, dropdown, multi dropdown, player dropdown, input, keybind, color picker with alpha, label, paragraph, divider, spacer, navigate, progress, stat, stat grid, graph, table, card, image, console, code
- Section toggle header, tabs inside sections, collapsible sections, floating option panels
- Configs: save, load, delete, rename, duplicate, diff, export/import strings, auto load, auto save, migrations
- Themes: six monochrome presets, custom accent, theme editor, export/import
- Ctrl+K palette, undo/redo, context menu, favorites, tour, anonymous mode, RU/EN locale
- Notifications with actions, watermark, keybind list, corner docking
