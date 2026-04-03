function ClassForge:SerializeData(data)
    return table.concat({
        "V2",
        data.className or "",
        data.shortName or "",
        data.color or "FFFFFFFF",
        data.role or "",
        data.order or ""
    }, "|")
end

function ClassForge:DeserializeData(msg)
    if not msg then return nil end

    local version, className, shortName, color, role, order = strsplit("|", msg)
    if version ~= "V2" then return nil end

    return {
        className = className ~= "" and className or "Hero",
        shortName = shortName ~= "" and shortName or "HERO",
        color = self:SanitizeHex(color) or "FFFFFFFF",
        role = role ~= "" and role or "Wanderer",
        order = order ~= "" and order or "Unaffiliated",
        updated = time(),
    }
end

function ClassForge:BroadcastSelf(channel, target)
    if not ClassForgeDB or not ClassForgeDB.profile.enabled then return end
    if not channel then return end

    local payload = self:SerializeData(self:GetMyData())
    SendAddonMessage(self.prefix, payload, channel, target)
end

function ClassForge:CHAT_MSG_ADDON(prefix, message, channel, sender)
    if prefix ~= self.prefix then return end
    if not sender or sender == "" then return end

    local data = self:DeserializeData(message)
    if not data then return end

    self:SetDataForName(sender, data)

    if UnitExists("target") then
        local tName = UnitName("target")
        if tName and string.lower(tName) == string.lower(sender) then
            self:UpdateTargetClassTag()
            self:UpdateInspectProfile()
        end
    end

    self:UpdateWhoList()
    self:UpdateGuildRoster()
end

function ClassForge:RequestSyncFromFriends()
    local numFriends = GetNumFriends()
    if not numFriends or numFriends <= 0 then return end

    for i = 1, numFriends do
        local name = GetFriendInfo(i)
        if name and name ~= "" then
            self:BroadcastSelf("WHISPER", name)
        end
    end
end

function ClassForge:RequestSyncFromWho()
    local numWhos = GetNumWhoResults()
    if not numWhos or numWhos <= 0 then return end

    for i = 1, numWhos do
        local name = GetWhoInfo(i)
        if name and name ~= "" then
            self:BroadcastSelf("WHISPER", name)
        end
    end
end