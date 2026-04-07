ClassForge = ClassForge or {}

ClassForge.autoClassPresets = {
    {
        name = "Abyssal Dreadstorm",
        color = "6A0DAD",
        description = "A walking calamity clad in flesh and fury, the Abyssal Dreadstorm is a harbinger of ruin that blurs the line between blade and cataclysm. Drawing power from the howling void beneath reality, they weave brutal melee strikes with surging tides of abyssal energy, tearing through enemies in a relentless storm of steel and shadow. Each swing feeds the tempest within, building toward devastating spellbursts that crack the battlefield open like a wound. To face a Dreadstorm is not to duel a warrior, but to stand against an oncoming apocalypse given form.",
        required = { "Blood Presence", "Sinister Strike", "Flametongue Weapon", "Seal of Righteousness" },
        weights = { ["Blood Presence"] = 6, ["Sinister Strike"] = 6, ["Flametongue Weapon"] = 6, ["Seal of Righteousness"] = 6, ["Shadow Bolt"] = 2, ["Earth Shock"] = 2 },
        minScore = 24,
    },
    {
        name = "Stormbrand Striker",
        color = "00BFFF",
        description = "A crackling weapon-channeler, the Stormbrand Striker binds elemental force to every swing. Flametongue, Stormstrike, and sudden shocks turn their melee rhythm into a rolling thunderhead of steel and lightning.",
        requiredAny = { "Stormstrike", "Flametongue Weapon", "Earth Shock" },
        weights = { ["Stormstrike"] = 7, ["Flametongue Weapon"] = 6, ["Earth Shock"] = 5, ["Lightning Shield"] = 4, ["Strength of Earth Totem"] = 3, ["Searing Totem"] = 3, ["Rockbiter Weapon"] = 2 },
        minScore = 25,
    },
    {
        name = "Thunderbrand Adept",
        color = "1E90FF",
        description = "A volatile shockcaster, the Thunderbrand Adept fights like a storm breaking through mortal skin. Lightning, shocks, and totemic fire strike in jagged rhythm until the battlefield feels charged enough to split.",
        requiredAny = { "Lightning Bolt", "Earth Shock", "Flame Shock" },
        weights = { ["Lightning Bolt"] = 6, ["Earth Shock"] = 6, ["Flame Shock"] = 5, ["Searing Totem"] = 5, ["Lightning Shield"] = 3, ["Flametongue Weapon"] = 2 },
        minScore = 24,
    },
    {
        name = "Magma Totemist",
        color = "FF4500",
        description = "A fire-totem battlecaller, the Magma Totemist pins enemies inside a furnace of shocks, flame, and summoned heat. They do not chase the fight so much as make the ground itself hostile.",
        requiredAny = { "Searing Totem", "Flame Shock", "Fire Blast" },
        weights = { ["Searing Totem"] = 7, ["Flame Shock"] = 6, ["Fire Blast"] = 5, ["Fireball"] = 4, ["Immolate"] = 3, ["Earthbind Totem"] = 2 },
        minScore = 24,
    },
    {
        name = "Runeblade Ravager",
        color = "C41E3A",
        description = "A death-charged melee executioner, the Runeblade Ravager turns presence, plague, and weapon strikes into a ruthless close-range engine. They carve through enemies with runic pressure and blood-fed momentum, building every exchange toward a killing blow.",
        requiredAny = { "Blood Presence", "Blood Strike", "Plague Strike", "Obliterate" },
        weights = { ["Blood Presence"] = 6, ["Blood Strike"] = 6, ["Plague Strike"] = 5, ["Obliterate"] = 5, ["Death Strike"] = 4, ["Icy Touch"] = 3, ["Death Coil"] = 2 },
        minScore = 24,
    },
    {
        name = "Plagueforged Butcher",
        color = "8B0000",
        description = "A gore-slick runebrawler, the Plagueforged Butcher spreads sickness with one hand and carves openings with the other. Every strike feels less like swordplay and more like a wound learning to walk.",
        requiredAny = { "Plague Strike", "Blood Boil", "Icy Touch" },
        weights = { ["Plague Strike"] = 7, ["Blood Boil"] = 6, ["Icy Touch"] = 5, ["Blood Strike"] = 4, ["Death and Decay"] = 4, ["Unholy Presence"] = 3 },
        minScore = 24,
    },
    {
        name = "Radiant Blade",
        color = "F48CBA",
        description = "A holy melee champion, the Radiant Blade carries divine judgment into the front line. Seals, crusader strikes, and righteous force turn their weapon into a bright sentence passed on anything foolish enough to stand close.",
        requiredAny = { "Seal of Righteousness", "Crusader Strike", "Judgement of Light" },
        weights = { ["Seal of Righteousness"] = 6, ["Crusader Strike"] = 7, ["Judgement of Light"] = 5, ["Judgement of Wisdom"] = 5, ["Blessing of Might"] = 4, ["Consecration"] = 3, ["Devotion Aura"] = 2 },
        minScore = 25,
    },
    {
        name = "Sunlit Executor",
        color = "FFDE59",
        description = "A bright-handed enforcer, the Sunlit Executor blends righteous seals, holy bursts, and blunt conviction. Their magic does not soothe first; it judges, burns, and only then decides whether mercy is useful.",
        requiredAny = { "Smite", "Seal of Righteousness", "Holy Light" },
        weights = { ["Smite"] = 6, ["Seal of Righteousness"] = 5, ["Holy Light"] = 4, ["Blessing of Might"] = 4, ["Power Word: Fortitude"] = 3, ["Power Word: Shield"] = 3 },
        minScore = 23,
    },
    {
        name = "Shadowcut Duelist",
        color = "2B2B2B",
        description = "A quick-handed melee opportunist, the Shadowcut Duelist wins through openings, poisons, and vicious precision. Sinister Strike, Slice and Dice, and finishing blows make them less a soldier than a sudden bad decision with a blade.",
        requiredAny = { "Sinister Strike", "Backstab", "Eviscerate" },
        weights = { ["Sinister Strike"] = 7, ["Slice and Dice"] = 6, ["Eviscerate"] = 5, ["Backstab"] = 5, ["Gouge"] = 4, ["Stealth"] = 3, ["Sprint"] = 2 },
        minScore = 24,
    },
    {
        name = "Gutterblade Stalker",
        color = "3B0A45",
        description = "A dirty-fighting ambusher, the Gutterblade Stalker survives by never letting a fight become fair. Gouges, backstabs, sudden sprints, and cruel openings turn panic into a weapon.",
        requiredAny = { "Backstab", "Gouge", "Stealth" },
        weights = { ["Backstab"] = 7, ["Gouge"] = 6, ["Stealth"] = 5, ["Sprint"] = 4, ["Sinister Strike"] = 3, ["Evasion"] = 3 },
        minScore = 24,
    },
    {
        name = "Feral Ripper",
        color = "FF7C0A",
        description = "A shapeshifting predator, the Feral Ripper fights from instinct, momentum, and blood on the ground. Cat Form, Claw, and Rip make every second in melee feel like being hunted by the wild itself.",
        requiredAny = { "Cat Form", "Claw", "Rip" },
        weights = { ["Cat Form"] = 7, ["Claw"] = 6, ["Rip"] = 6, ["Prowl"] = 4, ["Feral Charge - Cat"] = 4, ["Mark of the Wild"] = 2 },
        minScore = 24,
    },
    {
        name = "Moonclaw Mystic",
        color = "7FFFD4",
        description = "A lunar predator, the Moonclaw Mystic mixes animal violence with moonlit curses and roots. One moment they are claw and fang; the next, the sky itself is bleeding silver into the fight.",
        requiredAny = { "Cat Form", "Moonfire", "Wrath" },
        weights = { ["Cat Form"] = 6, ["Moonfire"] = 6, ["Wrath"] = 5, ["Entangling Roots"] = 4, ["Mark of the Wild"] = 3, ["Rejuvenation"] = 2 },
        minScore = 24,
    },
    {
        name = "Iron Mauler",
        color = "708090",
        description = "A brutal front-line bruiser, the Iron Mauler turns raw weapon pressure into steady ruin. Heroic Strike, Battle Shout, and heavy defensive instincts keep them planted in the fight long after softer killers would break.",
        requiredAny = { "Heroic Strike", "Victory Rush", "Battle Stance" },
        weights = { ["Heroic Strike"] = 6, ["Battle Shout"] = 5, ["Victory Rush"] = 5, ["Bloodrage"] = 4, ["Battle Stance"] = 4, ["Rend"] = 3, ["Thunder Clap"] = 2 },
        minScore = 24,
    },
    {
        name = "Thunderfoot Bruiser",
        color = "C69B6D",
        description = "A brawling shock-trooper, the Thunderfoot Bruiser opens space with thunder, rage, and weapon pressure. Their style is not elegant, but very little remains standing long enough to complain.",
        requiredAny = { "Thunder Clap", "Bloodrage", "Heroic Strike" },
        weights = { ["Thunder Clap"] = 7, ["Bloodrage"] = 5, ["Heroic Strike"] = 5, ["Battle Shout"] = 4, ["Sunder Armor"] = 3, ["Defensive Stance"] = 2 },
        minScore = 24,
    },
    {
        name = "Wildfang Warden",
        color = "AAD372",
        description = "A rugged beast-side skirmisher, the Wildfang Warden mixes hunter discipline with close-range savagery. Raptor Strike, Mongoose Bite, and animal instinct make them dangerous even when the fight collapses into tooth-and-claw range.",
        requiredAny = { "Raptor Strike", "Mongoose Bite", "Aspect of the Monkey" },
        weights = { ["Raptor Strike"] = 7, ["Mongoose Bite"] = 6, ["Aspect of the Monkey"] = 5, ["Hunter's Mark"] = 4, ["Tame Beast"] = 3, ["Serpent Sting"] = 3 },
        minScore = 24,
    },
    {
        name = "Hawkeye Skirmisher",
        color = "9ACD32",
        description = "A mobile bow-fighter, the Hawkeye Skirmisher marks prey, keeps distance, and threads shots through the chaos. When cornered, they still have enough bite to make pursuit expensive.",
        requiredAny = { "Arcane Shot", "Auto Shot", "Steady Shot" },
        weights = { ["Arcane Shot"] = 7, ["Auto Shot"] = 6, ["Steady Shot"] = 6, ["Aspect of the Hawk"] = 5, ["Hunter's Mark"] = 4, ["Concussive Shot"] = 3, ["Serpent Sting"] = 3 },
        minScore = 24,
    },
    {
        name = "Felbrand Reaver",
        color = "8788EE",
        description = "A fel-touched aggressor, the Felbrand Reaver mixes weapon pressure with curses, flame, and demonic attrition. They do not simply cut enemies down; they make the wound burn, linger, and answer to darker powers.",
        requiredAny = { "Immolate", "Corruption", "Shadow Bolt" },
        weights = { ["Demon Skin"] = 4, ["Immolate"] = 6, ["Corruption"] = 6, ["Curse of Agony"] = 5, ["Shadow Bolt"] = 5, ["Life Tap"] = 4, ["Drain Soul"] = 3 },
        minScore = 24,
    },
    {
        name = "Soulburn Hexer",
        color = "9932CC",
        description = "A curse-driven executioner, the Soulburn Hexer lets agony do the stalking while shadow and flame finish the argument. Their enemies rarely fall cleanly; they unravel.",
        requiredAny = { "Curse of Agony", "Drain Soul", "Corruption" },
        weights = { ["Curse of Agony"] = 7, ["Drain Soul"] = 6, ["Corruption"] = 6, ["Shadow Bolt"] = 4, ["Life Tap"] = 4, ["Fear"] = 3, ["Summon Imp"] = 2 },
        minScore = 24,
    },
    {
        name = "Frostfire Savant",
        color = "3FC7EB",
        description = "A dueling arcanist, the Frostfire Savant switches between freezing control, burning punishment, and raw arcane force. Their spellbook is less a school and more a loaded argument.",
        requiredAny = { "Frostbolt", "Fireball", "Arcane Missiles" },
        weights = { ["Frostbolt"] = 6, ["Fireball"] = 6, ["Arcane Missiles"] = 6, ["Fire Blast"] = 5, ["Frost Nova"] = 4, ["Arcane Intellect"] = 3, ["Mage Armor"] = 2 },
        minScore = 24,
    },
    {
        name = "Arcane Barragewright",
        color = "B87333",
        description = "A precision spellwright, the Arcane Barragewright shapes missiles, intellect, and sudden blasts into a clean mathematical violence. Everything about them suggests calculation until the air explodes.",
        requiredAny = { "Arcane Missiles", "Arcane Intellect", "Fire Blast" },
        weights = { ["Arcane Missiles"] = 7, ["Arcane Intellect"] = 5, ["Fire Blast"] = 5, ["Frost Nova"] = 3, ["Mage Armor"] = 3, ["Polymorph"] = 2 },
        minScore = 23,
    },
    {
        name = "Void Psalmist",
        color = "4B0082",
        description = "A shadow-prayer combatant, the Void Psalmist threads pain, mind force, and stolen breath into a hymn no sane enemy wants to hear twice. Their faith does not shine; it listens from the dark.",
        requiredAny = { "Shadow Word: Pain", "Mind Blast", "Smite" },
        weights = { ["Shadow Word: Pain"] = 7, ["Mind Blast"] = 6, ["Smite"] = 4, ["Power Word: Shield"] = 4, ["Power Word: Fortitude"] = 3, ["Renew"] = 2 },
        minScore = 24,
    },
    {
        name = "Battle Cleric",
        color = "FFFFFF",
        description = "A stubborn light-bearing combatant, the Battle Cleric survives by layering faith, protection, and punishment. Shields and blessings keep them moving while holy strikes and steady pressure wear the enemy down.",
        requiredAny = { "Smite", "Power Word: Shield", "Renew" },
        weights = { ["Power Word: Shield"] = 6, ["Power Word: Fortitude"] = 4, ["Smite"] = 6, ["Renew"] = 4, ["Greater Heal"] = 3, ["Holy Light"] = 2 },
        minScore = 23,
    },
    {
        name = "Blightshot Ranger",
        color = "556B2F",
        description = "A poison-and-arrow opportunist, the Blightshot Ranger stacks marks, stings, and quick shots until the target is fighting the wound as much as the hunter.",
        requiredAny = { "Serpent Sting", "Arcane Shot", "Hunter's Mark" },
        weights = { ["Serpent Sting"] = 7, ["Arcane Shot"] = 6, ["Hunter's Mark"] = 5, ["Auto Shot"] = 4, ["Concussive Shot"] = 3, ["Aspect of the Hawk"] = 3 },
        minScore = 24,
    },
    {
        name = "Emberknife Adept",
        color = "FF6347",
        description = "A close-range pyromancer, the Emberknife Adept prefers enemies near enough to see the fear arrive. Fire blasts, burning curses, and sudden blade work turn every fight into a flashover.",
        requiredAny = { "Fire Blast", "Immolate", "Sinister Strike" },
        weights = { ["Fire Blast"] = 6, ["Immolate"] = 6, ["Sinister Strike"] = 5, ["Flametongue Weapon"] = 4, ["Seal of Righteousness"] = 3, ["Fireball"] = 3 },
        minScore = 24,
    },
    {
        name = "Starshot Invoker",
        color = "4169E1",
        description = "A ranged spell-archer, the Starshot Invoker mixes missiles, moonfire, and marked shots into a strange celestial volley. Their best fights end before the enemy decides whether to raise a shield or look up.",
        requiredAny = { "Arcane Shot", "Arcane Missiles", "Moonfire" },
        weights = { ["Arcane Shot"] = 6, ["Arcane Missiles"] = 6, ["Moonfire"] = 6, ["Hunter's Mark"] = 4, ["Wrath"] = 3, ["Auto Shot"] = 3 },
        minScore = 24,
    },
    {
        name = "Gravefire Channeler",
        color = "800000",
        description = "A death-and-flame channeler, the Gravefire Channeler feeds shadow into fire until both become indistinguishable. Bolts, burns, and death magic gather around them like smoke around a battlefield pyre.",
        requiredAny = { "Shadow Bolt", "Death Coil", "Immolate" },
        weights = { ["Shadow Bolt"] = 6, ["Death Coil"] = 6, ["Immolate"] = 5, ["Corruption"] = 4, ["Icy Touch"] = 3, ["Drain Soul"] = 3 },
        minScore = 24,
    },
    {
        name = "Rootstorm Warden",
        color = "228B22",
        description = "A battlefield controller, the Rootstorm Warden turns nature magic into a trap that bites back. Roots, thorns, moonfire, and healing keep the fight exactly where they want it.",
        requiredAny = { "Entangling Roots", "Thorns", "Moonfire" },
        weights = { ["Entangling Roots"] = 7, ["Thorns"] = 5, ["Moonfire"] = 5, ["Wrath"] = 4, ["Mark of the Wild"] = 4, ["Rejuvenation"] = 3 },
        minScore = 23,
    },
    {
        name = "Bulwark Mystic",
        color = "AFEEEE",
        description = "A defensive spellguard, the Bulwark Mystic layers shields, armor, auras, and stubborn magic into a wall that still knows how to strike back.",
        requiredAny = { "Power Word: Shield", "Frost Armor", "Devotion Aura" },
        weights = { ["Power Word: Shield"] = 6, ["Frost Armor"] = 5, ["Devotion Aura"] = 5, ["Divine Protection"] = 4, ["Stoneskin Totem"] = 4, ["Smite"] = 2 },
        minScore = 23,
    },
}

