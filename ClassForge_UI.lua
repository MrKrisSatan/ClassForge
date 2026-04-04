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
        self:Print("/cf setorder <order>")
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

        ClassForgeDB.profile.className = rest
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

        ClassForgeDB.profile.color = color
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

        ClassForgeDB.profile.role = role
        self:RefreshPlayerCache()
        self:BroadcastStartup()
        self:RefreshAllDisplays()
        self:Print("Role set to " .. role .. ".")
        return
    end

    if command == "setorder" then
        ClassForgeDB.profile.order = self:Trim(rest)
        self:RefreshPlayerCache()
        self:BroadcastStartup()
        self:RefreshAllDisplays()
        self:Print("Order updated.")
        return
    end

    if command == "show" then
        local data = self:BuildProfileData()
        self:Print("Class: " .. data.className)
        self:Print("Color: #" .. data.color)
        self:Print("Role: " .. data.role)
        self:Print("Order: " .. (data.order ~= "" and data.order or "-"))
        self:Print("Source: " .. self:GetSourceLabel(data))
        self:Print("Realm-aware names: " .. (self:IsRealmAwareEnabled() and "On" or "Off"))
        self:Print("Version: " .. (self.version or "2.5.0"))
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
        ClassForgeDB.profile.className = self.defaults.profile.className
        ClassForgeDB.profile.color = self.defaults.profile.color
        ClassForgeDB.profile.role = self.defaults.profile.role
        ClassForgeDB.profile.order = self.defaults.profile.order
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
    local colorBox = createEditBox(overview, 220, 30, "Class color hex", 0, -62)
    local roleBox = createEditBox(overview, 220, 30, "Role (Heal/Tank/DPS)", 0, -124)
    local orderBox = createEditBox(overview, 220, 30, "Order", 0, -186)

    local preview = overview:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    preview:SetPoint("TOPLEFT", 280, -28)
    preview:SetWidth(260)
    preview:SetJustifyH("LEFT")

    local function updatePreview()
        local role = ClassForge:NormalizeRole(roleBox:GetText()) or ClassForge.defaults.profile.role
        local data = {
            className = ClassForge:Trim(classBox:GetText()) ~= "" and ClassForge:Trim(classBox:GetText()) or ClassForge.defaults.profile.className,
            color = ClassForge:SanitizeHex(colorBox:GetText()) or ClassForge.defaults.profile.color,
            role = role,
            order = ClassForge:Trim(orderBox:GetText()),
        }

        local orderText = data.order ~= "" and ("\nOrder: " .. data.order) or ""
        preview:SetText("Preview\n" .. ClassForge:GetColoredClassText(data) .. "\nRole: " .. data.role .. orderText)
    end

    local saveButton = CreateFrame("Button", nil, overview, "UIPanelButtonTemplate")
    saveButton:SetWidth(100)
    saveButton:SetHeight(24)
    saveButton:SetPoint("TOPLEFT", orderBox, "BOTTOMLEFT", 0, -16)
    saveButton:SetText("Save")
    saveButton:SetScript("OnClick", function()
        local className = ClassForge:Trim(classBox:GetText())
        local color = ClassForge:SanitizeHex(colorBox:GetText())
        local role = ClassForge:NormalizeRole(roleBox:GetText())

        ClassForgeDB.profile.className = className ~= "" and className or ClassForge.defaults.profile.className
        ClassForgeDB.profile.color = color or ClassForge.defaults.profile.color
        ClassForgeDB.profile.role = role or ClassForge.defaults.profile.role
        ClassForgeDB.profile.order = ClassForge:Trim(orderBox:GetText())

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
        classBox:SetText(ClassForge.defaults.profile.className)
        colorBox:SetText(ClassForge.defaults.profile.color)
        roleBox:SetText(ClassForge.defaults.profile.role)
        orderBox:SetText(ClassForge.defaults.profile.order)
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

    local panelVisibleToggle = CreateFrame("CheckButton", "ClassForgeOptionsPanelVisibleToggle", display, "UICheckButtonTemplate")
    panelVisibleToggle:SetPoint("TOPLEFT", realmToggle, "BOTTOMLEFT", 0, -10)
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

    local panelResetButton = CreateFrame("Button", nil, display, "UIPanelButtonTemplate")
    panelResetButton:SetWidth(140)
    panelResetButton:SetHeight(24)
    panelResetButton:SetPoint("TOPLEFT", panelLockToggle, "BOTTOMLEFT", 4, -14)
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

    local function updateKnownPlayersBrowser()
        local entries = {}
        local lines = { "Name | Class | Role | Source | Version | Updated" }

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
            lines[#lines + 1] = string.format(
                "%s | %s | %s | %s | %s | %s",
                data.name or "Unknown",
                data.className or "Unknown",
                data.role or "-",
                ClassForge:GetSourceLabel(data),
                (data.addonVersion and data.addonVersion ~= "") and data.addonVersion or "-",
                ClassForge:FormatUpdatedTime(data.updated)
            )
        end

        browserText:SetText(table.concat(lines, "\n"))
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
        statusText:SetText("Addon version: " .. (ClassForge.version or "2.5.0") .. "\nSync protocol: CF2\nUse /cf sync to refresh your record and query nearby players.")
        displayStatus:SetText("Minimap button: " .. (ClassForge:IsMinimapButtonHidden() and "Hidden" or "Shown")
            .. " |cff808080-|r Target profile: " .. (ClassForge:IsTargetProfileHidden() and "Hidden" or "Shown")
            .. " |cff808080-|r Locked: " .. (ClassForge:IsTargetProfileLocked() and "Yes" or "No")
            .. " |cff808080-|r Realm-aware names: " .. (ClassForge:IsRealmAwareEnabled() and "On" or "Off"))
    end

    panel:SetScript("OnShow", function()
        local profile = ClassForge:GetProfile()
        classBox:SetText(profile.className or ClassForge.defaults.profile.className)
        colorBox:SetText(profile.color or ClassForge.defaults.profile.color)
        roleBox:SetText(profile.role or ClassForge.defaults.profile.role)
        orderBox:SetText(profile.order or "")
        minimapToggle:SetChecked(not ClassForge:IsMinimapButtonHidden())
        chatToggle:SetChecked(ClassForge:IsChatDecorationEnabled())
        realmToggle:SetChecked(ClassForge:IsRealmAwareEnabled())
        panelVisibleToggle:SetChecked(not ClassForge:IsTargetProfileHidden())
        panelLockToggle:SetChecked(ClassForge:IsTargetProfileLocked())
        updatePreview()
        updateCacheDisplay()
        updateKnownPlayersBrowser()
        refreshStatusText()
        selectTab("overview")
    end)

    InterfaceOptions_AddCategory(panel)
    self.optionsPanel = panel
end
