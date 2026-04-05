ClassForge for Wrath of the Lich King 3.3.5a

Core commands:

`/cf help`
`/cf setclass <name>`
`/cf setcolor <hex>`
`/cf setrole <Heal|Tank|DPS>`
`/cf realmaware on|off`
`/cf show`
`/cf sync`
`/cf showminimap`
`/cf hideminimap`
`/cf resetminimap`
`/cf chattags on|off`
`/cf showpanel`
`/cf hidepanel`
`/cf lockpanel`
`/cf unlockpanel`
`/cf resetpanel`
`/cf reset`
`/cf options`

What it does:

- Saves your custom class name, class colour, and role in SavedVariables, and syncs the character's faction automatically.
- Shares your profile with other addon users through `SendAddonMessage`.
- Caches received player data by normalized player name.
- Displays custom class data in tooltips, `/who`, guild roster, friends list, character panel, target tag, inspect panel, and a target-side profile box.
- `/cf sync` refreshes your own cache entry, runs a `/who` sync pass, seeds placeholder records for new results, and requests addon data from visible players.
- Sync traffic is throttled to reduce whisper and channel spam during repeated updates.
- Background `/who` syncing can now be toggled for login and group changes separately in options.
- The target profile panel can be moved with `Shift` + drag and reset with `/cf resetpanel`.
- The target profile panel now has a compact mode and a refresh button for the current target.
- The minimap button can be dragged, hidden, shown, and reset.
- Cached player data now shows freshness timestamps, and the options panel can clear stale or all cache entries.
- The cache browser now supports search for fast player lookups.
- Addon sync now carries addon version info and warns on mismatches.
- Tooltips and inspect/target views now show data source, freshness, and addon version when available.
- The options panel now includes a known-player browser and optional chat class tags for confirmed addon users.
- Party and raid frame names can be recolored with custom class colors.
- SavedVariables now use schema migration so profile and cache changes are upgraded forward on load.
- The target profile panel can now be hidden, shown, locked, unlocked, and reset.
- Realm-aware naming can be enabled for servers that expose realm suffixes.
- The options panel is split into Profile, Display, and Cache tabs.
