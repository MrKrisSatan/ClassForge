function ClassForge:InitDisplay()
    self:HookTooltips()
    self:CreateTargetClassTag()
    self:HookChatFrames()
    self:HookWhoFrame()
    self:HookGuildFrame()
    self:CreateInspectProfileFrame()
end

-- =========================
-- TOOLTIP
-- =========================
function ClassForge:HookTooltips()
    GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
        local _, unit = tooltip:GetUnit()
        if not unit or not UnitIsPlayer(unit) then return end

        local data = ClassForge:GetUnitDisplayData(unit)
        if not data then return end

        tooltip:AddLine(" ")
        tooltip:AddLine("Class: " .. ClassForge:GetColoredClassText(data))
        tooltip:AddLine("Role: |cffffffff" .. (data.role or "Wanderer") .. "|r")
        tooltip:AddLine("Order: |cffffffff" .. (data.order or "Unaffiliated") .. "|r")
        tooltip:Show()
    end)
end

-- =========================
-- TARGET FRAME
-- =========================
function ClassForge:CreateTargetClassTag()
    if self.targetTag then return end

    local fs = TargetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetPoint("TOP", TargetFrameTextureFrame, "BOTTOM", 0, 18)
    fs:SetText("")
    self.targetTag = fs

    self:UpdateTargetClassTag()
end

function ClassForge:UpdateTargetClassTag()
    if not self.targetTag then return end

    if not UnitExists("target") or not UnitIsPlayer("target") then
        self.targetTag:SetText("")
        return
    end

    local data = self:GetUnitDisplayData("target")
    if not data then
        self.targetTag:SetText("")
        return
    end

    self.targetTag:SetText(self:GetColoredClassText(data))
end

-- =========================
-- CHAT TAGS
-- =========================
local hookedFrames = {}

function ClassForge:HookChatFrames()
    for i = 1, NUM_CHAT_WINDOWS do
        local frame = _G["ChatFrame" .. i]
        if frame and not hookedFrames[frame] then
            self:HookChatFrame(frame)
            hookedFrames[frame] = true
        end
    end
end

function ClassForge:HookChatFrame(frame)
    local original = frame.AddMessage

    frame.AddMessage = function(selfFrame, text, r, g, b, ...)
        if text and type(text) == "string" then
            text = ClassForge:InjectKnownPlayerTags(text)
        end
        return original(selfFrame, text, r, g, b, ...)
    end
end

function ClassForge:InjectKnownPlayerTags(text)
    if not text then return text end

    local myName = UnitName("player")
    local myData = self:GetMyData()

    if myName and myData then
        local myTag = self:GetColoredShortText(myData)
        text = text:gsub("(|Hplayer:" .. myName .. "[^|]-|h%[" .. myName .. "%]|h)", "%1 " .. myTag)
        text = text:gsub("(%f[%a]" .. myName .. "%f[%A])", "%1 " .. myTag)
    end

    for key, data in pairs(ClassForgeCache or {}) do
        local name = key
        if name and data and data.shortName then
            local tag = self:GetColoredShortText(data)
            text = text:gsub("(|Hplayer:" .. name .. "[^|]-|h%[" .. name .. "%]|h)", "%1 " .. tag)
        end
    end

    return text
end

-- =========================
-- WHO FRAME
-- =========================
function ClassForge:HookWhoFrame()
    if self.whoHooked then return end
    self.whoHooked = true

    hooksecurefunc("WhoList_Update", function()
        ClassForge:UpdateWhoList()
    end)
end

function ClassForge:UpdateWhoList()
    local numWhos = GetNumWhoResults()
    if not numWhos or numWhos <= 0 then return end

    local offset = FauxScrollFrame_GetOffset(WhoListScrollFrame)

    for i = 1, WHOS_TO_DISPLAY do
        local index = offset + i
        local button = _G["WhoFrameButton" .. i]

        if button and index <= numWhos then
            local name, guild, level, race, class, zone = GetWhoInfo(index)
            local data = self:GetDataForName(name)

            local classText = _G["WhoFrameButton" .. i .. "Class"]
            if classText then
                if data then
                    classText:SetText(data.className or "Hero")
                    local r, g, b = self:HexToRGB(data.color or "FFFFFFFF")
                    classText:SetTextColor(r, g, b)
                else
                    classText:SetText(class or "Hero")
                    classText:SetTextColor(1, 0.82, 0)
                end
            end
        end
    end
