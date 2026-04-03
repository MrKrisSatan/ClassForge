function ClassForge:InitDisplay()
    self:HookTooltips()
    self:HookWhoFrame()
    self:HookGuildFrame()
    self:HookFriendsFrame()
    self:CreateCharacterPanel()
    self:CreateTargetClassTag()
    self:CreateTargetProfile()
    self:SetupInspectHooks()
end

function ClassForge:HookTooltips()
    if self.tooltipHooked then
        return
    end

    self.tooltipHooked = true

    GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
        local _, unit = tooltip:GetUnit()
        if not unit or not UnitIsPlayer(unit) then
            return
        end

        local data = ClassForge:GetDataForUnit(unit)
        if not data then
            return
        end

        tooltip:AddLine(" ")
        tooltip:AddLine("Class: " .. ClassForge:GetColoredClassText(data))
        tooltip:AddLine("Role: |cffffffff" .. (data.role or "DPS") .. "|r")
        if data.order and data.order ~= "" then
            tooltip:AddLine("Order: |cffffffff" .. data.order .. "|r")
        end
        tooltip:Show()
    end)
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

    for row = 1, FRIENDS_TO_DISPLAY do
        local button = _G["FriendsFrameFriendButton" .. row]
        if button and button.name and button.index then
            local name = GetFriendInfo(button.index)
            if name then
                local data = self:GetDataForName(name)
                local baseName = self:NormalizePlayerName(name) or name

                if data then
                    button.name:SetText(baseName .. " |cff808080-|r " .. self:GetColoredClassText(data))
                else
                    button.name:SetText(baseName)
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

    local frame = CreateFrame("Frame", "ClassForgeTargetProfile", UIParent)
    frame:SetWidth(200)
    frame:SetHeight(74)
    frame:SetPoint("TOPLEFT", TargetFrame, "TOPRIGHT", 8, -12)
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

    frame.classText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.classText:SetPoint("TOPLEFT", 10, -10)
    frame.classText:SetJustifyH("LEFT")

    frame.roleText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.roleText:SetPoint("TOPLEFT", frame.classText, "BOTTOMLEFT", 0, -8)
    frame.roleText:SetJustifyH("LEFT")

    frame.orderText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.orderText:SetPoint("TOPLEFT", frame.roleText, "BOTTOMLEFT", 0, -6)
    frame.orderText:SetJustifyH("LEFT")

    self.targetProfile = frame
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
