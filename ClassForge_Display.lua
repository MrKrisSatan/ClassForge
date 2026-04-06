function ClassForge:InitDisplay()
    self:HookTooltips()
    self:HookFriendsTooltip()
    self:HookWhoFrame()
    self:HookGuildFrame()
    self:HookFriendsFrame()
    self:HookRaidBrowser()
    self:HookPartyFrames()
    self:SetupMapMarkerTooltips()
    self:CreateMinimapButton()
    self:CreateCharacterPanel()
    self:CreateTargetClassTag()
    self:CreateTargetProfile()
    self:CreateMeterPanel()
    self:SetupInspectHooks()
    self:SetupMapColorHooks()
    self:SetupChatDecorators()
end

function ClassForge:GetMeterPosition()
    local profile = self:GetProfile()
    local position = profile and profile.meterPosition or nil
    local defaults = self.defaults.profile.meterPosition

    return {
        point = position and position.point or defaults.point,
        relativePoint = position and position.relativePoint or defaults.relativePoint,
        x = position and position.x or defaults.x,
        y = position and position.y or defaults.y,
    }
end

function ClassForge:ApplyMeterPosition()
    if not self.meterPanel or not UIParent then
        return
    end

    local position = self:GetMeterPosition()
    self.meterPanel:ClearAllPoints()
    self.meterPanel:SetPoint(position.point, UIParent, position.relativePoint, position.x, position.y)
end

function ClassForge:SaveMeterPosition()
    if not self.meterPanel then
        return
    end

    local point, _, relativePoint, x, y = self.meterPanel:GetPoint(1)
    if not point or not relativePoint then
        return
    end

    local function round(value)
        if not value then
            return 0
        end
        if value >= 0 then
            return math.floor(value + 0.5)
        end

        return math.ceil(value - 0.5)
    end

    ClassForgeDB.profile.meterPosition = {
        point = point,
        relativePoint = relativePoint,
        x = round(x),
        y = round(y),
    }
end

function ClassForge:ResetMeterPosition()
    ClassForgeDB.profile.meterPosition = {
        point = self.defaults.profile.meterPosition.point,
        relativePoint = self.defaults.profile.meterPosition.relativePoint,
        x = self.defaults.profile.meterPosition.x,
        y = self.defaults.profile.meterPosition.y,
    }
    self:ApplyMeterPosition()
end

function ClassForge:GetMeterSize()
    local profile = self:GetProfile()
    local size = profile and profile.meterSize or nil
    local defaults = self.defaults.profile.meterSize
    local width = tonumber(size and size.width) or defaults.width
    local height = tonumber(size and size.height) or defaults.height

    if width < 420 then
        width = 420
    elseif width > 900 then
        width = 900
    end

    if height < 140 then
        height = 140
    elseif height > 520 then
        height = 520
    end

    return {
        width = math.floor(width + 0.5),
        height = math.floor(height + 0.5),
    }
end

function ClassForge:ApplyMeterSize()
    if not self.meterPanel then
        return
    end

    local size = self:GetMeterSize()
    self.meterPanel:SetWidth(size.width)
    self.meterPanel:SetHeight(size.height)
end

function ClassForge:SaveMeterSize()
    if not self.meterPanel then
        return
    end

    ClassForgeDB.profile.meterSize = {
        width = math.floor(self.meterPanel:GetWidth() + 0.5),
        height = math.floor(self.meterPanel:GetHeight() + 0.5),
    }
end

function ClassForge:ResetMeterSize()
    ClassForgeDB.profile.meterSize = {
        width = self.defaults.profile.meterSize.width,
        height = self.defaults.profile.meterSize.height,
    }
    self:ApplyMeterSize()
    self:UpdateMeterPanel()
end

function ClassForge:SetMeterEnabled(enabled)
    ClassForgeDB.profile.meter = ClassForgeDB.profile.meter or {}
    ClassForgeDB.profile.meter.enabled = enabled and true or false
    self:UpdateMeterPanel()
end

function ClassForge:SetMeterView(view)
    ClassForgeDB.profile.meter = ClassForgeDB.profile.meter or {}
    local normalized = string.lower(self:Trim(view))
    if normalized ~= "dps" and normalized ~= "threat" and normalized ~= "healing_done" and normalized ~= "healing_received" then
        normalized = self.defaults.profile.meter.view or "dps"
    end

    ClassForgeDB.profile.meter.view = normalized
    self:UpdateMeterPanel()
end

function ClassForge:SetMeterLocked(locked)
    ClassForgeDB.profile.meter = ClassForgeDB.profile.meter or {}
    ClassForgeDB.profile.meter.locked = locked and true or false

    if self.meterPanel and self.meterPanel.hintText then
        self.meterPanel.hintText:SetText(locked and self:L("locked") or self:L("shift_drag"))
    end
end

function ClassForge:SetMeterSectionEnabled(key, enabled)
    ClassForgeDB.profile.meter = ClassForgeDB.profile.meter or {}
    ClassForgeDB.profile.meter[key] = enabled and true or false
    self:UpdateMeterPanel()
end

function ClassForge:SetMeterMaxRows(value)
    ClassForgeDB.profile.meter = ClassForgeDB.profile.meter or {}
    local numeric = tonumber(value) or self.defaults.profile.meter.maxRows
    if numeric < 3 then
        numeric = 3
    elseif numeric > 10 then
        numeric = 10
    end
    ClassForgeDB.profile.meter.maxRows = math.floor(numeric + 0.5)
    self:UpdateMeterPanel()
end

function ClassForge:SetMeterExportTarget(exportType)
    ClassForgeDB.profile.meter = ClassForgeDB.profile.meter or {}
    ClassForgeDB.profile.meter.exportType = self:Trim(exportType) ~= "" and exportType or self.defaults.profile.meter.exportType
end

function ClassForge:SetMeterExportChannel(channelName)
    ClassForgeDB.profile.meter = ClassForgeDB.profile.meter or {}
    ClassForgeDB.profile.meter.exportChannel = self:Trim(channelName) ~= "" and self:Trim(channelName) or self.defaults.profile.meter.exportChannel
end

function ClassForge:IsTrackedGroupPlayer(name)
    local normalized = self:NormalizePlayerName(name)
    local playerName = self:NormalizePlayerName(UnitName("player"))
    if not normalized then
        return false
    end

    if normalized == playerName then
        return true
    end

    if GetNumRaidMembers and (GetNumRaidMembers() or 0) > 0 then
        for index = 1, MAX_RAID_MEMBERS do
            local unit = "raid" .. index
            if UnitExists(unit) and UnitIsPlayer(unit) then
                if self:NormalizePlayerName(UnitName(unit)) == normalized then
                    return true
                end
            end
        end
        return false
    end

    for index = 1, MAX_PARTY_MEMBERS do
        local unit = "party" .. index
        if UnitExists(unit) and UnitIsPlayer(unit) then
            if self:NormalizePlayerName(UnitName(unit)) == normalized then
                return true
            end
        end
    end

    return false
end

function ClassForge:IsTrackedCombatSource(sourceFlags, sourceName, sourceGUID)
    local playerGUID = UnitGUID and UnitGUID("player") or nil
    if playerGUID and sourceGUID and playerGUID == sourceGUID then
        return true
    end

    return self:IsTrackedGroupPlayer(sourceName)
end

function ClassForge:ResetMeterCombat()
    self.meterState = self.meterState or {}
    self.meterState.combat = {
        active = false,
        started = 0,
        ended = 0,
        damage = {},
        healing = {},
        healingReceived = {},
    }
    self:UpdateMeterPanel()
end

function ClassForge:ResetMeterData()
    self:ResetMeterCombat()
end

function ClassForge:EnsureMeterCombatActive()
    if not self:IsMeterEnabled() then
        return nil
    end

    self.meterState = self.meterState or {}
    self.meterState.combat = self.meterState.combat or {
        active = false,
        started = 0,
        ended = 0,
        damage = {},
        healing = {},
        healingReceived = {},
    }

    local combat = self.meterState.combat
    combat.healingReceived = combat.healingReceived or {}
    if not combat.started or combat.started == 0 then
        combat.started = (GetTime and GetTime()) or time()
    end
    combat.active = true

    return combat
end

function ClassForge:GetMeterCombatDuration()
    local combat = self.meterState and self.meterState.combat or nil
    if not combat or not combat.started or combat.started <= 0 then
        return 1
    end

    local now = (GetTime and GetTime()) or time()
    local finish = combat.active and now or (combat.ended or now)
    local duration = finish - combat.started
    if duration < 1 then
        duration = 1
    end

    return duration
end