end

-- =========================
-- GUILD ROSTER
-- =========================
function ClassForge:HookGuildFrame()
    if self.guildHooked then return end
    self.guildHooked = true

    hooksecurefunc("GuildStatus_Update", function()
        ClassForge:UpdateGuildRoster()
    end)

    hooksecurefunc("GuildRoster", function()
        ClassForge:DelayedGuildUpdate()
    end)

    if GuildFrame then
        GuildFrame:HookScript("OnShow", function()
            ClassForge:DelayedGuildUpdate()
        end)
    end

    if GuildListScrollFrame then
        GuildListScrollFrame:HookScript("OnVerticalScroll", function()
            ClassForge:DelayedGuildUpdate()
        end)
    end
end

function ClassForge:DelayedGuildUpdate()
    if not self.guildUpdateFrame then
        self.guildUpdateFrame = CreateFrame("Frame")
    end

    self.guildUpdateFrame:SetScript("OnUpdate", function(frame, elapsed)
        frame.timer = (frame.timer or 0) + elapsed
        if frame.timer > 0.1 then
            frame:SetScript("OnUpdate", nil)
            frame.timer = 0
            ClassForge:UpdateGuildRoster()
        end
    end)
end

function ClassForge:UpdateGuildRoster()
    if not GuildFrame or not GuildFrame:IsShown() then return end
    if not GuildListScrollFrame then return end

    local offset = FauxScrollFrame_GetOffset(GuildListScrollFrame)
    local totalGuildMembers = GetNumGuildMembers(true)

    for i = 1, GUILDMEMBERS_TO_DISPLAY do
        local index = offset + i

        if index <= totalGuildMembers then
		local fullName, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(index)
		local name = self:NormalizePlayerName(fullName)
		local data = name and self:GetDataForName(name) or nil

            local classButton = _G["GuildFrameButton" .. i .. "Class"]
            if classButton then
                if data then
                    classButton:SetText(data.className or "Hero")
                    local r, g, b = self:HexToRGB(data.color or "FFFFFFFF")
                    classButton:SetTextColor(r, g, b)
                else
                    classButton:SetText(class or "Hero")
                    classButton:SetTextColor(1, 0.82, 0)
                end
            end
        end
    end
end

function ClassForge:DebugGuildFrames()
    self:Print("===== GUILD FRAME DEBUG START =====")

    if not GuildFrame then
        self:Print("GuildFrame not found.")
        return
    end

    if not GuildListScrollFrame then
        self:Print("GuildListScrollFrame not found.")
    else
        self:Print("GuildListScrollFrame found: " .. GuildListScrollFrame:GetName())
    end

    local totalGuildMembers = GetNumGuildMembers(true)
    self:Print("Guild members: " .. tostring(totalGuildMembers))
    self:Print("GUILDMEMBERS_TO_DISPLAY: " .. tostring(GUILDMEMBERS_TO_DISPLAY))

    local offset = GuildListScrollFrame and FauxScrollFrame_GetOffset(GuildListScrollFrame) or 0
    self:Print("Scroll offset: " .. tostring(offset))

    for i = 1, (GUILDMEMBERS_TO_DISPLAY or 14) do
        local index = offset + i
        local buttonName = "GuildFrameButton" .. i
        local button = _G[buttonName]
        local classFrameName = buttonName .. "Class"
        local classFrame = _G[classFrameName]

        self:Print("---- Row " .. i .. " (Guild Index " .. index .. ") ----")
        self:Print("Button: " .. tostring(buttonName) .. " exists=" .. tostring(button ~= nil))
        self:Print("ClassFrame: " .. tostring(classFrameName) .. " exists=" .. tostring(classFrame ~= nil))

        if index <= totalGuildMembers then
            local fullName, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(index)
	    local name = self:NormalizePlayerName(fullName)
            local data = name and self:GetDataForName(name) or nil

            self:Print("Guild API Full Name: " .. tostring(fullName))
	    self:Print("Guild API Name: " .. tostring(name))
            self:Print("Guild API Class: " .. tostring(class))
            if data then
    self:Print("Cached Custom Class: " .. tostring(data.className or "NONE"))
else
    self:Print("Cached Custom Class: NONE")
    self:Print("Cache lookup FAILED for this guild name")
end

            if classFrame then
                self:Print("Visible Class Text: " .. tostring(classFrame:GetText()))
            end
        else
            self:Print("No guild member for this visible row.")
        end
    end

    self:Print("===== GUILD FRAME DEBUG END =====")