local generatedAutoClassThemes = {
    { suffix = "Stormblade", color = "00BFFF", spells = { "Lightning Bolt", "Earth Shock", "Flame Shock", "Searing Totem" }, description = "storm-charged fighter who turns shocks, bolts, and crackling pressure into a fast battlefield rhythm." },
    { suffix = "Sunbreaker", color = "FFD700", spells = { "Smite", "Seal of Righteousness", "Blessing of Might", "Holy Light" }, description = "radiant combatant who carries light into the first exchange and makes every strike feel like judgment." },
    { suffix = "Voidscar", color = "6A0DAD", spells = { "Shadow Word: Pain", "Shadow Bolt", "Corruption", "Mind Blast" }, description = "shadow-marked caster who lets pain, void, and psychic pressure do the stalking." },
    { suffix = "Bulwark", color = "708090", spells = { "Defensive Stance", "Sunder Armor", "Devotion Aura", "Shield of Righteousness" }, description = "shield-minded defender who turns stance work, armor breaks, and holy protection into a stubborn front line." },
    { suffix = "Stonehide", color = "556B2F", spells = { "Bear Form", "Stoneclaw Totem", "Stoneskin Totem", "Thorns" }, description = "earthbound guardian who layers hide, thorns, and stone totems into a wall that bites back." },
    { suffix = "Rockbreaker", color = "B87333", spells = { "Rockbiter Weapon", "Thunder Clap", "Righteous Fury", "Lightning Shield" }, description = "threat-hungry bruiser who uses rockbiter force, thunder, and fury to keep danger focused on them." },
    { suffix = "Wildclaw", color = "FF7C0A", spells = { "Cat Form", "Claw", "Moonfire", "Mark of the Wild" }, description = "wild predator who blends instinct, claws, and nature magic into a hungry opening rush." },
    { suffix = "Lifebloom", color = "00FF98", spells = { "Healing Wave", "Rejuvenation", "Healing Touch", "Renew" }, description = "restorative mystic who keeps wounds closing through waves, blossoms, and quiet persistence." },
    { suffix = "Lightwell", color = "FFFFFF", spells = { "Power Word: Shield", "Holy Light", "Greater Heal", "Renew" }, description = "radiant protector who answers disaster with shields, light, and patient recovery magic." },
    { suffix = "Wisdomtide", color = "20B2AA", spells = { "Seal of Wisdom", "Healing Wave", "Hand of Protection", "Mage Armor" }, description = "resourceful field healer who survives through wisdom, protection, and steady healing cadence." },
    { suffix = "Ironhowl", color = "C69B6D", spells = { "Heroic Strike", "Battle Shout", "Victory Rush", "Bloodrage" }, description = "stubborn weapon fighter who answers danger with rage, steel, and a refusal to step back." },
    { suffix = "Guardfang", color = "9ACD32", spells = { "Raptor Strike", "Evasion", "Aspect of the Monkey", "Demon Skin" }, description = "avoidance fighter who survives through animal reflexes, evasive movement, and close-range punishment." },
}