function ClassForge:GetMeterEntry(container, name)
    local normalized = self:NormalizePlayerName(name)
    if not normalized then
        return nil
    end

    container[normalized] = container[normalized] or {
        name = normalized,
        total = 0,
        spells = {},
    }

    return container[normalized]
end

function ClassForge:RecordMeterDamage(sourceName, spellName, amount, sourceFlags, sourceGUID)
    if not self:IsMeterEnabled() then
        return
    end

    if (not sourceName and not sourceGUID) or not amount or amount <= 0 or not self:IsTrackedCombatSource(sourceFlags, sourceName, sourceGUID) then
        return
    end

    local combat = self:EnsureMeterCombatActive()
    local entry = self:GetMeterEntry(combat.damage, sourceName or UnitName("player"))
    if not entry then
        return
    end

    local spellKey = self:Trim(spellName) ~= "" and spellName or "Melee"
    entry.total = (entry.total or 0) + amount
    entry.spells[spellKey] = (entry.spells[spellKey] or 0) + amount
end

function ClassForge:RecordMeterHealing(sourceName, amount, sourceFlags, sourceGUID, destName)
    if not self:IsMeterEnabled() then
        return
    end

    if (not sourceName and not sourceGUID) or not amount or amount <= 0 or not self:IsTrackedCombatSource(sourceFlags, sourceName, sourceGUID) then
        return
    end

    local combat = self:EnsureMeterCombatActive()
    local entry = self:GetMeterEntry(combat.healing, sourceName or UnitName("player"))
    if not entry then
        return
    end

    entry.total = (entry.total or 0) + amount

    if destName then
        local receivedEntry = self:GetMeterEntry(combat.healingReceived, destName)
        if receivedEntry then
            receivedEntry.total = (receivedEntry.total or 0) + amount
        end
    end
end

function ClassForge:GetMeterIdentityText(name)
    local data = self:GetDataForName(name)
    local displayName = self:NormalizePlayerName(name) or name or self:L("unknown")
    if data and data.className then
        return displayName .. " (" .. self:GetColoredClassText(data) .. ")"
    end

    return displayName
end

function ClassForge:GetPlainMeterIdentityText(name)
    local data = self:GetDataForName(name)
    local displayName = self:NormalizePlayerName(name) or name or self:L("unknown")
    if data and data.className then
        return displayName .. " (" .. (data.className or self:L("unknown")) .. ")"
    end

    return displayName
end

function ClassForge:GetMeterTopSpellText()
    local combat = self.meterState and self.meterState.combat or nil
    local playerName = UnitName("player")
    local entry = nil
    if combat and combat.damage and playerName then
        entry = combat.damage[self:NormalizePlayerName(playerName)]
    end
    if not entry or not entry.spells then
        return self:L("none")
    end

    local bestSpell, bestAmount
    for spellName, amount in pairs(entry.spells) do
        if not bestAmount or amount > bestAmount then
            bestSpell = spellName
            bestAmount = amount
        end
    end

    if not bestSpell then
        return self:L("none")
    end

    return string.format("%s (%d)", bestSpell, bestAmount or 0)
end

function ClassForge:GetMeterTopSpellForName(name)
    local combat = self.meterState and self.meterState.combat or nil
    local normalized = self:NormalizePlayerName(name)
    local entry = combat and combat.damage and normalized and combat.damage[normalized] or nil
    if not entry or not entry.spells then
        return self:L("none")
    end

    local bestSpell, bestAmount
    for spellName, amount in pairs(entry.spells) do
        if not bestAmount or amount > bestAmount then
            bestSpell = spellName
            bestAmount = amount
        end
    end

    if not bestSpell then
        return self:L("none")
    end

    return string.format("%s (%d)", bestSpell, bestAmount or 0)
end

function ClassForge:GetMeterLeaderText(containerName, perSecond)
    local combat = self.meterState and self.meterState.combat or nil
    local container = combat and combat[containerName] or nil
    if not container then
        return self:L("none")
    end

    local duration = self:GetMeterCombatDuration()
    local bestEntry
    for _, entry in pairs(container) do
        if not bestEntry or (entry.total or 0) > (bestEntry.total or 0) then
            bestEntry = entry
        end
    end

    if not bestEntry then
        return self:L("none")
    end

    local value = bestEntry.total or 0
    if perSecond then
        value = math.floor((value / duration) + 0.5)
    end

    return string.format("%s (%d)", self:GetMeterIdentityText(bestEntry.name), value)
end

function ClassForge:GetThreatLeaderText()
    if not UnitDetailedThreatSituation or not UnitExists("target") or not UnitCanAttack("player", "target") then
        return self:L("none")
    end

    local bestName
    local bestThreat = -1
    local function checkUnit(unit)
        if UnitExists(unit) and UnitIsPlayer(unit) then
            local _, _, percent = UnitDetailedThreatSituation(unit, "target")
            percent = tonumber(percent) or 0
            if percent > bestThreat then
                bestThreat = percent
                bestName = UnitName(unit)
            end
        end
    end

    checkUnit("player")
    if GetNumRaidMembers and (GetNumRaidMembers() or 0) > 0 then
        for index = 1, MAX_RAID_MEMBERS do
            checkUnit("raid" .. index)
        end
    else
        for index = 1, MAX_PARTY_MEMBERS do
            checkUnit("party" .. index)
        end
    end

    if not bestName then
        return self:L("none")
    end

    return string.format("%s (%.0f%%)", self:GetMeterIdentityText(bestName), bestThreat)
end

function ClassForge:GetThreatTable()
    local threats = {}
    if not UnitDetailedThreatSituation or not UnitExists("target") or not UnitCanAttack("player", "target") then
        return threats
    end

    local function addUnit(unit)
        if UnitExists(unit) and UnitIsPlayer(unit) then
            local name = UnitName(unit)
            local _, _, percent = UnitDetailedThreatSituation(unit, "target")
            if name and percent then
                threats[self:NormalizePlayerName(name)] = tonumber(percent) or 0
            end
        end
    end

    addUnit("player")
    if GetNumRaidMembers and (GetNumRaidMembers() or 0) > 0 then
        for index = 1, MAX_RAID_MEMBERS do
            addUnit("raid" .. index)
        end
    else
        for index = 1, MAX_PARTY_MEMBERS do
            addUnit("party" .. index)
        end
    end

    return threats
end