end

function ClassForge:DebugWhoFrames()
    self:Print("===== WHO FRAME DEBUG START =====")

    local numWhos = GetNumWhoResults()
    self:Print("Who results: " .. tostring(numWhos))
    self:Print("WHOS_TO_DISPLAY: " .. tostring(WHOS_TO_DISPLAY))

    local offset = WhoListScrollFrame and FauxScrollFrame_GetOffset(WhoListScrollFrame) or 0
    self:Print("Scroll offset: " .. tostring(offset))

    for i = 1, (WHOS_TO_DISPLAY or 17) do
        local index = offset + i
        local buttonName = "WhoFrameButton" .. i
        local classFrameName = buttonName .. "Class"
        local classFrame = _G[classFrameName]

        self:Print("---- Row " .. i .. " (Who Index " .. index .. ") ----")
        self:Print("ClassFrame: " .. tostring(classFrameName) .. " exists=" .. tostring(classFrame ~= nil))

        if index <= numWhos then
            local name, guild, level, race, class, zone = GetWhoInfo(index)
            local data = name and self:GetDataForName(name) or nil

            self:Print("Who API Name: " .. tostring(name))
            self:Print("Who API Class: " .. tostring(class))
            self:Print("Cached Custom Class: " .. tostring(data and data.className or "NONE"))

            if classFrame then
                self:Print("Visible Class Text: " .. tostring(classFrame:GetText()))
            end
        end
    end

    self:Print("===== WHO FRAME DEBUG END =====")
end

function ClassForge:DebugTarget()
    self:Print("===== TARGET DEBUG START =====")

    if not UnitExists("target") then
        self:Print("No target.")
        return
    end

    local name = UnitName("target")
    self:Print("Target Name: " .. tostring(name))
    self:Print("Is Player: " .. tostring(UnitIsPlayer("target")))

    local data = self:GetUnitDisplayData("target")
    if data then
        self:Print("Cached Class: " .. tostring(data.className))
        self:Print("Cached Short: " .. tostring(data.shortName))
        self:Print("Cached Role: " .. tostring(data.role))
        self:Print("Cached Order: " .. tostring(data.order))
    else
        self:Print("No cached data for target.")
    end

    self:Print("===== TARGET DEBUG END =====")
end

function ClassForge:DebugCache()
    self:Print("===== CACHE DEBUG START =====")

    local count = 0
    for name, data in pairs(ClassForgeCache or {}) do
        count = count + 1
        self:Print(
            tostring(name) ..
            " => class=" .. tostring(data.className) ..
            ", short=" .. tostring(data.shortName) ..
            ", role=" .. tostring(data.role) ..
            ", order=" .. tostring(data.order)
        )
    end

    self:Print("Total cached players: " .. tostring(count))
    self:Print("===== CACHE DEBUG END =====")
end

-- =========================
-- INSPECT STYLE PROFILE
-- =========================
function ClassForge:CreateInspectProfileFrame()
    if self.inspectFrame then return end

    local f = CreateFrame("Frame", "ClassForgeInspectProfile", UIParent)
    f:SetWidth(220)
    f:SetHeight(90)
    f:SetPoint("TOPLEFT", TargetFrame, "TOPRIGHT", 10, -10)
    f:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0, 0, 0, 0.85)
    f:Hide()

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.title:SetPoint("TOPLEFT", 10, -10)
    f.title:SetText("Hero Profile")

    f.class = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.class:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -8)

    f.role = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.role:SetPoint("TOPLEFT", f.class, "BOTTOMLEFT", 0, -8)

    f.order = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.order:SetPoint("TOPLEFT", f.role, "BOTTOMLEFT", 0, -6)

    self.inspectFrame = f
end

function ClassForge:UpdateInspectProfile()
    if not self.inspectFrame then return end

    if not UnitExists("target") or not UnitIsPlayer("target") then
        self.inspectFrame:Hide()
        return
    end

    local data = self:GetUnitDisplayData("target")
    if not data then
        self.inspectFrame:Hide()
        return
    end

    self.inspectFrame.class:SetText("Class: " .. self:GetColoredClassText(data))
    self.inspectFrame.role:SetText("Role: " .. (data.role or "Wanderer"))
    self.inspectFrame.order:SetText("Order: " .. (data.order or "Unaffiliated"))
    self.inspectFrame:Show()
end