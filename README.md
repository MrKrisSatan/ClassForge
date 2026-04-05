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
<br>
<img width="437" height="570" alt="who" src="https://github.com/user-attachments/assets/88e6291c-8e28-419e-9a64-2953f8921909" />
<img width="1077" height="825" alt="options3" src="https://github.com/user-attachments/assets/040b03ca-7a31-48f4-b5ca-92ce2c814497" />
<img width="1065" height="818" alt="options2" src="https://github.com/user-attachments/assets/a5902fab-27d8-452f-83b1-b5e089d7595f" />
<img width="1070" height="821" alt="options1" src="https://github.com/user-attachments/assets/5ba30417-164d-42e7-a01f-dfd97326fe41" />
<img width="428" height="571" alt="guild" src="https://github.com/user-attachments/assets/31ffe614-0722-4c5d-b6db-bb9c712540be" />
<img width="436" height="579" alt="friends" src="https://github.com/user-attachments/assets/a1940486-a2d2-4feb-8430-3c53940b775f" />

