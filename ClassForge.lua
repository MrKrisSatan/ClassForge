ClassForge = ClassForge or {}

ClassForge.name = "ClassForge"
ClassForge.prefix = "CLASSFORGE"
ClassForge.version = "2.5.6"
ClassForge.dbVersion = 4
ClassForge.homepage = "https://github.com/MrKrisSatan/ClassForge"
ClassForge.releasesPage = "https://github.com/MrKrisSatan/ClassForge/releases"

local addon = CreateFrame("Frame")
ClassForge.frame = addon

ClassForge.defaults = {
    character = {
        className = "Hero",
        color = "FFD100",
        role = "DPS",
    },
    profile = {
        enabled = true,
        targetProfilePosition = {
            point = "TOP",
            relativePoint = "BOTTOM",
            x = 0,
            y = -20,
        },
        targetProfile = {
            hidden = false,
            locked = false,
        },
        minimapButton = {
            angle = 225,
            hidden = false,
        },
        chat = {
            enabled = false,
        },
        names = {
            realmAware = false,
        },
        syncThrottle = {
            broadcast = 10,
            whisper = 20,
            who = 30,
        },
    },
}

local registeredEvents = {
    "ADDON_LOADED",
    "PLAYER_LOGIN",
    "PLAYER_ENTERING_WORLD",
    "CHAT_MSG_ADDON",
    "GROUP_ROSTER_UPDATE",
    "GUILD_ROSTER_UPDATE",
    "PLAYER_GUILD_UPDATE",
    "PLAYER_TARGET_CHANGED",
    "WHO_LIST_UPDATE",
    "FRIENDLIST_UPDATE",
    "INSPECT_READY",
}

for _, eventName in ipairs(registeredEvents) do
    addon:RegisterEvent(eventName)
end

addon:SetScript("OnEvent", function(_, event, ...)
    local handler = ClassForge[event]
    if handler then
        handler(ClassForge, ...)
    end
end)

function ClassForge:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffClassForge|r: " .. tostring(message))
end

function ClassForge:GetProfile()
    return ClassForgeDB and ClassForgeDB.profile or self.defaults.profile
end

function ClassForge:GetCurrentCharacterKey()
    local playerName = UnitName("player")
    local realmName = GetRealmName and GetRealmName() or nil

    playerName = self:Trim(playerName)
    realmName = self:GetNormalizedRealmName(realmName)

    if playerName == "" then
        return nil
    end

    if realmName and realmName ~= "" then
        return playerName .. "-" .. realmName
    end

    return playerName
end

function ClassForge:GetCharacterProfile()
    if not ClassForgeDB then
        return self.defaults.character
    end

    ClassForgeDB.characters = ClassForgeDB.characters or {}

    local characterKey = self:GetCurrentCharacterKey()
    if not characterKey then
        return self.defaults.character
    end

    ClassForgeDB.characters[characterKey] = self:CopyDefaults(self.defaults.character, ClassForgeDB.characters[characterKey] or {})
    return ClassForgeDB.characters[characterKey]
end

function ClassForge:EnsureCurrentCharacterProfile()
    local characterProfile = self:GetCharacterProfile()
    local globalProfile = self:GetProfile()

    if not characterProfile._migratedFromLegacy then
        local hasLegacyIdentity = globalProfile and (
            self:Trim(globalProfile.className) ~= ""
            or self:SanitizeHex(globalProfile.color)
            or self:NormalizeRole(globalProfile.role)
        )

        if hasLegacyIdentity then
            characterProfile.className = self:Trim(characterProfile.className) ~= "" and characterProfile.className or (self:Trim(globalProfile.className) ~= "" and self:Trim(globalProfile.className) or self.defaults.character.className)
            characterProfile.color = self:SanitizeHex(characterProfile.color) or self:SanitizeHex(globalProfile.color) or self.defaults.character.color
            characterProfile.role = self:NormalizeRole(characterProfile.role) or self:NormalizeRole(globalProfile.role) or self.defaults.character.role
        end

        characterProfile._migratedFromLegacy = true
    end

    return characterProfile
end

