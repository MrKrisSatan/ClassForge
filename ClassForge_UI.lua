local function createEditBox(parent, width, height, labelText, x, y)
    local label = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", x, y)
    label:SetText(labelText)

    local box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    box:SetAutoFocus(false)
    box:SetWidth(width)
    box:SetHeight(height)
    box:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -6)

    return box
end

function ClassForge:SetupSlashCommands()
    SLASH_CLASSFORGE1 = "/cf"
    SLASH_CLASSFORGE2 = "/classforge"

    SlashCmdList.CLASSFORGE = function(message)
        ClassForge:HandleSlash(message)
    end
end

function ClassForge:HandleSlash(message)
    local trimmed = self:Trim(message)
    local command, rest = trimmed:match("^(%S*)%s*(.-)$")
    command = string.lower(command or "")

    if command == "" or command == "help" then
        self:Print("/cf help")
        self:Print("/cf setclass <name>")
        self:Print("/cf setcolor <hex>")
        self:Print("/cf setrole <role>")
        self:Print("/cf realmaware on|off")
        self:Print("/cf show")
        self:Print("/cf sync")
        self:Print("/cf showminimap")
        self:Print("/cf hideminimap")
        self:Print("/cf resetminimap")
        self:Print("/cf chattags on|off")
        self:Print("/cf showpanel")
        self:Print("/cf hidepanel")
        self:Print("/cf lockpanel")
        self:Print("/cf unlockpanel")
        self:Print("/cf resetpanel")
        self:Print("/cf reset")
        self:Print("/cf options")
        return
    end

    if command == "setclass" then
        if rest == "" then
            self:Print("Usage: /cf setclass <name>")
            return
        end

        self:GetCharacterProfile().className = rest
        self:RefreshPlayerCache()
        self:BroadcastStartup()
        self:RefreshAllDisplays()
        self:Print("Class set to " .. rest .. ".")
        return
    end

    if command == "setcolor" then
        local color = self:SanitizeHex(rest)
        if not color then
            self:Print("Usage: /cf setcolor <hex>")
            return
        end

        self:GetCharacterProfile().color = color
        self:RefreshPlayerCache()
        self:BroadcastStartup()
        self:RefreshAllDisplays()
        self:Print("Color set to #" .. color .. ".")
        return
    end

    if command == "setrole" then
        local role = self:NormalizeRole(rest)
        if not role then
            self:Print("Role must be Heal, Tank, or DPS.")
            return
        end

        self:GetCharacterProfile().role = role
        self:RefreshPlayerCache()
        self:BroadcastStartup()
        self:RefreshAllDisplays()
        self:Print("Role set to " .. role .. ".")
        return
    end

    if command == "show" then
        local data = self:BuildProfileData()
        self:Print("Class: " .. data.className)
        self:Print("Color: #" .. data.color)
        self:Print("Role: " .. data.role)
        self:Print("Faction: " .. self:GetFactionText(data))
        self:Print("Source: " .. self:GetSourceLabel(data))
        self:Print("Realm-aware names: " .. (self:IsRealmAwareEnabled() and "On" or "Off"))
        self:Print("Version: " .. (self.version or "3.0.0"))
        self:Print("Downloads: " .. (self.releasesPage or self.homepage))
        return
    end

    if command == "sync" then
        self:RefreshPlayerCache()
        self:BroadcastStartup()
        self:RequestSyncFromFriends()
        if self:PerformWhoSync() then
            self:Print("Sync started.")
        else
            self:Print("Sync throttled. Try again in a moment.")
        end
        return
    end

    if command == "showminimap" then
        self:SetMinimapButtonHidden(false)
        self:Print("Minimap button shown.")
        return
    end

    if command == "hideminimap" then
        self:SetMinimapButtonHidden(true)
        self:Print("Minimap button hidden.")
        return
    end

    if command == "resetminimap" then
        self:ResetMinimapButtonPosition()
        self:Print("Minimap button reset.")
        return
    end

    if command == "chattags" then
        local lowerRest = string.lower(self:Trim(rest))
        if lowerRest == "on" then
            self:SetChatDecorationEnabled(true)
            self:Print("Chat tags enabled.")
            return
        end
        if lowerRest == "off" then
            self:SetChatDecorationEnabled(false)
            self:Print("Chat tags disabled.")
            return
        end

        self:Print("Usage: /cf chattags on|off")
        return
    end

    if command == "realmaware" then
        local lowerRest = string.lower(self:Trim(rest))
        if lowerRest == "on" then
            ClassForgeDB.profile.names.realmAware = true
            self:MigrateDatabase()
            self:RefreshPlayerCache()
            self:RefreshAllDisplays()
            self:Print("Realm-aware names enabled.")
            return
        end
        if lowerRest == "off" then
            ClassForgeDB.profile.names.realmAware = false
            self:MigrateDatabase()
            self:RefreshPlayerCache()
            self:RefreshAllDisplays()
            self:Print("Realm-aware names disabled.")
            return
        end

        self:Print("Usage: /cf realmaware on|off")
        return
    end

    if command == "showpanel" then
        self:SetTargetProfileHidden(false)
        self:Print("Target profile shown.")
        return
    end

    if command == "hidepanel" then
        self:SetTargetProfileHidden(true)
        self:Print("Target profile hidden.")
        return
    end

    if command == "lockpanel" then
        self:SetTargetProfileLocked(true)
        self:Print("Target profile locked.")
        return
    end

    if command == "unlockpanel" then
        self:SetTargetProfileLocked(false)
        self:Print("Target profile unlocked.")
        return
    end

    if command == "resetpanel" then
        if self.ResetTargetProfilePosition then
            self:ResetTargetProfilePosition()
            self:Print("Target profile panel reset.")
        end
        return
    end

    if command == "reset" then
        local characterProfile = self:GetCharacterProfile()
        characterProfile.className = self.defaults.character.className
        characterProfile.color = self.defaults.character.color
        characterProfile.role = self.defaults.character.role
        self:RefreshPlayerCache()
        self:BroadcastStartup()
        self:RefreshAllDisplays()
        self:Print("Profile reset to defaults.")
        return
    end

    if command == "options" then
        if self.optionsPanel then
            InterfaceOptionsFrame_OpenToCategory(self.optionsPanel)
            InterfaceOptionsFrame_OpenToCategory(self.optionsPanel)
        end
        return
    end

    self:Print("Unknown command. Type /cf help.")
