ClassForge = ClassForge or {}

ClassForge.name = "ClassForge"
ClassForge.prefix = "CLASSFORGE"
ClassForge.version = "1.0.0"

local addon = CreateFrame("Frame")
ClassForge.frame = addon

ClassForge.defaults = {
    profile = {
        enabled = true,
        className = "Hero",
        color = "FFD100",
        role = "DPS",
        order = "",
        targetProfilePosition = {
            point = "TOP",
            relativePoint = "BOTTOM",
            x = 0,
            y = -20,
        },
        minimapButton = {
            angle = 225,
            hidden = false,
        },
        chat = {
            enabled = false,
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

function ClassForge:BuildProfileData()
    local profile = self:GetProfile()

    return {
        className = self:Trim(profile.className) ~= "" and self:Trim(profile.className) or self.defaults.profile.className,
        color = self:SanitizeHex(profile.color) or self.defaults.profile.color,
        role = self:NormalizeRole(profile.role) or self.defaults.profile.role,
        order = self:Trim(profile.order),
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
end

function ClassForge:ADDON_LOADED(name)
    if name == self.name then
        ClassForgeDB = self:CopyDefaults(self.defaults, ClassForgeDB or {})
        ClassForgeCache = ClassForgeCache or {}
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
