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
        "CF1",
        encodeField(data.className or ""),
        encodeField(self:SanitizeHex(data.color) or self.defaults.profile.color),
        encodeField(self:NormalizeRole(data.role) or self.defaults.profile.role),
        encodeField(data.order or ""),
    }, "|")
end

function ClassForge:DeserializeData(message)
    if type(message) ~= "string" then
        return nil
    end

    local version, className, color, role, order = strsplit("|", message)
    if version ~= "CF1" then
        return nil
    end

    return {
        className = decodeField(className),
        color = decodeField(color),
        role = decodeField(role),
        order = decodeField(order),
        updated = time(),
        source = "addon",
    }
end

function ClassForge:BroadcastSelf(channel, target)
    local profile = self:GetProfile()
    if not profile.enabled or not channel then
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
    self.pendingWhoSync = true
    SetWhoToUI(1)
    SendWho("")
    self:ProcessWhoResults()
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
    self:RefreshAllDisplays()
end