end

function ClassForge:CreateOptionsPanel()
    if self.optionsPanel then
        return
    end

    local panel = CreateFrame("Frame", "ClassForgeOptionsPanel", InterfaceOptionsFramePanelContainer)
    panel.name = "ClassForge"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("ClassForge")

    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Custom class identities for Wrath 3.3.5a with sync, cache, and map support.")

    local tabs = {}
    local tabFrames = {}

    local function selectTab(name)
        for tabName, frame in pairs(tabFrames) do
            if tabName == name then
                frame:Show()
            else
                frame:Hide()
            end
        end

        for tabName, button in pairs(tabs) do
            if tabName == name then
                button:Disable()
            else
                button:Enable()
            end
        end
    end

    local function createTab(name, label, xOffset)
        local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        button:SetWidth(110)
        button:SetHeight(22)
        button:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", xOffset, -14)
        button:SetText(label)
        tabs[name] = button

        local frame = CreateFrame("Frame", nil, panel)
        frame:SetPoint("TOPLEFT", 16, -96)
        frame:SetPoint("BOTTOMRIGHT", -36, 16)
        frame:Hide()
        tabFrames[name] = frame

        button:SetScript("OnClick", function()
            selectTab(name)
        end)

        return frame
    end

    local overview = createTab("overview", "Profile", 0)
    local display = createTab("display", "Display", 116)
    local cache = createTab("cache", "Cache", 232)

    local classBox = createEditBox(overview, 220, 30, "Custom class name", 0, 0)
    local classPresets = {
        { name = "Death Knight", color = "C41E3A" },
        { name = "Demon Hunter", color = "A330C9" },
        { name = "Druid", color = "FF7C0A" },
        { name = "Evoker", color = "33937F" },
        { name = "Hunter", color = "AAD372" },
        { name = "Mage", color = "3FC7EB" },
        { name = "Monk", color = "00FF98" },
        { name = "Paladin", color = "F48CBA" },
        { name = "Priest", color = "FFFFFF" },
        { name = "Rogue", color = "FFF468" },
        { name = "Shaman", color = "0070DD" },
        { name = "Warlock", color = "8788EE" },
        { name = "Warrior", color = "C69B6D" },
        { name = "Spell Breaker", color = "7DF9FF" },
        { name = "Abyss Walker", color = "1A1A2E" },
        { name = "Bloodbinder", color = "8B0000" },
        { name = "Chronomancer", color = "FFD700" },
        { name = "Grave Warden", color = "4B5320" },
        { name = "Storm Herald", color = "00BFFF" },
        { name = "Runesmith", color = "B87333" },
        { name = "Soul Weaver", color = "6A0DAD" },
        { name = "Beast Warden", color = "556B2F" },
        { name = "Voidcaller", color = "2F4F4F" },
        { name = "Sun Cleric", color = "FFDE59" },
        { name = "Frostbinder", color = "AFEEEE" },
        { name = "Ashbringer", color = "A9A9A9" },
        { name = "Hexblade", color = "3B0A45" },
        { name = "Spirit Dancer", color = "7FFFD4" },
        { name = "Iron Vanguard", color = "708090" },
        { name = "Plaguebringer", color = "556B2F" },
        { name = "Starcaller", color = "4169E1" },
        { name = "Shadow Duelist", color = "2B2B2B" },
        { name = "Ember Knight", color = "FF4500" },
        { name = "Tide Sage", color = "20B2AA" },
        { name = "Bone Oracle", color = "F5F5DC" },
        { name = "Thunder Reaver", color = "1E90FF" },
        { name = "Nether Alchemist", color = "9932CC" },
        { name = "Wildheart", color = "228B22" },
        { name = "Doom Harbinger", color = "800000" },
    }
    local updatePreview

    local presetButton = CreateFrame("Button", nil, overview, "UIPanelButtonTemplate")
    presetButton:SetWidth(64)
    presetButton:SetHeight(22)
    presetButton:SetPoint("LEFT", classBox, "RIGHT", 10, 0)
    presetButton:SetText("Presets")
    local presetPopup = CreateFrame("Frame", "ClassForgePresetPopup", overview)
    presetPopup:SetWidth(250)
    presetPopup:SetHeight(220)
    presetPopup:SetPoint("TOPLEFT", presetButton, "BOTTOMLEFT", 0, -4)
    presetPopup:SetFrameStrata("DIALOG")
    presetPopup:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    presetPopup:SetBackdropColor(0, 0, 0, 0.95)
    presetPopup:Hide()

    local presetScrollFrame = CreateFrame("ScrollFrame", "ClassForgePresetScrollFrame", presetPopup, "UIPanelScrollFrameTemplate")
    presetScrollFrame:SetPoint("TOPLEFT", 8, -8)
    presetScrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)

    local presetContent = CreateFrame("Frame", nil, presetScrollFrame)
    presetContent:SetWidth(214)
    presetContent:SetHeight(#classPresets * 22)
    presetScrollFrame:SetScrollChild(presetContent)
    local colorBox = createEditBox(overview, 220, 30, "Class color hex", 0, -62)

    local roleLabel = overview:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    roleLabel:SetPoint("TOPLEFT", 0, -124)
    roleLabel:SetText("Role")

    local roleDropdown = CreateFrame("Frame", "ClassForgeRoleDropdown", overview, "UIDropDownMenuTemplate")
    roleDropdown:SetPoint("TOPLEFT", roleLabel, "BOTTOMLEFT", -16, -2)
    local roleOptions = {
        { text = "Tank", value = "Tank" },
        { text = "Healer", value = "Heal" },
        { text = "Damage", value = "DPS" },
    }

    local function getRoleLabel(value)
        for _, option in ipairs(roleOptions) do
            if option.value == value then
                return option.text
            end
        end

        return "Damage"
    end

    local function setSelectedRole(value)
        local normalized = ClassForge:NormalizeRole(value) or ClassForge.defaults.character.role
        roleDropdown.selectedValue = normalized
        UIDropDownMenu_SetText(roleDropdown, getRoleLabel(normalized))
    end

    UIDropDownMenu_SetWidth(roleDropdown, 190)
    UIDropDownMenu_Initialize(roleDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for _, option in ipairs(roleOptions) do
            info.text = option.text
            info.value = option.value
            info.func = function()
                setSelectedRole(option.value)
                updatePreview()
            end
            info.checked = (roleDropdown.selectedValue == option.value)
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    local factionLabel = overview:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    factionLabel:SetPoint("TOPLEFT", 0, -186)
    factionLabel:SetText("Faction")

    local factionValue = overview:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    factionValue:SetPoint("TOPLEFT", factionLabel, "BOTTOMLEFT", 0, -8)
    factionValue:SetWidth(220)
    factionValue:SetJustifyH("LEFT")

    local preview = overview:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    preview:SetPoint("TOPLEFT", 360, -28)
    preview:SetWidth(260)
    preview:SetJustifyH("LEFT")

    local colorPickerButton = CreateFrame("Button", nil, overview, "UIPanelButtonTemplate")
    colorPickerButton:SetWidth(52)
    colorPickerButton:SetHeight(22)
    colorPickerButton:SetPoint("LEFT", colorBox, "RIGHT", 10, 0)
    colorPickerButton:SetText("Pick")

    updatePreview = function()
        local role = roleDropdown.selectedValue or ClassForge.defaults.character.role
        local data = {
            className = ClassForge:Trim(classBox:GetText()) ~= "" and ClassForge:Trim(classBox:GetText()) or ClassForge.defaults.character.className,
            color = ClassForge:SanitizeHex(colorBox:GetText()) or ClassForge.defaults.character.color,
            role = role,
            faction = ClassForge:GetUnitFaction("player"),
        }

        preview:SetText("Preview\n" .. ClassForge:GetColoredClassText(data) .. "\nRole: " .. data.role .. "\nFaction: " .. ClassForge:GetFactionText(data))
    end

    for index, preset in ipairs(classPresets) do
        local row = CreateFrame("Button", nil, presetContent)
        row:SetWidth(214)
        row:SetHeight(20)
        row:SetPoint("TOPLEFT", 0, -((index - 1) * 22))

        row.text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        row.text:SetPoint("LEFT", 4, 0)
        row.text:SetJustifyH("LEFT")
        row.text:SetText(string.format("%s  (#%s)", preset.name, preset.color))

        row.highlight = row:CreateTexture(nil, "HIGHLIGHT")
        row.highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        row.highlight:SetBlendMode("ADD")
        row.highlight:SetAllPoints(row)

        row:SetScript("OnClick", function()
            classBox:SetText(preset.name)
            colorBox:SetText(preset.color)
            presetPopup:Hide()
            updatePreview()
        end)
    end

    presetButton:SetScript("OnClick", function()
        if presetPopup:IsShown() then
            presetPopup:Hide()
        else
            presetPopup:Show()
        end
    end)

    local function applyPickedColor(red, green, blue)
        local hex = ClassForge:RGBToHex(red, green, blue)
        colorBox:SetText(hex)
        updatePreview()
    end

    colorPickerButton:SetScript("OnClick", function()
        if not ColorPickerFrame then
            return
        end

        local initialHex = ClassForge:SanitizeHex(colorBox:GetText()) or ClassForge.defaults.character.color
        local red, green, blue = ClassForge:HexToRGB(initialHex)

        ColorPickerFrame.hasOpacity = nil
        ColorPickerFrame.opacity = 0
        ColorPickerFrame.previousValues = { red, green, blue }
        ColorPickerFrame.func = function()
            local currentRed, currentGreen, currentBlue = ColorPickerFrame:GetColorRGB()
            applyPickedColor(currentRed, currentGreen, currentBlue)
        end
        ColorPickerFrame.cancelFunc = function(previousValues)
            if previousValues then
                applyPickedColor(previousValues[1], previousValues[2], previousValues[3])
            end
        end
        ColorPickerFrame:SetColorRGB(red, green, blue)
        ColorPickerFrame:Show()
    end)

    local saveButton = CreateFrame("Button", nil, overview, "UIPanelButtonTemplate")
    saveButton:SetWidth(100)
    saveButton:SetHeight(24)
    saveButton:SetPoint("TOPLEFT", factionValue, "BOTTOMLEFT", 0, -16)
    saveButton:SetText("Save")
    saveButton:SetScript("OnClick", function()
        local className = ClassForge:Trim(classBox:GetText())
        local color = ClassForge:SanitizeHex(colorBox:GetText())
        local role = roleDropdown.selectedValue or ClassForge.defaults.character.role

        local characterProfile = ClassForge:GetCharacterProfile()
        characterProfile.className = className ~= "" and className or ClassForge.defaults.character.className
        characterProfile.color = color or ClassForge.defaults.character.color
        characterProfile.role = role or ClassForge.defaults.character.role

        ClassForge:RefreshPlayerCache()
        ClassForge:BroadcastStartup()
        ClassForge:RefreshAllDisplays()
        updatePreview()
        ClassForge:Print("Profile saved.")
    end)

    local syncButton = CreateFrame("Button", nil, overview, "UIPanelButtonTemplate")
    syncButton:SetWidth(100)
    syncButton:SetHeight(24)
    syncButton:SetPoint("LEFT", saveButton, "RIGHT", 8, 0)
    syncButton:SetText("Sync")
    syncButton:SetScript("OnClick", function()
        ClassForge:HandleSlash("sync")
    end)

    local resetButton = CreateFrame("Button", nil, overview, "UIPanelButtonTemplate")
    resetButton:SetWidth(100)
    resetButton:SetHeight(24)
    resetButton:SetPoint("LEFT", syncButton, "RIGHT", 8, 0)
    resetButton:SetText("Reset")
    resetButton:SetScript("OnClick", function()
        classBox:SetText(ClassForge.defaults.character.className)
        colorBox:SetText(ClassForge.defaults.character.color)
        setSelectedRole(ClassForge.defaults.character.role)
        factionValue:SetText(ClassForge:GetFactionText(ClassForge:BuildProfileData()))
        updatePreview()
    end)

    local statusText = overview:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    statusText:SetPoint("TOPLEFT", saveButton, "BOTTOMLEFT", 0, -12)
    statusText:SetWidth(520)
    statusText:SetJustifyH("LEFT")

    local minimapToggle = CreateFrame("CheckButton", "ClassForgeOptionsMinimapToggle", display, "UICheckButtonTemplate")
    minimapToggle:SetPoint("TOPLEFT", 0, -10)
    _G[minimapToggle:GetName() .. "Text"]:SetText("Show minimap button")
    minimapToggle:SetScript("OnClick", function(selfButton)
        ClassForge:SetMinimapButtonHidden(not selfButton:GetChecked())
    end)

    local minimapResetButton = CreateFrame("Button", nil, display, "UIPanelButtonTemplate")
    minimapResetButton:SetWidth(140)
    minimapResetButton:SetHeight(24)
    minimapResetButton:SetPoint("LEFT", minimapToggle, "RIGHT", 150, 0)
    minimapResetButton:SetText("Reset Minimap")
    minimapResetButton:SetScript("OnClick", function()
        ClassForge:ResetMinimapButtonPosition()
        minimapToggle:SetChecked(true)
        ClassForge:Print("Minimap button reset.")
    end)

    local chatToggle = CreateFrame("CheckButton", "ClassForgeOptionsChatToggle", display, "UICheckButtonTemplate")
    chatToggle:SetPoint("TOPLEFT", minimapToggle, "BOTTOMLEFT", 0, -10)
    _G[chatToggle:GetName() .. "Text"]:SetText("Show custom class tags in party, raid, guild, and whisper chat")
    chatToggle:SetScript("OnClick", function(selfButton)
        ClassForge:SetChatDecorationEnabled(selfButton:GetChecked())
    end)

    local realmToggle = CreateFrame("CheckButton", "ClassForgeOptionsRealmToggle", display, "UICheckButtonTemplate")
    realmToggle:SetPoint("TOPLEFT", chatToggle, "BOTTOMLEFT", 0, -10)
    _G[realmToggle:GetName() .. "Text"]:SetText("Use realm-aware names when a realm suffix is present")
    realmToggle:SetScript("OnClick", function(selfButton)
        ClassForgeDB.profile.names.realmAware = selfButton:GetChecked() and true or false
        ClassForge:MigrateDatabase()
        ClassForge:RefreshPlayerCache()
        ClassForge:RefreshAllDisplays()
    end)

    local autoWhoLoginToggle = CreateFrame("CheckButton", "ClassForgeOptionsAutoWhoLoginToggle", display, "UICheckButtonTemplate")
    autoWhoLoginToggle:SetPoint("TOPLEFT", realmToggle, "BOTTOMLEFT", 0, -10)
    _G[autoWhoLoginToggle:GetName() .. "Text"]:SetText("Run background /who sync on login")
    autoWhoLoginToggle:SetScript("OnClick", function(selfButton)
        ClassForgeDB.profile.sync.autoWhoOnLogin = selfButton:GetChecked() and true or false
    end)

    local autoWhoGroupToggle = CreateFrame("CheckButton", "ClassForgeOptionsAutoWhoGroupToggle", display, "UICheckButtonTemplate")
    autoWhoGroupToggle:SetPoint("TOPLEFT", autoWhoLoginToggle, "BOTTOMLEFT", 0, -10)
    _G[autoWhoGroupToggle:GetName() .. "Text"]:SetText("Run background /who sync on group changes")
    autoWhoGroupToggle:SetScript("OnClick", function(selfButton)
        ClassForgeDB.profile.sync.autoWhoOnGroup = selfButton:GetChecked() and true or false
    end)

    local panelVisibleToggle = CreateFrame("CheckButton", "ClassForgeOptionsPanelVisibleToggle", display, "UICheckButtonTemplate")
    panelVisibleToggle:SetPoint("TOPLEFT", autoWhoGroupToggle, "BOTTOMLEFT", 0, -10)
    _G[panelVisibleToggle:GetName() .. "Text"]:SetText("Show target profile panel")
    panelVisibleToggle:SetScript("OnClick", function(selfButton)
        ClassForge:SetTargetProfileHidden(not selfButton:GetChecked())
    end)

    local panelLockToggle = CreateFrame("CheckButton", "ClassForgeOptionsPanelLockToggle", display, "UICheckButtonTemplate")
    panelLockToggle:SetPoint("TOPLEFT", panelVisibleToggle, "BOTTOMLEFT", 0, -10)
    _G[panelLockToggle:GetName() .. "Text"]:SetText("Lock target profile panel position")
    panelLockToggle:SetScript("OnClick", function(selfButton)
        ClassForge:SetTargetProfileLocked(selfButton:GetChecked())
    end)

    local panelCompactToggle = CreateFrame("CheckButton", "ClassForgeOptionsPanelCompactToggle", display, "UICheckButtonTemplate")
    panelCompactToggle:SetPoint("TOPLEFT", panelLockToggle, "BOTTOMLEFT", 0, -10)
    _G[panelCompactToggle:GetName() .. "Text"]:SetText("Use compact target profile panel")
    panelCompactToggle:SetScript("OnClick", function(selfButton)
        ClassForge:SetTargetProfileCompact(selfButton:GetChecked())
    end)

    local groupFrameColorsToggle = CreateFrame("CheckButton", "ClassForgeOptionsGroupColorsToggle", display, "UICheckButtonTemplate")
    groupFrameColorsToggle:SetPoint("TOPLEFT", panelCompactToggle, "BOTTOMLEFT", 0, -10)
    _G[groupFrameColorsToggle:GetName() .. "Text"]:SetText("Color party and raid frame names with custom class color")
    groupFrameColorsToggle:SetScript("OnClick", function(selfButton)
        ClassForgeDB.profile.colors.groupFrames = selfButton:GetChecked() and true or false
        ClassForge:RefreshAllDisplays()
    end)

    local panelResetButton = CreateFrame("Button", nil, display, "UIPanelButtonTemplate")
    panelResetButton:SetWidth(140)
    panelResetButton:SetHeight(24)
    panelResetButton:SetPoint("TOPLEFT", groupFrameColorsToggle, "BOTTOMLEFT", 4, -14)
    panelResetButton:SetText("Reset Panel")
    panelResetButton:SetScript("OnClick", function()
        ClassForge:ResetTargetProfilePosition()
        ClassForge:Print("Target profile panel reset.")
    end)

    local panelHint = display:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    panelHint:SetPoint("LEFT", panelResetButton, "RIGHT", 12, 0)
    panelHint:SetText("Hold Shift and drag the target profile when it is unlocked.")

    local displayStatus = display:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    displayStatus:SetPoint("TOPLEFT", panelResetButton, "BOTTOMLEFT", 0, -14)
    displayStatus:SetWidth(520)
    displayStatus:SetJustifyH("LEFT")

    local cacheStatus = cache:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    cacheStatus:SetPoint("TOPLEFT", 0, -10)
    cacheStatus:SetWidth(340)
    cacheStatus:SetJustifyH("LEFT")

    local cacheList = cache:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    cacheList:SetPoint("TOPLEFT", cacheStatus, "BOTTOMLEFT", 0, -8)
    cacheList:SetWidth(520)
    cacheList:SetJustifyH("LEFT")
    cacheList:SetJustifyV("TOP")

    local function updateCacheDisplay()
        local lines = {}
        local entries = {}

        if ClassForgeCache then
            for _, data in pairs(ClassForgeCache) do
                entries[#entries + 1] = data
            end
        end

        table.sort(entries, function(left, right)
            return (tonumber(left.updated) or 0) > (tonumber(right.updated) or 0)
        end)

        cacheStatus:SetText("Cached players: " .. ClassForge:GetCacheEntryCount() .. "\nDatabase schema: " .. tostring(ClassForgeDB.dbVersion or ClassForge.dbVersion))

        local limit = math.min(#entries, 8)
        for index = 1, limit do
            local data = entries[index]
            lines[#lines + 1] = string.format("%s - %s - %s", data.name or "Unknown", ClassForge:GetSourceLabel(data), ClassForge:FormatUpdatedTime(data.updated))
        end

        if #lines == 0 then
            cacheList:SetText("No cached players yet.")
        else
            cacheList:SetText("Recent entries:\n" .. table.concat(lines, "\n"))
        end
    end

    local clearStaleButton = CreateFrame("Button", nil, cache, "UIPanelButtonTemplate")
    clearStaleButton:SetWidth(100)
    clearStaleButton:SetHeight(24)
    clearStaleButton:SetPoint("TOPLEFT", cacheList, "BOTTOMLEFT", 0, -12)
    clearStaleButton:SetText("Clear Stale")

    local clearAllButton = CreateFrame("Button", nil, cache, "UIPanelButtonTemplate")
    clearAllButton:SetWidth(100)
    clearAllButton:SetHeight(24)
    clearAllButton:SetPoint("LEFT", clearStaleButton, "RIGHT", 8, 0)
    clearAllButton:SetText("Clear All")

    local browserTitle = cache:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    browserTitle:SetPoint("TOPLEFT", clearStaleButton, "BOTTOMLEFT", 0, -22)
    browserTitle:SetText("Known Players")

    local updateKnownPlayersBrowser

    local browserSearchBox = CreateFrame("EditBox", nil, cache, "InputBoxTemplate")
    browserSearchBox:SetAutoFocus(false)
    browserSearchBox:SetWidth(220)
    browserSearchBox:SetHeight(20)
    browserSearchBox:SetPoint("LEFT", browserTitle, "RIGHT", 12, 0)
    browserSearchBox:SetScript("OnTextChanged", function()
        updateKnownPlayersBrowser()
    end)

    local browserFrame = CreateFrame("ScrollFrame", "ClassForgeKnownPlayersScrollFrame", cache, "UIPanelScrollFrameTemplate")
    browserFrame:SetPoint("TOPLEFT", browserTitle, "BOTTOMLEFT", 0, -8)
    browserFrame:SetWidth(530)
    browserFrame:SetHeight(170)

    local browserContent = CreateFrame("Frame", nil, browserFrame)
    browserContent:SetWidth(510)
    browserContent:SetHeight(170)
    browserFrame:SetScrollChild(browserContent)

    local browserText = browserContent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    browserText:SetPoint("TOPLEFT", 0, 0)
    browserText:SetWidth(500)
    browserText:SetJustifyH("LEFT")
    browserText:SetJustifyV("TOP")

    updateKnownPlayersBrowser = function()
        local entries = {}
        local lines = { "Name | Class | Role | Source | Version | Updated" }
        local filter = string.lower(ClassForge:Trim(browserSearchBox:GetText()))

        if ClassForgeCache then
            for _, data in pairs(ClassForgeCache) do
                entries[#entries + 1] = data
            end
        end

        table.sort(entries, function(left, right)
            return string.lower(left.name or "") < string.lower(right.name or "")
        end)

        if #entries == 0 then
            browserText:SetText("No known players yet.")
            browserContent:SetHeight(170)
            return
        end

        for _, data in ipairs(entries) do
            local nameText = data.name or "Unknown"
            local classText = data.className or "Unknown"
            if filter == ""
                or string.find(string.lower(nameText), filter, 1, true)
                or string.find(string.lower(classText), filter, 1, true) then
                lines[#lines + 1] = string.format(
                    "%s | %s | %s | %s | %s | %s",
                    nameText,
                    classText,
                    data.role or "-",
                    ClassForge:GetSourceLabel(data),
                    (data.addonVersion and data.addonVersion ~= "") and data.addonVersion or "-",
                    ClassForge:FormatUpdatedTime(data.updated)
                )
            end
        end

        if #lines == 1 then
            browserText:SetText("No matching players found.")
        else
            browserText:SetText(table.concat(lines, "\n"))
        end
        browserContent:SetHeight(math.max(170, browserText:GetStringHeight() + 10))
    end

    clearStaleButton:SetScript("OnClick", function()
        local removed = ClassForge:ClearStaleCacheEntries(30 * 24 * 60 * 60)
        updateCacheDisplay()
        updateKnownPlayersBrowser()
        ClassForge:Print("Removed " .. removed .. " stale cache entr" .. (removed == 1 and "y." or "ies."))
    end)

    clearAllButton:SetScript("OnClick", function()
        ClassForge:ClearCache(true)
        updateCacheDisplay()
        updateKnownPlayersBrowser()
        ClassForge:Print("Cache cleared.")
    end)

    local function refreshStatusText()
        local syncState = ClassForge.syncState or {}
        local whoState = syncState.who or {}
        statusText:SetText(
            "Addon version: " .. (ClassForge.version or "3.0.0")
            .. "\nSync protocol: CF3"
            .. "\nLast sync: " .. ClassForge:FormatUpdatedTime(syncState.lastSync)
            .. " |cff808080-|r Last /who: " .. ClassForge:FormatUpdatedTime(whoState.lastComplete)
            .. " |cff808080-|r Addon users: " .. ClassForge:GetConfirmedAddonUserCount()
            .. "\nUse /cf sync to refresh your record and query nearby players."
        )
        displayStatus:SetText("Minimap button: " .. (ClassForge:IsMinimapButtonHidden() and "Hidden" or "Shown")
            .. " |cff808080-|r Target profile: " .. (ClassForge:IsTargetProfileHidden() and "Hidden" or "Shown")
            .. " |cff808080-|r Locked: " .. (ClassForge:IsTargetProfileLocked() and "Yes" or "No")
            .. " |cff808080-|r Compact: " .. (ClassForge:IsTargetProfileCompact() and "Yes" or "No")
            .. " |cff808080-|r Group colors: " .. (ClassForge:IsGroupFrameColoringEnabled() and "On" or "Off")
            .. " |cff808080-|r Realm-aware names: " .. (ClassForge:IsRealmAwareEnabled() and "On" or "Off"))
    end

    panel:SetScript("OnShow", function()
        local profile = ClassForge:GetProfile()
        local characterProfile = ClassForge:GetCharacterProfile()
        classBox:SetText(characterProfile.className or ClassForge.defaults.character.className)
        colorBox:SetText(characterProfile.color or ClassForge.defaults.character.color)
        setSelectedRole(characterProfile.role or ClassForge.defaults.character.role)
        factionValue:SetText(ClassForge:GetFactionText(ClassForge:BuildProfileData()))
        minimapToggle:SetChecked(not ClassForge:IsMinimapButtonHidden())
        chatToggle:SetChecked(ClassForge:IsChatDecorationEnabled())
        realmToggle:SetChecked(ClassForge:IsRealmAwareEnabled())
        autoWhoLoginToggle:SetChecked(ClassForge:IsAutoWhoOnLoginEnabled())
        autoWhoGroupToggle:SetChecked(ClassForge:IsAutoWhoOnGroupEnabled())
        panelVisibleToggle:SetChecked(not ClassForge:IsTargetProfileHidden())
        panelLockToggle:SetChecked(ClassForge:IsTargetProfileLocked())
        panelCompactToggle:SetChecked(ClassForge:IsTargetProfileCompact())
        groupFrameColorsToggle:SetChecked(ClassForge:IsGroupFrameColoringEnabled())
        updatePreview()
        updateCacheDisplay()
        updateKnownPlayersBrowser()
        refreshStatusText()
        selectTab("overview")
    end)

    InterfaceOptions_AddCategory(panel)
    self.optionsPanel = panel
end