function ClassForge:BuildProfileData()
    local profile = self:GetCharacterProfile()

    return {
        className = self:Trim(profile.className) ~= "" and self:Trim(profile.className) or self.defaults.character.className,
        color = self:SanitizeHex(profile.color) or self.defaults.character.color,
        role = self:NormalizeRole(profile.role) or self.defaults.character.role,
        faction = self:GetUnitFaction("player") or "",
        addonVersion = self.version,
        updated = time(),
        source = "self",
    }
end

function ClassForge:RefreshPlayerCache()
    local playerName = UnitName("player")
    if not playerName then
        return nil
    end

    local data = self:BuildProfileData()
    self:SetDataForName(playerName, data)

    return data
end

function ClassForge:RefreshAllDisplays()
    if self.UpdateCharacterPanel then
        self:UpdateCharacterPanel()
    end
    if self.UpdateWhoList then
        self:UpdateWhoList()
    end
    if self.UpdateGuildRoster then
        self:UpdateGuildRoster()
    end
    if self.UpdateFriendsList then
        self:UpdateFriendsList()
    end
    if self.UpdateRaidBrowser then
        self:UpdateRaidBrowser()
    end
    if self.UpdateTargetClassTag then
        self:UpdateTargetClassTag()
    end
    if self.UpdateTargetProfile then
        self:UpdateTargetProfile()
    end
    if self.UpdateInspectFrame then
        self:UpdateInspectFrame()
    end
    if self.UpdateMapMemberColors then
        self:UpdateMapMemberColors()
    end
    if self.ScheduleMapMemberUpdate then
        self:ScheduleMapMemberUpdate(0)
    end
end

function ClassForge:ADDON_LOADED(name)
    if name == self.name then
        ClassForgeDB = self:CopyDefaults(self.defaults, ClassForgeDB or {})
        ClassForgeCache = ClassForgeCache or {}
        self:MigrateDatabase()
        return
    end

    if name == "Blizzard_InspectUI" and self.SetupInspectHooks then
        self:SetupInspectHooks()
        self:UpdateInspectFrame()
    end
end

function ClassForge:PLAYER_LOGIN()
    if RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix(self.prefix)
    end

    self.syncState = {
        broadcasts = {},
        whispers = {},
        who = {
            lastRun = 0,
        },
    }

    self:EnsureCurrentCharacterProfile()
    self:SetupSlashCommands()
    self:CreateOptionsPanel()
    self:InitDisplay()
    self:RefreshPlayerCache()
    self:BroadcastStartup()
    self:RefreshAllDisplays()
    self:Print("Loaded. Type |cffffff00/cf help|r for commands.")
end

function ClassForge:PLAYER_ENTERING_WORLD()
    self:RequestSyncFromFriends()
    self:PerformWhoSync()
end

function ClassForge:GROUP_ROSTER_UPDATE()
    self:BroadcastSelf("PARTY")
    self:BroadcastSelf("RAID")
    if self.ScheduleMapMemberUpdate then
        self:ScheduleMapMemberUpdate(0.05)
    end
end

function ClassForge:GUILD_ROSTER_UPDATE()
    self:UpdateGuildRoster()
end

function ClassForge:PLAYER_GUILD_UPDATE()
    self:BroadcastSelf("GUILD")
    self:UpdateGuildRoster()
end

function ClassForge:PLAYER_TARGET_CHANGED()
    self:UpdateTargetClassTag()
    self:UpdateTargetProfile()
    self:UpdateInspectFrame()

    if UnitExists("target") and UnitIsPlayer("target") then
        local targetName = UnitName("target")
        if targetName then
            self:RequestSyncFromName(targetName)
        end
    end

    if self.ScheduleMapMemberUpdate then
        self:ScheduleMapMemberUpdate(0)
    end
end

function ClassForge:WHO_LIST_UPDATE()
    self:ProcessWhoResults()
    self:UpdateWhoList()
end

function ClassForge:FRIENDLIST_UPDATE()
    self:UpdateFriendsList()
end

function ClassForge:INSPECT_READY()
    self:UpdateInspectFrame()
end
