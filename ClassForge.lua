ClassForge = {}
ClassForge.prefix = "CLASSFORGE2"
ClassForge.version = "0.2.0"

local addon = CreateFrame("Frame")
ClassForge.frame = addon

addon:RegisterEvent("ADDON_LOADED")
addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:RegisterEvent("CHAT_MSG_ADDON")
addon:RegisterEvent("GROUP_ROSTER_UPDATE")
addon:RegisterEvent("GUILD_ROSTER_UPDATE")
addon:RegisterEvent("PLAYER_TARGET_CHANGED")
addon:RegisterEvent("WHO_LIST_UPDATE")
addon:RegisterEvent("FRIENDLIST_UPDATE")
addon:RegisterEvent("PLAYER_GUILD_UPDATE")

function ClassForge:NormalizePlayerName(name)
    if not name or name == "" then return nil end

    -- Remove realm suffix if present
    name = string.gsub(name, "%-.+$", "")

    -- Trim spaces
    name = string.gsub(name, "^%s+", "")
    name = string.gsub(name, "%s+$", "")

    return name
end

function ClassForge:GetDataForName(name)
    if not name or not ClassForgeCache then return nil end

    local cleanName = self:NormalizePlayerName(name)
    if not cleanName then return nil end

    -- Exact match
    if ClassForgeCache[cleanName] then
        return ClassForgeCache[cleanName]
    end

    -- Case-insensitive fallback
    local lowerClean = string.lower(cleanName)
    for cachedName, data in pairs(ClassForgeCache) do
        local cachedClean = self:NormalizePlayerName(cachedName)
        if cachedClean and string.lower(cachedClean) == lowerClean then
            return data
        end
    end

    return nil
end

local defaults = {
    profile = {
        enabled = true,
        className = "Hero",
        shortName = "HERO",
        color = "FFFFD100",
        role = "Wanderer",
        order = "Unaffiliated",
    }
}

local function CopyDefaults(src, dst)
    if type(src) ~= "table" then return {} end
    if type(dst) ~= "table" then dst = {} end

    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = CopyDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end

    return dst
end

addon:SetScript("OnEvent", function(self, event, ...)
    if ClassForge[event] then
        ClassForge[event](ClassForge, ...)
    end
end)

function ClassForge:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffClassForge|r: " .. tostring(msg))
end

function ClassForge:ADDON_LOADED(name)
    if name ~= "ClassForge" then return end

    ClassForgeDB = CopyDefaults(defaults, ClassForgeDB or {})
    ClassForgeCache = ClassForgeCache or {}
end

function ClassForge:PLAYER_LOGIN()
    if RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix(self.prefix)
    end

    self:SetupSlashCommands()
    self:CreateOptionsPanel()
    self:InitDisplay()
    self:BroadcastStartup()

    self:Print("Hero Server Edition loaded. Type |cffffff00/cf|r for commands.")
end

function ClassForge:PLAYER_ENTERING_WORLD()
    self:RequestSyncFromVisibleSources()
end

function ClassForge:GROUP_ROSTER_UPDATE()
    self:BroadcastSelf("PARTY")
    self:BroadcastSelf("RAID")
end

function ClassForge:GUILD_ROSTER_UPDATE()
    self:BroadcastSelf("GUILD")
    self:UpdateGuildRoster()
end

function ClassForge:PLAYER_GUILD_UPDATE()
    self:BroadcastSelf("GUILD")
    self:UpdateGuildRoster()
end

function ClassForge:PLAYER_TARGET_CHANGED()
    if UnitExists("target") and UnitIsPlayer("target") then
        local name = UnitName("target")
        if name then
            self:BroadcastSelf("WHISPER", name)
            self:UpdateTargetClassTag()
            self:UpdateInspectProfile()
        end
    else
        self:UpdateTargetClassTag()
        self:UpdateInspectProfile()
    end
end

function ClassForge:WHO_LIST_UPDATE()
    self:UpdateWhoList()
end

function ClassForge:FRIENDLIST_UPDATE()
    self:RequestSyncFromFriends()
end

function ClassForge:BroadcastStartup()
    self:BroadcastSelf("GUILD")
    self:BroadcastSelf("PARTY")
    self:BroadcastSelf("RAID")
end

function ClassForge:RequestSyncFromVisibleSources()
    self:RequestSyncFromFriends()
    self:RequestSyncFromWho()
    self:BroadcastStartup()
end