function ClassForge:GetMeterRows(view)
    local combat = self.meterState and self.meterState.combat or nil
    local selectedView = view or self:GetMeterView()
    if not combat then
        return nil, self:GetMeterCombatDuration()
    end

    if selectedView == "dps" and (not next(combat.damage or {})) then
        return nil, self:GetMeterCombatDuration()
    end

    if selectedView == "healing_done" and (not next(combat.healing or {})) then
        return nil, self:GetMeterCombatDuration()
    end

    if selectedView == "healing_received" and (not next(combat.healingReceived or {})) then
        return nil, self:GetMeterCombatDuration()
    end

    local entriesByName = {}
    local order = {}
    local threatByName = self:GetThreatTable()

    local function ensureEntry(name)
        local normalized = self:NormalizePlayerName(name)
        if not normalized then
            return nil
        end
        if not entriesByName[normalized] then
            entriesByName[normalized] = {
                name = normalized,
                damage = 0,
                healing = 0,
            }
            order[#order + 1] = entriesByName[normalized]
        end

        return entriesByName[normalized]
    end

    if selectedView == "dps" then
        for _, entry in pairs(combat.damage or {}) do
            local row = ensureEntry(entry.name)
            if row then
                row.damage = entry.total or 0
            end
        end

        for _, entry in pairs(combat.healing or {}) do
            local row = ensureEntry(entry.name)
            if row then
                row.healing = entry.total or 0
            end
        end

        for normalized, percent in pairs(threatByName) do
            local row = ensureEntry(normalized)
            if row then
                row.threat = percent
            end
        end
    elseif selectedView == "threat" then
        for normalized, percent in pairs(threatByName) do
            local row = ensureEntry(normalized)
            if row then
                row.threat = percent
            end
        end
    elseif selectedView == "healing_done" then
        for _, entry in pairs(combat.healing or {}) do
            local row = ensureEntry(entry.name)
            if row then
                row.healing = entry.total or 0
            end
        end
    elseif selectedView == "healing_received" then
        for _, entry in pairs(combat.healingReceived or {}) do
            local row = ensureEntry(entry.name)
            if row then
                row.received = entry.total or 0
            end
        end
    end

    table.sort(order, function(left, right)
        local leftValue = 0
        local rightValue = 0

        if selectedView == "threat" then
            leftValue = left.threat or 0
            rightValue = right.threat or 0
        elseif selectedView == "healing_done" then
            leftValue = left.healing or 0
            rightValue = right.healing or 0
        elseif selectedView == "healing_received" then
            leftValue = left.received or 0
            rightValue = right.received or 0
        else
            leftValue = left.damage or 0
            rightValue = right.damage or 0
        end

        if leftValue == rightValue then
            return string.lower(left.name or "") < string.lower(right.name or "")
        end

        return leftValue > rightValue
    end)

    return order, self:GetMeterCombatDuration()
end

function ClassForge:GetMeterRowColor(index, total)
    local startRed, startGreen, startBlue = self:HexToRGB("CE2029")
    local endRed, endGreen, endBlue = self:HexToRGB("36454F")
    local progress = 0

    if total and total > 1 then
        progress = (index - 1) / (total - 1)
    end

    local red = startRed + ((endRed - startRed) * progress)
    local green = startGreen + ((endGreen - startGreen) * progress)
    local blue = startBlue + ((endBlue - startBlue) * progress)

    return string.format("%02x%02x%02x", math.floor(red * 255 + 0.5), math.floor(green * 255 + 0.5), math.floor(blue * 255 + 0.5))
end

function ClassForge:BuildMeterText()
    local selectedView = self:GetMeterView()
    local rows, duration = self:GetMeterRows(selectedView)
    if not rows or #rows == 0 then
        return self:L("meter_waiting")
    end

    local maxRows = self:GetMeterMaxRows()
    local header = "Player"
    if selectedView == "threat" then
        header = header .. " | " .. self:L("threat_leader")
    elseif selectedView == "healing_done" then
        header = header .. " | " .. self:L("healing_leader")
    elseif selectedView == "healing_received" then
        header = header .. " | " .. self:L("meter_view_healing_received")
    else
        header = header .. " | DPS | Damage | " .. self:L("top_spell")
    end

    local lines = { header }
    local visibleRows = math.min(#rows, maxRows)
    for index = 1, visibleRows do
        local row = rows[index]
        local parts = { self:GetMeterIdentityText(row.name) }
        if selectedView == "threat" then
            parts[#parts + 1] = row.threat and string.format("%.0f%%", row.threat) or "-"
        elseif selectedView == "healing_done" then
            parts[#parts + 1] = tostring(row.healing or 0)
        elseif selectedView == "healing_received" then
            parts[#parts + 1] = tostring(row.received or 0)
        else
            parts[#parts + 1] = tostring(math.floor(((row.damage or 0) / duration) + 0.5))
            parts[#parts + 1] = tostring(row.damage or 0)
            parts[#parts + 1] = self:GetMeterTopSpellForName(row.name)
        end
        lines[#lines + 1] = string.format("|cff%s%s|r", self:GetMeterRowColor(index, visibleRows), table.concat(parts, " | "))
    end

    return table.concat(lines, "\n")
end

function ClassForge:BuildMeterExportLines()
    local selectedView = self:GetMeterView()
    local rows, duration = self:GetMeterRows(selectedView)
    if not rows or #rows == 0 then
        return nil
    end

    local maxRows = self:GetMeterMaxRows()
    local header = "Player"
    if selectedView == "threat" then
        header = header .. " | " .. self:L("threat_leader")
    elseif selectedView == "healing_done" then
        header = header .. " | " .. self:L("healing_leader")
    elseif selectedView == "healing_received" then
        header = header .. " | " .. self:L("meter_view_healing_received")
    else
        header = header .. " | DPS | Damage | " .. self:L("top_spell")
    end

    local lines = { "[ClassForge Meter]", header }
    for index = 1, math.min(#rows, maxRows) do
        local row = rows[index]
        local parts = { self:GetPlainMeterIdentityText(row.name) }
        if selectedView == "threat" then
            parts[#parts + 1] = row.threat and string.format("%.0f%%", row.threat) or "-"
        elseif selectedView == "healing_done" then
            parts[#parts + 1] = tostring(row.healing or 0)
        elseif selectedView == "healing_received" then
            parts[#parts + 1] = tostring(row.received or 0)
        else
            parts[#parts + 1] = tostring(math.floor(((row.damage or 0) / duration) + 0.5))
            parts[#parts + 1] = tostring(row.damage or 0)
            parts[#parts + 1] = self:GetMeterTopSpellForName(row.name)
        end
        lines[#lines + 1] = table.concat(parts, " | ")
    end

    return lines
end

function ClassForge:ExportMeterToChat()
    if not SendChatMessage then
        return
    end

    local lines = self:BuildMeterExportLines()
    if not lines then
        self:Print(self:L("meter_waiting"))
        return
    end

    local exportType = self:GetMeterExportType()
    local channelName = self:GetMeterExportChannel()

    if exportType == "CHANNEL" then
        local channelId = GetChannelName and GetChannelName(channelName) or 0
        if not channelId or channelId == 0 then
            self:Print("Channel not found: " .. channelName)
            return
        end
        for _, line in ipairs(lines) do
            SendChatMessage(line, "CHANNEL", nil, channelId)
        end
        return
    end

    for _, line in ipairs(lines) do
        SendChatMessage(line, exportType)
    end
end

function ClassForge:CreateMeterPanel()
    if self.meterPanel then
        return
    end

    local frame = CreateFrame("Frame", "ClassForgeMeterPanel", UIParent)
    frame:SetMinResize(420, 140)
    frame:SetMaxResize(900, 520)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(10)
    frame:SetClampedToScreen(true)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0, 0, 0, 0.85)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:SetScript("OnDragStart", function(selfFrame)
        if IsShiftKeyDown() and not ClassForge:IsMeterLocked() then
            selfFrame:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", function(selfFrame)
        selfFrame:StopMovingOrSizing()
        ClassForge:SaveMeterPosition()
    end)
    frame:SetScript("OnSizeChanged", function(selfFrame, width, height)
        if selfFrame.scrollChild then
            selfFrame.scrollChild:SetWidth(math.max(320, width - 38))
        end
        if selfFrame.text then
            selfFrame.text:SetWidth(math.max(300, width - 44))
        end
        if selfFrame.scrollFrame then
            local visibleHeight = math.max(20, selfFrame.scrollFrame:GetHeight() - 4)
            local contentHeight = selfFrame.text and selfFrame.text:GetStringHeight() or 0
            selfFrame.scrollChild:SetHeight(math.max(visibleHeight, contentHeight + 8))
        end
    end)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetPoint("TOPLEFT", 10, -10)
    frame.title:SetText("ClassForge")

    frame.viewButtons = {}
    local viewOrder = {
        { key = "dps", label = "meter_view_dps" },
        { key = "threat", label = "meter_view_threat" },
        { key = "healing_done", label = "meter_view_healing_done" },
        { key = "healing_received", label = "meter_view_healing_received" },
    }
    local previousButton
    for _, viewData in ipairs(viewOrder) do
        local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        button:SetHeight(18)
        button.viewKey = viewData.key
        if previousButton then
            button:SetPoint("TOPLEFT", previousButton, "TOPRIGHT", 4, 0)
        else
            button:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -6)
        end
        button:SetScript("OnClick", function(selfButton)
            ClassForge:SetMeterView(selfButton.viewKey)
        end)
        button.labelKey = viewData.label
        frame.viewButtons[#frame.viewButtons + 1] = button
        previousButton = button
    end

    frame.resetButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.resetButton:SetWidth(48)
    frame.resetButton:SetHeight(18)
    frame.resetButton:SetPoint("TOPRIGHT", -8, -8)
    frame.resetButton:SetText(self:L("reset"))
    frame.resetButton:SetScript("OnClick", function()
        ClassForge:ResetMeterData()
    end)

    frame.exportButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.exportButton:SetWidth(48)
    frame.exportButton:SetHeight(18)
    frame.exportButton:SetPoint("RIGHT", frame.resetButton, "LEFT", -6, 0)
    frame.exportButton:SetText("Send")
    frame.exportButton:SetScript("OnClick", function()
        ClassForge:ExportMeterToChat()
    end)

    frame.hintText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.hintText:SetPoint("RIGHT", frame.exportButton, "LEFT", -8, 0)
    frame.hintText:SetText(self:IsMeterLocked() and self:L("locked") or self:L("shift_drag"))

    frame.scrollFrame = CreateFrame("ScrollFrame", "ClassForgeMeterScrollFrame", frame, "UIPanelScrollFrameTemplate")
    frame.scrollFrame:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -32)
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", -28, 12)

    frame.scrollChild = CreateFrame("Frame", nil, frame.scrollFrame)
    frame.scrollChild:SetWidth(482)
    frame.scrollChild:SetHeight(120)
    frame.scrollFrame:SetScrollChild(frame.scrollChild)

    frame.text = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.text:SetPoint("TOPLEFT", 0, 0)
    frame.text:SetWidth(476)
    frame.text:SetJustifyH("LEFT")
    frame.text:SetJustifyV("TOP")

    frame.resizeHandle = CreateFrame("Button", nil, frame)
    frame.resizeHandle:SetWidth(18)
    frame.resizeHandle:SetHeight(18)
    frame.resizeHandle:SetPoint("BOTTOMRIGHT", -6, 6)
    frame.resizeHandle:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    frame.resizeHandle:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    frame.resizeHandle:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    frame.resizeHandle:SetScript("OnMouseDown", function()
        if not ClassForge:IsMeterLocked() then
            frame:StartSizing("BOTTOMRIGHT")
        end
    end)
    frame.resizeHandle:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        ClassForge:SaveMeterSize()
        ClassForge:UpdateMeterPanel()
    end)

    frame.liveUpdate = CreateFrame("Frame", nil, frame)
    frame.liveUpdate.elapsed = 0
    frame.liveUpdate:SetScript("OnUpdate", function(_, elapsed)
        if not ClassForge:IsMeterEnabled() then
            return
        end

        local combat = ClassForge.meterState and ClassForge.meterState.combat or nil
        if not combat or not combat.active then
            return
        end

        frame.liveUpdate.elapsed = frame.liveUpdate.elapsed + elapsed
        if frame.liveUpdate.elapsed >= 0.2 then
            frame.liveUpdate.elapsed = 0
            ClassForge:UpdateMeterPanel()
        end
    end)

    self.meterPanel = frame
    self:ApplyMeterPosition()
    self:ApplyMeterSize()
    self:UpdateMeterPanel()
end

function ClassForge:UpdateMeterPanel()
    if not self.meterPanel then
        return
    end

    if not self:IsMeterEnabled() then
        self.meterPanel:Hide()
        return
    end

    self.meterPanel.title:SetText((self.name or "ClassForge") .. " " .. self:L("meter_tab"))
    if self.meterPanel.viewButtons then
        local activeView = self:GetMeterView()
        for _, button in ipairs(self.meterPanel.viewButtons) do
            button:SetText(self:L(button.labelKey))
            button:SetWidth(math.max(72, button:GetTextWidth() + 16))
            if button.viewKey == activeView then
                button:Disable()
            else
                button:Enable()
            end
        end
    end
    if self.meterPanel.resetButton then
        self.meterPanel.resetButton:SetText(self:L("reset"))
    end
    if self.meterPanel.exportButton then
        self.meterPanel.exportButton:SetText(self:L("meter_export"))
        self.meterPanel.exportButton:SetWidth(math.max(48, self.meterPanel.exportButton:GetTextWidth() + 18))
    end
    self.meterPanel.hintText:SetText(self:IsMeterLocked() and self:L("locked") or self:L("shift_drag"))
    self.meterPanel.text:SetText(self:BuildMeterText())
    if self.meterPanel.scrollChild and self.meterPanel.scrollFrame and self.meterPanel.text then
        self.meterPanel.scrollChild:SetWidth(math.max(320, self.meterPanel:GetWidth() - 38))
        self.meterPanel.text:SetWidth(math.max(300, self.meterPanel:GetWidth() - 44))
        local visibleHeight = math.max(20, self.meterPanel.scrollFrame:GetHeight() - 4)
        local contentHeight = self.meterPanel.text:GetStringHeight() or 0
        self.meterPanel.scrollChild:SetHeight(math.max(visibleHeight, contentHeight + 8))
    end
    self.meterPanel:Show()
end

function ClassForge:IsChatDecorationEnabled()
    local profile = self:GetProfile()
    local chat = profile and profile.chat or nil

    if chat and chat.enabled ~= nil then
        return chat.enabled and true or false
    end

    return self.defaults.profile.chat.enabled and true or false
end

function ClassForge:IsTargetProfileHidden()
    local profile = self:GetProfile()
    local targetProfile = profile and profile.targetProfile or nil

    if targetProfile and targetProfile.hidden ~= nil then
        return targetProfile.hidden and true or false
    end

    return self.defaults.profile.targetProfile.hidden and true or false
end

function ClassForge:IsTargetProfileLocked()
    local profile = self:GetProfile()
    local targetProfile = profile and profile.targetProfile or nil

    if targetProfile and targetProfile.locked ~= nil then
        return targetProfile.locked and true or false
    end

    return self.defaults.profile.targetProfile.locked and true or false
end

function ClassForge:SetTargetProfileHidden(hidden)
    ClassForgeDB.profile.targetProfile = ClassForgeDB.profile.targetProfile or {}
    ClassForgeDB.profile.targetProfile.hidden = hidden and true or false

    if hidden and self.targetProfile then
        self.targetProfile:Hide()
    else
        self:UpdateTargetProfile()
    end
end

function ClassForge:SetTargetProfileLocked(locked)
    ClassForgeDB.profile.targetProfile = ClassForgeDB.profile.targetProfile or {}
    ClassForgeDB.profile.targetProfile.locked = locked and true or false

    if self.targetProfile and self.targetProfile.hintText then
        self.targetProfile.hintText:SetText(locked and self:L("locked") or self:L("shift_drag"))
    end
end

function ClassForge:SetTargetProfileCompact(compact)
    ClassForgeDB.profile.targetProfile = ClassForgeDB.profile.targetProfile or {}
    ClassForgeDB.profile.targetProfile.compact = compact and true or false

    if self.targetProfile then
        self:UpdateTargetProfileLayout()
        self:UpdateTargetProfile()
    end
end

function ClassForge:SetChatDecorationEnabled(enabled)
    ClassForgeDB.profile.chat = ClassForgeDB.profile.chat or {}
    ClassForgeDB.profile.chat.enabled = enabled and true or false
end

function ClassForge:DecorateChatMessage(_, _, message, sender, ...)
    if not ClassForge:IsChatDecorationEnabled() or not sender or not message then
        return false, message, sender, ...
    end

    local data = ClassForge:GetDataForName(sender)
    if not ClassForge:IsConfirmedAddonUser(data) then
        return false, message, sender, ...
    end

    if string.find(message, "|Hplayer:") and string.find(message, "%[|cff") then
        return false, message, sender, ...
    end

    local prefix = "[" .. ClassForge:GetColoredClassText(data) .. "] "
    return false, prefix .. message, sender, ...
end

function ClassForge:SetupChatDecorators()
    if self.chatDecoratorsHooked or not ChatFrame_AddMessageEventFilter then
        return
    end

    self.chatDecoratorsHooked = true

    local events = {
        "CHAT_MSG_PARTY",
        "CHAT_MSG_PARTY_LEADER",
        "CHAT_MSG_RAID",
        "CHAT_MSG_RAID_LEADER",
        "CHAT_MSG_GUILD",
        "CHAT_MSG_OFFICER",
        "CHAT_MSG_WHISPER",
    }

    for _, eventName in ipairs(events) do
        ChatFrame_AddMessageEventFilter(eventName, function(...)
            return ClassForge:DecorateChatMessage(...)
        end)
    end
end

function ClassForge:GetDataStatusText(data)
    if not data then
        return self:L("unknown")
    end

    local parts = {
        self:L("source_label") .. ": |cffffffff" .. self:GetSourceLabel(data) .. "|r",
        self:L("updated_label") .. ": " .. self:FormatUpdatedTimeColored(data.updated),
    }

    if data.addonVersion and data.addonVersion ~= "" then
        parts[#parts + 1] = self:L("version_label") .. ": |cffffffff" .. data.addonVersion .. "|r"
    end

    return table.concat(parts, " |cff808080-|r ")
end

function ClassForge:GetMinimapButtonAngle()
    local profile = self:GetProfile()
    local minimapButton = profile and profile.minimapButton or nil
    local defaults = self.defaults.profile.minimapButton

    return tonumber(minimapButton and minimapButton.angle) or defaults.angle
end

function ClassForge:IsMinimapButtonHidden()
    local profile = self:GetProfile()
    local minimapButton = profile and profile.minimapButton or nil
    local defaults = self.defaults.profile.minimapButton

    if minimapButton and minimapButton.hidden ~= nil then
        return minimapButton.hidden and true or false
    end

    return defaults.hidden and true or false
end

function ClassForge:SetMinimapButtonAngle(angle)
    ClassForgeDB.profile.minimapButton = ClassForgeDB.profile.minimapButton or {}
    ClassForgeDB.profile.minimapButton.angle = angle
end

function ClassForge:SetMinimapButtonHidden(hidden)
    ClassForgeDB.profile.minimapButton = ClassForgeDB.profile.minimapButton or {}
    ClassForgeDB.profile.minimapButton.hidden = hidden and true or false

    if not self.minimapButton then
        return
    end

    if hidden then
        self.minimapButton:Hide()
    else
        self.minimapButton:Show()
        self:UpdateMinimapButtonPosition()
    end
end

function ClassForge:ResetMinimapButtonPosition()
    ClassForgeDB.profile.minimapButton = ClassForgeDB.profile.minimapButton or {}
    ClassForgeDB.profile.minimapButton.angle = self.defaults.profile.minimapButton.angle
    self:SetMinimapButtonHidden(false)
    self:UpdateMinimapButtonPosition()
end

function ClassForge:UpdateMinimapButtonPosition()
    if not self.minimapButton or not Minimap or self:IsMinimapButtonHidden() then
        return
    end

    local angle = self:GetMinimapButtonAngle()
    local radians = math.rad(angle)
    local radius = (Minimap:GetWidth() / 2) + 5
    local x = math.cos(radians) * radius
    local y = math.sin(radians) * radius

    self.minimapButton:ClearAllPoints()
    self.minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function ClassForge:OpenOptionsPanel()
    if not self.optionsPanel then
        return
    end

    InterfaceOptionsFrame_OpenToCategory(self.optionsPanel)
    InterfaceOptionsFrame_OpenToCategory(self.optionsPanel)
end

function ClassForge:CreateMinimapButton()
    if self.minimapButton or not Minimap then
        return
    end

    local button = CreateFrame("Button", "ClassForgeMinimapButton", Minimap)
    button:SetWidth(32)
    button:SetHeight(32)
    button:SetFrameStrata("MEDIUM")
    button:SetMovable(false)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    background:SetWidth(54)
    background:SetHeight(54)
    background:SetPoint("TOPLEFT")
    button.background = background

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\AddOns\\ClassForge\\Media\\ClassForge-Minimap")
    icon:SetWidth(20)
    icon:SetHeight(20)
    icon:SetPoint("CENTER", 0, 1)
    button.icon = icon

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    highlight:SetBlendMode("ADD")
    highlight:SetAllPoints(button)

    button.isDragging = nil
    button.dragStopTime = 0
    button:SetScript("OnDragStart", function(selfButton)
        selfButton.isDragging = true
        selfButton:SetScript("OnUpdate", function(_, elapsed)
            local scale = Minimap:GetEffectiveScale()
            local cursorX, cursorY = GetCursorPosition()
            local centerX, centerY = Minimap:GetCenter()
            if not centerX or not centerY then
                return
            end

            local x = cursorX / scale - centerX
            local y = cursorY / scale - centerY
            local targetAngle = math.deg(atan2(y, x))
            local currentAngle = ClassForge:GetMinimapButtonAngle()
            local delta = targetAngle - currentAngle

            while delta > 180 do
                delta = delta - 360
            end
            while delta < -180 do
                delta = delta + 360
            end

            local smoothing = math.min(1, (elapsed or 0.016) * 8)
            local nextAngle = currentAngle + (delta * smoothing)
            ClassForge:SetMinimapButtonAngle(nextAngle)
            ClassForge:UpdateMinimapButtonPosition()
        end)
    end)

    button:SetScript("OnDragStop", function(selfButton)
        selfButton.isDragging = nil
        selfButton.dragStopTime = GetTime()
        selfButton:SetScript("OnUpdate", nil)
    end)

    button:SetScript("OnClick", function(selfButton)
        if selfButton.isDragging or (GetTime() - (selfButton.dragStopTime or 0)) < 0.2 then
            return
        end

        ClassForge:OpenOptionsPanel()
    end)

    button:SetScript("OnEnter", function(selfButton)
        GameTooltip:SetOwner(selfButton, "ANCHOR_LEFT")
        GameTooltip:SetText(ClassForge.name or "ClassForge")
        GameTooltip:AddLine(ClassForge:L("left_click_open"), 1, 1, 1)
        GameTooltip:AddLine(ClassForge:L("drag_move_button"), 1, 1, 1)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    self.minimapButton = button
    if self:IsMinimapButtonHidden() then
        button:Hide()
    else
        self:UpdateMinimapButtonPosition()
    end
end

function ClassForge:GetMapMemberColor(unit)
    local data = unit and self:GetDataForUnit(unit) or nil
    if not data then
        return 1, 1, 1
    end

    return self:HexToRGB(data.color)
end

function ClassForge:ApplyColorToMapTexture(texture, unit)
    if not texture or not texture.SetVertexColor then
        return
    end

    texture:SetVertexColor(self:GetMapMemberColor(unit))
end

function ClassForge:GetMapObjectTexture(object)
    if not object then
        return nil
    end

    if object.icon and object.icon.SetVertexColor then
        return object.icon
    end

    if object.texture and object.texture.SetVertexColor then
        return object.texture
    end

    if object.Icon and object.Icon.SetVertexColor then
        return object.Icon
    end

    if object.Texture and object.Texture.SetVertexColor then
        return object.Texture
    end

    if object.SetVertexColor then
        return object
    end

    if object.GetName then
        local objectName = object:GetName()
        if objectName then
            local namedTexture = _G[objectName .. "Icon"]
                or _G[objectName .. "Texture"]
                or _G[objectName .. "IconTexture"]

            if namedTexture and namedTexture.SetVertexColor then
                return namedTexture
            end
        end
    end

    return nil
end

function ClassForge:ApplyColorToMapObject(object, unit)
    self:ApplyColorToMapTexture(self:GetMapObjectTexture(object), unit)
end

function ClassForge:UpdateWorldMapMemberColors()
    for index = 1, MAX_PARTY_MEMBERS do
        self:ApplyColorToMapObject(_G["WorldMapParty" .. index], "party" .. index)
    end

    for index = 1, MAX_RAID_MEMBERS do
        self:ApplyColorToMapObject(_G["WorldMapRaid" .. index], "raid" .. index)
    end
end

function ClassForge:UpdateMinimapMemberColors()
    local partyPrefixes = { "MiniMapParty", "MinimapParty" }
    local raidPrefixes = { "MiniMapRaid", "MinimapRaid" }

    for index = 1, MAX_PARTY_MEMBERS do
        local unit = "party" .. index
        for _, prefix in ipairs(partyPrefixes) do
            self:ApplyColorToMapObject(_G[prefix .. index], unit)
        end
    end

    for index = 1, MAX_RAID_MEMBERS do
        local unit = "raid" .. index
        for _, prefix in ipairs(raidPrefixes) do
            self:ApplyColorToMapObject(_G[prefix .. index], unit)
        end
    end
end

function ClassForge:UpdateMapMemberColors()
    self:UpdateWorldMapMemberColors()
    self:UpdateMinimapMemberColors()
end

function ClassForge:ScheduleMapMemberUpdate(delay)
    self.mapColorState = self.mapColorState or {}
    self.mapColorState.pending = true
    self.mapColorState.delay = tonumber(delay) or 0
    self.mapColorState.elapsed = 0
end

function ClassForge:SetupMapColorHooks()
    if self.mapColorHooked then
        return
    end

    self.mapColorHooked = true

    if WorldMapUnit_Update then
        hooksecurefunc("WorldMapUnit_Update", function(frame)
            if not frame then
                return
            end

            local unit = frame.unit
            if unit and (string.find(unit, "^party%d+$") or string.find(unit, "^raid%d+$")) then
                ClassForge:ApplyColorToMapObject(frame, unit)
            end
        end)
    end

    if WorldMapFrame_UpdateUnits then
        hooksecurefunc("WorldMapFrame_UpdateUnits", function()
            ClassForge:UpdateWorldMapMemberColors()
        end)
    end

    if not self.mapColorTicker then
        self.mapColorState = { pending = true, delay = 0, elapsed = 0, fallbackElapsed = 0 }
        local ticker = CreateFrame("Frame")
        ticker:SetScript("OnUpdate", function(_, elapsed)
            local state = ClassForge.mapColorState
            state.elapsed = state.elapsed + elapsed
            state.fallbackElapsed = state.fallbackElapsed + elapsed

            if state.pending and state.elapsed >= state.delay then
                state.pending = nil
                state.delay = 0
                state.elapsed = 0
                ClassForge:UpdateMapMemberColors()
            end

            if not GetNumPartyMembers and not GetNumRaidMembers then
                return
            end

            if state.fallbackElapsed < 1.0 then
                return
            end

            state.fallbackElapsed = 0

            local hasParty = (GetNumPartyMembers() or 0) > 0
            local hasRaid = (GetNumRaidMembers() or 0) > 0
            if hasParty or hasRaid then
                ClassForge:UpdateMapMemberColors()
            end
        end)
        self.mapColorTicker = ticker
    end
end

function ClassForge:UpdatePartyFrameColors()
    for index = 1, MAX_PARTY_MEMBERS do
        local unit = "party" .. index
        local nameFontString = _G["PartyMemberFrame" .. index .. "Name"]

        if nameFontString and UnitExists(unit) and UnitIsPlayer(unit) then
            local data = self:GetDataForUnit(unit)
            if self:IsGroupFrameColoringEnabled() and data and data.color then
                nameFontString:SetTextColor(self:HexToRGB(data.color))
            else
                nameFontString:SetTextColor(1, 0.82, 0)
            end
        end
    end
end

function ClassForge:GetTargetProfilePosition()
    local profile = self:GetProfile()
    local position = profile and profile.targetProfilePosition or nil
    local defaults = self.defaults.profile.targetProfilePosition

    return {
        point = position and position.point or defaults.point,
        relativePoint = position and position.relativePoint or defaults.relativePoint,
        x = position and position.x or defaults.x,
        y = position and position.y or defaults.y,
    }
end

function ClassForge:ApplyTargetProfilePosition()
    if not self.targetProfile or not TargetFrame then
        return
    end

    local position = self:GetTargetProfilePosition()
    self.targetProfile:ClearAllPoints()
    self.targetProfile:SetPoint(position.point, TargetFrame, position.relativePoint, position.x, position.y)
end

function ClassForge:SaveTargetProfilePosition()
    if not self.targetProfile then
        return
    end

    local function round(value)
        if not value then
            return 0
        end

        if value >= 0 then
            return math.floor(value + 0.5)
        end

        return math.ceil(value - 0.5)
    end

    local point, _, relativePoint, x, y = self.targetProfile:GetPoint(1)
    if not point or not relativePoint then
        return
    end

    ClassForgeDB.profile.targetProfilePosition = {
        point = point,
        relativePoint = relativePoint,
        x = round(x),
        y = round(y),
    }
end

function ClassForge:ResetTargetProfilePosition()
    ClassForgeDB.profile.targetProfilePosition = {
        point = self.defaults.profile.targetProfilePosition.point,
        relativePoint = self.defaults.profile.targetProfilePosition.relativePoint,
        x = self.defaults.profile.targetProfilePosition.x,
        y = self.defaults.profile.targetProfilePosition.y,
    }
    self:ApplyTargetProfilePosition()
end

function ClassForge:AppendTooltipData(tooltip, data)
    if not tooltip or tooltip.classForgeTooltipApplied or not data then
        return
    end

    tooltip.classForgeTooltipApplied = true
    tooltip:AddLine(" ")
    tooltip:AddLine(self:L("class_label") .. ": " .. self:GetColoredClassText(data))
    tooltip:AddLine(self:L("role_label") .. ": |cffffffff" .. self:GetRoleDisplayText(data.role) .. "|r")
    tooltip:AddLine(self:L("faction_label") .. ": |cffffffff" .. self:GetFactionText(data) .. "|r")
    tooltip:AddLine(self:GetDataStatusText(data))
    tooltip:Show()
end

function ClassForge:AppendMapTooltipData(tooltip, unit)
    if not tooltip or not unit then
        return
    end

    local data = self:GetDataForUnit(unit)
    if not data then
        return
    end

    tooltip:AddLine(" ")
    tooltip:AddLine((self.name or "ClassForge") .. ": " .. self:GetColoredClassText(data))
    tooltip:AddLine(self:L("role_label") .. ": |cffffffff" .. self:GetRoleDisplayText(data.role) .. "|r")
    tooltip:AddLine(self:L("faction_label") .. ": |cffffffff" .. self:GetFactionText(data) .. "|r")
    tooltip:AddLine(self:GetDataStatusText(data))
    tooltip:Show()
end

function ClassForge:GetTooltipOwnedUnit(tooltip)
    if not tooltip or not tooltip.GetOwner then
        return nil
    end

    local owner = tooltip:GetOwner()
    local depth = 0

    while owner and depth < 5 do
        if owner.unit and UnitExists(owner.unit) then
            return owner.unit
        end

        if not owner.GetParent then
            break
        end

        owner = owner:GetParent()
        depth = depth + 1
    end

    return nil
end

function ClassForge:AppendTooltipDataForUnit(tooltip, unit)
    if not tooltip or not unit or not UnitExists(unit) or not UnitIsPlayer(unit) then
        return
    end

    local data = self:GetDataForUnit(unit)
    if not data then
        return
    end

    self:AppendTooltipData(tooltip, data)
end

function ClassForge:HookMapTooltipFrame(frame, tooltipObject, unit)
    if not frame or frame.classForgeMapTooltipHooked then
        return
    end

    frame.classForgeMapTooltipHooked = true
    frame:HookScript("OnEnter", function()
        ClassForge:AppendMapTooltipData(tooltipObject, unit or frame.unit)
    end)
end

function ClassForge:SetupMapMarkerTooltips()
    if self.mapMarkerTooltipTicker then
        return
    end

    local ticker = CreateFrame("Frame")
    ticker.elapsed = 0
    ticker:SetScript("OnUpdate", function(_, elapsed)
        ticker.elapsed = ticker.elapsed + elapsed
        if ticker.elapsed < 0.5 then
            return
        end

        ticker.elapsed = 0

        for index = 1, MAX_PARTY_MEMBERS do
            ClassForge:HookMapTooltipFrame(_G["WorldMapParty" .. index], WorldMapTooltip, "party" .. index)
            ClassForge:HookMapTooltipFrame(_G["MiniMapParty" .. index] or _G["MinimapParty" .. index], GameTooltip, "party" .. index)
        end

        for index = 1, MAX_RAID_MEMBERS do
            ClassForge:HookMapTooltipFrame(_G["WorldMapRaid" .. index], WorldMapTooltip, "raid" .. index)
            ClassForge:HookMapTooltipFrame(_G["MiniMapRaid" .. index] or _G["MinimapRaid" .. index], GameTooltip, "raid" .. index)
        end
    end)
    self.mapMarkerTooltipTicker = ticker
end

function ClassForge:HookTooltips()
    if self.tooltipHooked then
        return
    end

    self.tooltipHooked = true

    GameTooltip:HookScript("OnHide", function(tooltip)
        tooltip.classForgeTooltipApplied = nil
    end)

    GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
        local _, unit = tooltip:GetUnit()
        if not unit or not UnitIsPlayer(unit) then
            return
        end

        local ownerUnit = ClassForge:GetTooltipOwnedUnit(tooltip)
        if ownerUnit and UnitIsUnit(unit, ownerUnit) then
            ClassForge:AppendTooltipDataForUnit(tooltip, ownerUnit)
            return
        end

        if UnitExists("mouseover") and UnitIsUnit(unit, "mouseover") then
            ClassForge:AppendTooltipDataForUnit(tooltip, "mouseover")
        end
    end)
end

function ClassForge:GetRaidBrowserClassColor(data, fileName, online, isDead)
    if not online then
        return GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b
    end

    if isDead then
        return RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b
    end

    if data and data.color then
        return self:HexToRGB(data.color)
    end

    local color = fileName and RAID_CLASS_COLORS and RAID_CLASS_COLORS[fileName]
    if color then
        return color.r, color.g, color.b
    end

    return 1, 1, 1
end

function ClassForge:UpdateRaidBrowser()
    if not RaidGroupFrame_Update then
        return
    end

    for index = 1, MAX_RAID_MEMBERS do
        local button = _G["RaidGroupButton" .. index]
        local classFontString = _G["RaidGroupButton" .. index .. "Class"]
        if button and classFontString and button:IsShown() and button.unit and UnitExists(button.unit) and UnitIsPlayer(button.unit) then
            local _, _, _, _, className, fileName, _, online, isDead = GetRaidRosterInfo(index)
            local data = self:GetDataForUnit(button.unit)
            local nameFontString = _G["RaidGroupButton" .. index .. "Name"]

            if data and data.className and data.className ~= "" then
                classFontString:SetText(data.className)
            else
                classFontString:SetText(className or "")
            end

            local r, g, b = self:GetRaidBrowserClassColor(data, fileName, online, isDead)
            classFontString:SetTextColor(r, g, b)
            if nameFontString then
                if self:IsGroupFrameColoringEnabled() and online and not isDead and data and data.color then
                    nameFontString:SetTextColor(self:HexToRGB(data.color))
                else
                    nameFontString:SetTextColor(r, g, b)
                end
            end
        end
    end
end

function ClassForge:HookRaidBrowser()
    if self.raidFrameLoadHooked == nil and RaidFrame_LoadUI then
        self.raidFrameLoadHooked = true
        hooksecurefunc("RaidFrame_LoadUI", function()
            ClassForge:HookRaidBrowser()
        end)
    end

    if self.raidBrowserHooked or not RaidGroupFrame_Update then
        return
    end

    self.raidBrowserHooked = true

    hooksecurefunc("RaidGroupFrame_Update", function()
        ClassForge:UpdateRaidBrowser()
    end)

    if RaidGroupFrame_UpdateHealth then
        hooksecurefunc("RaidGroupFrame_UpdateHealth", function()
            ClassForge:UpdateRaidBrowser()
        end)
    end

    self:UpdateRaidBrowser()
end

function ClassForge:HookPartyFrames()
    if self.partyFrameHooked then
        return
    end

    self.partyFrameHooked = true

    if PartyMemberFrame_UpdateMember then
        hooksecurefunc("PartyMemberFrame_UpdateMember", function()
            ClassForge:UpdatePartyFrameColors()
        end)
    end
end

function ClassForge:EnsureFriendsTooltipExtras()
    if self.friendsTooltipExtras or not FriendsTooltip then
        return
    end

    local classText = FriendsTooltip:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    classText:SetJustifyH("LEFT")
    classText:SetWidth(188)

    local roleText = FriendsTooltip:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    roleText:SetJustifyH("LEFT")
    roleText:SetWidth(188)

    local orderText = FriendsTooltip:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    orderText:SetJustifyH("LEFT")
    orderText:SetWidth(188)

    local updatedText = FriendsTooltip:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    updatedText:SetJustifyH("LEFT")
    updatedText:SetWidth(188)

    self.friendsTooltipExtras = {
        classText = classText,
        roleText = roleText,
        orderText = orderText,
        updatedText = updatedText,
    }
end

function ClassForge:GetFriendsTooltipBottomAnchor()
    local candidates = {
        FriendsTooltipToonMany,
        FriendsTooltipToon5Info,
        FriendsTooltipToon5Name,
        FriendsTooltipToon4Info,
        FriendsTooltipToon4Name,
        FriendsTooltipToon3Info,
        FriendsTooltipToon3Name,
        FriendsTooltipToon2Info,
        FriendsTooltipToon2Name,
        FriendsTooltipOtherToons,
        FriendsTooltipBroadcastText,
        FriendsTooltipNoteText,
        FriendsTooltipLastOnline,
        FriendsTooltipToon1Info,
        FriendsTooltipToon1Name,
        FriendsTooltipHeader,
    }

    for _, region in ipairs(candidates) do
        if region and region:IsShown() then
            return region
        end
    end

    return FriendsTooltipHeader
end

function ClassForge:HideFriendsTooltipExtras()
    if not self.friendsTooltipExtras then
        return
    end

    self.friendsTooltipExtras.classText:Hide()
    self.friendsTooltipExtras.roleText:Hide()
    self.friendsTooltipExtras.orderText:Hide()
    self.friendsTooltipExtras.updatedText:Hide()
end

function ClassForge:UpdateFriendsTooltip(button)
    if not FriendsTooltip or not button or button.buttonType ~= FRIENDS_BUTTON_TYPE_WOW or not button.id then
        self:HideFriendsTooltipExtras()
        return
    end

    local name = GetFriendInfo(button.id)
    local data = name and self:GetDataForName(name) or nil
    if not data then
        self:HideFriendsTooltipExtras()
        return
    end

    self:EnsureFriendsTooltipExtras()

    local anchor = self:GetFriendsTooltipBottomAnchor()
    local classText = self.friendsTooltipExtras.classText
    local roleText = self.friendsTooltipExtras.roleText
    local orderText = self.friendsTooltipExtras.orderText
    local updatedText = self.friendsTooltipExtras.updatedText

    FriendsFrameTooltip_SetLine(classText, anchor, self:L("class_label") .. ": " .. self:GetColoredClassText(data), -8)
    FriendsFrameTooltip_SetLine(roleText, classText, self:L("role_label") .. ": |cffffffff" .. self:GetRoleDisplayText(data.role) .. "|r", -2)
    FriendsFrameTooltip_SetLine(orderText, roleText, self:L("faction_label") .. ": |cffffffff" .. self:GetFactionText(data) .. "|r", -2)
    FriendsFrameTooltip_SetLine(updatedText, orderText, self:L("source_label") .. ": |cffffffff" .. self:GetSourceLabel(data) .. "|r |cff808080-|r " .. self:L("updated_label") .. ": " .. self:FormatUpdatedTimeColored(data.updated), -2)

    FriendsTooltip:SetHeight(FriendsTooltip.height + FRIENDS_TOOLTIP_MARGIN_WIDTH)
    FriendsTooltip:SetWidth(min(FRIENDS_TOOLTIP_MAX_WIDTH, FriendsTooltip.maxWidth + FRIENDS_TOOLTIP_MARGIN_WIDTH))
end

function ClassForge:HookFriendsTooltip()
    if self.friendsTooltipHooked or not FriendsTooltip then
        return
    end

    self.friendsTooltipHooked = true

    FriendsTooltip:HookScript("OnShow", function(tooltip)
        if not tooltip.button then
            ClassForge:HideFriendsTooltipExtras()
            return
        end

        ClassForge:UpdateFriendsTooltip(tooltip.button)
    end)

    FriendsTooltip:HookScript("OnHide", function()
        ClassForge:HideFriendsTooltipExtras()
    end)
end

function ClassForge:GetVisibleFriendButtons()
    local buttons = {}
    local row = 1

    while true do
        local button = _G["FriendsFrameFriendsScrollFrameButton" .. row]
        if not button then
            break
        end

        buttons[#buttons + 1] = button
        row = row + 1
    end

    return buttons
end

function ClassForge:GetFriendButtonNameFontString(button)
    if not button or not button.GetName then
        return nil
    end

    return button.name
        or button.text
        or _G[button:GetName() .. "Name"]
        or _G[button:GetName() .. "Text"]
end

function ClassForge:HookWhoFrame()
    if self.whoHooked then
        return
    end

    self.whoHooked = true
    hooksecurefunc("WhoList_Update", function()
        ClassForge:UpdateWhoList()
    end)
end

function ClassForge:UpdateWhoList()
    if not WhoFrame or not WhoFrame:IsShown() or not WhoListScrollFrame then
        return
    end

    local offset = FauxScrollFrame_GetOffset(WhoListScrollFrame)
    local total = GetNumWhoResults() or 0

    for row = 1, WHOS_TO_DISPLAY do
        local index = offset + row
        if index <= total then
            local name, _, _, _, className = GetWhoInfo(index)
            local data = self:GetDataForName(name)
            local classFontString = _G["WhoFrameButton" .. row .. "Class"]

            if classFontString then
                if data then
                    classFontString:SetText(data.className or className or "")
                    classFontString:SetTextColor(self:HexToRGB(data.color))
                else
                    classFontString:SetText(className or "")
                    classFontString:SetTextColor(1, 0.82, 0)
                end
            end
        end
    end
end

function ClassForge:HookGuildFrame()
    if self.guildHooked then
        return
    end

    self.guildHooked = true

    hooksecurefunc("GuildStatus_Update", function()
        ClassForge:UpdateGuildRoster()
    end)

    hooksecurefunc("GuildRoster", function()
        ClassForge:UpdateGuildRoster()
    end)
end

function ClassForge:UpdateGuildRoster()
    if not GuildFrame or not GuildFrame:IsShown() or not GuildListScrollFrame then
        return
    end

    local total = GetNumGuildMembers(true) or 0
    local offset = FauxScrollFrame_GetOffset(GuildListScrollFrame)

    for row = 1, GUILDMEMBERS_TO_DISPLAY do
        local index = offset + row
        if index <= total then
            local fullName, _, _, _, className = GetGuildRosterInfo(index)
            local data = self:GetDataForName(fullName)
            local classFontString = _G["GuildFrameButton" .. row .. "Class"]

            if classFontString then
                if data then
                    classFontString:SetText(data.className or className or "")
                    classFontString:SetTextColor(self:HexToRGB(data.color))
                else
                    classFontString:SetText(className or "")
                    classFontString:SetTextColor(1, 0.82, 0)
                end
            end
        end
    end
end

function ClassForge:HookFriendsFrame()
    if self.friendsHooked then
        return
    end

    self.friendsHooked = true

    hooksecurefunc("FriendsFrame_Update", function()
        ClassForge:UpdateFriendsList()
    end)

    if FriendsList_Update then
        hooksecurefunc("FriendsList_Update", function()
            ClassForge:UpdateFriendsList()
        end)
    end

    if FriendsFrame then
        FriendsFrame:HookScript("OnShow", function()
            ClassForge:UpdateFriendsList()
        end)
    end
end

function ClassForge:UpdateFriendsList()
    if not FriendsFrame or not FriendsFrame:IsShown() or FriendsFrame.selectedTab ~= 1 then
        return
    end

    local buttons = self:GetVisibleFriendButtons()

    for _, button in ipairs(buttons) do
        local nameFontString = self:GetFriendButtonNameFontString(button)
        if button and button:IsShown() and nameFontString and button.buttonType == FRIENDS_BUTTON_TYPE_WOW and button.id then
            local name, _, _, _, _, _, noteText = GetFriendInfo(button.id)
            if name then
                local data = self:GetDataForName(name)
                local baseName = self:NormalizePlayerName(name) or name

                if noteText and noteText ~= "" then
                    baseName = baseName .. " |cff808080(" .. noteText .. ")|r"
                end

                if data then
                    nameFontString:SetText(baseName .. " |cff808080-|r " .. self:GetColoredClassText(data))
                else
                    nameFontString:SetText(baseName)
                end
            end
        end
    end
end

function ClassForge:CreateCharacterPanel()
    if not PaperDollFrame or PaperDollFrame.ClassForgeInfo then
        return
    end

    local info = PaperDollFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    info:SetPoint("TOP", CharacterLevelText, "BOTTOM", 0, -4)
    info:SetJustifyH("CENTER")
    info:SetWidth(220)
    PaperDollFrame.ClassForgeInfo = info

    hooksecurefunc("PaperDollFrame_SetLevel", function()
        ClassForge:UpdateCharacterPanel()
    end)
end

function ClassForge:UpdateCharacterPanel()
    if not PaperDollFrame or not PaperDollFrame.ClassForgeInfo then
        return
    end

    local data = self:BuildProfileData()
    local roleText = self:GetRoleDisplayText(data.role)
    local factionText = self:GetFactionText(data)

    PaperDollFrame.ClassForgeInfo:SetText(self:GetColoredClassText(data) .. " |cff808080(|r" .. roleText .. " |cff808080-|r " .. factionText .. "|cff808080)|r")
end

function ClassForge:CreateTargetClassTag()
    if self.targetTag or not TargetFrameTextureFrame then
        return
    end

    local tag = TargetFrameTextureFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    tag:SetPoint("TOP", TargetFrameTextureFrame, "BOTTOM", 0, 18)
    self.targetTag = tag
end

function ClassForge:UpdateTargetClassTag()
    if not self.targetTag then
        return
    end

    local data = self:GetDataForUnit("target")
    if not data then
        self.targetTag:SetText("")
        return
    end

    self.targetTag:SetText(self:GetColoredClassText(data))
end

function ClassForge:CreateTargetProfile()
    if self.targetProfile then
        return
    end

    if not TargetFrame then
        return
    end

    local frame = CreateFrame("Frame", "ClassForgeTargetProfile", TargetFrame)
    frame:SetWidth(220)
    frame:SetHeight(92)
    frame:SetFrameStrata(TargetFrame:GetFrameStrata())
    frame:SetFrameLevel(TargetFrame:GetFrameLevel() + 5)
    frame:SetClampedToScreen(true)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0, 0, 0, 0.85)
    frame:Hide()
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetMovable(true)
    frame:SetScript("OnDragStart", function(selfFrame)
        if IsShiftKeyDown() and not ClassForge:IsTargetProfileLocked() then
            selfFrame:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", function(selfFrame)
        selfFrame:StopMovingOrSizing()
        ClassForge:SaveTargetProfilePosition()
    end)

    frame.classText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.classText:SetPoint("TOPLEFT", 10, -10)
    frame.classText:SetJustifyH("LEFT")

    frame.roleText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.roleText:SetPoint("TOPLEFT", frame.classText, "BOTTOMLEFT", 0, -8)
    frame.roleText:SetJustifyH("LEFT")

    frame.orderText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.orderText:SetPoint("TOPLEFT", frame.roleText, "BOTTOMLEFT", 0, -6)
    frame.orderText:SetJustifyH("LEFT")

    frame.statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.statusText:SetPoint("TOPLEFT", frame.orderText, "BOTTOMLEFT", 0, -6)
    frame.statusText:SetJustifyH("LEFT")
    frame.statusText:SetWidth(190)

    frame.refreshButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.refreshButton:SetWidth(52)
    frame.refreshButton:SetHeight(18)
    frame.refreshButton:SetText(self:L("refresh"))
    frame.refreshButton:SetScript("OnClick", function()
        if UnitExists("target") and UnitIsPlayer("target") then
            local targetName = UnitName("target")
            if targetName then
                ClassForge:RequestSyncFromName(targetName)
            end
            ClassForge:PerformWhoSync()
        end
    end)

    frame.hintText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.hintText:SetPoint("BOTTOMRIGHT", -8, 8)
    frame.hintText:SetText(self:IsTargetProfileLocked() and self:L("locked") or self:L("shift_drag"))

    self.targetProfile = frame
    self:UpdateTargetProfileLayout()
    self:ApplyTargetProfilePosition()
end

function ClassForge:UpdateTargetProfileLayout()
    if not self.targetProfile then
        return
    end

    if self:IsTargetProfileCompact() then
        self.targetProfile:SetWidth(190)
        self.targetProfile:SetHeight(62)
        self.targetProfile.orderText:Hide()
        self.targetProfile.statusText:Hide()
    else
        self.targetProfile:SetWidth(220)
        self.targetProfile:SetHeight(92)
        self.targetProfile.orderText:Show()
        self.targetProfile.statusText:Show()
    end

    self.targetProfile.refreshButton:ClearAllPoints()
    self.targetProfile.refreshButton:SetPoint("TOPRIGHT", -8, -8)
end

function ClassForge:UpdateTargetProfile()
    if not self.targetProfile then
        return
    end

    if self:IsTargetProfileHidden() then
        self.targetProfile:Hide()
        return
    end

    local data = self:GetDataForUnit("target")
    if not data then
        self.targetProfile:Hide()
        return
    end

    self.targetProfile.classText:SetText(self:L("class_label") .. ": " .. self:GetColoredClassText(data))
    self.targetProfile.roleText:SetText(self:L("role_label") .. ": " .. self:GetRoleDisplayText(data.role))
    self.targetProfile.orderText:SetText(self:L("faction_label") .. ": " .. self:GetFactionText(data))
    self.targetProfile.statusText:SetText(self:GetSourceLabel(data) .. " |cff808080-|r " .. self:FormatUpdatedTimeColored(data.updated))
    self:UpdateTargetProfileLayout()
    self.targetProfile:Show()
end

function ClassForge:SetupInspectHooks()
    if self.inspectHooked then
        return
    end

    if not IsAddOnLoaded("Blizzard_InspectUI") then
        LoadAddOn("Blizzard_InspectUI")
    end

    if not InspectPaperDollFrame then
        return
    end

    self.inspectHooked = true

    local anchor = InspectLevelText or InspectNameText or InspectPaperDollFrame
    local text = InspectPaperDollFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    text:SetPoint("TOP", anchor, "BOTTOM", 0, -4)
    text:SetJustifyH("CENTER")
    text:SetWidth(220)
    InspectPaperDollFrame.ClassForgeInfo = text

    hooksecurefunc("InspectPaperDollFrame_SetLevel", function()
        ClassForge:UpdateInspectFrame()
    end)
end

function ClassForge:UpdateInspectFrame()
    if not InspectPaperDollFrame or not InspectPaperDollFrame.ClassForgeInfo then
        return
    end

    if not InspectFrame or not InspectFrame:IsShown() then
        InspectPaperDollFrame.ClassForgeInfo:SetText("")
        return
    end

    local name = UnitName("target")
    local data = name and self:GetDataForName(name) or nil

    if not data then
        InspectPaperDollFrame.ClassForgeInfo:SetText("")
        return
    end

    local factionText = self:GetFactionText(data)
    InspectPaperDollFrame.ClassForgeInfo:SetText(self:GetColoredClassText(data) .. " |cff808080(|r" .. self:GetRoleDisplayText(data.role) .. " |cff808080-|r " .. factionText .. " |cff808080-|r " .. self:GetSourceLabel(data) .. " |cff808080-|r " .. self:FormatUpdatedTimeColored(data.updated) .. "|cff808080)|r")
end
