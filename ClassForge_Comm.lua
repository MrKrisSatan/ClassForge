local function encodeField(value)
    value = tostring(value or "")
    value = value:gsub("%%", "%%25")
    value = value:gsub("|", "%%7C")
    return value
end

local function decodeField(value)
    value = tostring(value or "")
    value = value:gsub("%%7[Cc]", "|")
    value = value:gsub("%%25", "%%")
    return value
end

function ClassForge:SerializeData(data)
    return table.concat({
        "CF2",
        encodeField(self.version or "1.0.0"),
        encodeField(data.className or ""),
        encodeField(self:SanitizeHex(data.color) or self.defaults.character.color),
        encodeField(self:NormalizeRole(data.role) or self.defaults.character.role),
        encodeField(data.order or ""),
    }, "|")
end

function ClassForge:GetThrottleValue(kind)
    local profile = self:GetProfile()
    local syncThrottle = profile and profile.syncThrottle or nil
    local value = syncThrottle and syncThrottle[kind] or nil

    return tonumber(value) or 0
end

function ClassForge:CanSendBroadcast(channel, target)
    self.syncState = self.syncState or { broadcasts = {}, whispers = {}, who = { lastRun = 0 } }

    local now = time()
    if channel == "WHISPER" then
        local key = self:GetPlayerKey(target)
        if not key then
            return false
        end

        local interval = self:GetThrottleValue("whisper")
        local lastSent = self.syncState.whispers[key] or 0
        if interval > 0 and (now - lastSent) < interval then
            return false
        end

        self.syncState.whispers[key] = now
        return true
    end

    local interval = self:GetThrottleValue("broadcast")
    local lastSent = self.syncState.broadcasts[channel] or 0
    if interval > 0 and (now - lastSent) < interval then
        return false
    end

    self.syncState.broadcasts[channel] = now
    return true
end

function ClassForge:CanRunWhoSync()
    self.syncState = self.syncState or { broadcasts = {}, whispers = {}, who = { lastRun = 0 } }

    local interval = self:GetThrottleValue("who")
    local now = time()
    local lastRun = self.syncState.who.lastRun or 0
    if interval > 0 and (now - lastRun) < interval then
        return false
    end

    self.syncState.who.lastRun = now
    return true
end

function ClassForge:DeserializeData(message)
    if type(message) ~= "string" then
        return nil
    end

    local protocol, addonVersion, className, color, role, order = strsplit("|", message)

    if protocol == "CF2" then
        return {
            addonVersion = decodeField(addonVersion),
            className = decodeField(className),
            color = decodeField(color),
            role = decodeField(role),
            order = decodeField(order),
            updated = time(),
            source = "addon",
        }
    end

    if protocol == "CF1" then
        return {
            addonVersion = "1.0.0",
            className = decodeField(addonVersion),
            color = decodeField(className),
            role = decodeField(color),
            order = decodeField(role),
            updated = time(),
            source = "addon",
        }
    end

    return nil
end

function ClassForge:BroadcastSelf(channel, target)
    local profile = self:GetProfile()
    if not profile.enabled or not channel then
        return
    end

    if not self:CanSendBroadcast(channel, target) then
        return
    end

    local payload = self:SerializeData(self:RefreshPlayerCache())
    SendAddonMessage(self.prefix, payload, channel, target)
end

function ClassForge:BroadcastStartup()
    self:BroadcastSelf("GUILD")
    self:BroadcastSelf("PARTY")
    self:BroadcastSelf("RAID")
end

function ClassForge:RequestSyncFromName(name)
    local normalized = self:NormalizePlayerName(name)
    if not normalized or normalized == self:NormalizePlayerName(UnitName("player")) then
        return
    end

    self:BroadcastSelf("WHISPER", normalized)
end

function ClassForge:RequestSyncFromFriends()
    local total = GetNumFriends() or 0
    for index = 1, total do
        local friendName = GetFriendInfo(index)
        if friendName then
            self:RequestSyncFromName(friendName)
        end
    end
end

function ClassForge:RequestSyncFromWho()
    local total = GetNumWhoResults() or 0
    for index = 1, total do
        local whoName = GetWhoInfo(index)
        if whoName then
            self:RequestSyncFromName(whoName)
        end
    end
end

function ClassForge:ProcessWhoResults()
    local total = GetNumWhoResults() or 0
    local queriedNames = {}

    for index = 1, total do
        local name, _, _, _, className = GetWhoInfo(index)
        if name and className then
            if not self:GetDataForName(name) then
                self:SetDataForName(name, {
                    className = className,
                    color = self:GuessColorFromClass(className),
                    role = self:GuessRoleFromClass(className),
                    order = "",
                    updated = time(),
                    source = "who",
                })
            end

            if self.pendingWhoSync then
                queriedNames[#queriedNames + 1] = name
            end
        end
    end

    if self.pendingWhoSync then
        self.pendingWhoSync = nil
        for _, name in ipairs(queriedNames) do
            self:RequestSyncFromName(name)
        end
    end
end

function ClassForge:PerformWhoSync()
    if not self:CanRunWhoSync() then
        return false
    end

    self.pendingWhoSync = true
    SetWhoToUI(1)
    SendWho("")
    self:ProcessWhoResults()
    return true
end

function ClassForge:CHAT_MSG_ADDON(prefix, message, _, sender)
    if prefix ~= self.prefix or not sender then
        return
    end

    local data = self:DeserializeData(message)
    if not data then
        return
    end

    self:SetDataForName(sender, data)
    if data.addonVersion and data.addonVersion ~= "" and data.addonVersion ~= (self.version or "") then
        self.versionWarnings = self.versionWarnings or {}
        local key = self:GetPlayerKey(sender)
        if key and not self.versionWarnings[key] then
            self.versionWarnings[key] = true
            local normalizedSender = self:NormalizePlayerName(sender) or sender
            if self:CompareVersions(data.addonVersion, self.version or "") > 0 then
                self:Print("Newer ClassForge version detected: " .. data.addonVersion .. " from " .. normalizedSender .. ". You are on " .. (self.version or "unknown") .. ".")
                self:Print("Download: " .. (self.releasesPage or self.homepage or "https://github.com/MrKrisSatan/ClassForge"))
            else
                self:Print(normalizedSender .. " is using ClassForge " .. data.addonVersion .. ". Your version is " .. (self.version or "unknown") .. ".")
            end
        end
    end
    if self.ScheduleMapMemberUpdate then
        self:ScheduleMapMemberUpdate(0)
    end
    self:RefreshAllDisplays()
end
