# Changelog

## 1.2.2 - built from points

- The loader planet is really assembled now: ~1500 points land on it while it turns, and a build front lays down ~500 surface tiles and the ring segment by segment exactly where they land - the points flash and fuse as it passes
- Planet and ring turn together around the planet's own tilted axis, in place; banded surface with storms so the turning is easy to see
- The burst waits for the planet to finish forming (sped up if the menu is already ready)
- Website: one shared scene - 3200 points and 2400 ring points land on the spinning WebGL planet, the far side shows through until the front closes, the surface grows under them
- Website: the hero planet is no longer cut off on the left on phones, and the left half of the ring no longer fades away after it forms

## 1.2.1 - a real planet

- The planet loader is now a drawn 3D model: points gather into a dark sphere with a lit crescent edge and a tilted glowing ring, then it spins while the menu builds
- Pick the loading screen in Settings: Planet, Menu skeleton or None (`Loading = { Style = "Skeleton" }` in code)
- Menu skeleton: diagonal shimmer, a small orbit spinner, time left, and a soft wipe that reveals the finished menu with sections fading in one by one
- The topbar planet button moves past buttons that games and other scripts put into the topbar
- Website: the hero planet is a live 3D render that the points condense into, and the Builder is a real editor - New element, an inspector for every option, reorder, duplicate, undo, download

## 1.2.0 - the planet intro

- Loading screen: dimmed screen, a 3D planet assembled from points that turns into the Proximity artwork, real progress with time left, a burst, and the window grows out of it
- Key system: keys, your own check or a URL, get-a-key button, attempt limit, remembered keys; `KeySystem = true / false`
- Window opens from and folds into a planet button next to the Roblox menu; icons-only navigation; mini mode; background image or gradient; keyboard and gamepad navigation; remembered scroll
- 9 toggle styles, ~50 fonts (Roblox families plus Monocraft, VT323, Silkscreen and more), density modes, chips in multi dropdowns, glow on the active tab and switches, risky stripe on sections
- Key combos (Ctrl+Shift+X), modifier-only binds, mode shown on the chip
- Player list element, range / select / switch filters in tables
- Notification center, what's new dialog, update check for Proximity and for your script
- Widgets: player panel with a 3D model, FPS and ping graph, stopwatch, custom HUD panels, watermark with 16 items and a live FPS line, inactive binds and sorting in the keybind list
- Configs: scrambled files with a checksum, a backup before every overwrite, undo delete, short share codes
- `OnError`, readable option warnings, debug overlay, automatic FPS saving, notice when an older copy is replaced
- Website with docs, a code generator and live executor status; the script is also served from the site

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
