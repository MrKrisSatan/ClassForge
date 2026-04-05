# Changelog

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