local generatedAutoClassForms = {
    { prefix = "Acolyte", spells = { "Power Word: Shield", "Renew" }, description = "They are still raw, but already dangerous when their spell kit starts to line up." },
    { prefix = "Duelist", spells = { "Sinister Strike", "Gouge" }, description = "They prefer close openings, quick reads, and turning one clean hit into momentum." },
    { prefix = "Vanguard", spells = { "Defensive Stance", "Sunder Armor" }, description = "They step forward first, using defensive habits and armor pressure to define the fight." },
    { prefix = "Bulwark", spells = { "Righteous Fury", "Devotion Aura" }, description = "They are built to draw attention and stay upright while the field settles around them." },
    { prefix = "Mender", spells = { "Healing Wave", "Holy Light" }, description = "They lean toward recovery, turning a fragile roll into a surprisingly steady lifeline." },
    { prefix = "Preserver", spells = { "Rejuvenation", "Greater Heal" }, description = "They keep allies in the fight through patient restoration and one decisive answer to crisis." },
}

for _, theme in ipairs(generatedAutoClassThemes) do
    for _, form in ipairs(generatedAutoClassForms) do
        local weights = {}
        local requiredAny = {}
        for _, spellName in ipairs(theme.spells) do
            weights[spellName] = 6
            requiredAny[#requiredAny + 1] = spellName
        end
        for _, spellName in ipairs(form.spells) do
            weights[spellName] = (weights[spellName] or 0) + 4
            requiredAny[#requiredAny + 1] = spellName
        end

        ClassForge.autoClassPresets[#ClassForge.autoClassPresets + 1] = {
            name = form.prefix .. " " .. theme.suffix,
            color = theme.color,
            description = "A " .. theme.description .. " " .. form.description,
            requiredAny = requiredAny,
            weights = weights,
            minScore = 23,
        }
    end
end
