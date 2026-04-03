function ClassForge:InitDisplay()
    self:HookTooltips()
    self:HookFriendsTooltip()
    self:HookWhoFrame()
    self:HookGuildFrame()
    self:HookFriendsFrame()
    self:CreateCharacterPanel()
    self:CreateTargetClassTag()
    self:CreateTargetProfile()
    self:SetupInspectHooks()
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
    tooltip:AddLine("Class: " .. self:GetColoredClassText(data))
    tooltip:AddLine("Role: |cffffffff" .. (data.role or "DPS") .. "|r")
    if data.order and data.order ~= "" then
        tooltip:AddLine("Order: |cffffffff" .. data.order .. "|r")
    end
    tooltip:Show()
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
        if not unit or not UnitIsPlayer(unit) or not UnitExists("mouseover") or not UnitIsUnit(unit, "mouseover") then
            return
        end

        local data = ClassForge:GetDataForUnit("mouseover")
        if not data then
            return
        end

        ClassForge:AppendTooltipData(tooltip, data)
    end)
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

    self.friendsTooltipExtras = {
        classText = classText,
        roleText = roleText,
        orderText = orderText,
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

    FriendsFrameTooltip_SetLine(classText, anchor, "Class: " .. self:GetColoredClassText(data), -8)
    FriendsFrameTooltip_SetLine(roleText, classText, "Role: |cffffffff" .. (data.role or self.defaults.profile.role) .. "|r", -2)

    if data.order and data.order ~= "" then
        FriendsFrameTooltip_SetLine(orderText, roleText, "Order: |cffffffff" .. data.order .. "|r", -2)
    else
        orderText:Hide()
    end

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
    local roleText = data.role or self.defaults.profile.role
    local orderText = data.order ~= "" and (" |cff808080-|r " .. data.order) or ""

    PaperDollFrame.ClassForgeInfo:SetText(self:GetColoredClassText(data) .. " |cff808080(|r" .. roleText .. orderText .. "|cff808080)|r")
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
    frame:SetWidth(200)
    frame:SetHeight(74)
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
        if IsShiftKeyDown() then
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

    frame.hintText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.hintText:SetPoint("BOTTOMRIGHT", -8, 8)
    frame.hintText:SetText("Shift-drag")

    self.targetProfile = frame
    self:ApplyTargetProfilePosition()
end

function ClassForge:UpdateTargetProfile()
    if not self.targetProfile then
        return
    end

    local data = self:GetDataForUnit("target")
    if not data then
        self.targetProfile:Hide()
        return
    end

    self.targetProfile.classText:SetText("Class: " .. self:GetColoredClassText(data))
    self.targetProfile.roleText:SetText("Role: " .. (data.role or self.defaults.profile.role))
    self.targetProfile.orderText:SetText("Order: " .. (data.order ~= "" and data.order or "-"))
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

    local suffix = data.order ~= "" and (" |cff808080-|r " .. data.order) or ""
    InspectPaperDollFrame.ClassForgeInfo:SetText(self:GetColoredClassText(data) .. " |cff808080(|r" .. (data.role or self.defaults.profile.role) .. suffix .. "|cff808080)|r")
end
