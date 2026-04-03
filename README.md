ClassForge for Wrath of the Lich King 3.3.5a

Core commands:

`/cf help`
`/cf setclass <name>`
`/cf setcolor <hex>`
`/cf setrole <Heal|Tank|DPS>`
`/cf setorder <order>`
`/cf show`
`/cf sync`
`/cf resetpanel`
`/cf reset`
`/cf options`

What it does:

- Saves your custom class name, class colour, role, and order in SavedVariables.
- Shares your profile with other addon users through `SendAddonMessage`.
- Caches received player data by normalized player name.
- Displays custom class data in tooltips, `/who`, guild roster, friends list, character panel, target tag, inspect panel, and a target-side profile box.
- `/cf sync` refreshes your own cache entry, runs a `/who` sync pass, seeds placeholder records for new results, and requests addon data from visible players.
- Sync traffic is throttled to reduce whisper and channel spam during repeated updates.
- The target profile panel can be moved with `Shift` + drag and reset with `/cf resetpanel`.
