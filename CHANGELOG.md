# Changelog

## 3.5.0 - 2026-04-06

### Added
- ClassForge combat meter with a dedicated `Meter` options tab.
- Movable on-screen meter box with saved position and lock support.
- Meter settings for:
  - show/hide meter box
  - lock position
  - max displayed DPS rows
  - DPS rankings
  - top damage spell
  - highest threat on current target
  - healing leader
- Meter reset controls for both position and live combat data.
- Export controls for sending the current meter table to chat.
- Export targets for `Party`, `Raid`, `Guild`, `Officer`, `Say`, `Yell`, and custom `Channel` names such as `world`.
- On-box export button for quickly sending the current meter without opening options.
- Table-based meter display with one row per player.

### Changed
- Meter rows now display as `PlayerName (Custom Class)`.
- Meter output now uses ClassForge custom class identities and colors where cached data exists.
- Role handling now defaults to Blizzard’s selected role and falls back to `Damage` when no Blizzard role is selected.
- Version bumped to `3.5.0`.

### Fixed
- Meter tracking now works outside groups as well as in parties and raids.
- Added `UNIT_COMBAT` fallback support for private/custom 3.3.5a clients where `COMBAT_LOG_EVENT_UNFILTERED` is incomplete or nonstandard.
- Combat source tracking was relaxed to support classless/private-client payload differences.
- Combat amount parsing was made more tolerant of modified Wrath event payload layouts.

## 3.1.0 - 2026-04-05

### Added
- Language selection in options with `English`, `Español`, and `Русский`.
- Translation tables and locale helpers for addon-owned text.
- Localized labels for the main options UI, tabs, preview block, status text, tooltip labels, friends hover tooltip labels, minimap button tooltip, target profile labels, and out-of-date version warnings.
- Automatic role detection from Blizzard's selected group role.
- Event-driven role refresh when talents/spec/assigned role changes.
- Read-only role display in options with a note explaining that the Blizzard-selected role is used.

### Changed
- The addon now prefers the Blizzard-selected role instead of a manual ClassForge role selector.
- If Blizzard has no selected role, ClassForge now defaults to `Damage`.
- The options panel no longer uses a manual role dropdown.
- Spanish and Russian localization text was upgraded from placeholder/transliterated labels to proper localized strings.
- Version bumped to `3.1.0`.

### Fixed
- Target profile hint text, refresh button text, and other visible display labels now update correctly with the selected addon language.
- Inspect, tooltip, target, preview, and friends tooltip role text now use localized role display names consistently.

## 3.0.0 - 2026-04-05

### Added
- Options toggles for background `/who` sync on login and group changes.
- Sync status in options showing last sync, last `/who` completion, and known addon users.
- Cache browser search in the options panel.
- Compact mode for the target profile panel.
- Refresh button on the target profile panel to request a live update from the current target.
- Optional custom-color party and raid frame name coloring.
- Colored stale-data age cues for tooltip and profile freshness.

### Changed
- Background `/who` sync now stays silent and restores the social UI after results.
- Target profile layout now supports both full and compact presentation.
- Version bumped to `3.0.0`.

### Fixed
- Raid browser name coloring now restores correctly when custom group-frame coloring is turned off.
- Cache browser search now updates the known-players list immediately.
