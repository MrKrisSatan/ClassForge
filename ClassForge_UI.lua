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
        self:Print("/cf show")
        self:Print("/cf sync")
        self:Print("/cf showminimap")
        self:Print("/cf hideminimap")
        self:Print("/cf resetminimap")
        self:Print("/cf chattags on|off")
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
        self:Print("Colour set to #" .. color .. ".")
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
        self:Print("Colour: #" .. data.color)
        self:Print("Role: " .. data.role)
        self:Print("Order: " .. (data.order ~= "" and data.order or "-"))
        self:Print("Source: " .. self:GetSourceLabel(data))
        self:Print("Version: " .. (self.version or "1.0.0"))
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
    subtitle:SetText("Define a custom class identity and share it with other ClassForge users.")

    local classBox = createEditBox(panel, 220, 30, "Custom class name", 16, -60)
    local colorBox = createEditBox(panel, 220, 30, "Class colour hex", 16, -122)
    local roleBox = createEditBox(panel, 220, 30, "Role (Heal/Tank/DPS)", 16, -184)
    local orderBox = createEditBox(panel, 220, 30, "Order", 16, -246)

    local preview = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    preview:SetPoint("TOPLEFT", 280, -88)
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

    local saveButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    saveButton:SetWidth(100)
    saveButton:SetHeight(24)
    saveButton:SetPoint("TOPLEFT", orderBox, "BOTTOMLEFT", 0, -16)
    saveButton:SetText("Save")
    saveButton:SetScript("OnClick", function()
        local className = ClassForge:Trim(classBox:GetText())
        local color = ClassForge:SanitizeHex(colorBox:GetText())
        local role = ClassForge:NormalizeRole(roleBox:GetText())

        if className == "" then
            className = ClassForge.defaults.profile.className
        end
        if not color then
            color = ClassForge.defaults.profile.color
        end
        if not role then
            role = ClassForge.defaults.profile.role
        end

        ClassForgeDB.profile.className = className
        ClassForgeDB.profile.color = color
        ClassForgeDB.profile.role = role
        ClassForgeDB.profile.order = ClassForge:Trim(orderBox:GetText())

        ClassForge:RefreshPlayerCache()
        ClassForge:BroadcastStartup()
        ClassForge:RefreshAllDisplays()
        updatePreview()
        ClassForge:Print("Profile saved.")
    end)

    local syncButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    syncButton:SetWidth(100)
    syncButton:SetHeight(24)
    syncButton:SetPoint("LEFT", saveButton, "RIGHT", 8, 0)
    syncButton:SetText("Sync")
    syncButton:SetScript("OnClick", function()
        ClassForge:HandleSlash("sync")
    end)

    local resetButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
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

    local panelButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    panelButton:SetWidth(140)
    panelButton:SetHeight(24)
    panelButton:SetPoint("TOPLEFT", saveButton, "BOTTOMLEFT", 0, -10)
    panelButton:SetText("Reset Panel")
    panelButton:SetScript("OnClick", function()
        ClassForge:ResetTargetProfilePosition()
        ClassForge:Print("Target profile panel reset.")
    end)

    local panelHint = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    panelHint:SetPoint("LEFT", panelButton, "RIGHT", 10, 0)
    panelHint:SetText("Hold Shift and drag the target panel to move it.")

    local minimapToggle = CreateFrame("CheckButton", "ClassForgeOptionsMinimapToggle", panel, "UICheckButtonTemplate")
    minimapToggle:SetPoint("TOPLEFT", panelButton, "BOTTOMLEFT", 0, -14)
    _G[minimapToggle:GetName() .. "Text"]:SetText("Show minimap button")
    minimapToggle:SetScript("OnClick", function(selfButton)
        ClassForge:SetMinimapButtonHidden(not selfButton:GetChecked())
    end)

    local minimapResetButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    minimapResetButton:SetWidth(140)
    minimapResetButton:SetHeight(24)
    minimapResetButton:SetPoint("LEFT", minimapToggle, "RIGHT", 140, 0)
    minimapResetButton:SetText("Reset Minimap")
    minimapResetButton:SetScript("OnClick", function()
        ClassForge:ResetMinimapButtonPosition()
        minimapToggle:SetChecked(true)
        ClassForge:Print("Minimap button reset.")
    end)

    local chatToggle = CreateFrame("CheckButton", "ClassForgeOptionsChatToggle", panel, "UICheckButtonTemplate")
    chatToggle:SetPoint("TOPLEFT", minimapToggle, "BOTTOMLEFT", 0, -8)
    _G[chatToggle:GetName() .. "Text"]:SetText("Show custom class tags in party/guild/whisper chat")
    chatToggle:SetScript("OnClick", function(selfButton)
        ClassForge:SetChatDecorationEnabled(selfButton:GetChecked())
    end)

    local cacheTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    cacheTitle:SetPoint("TOPLEFT", chatToggle, "BOTTOMLEFT", 0, -22)
    cacheTitle:SetText("Cache")

    local cacheStatus = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    cacheStatus:SetPoint("TOPLEFT", cacheTitle, "BOTTOMLEFT", 0, -8)
    cacheStatus:SetWidth(340)
    cacheStatus:SetJustifyH("LEFT")

    local cacheList = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
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

        cacheStatus:SetText("Cached players: " .. ClassForge:GetCacheEntryCount())

        local limit = math.min(#entries, 8)
        for index = 1, limit do
            local data = entries[index]
            lines[#lines + 1] = string.format("%s - %s", data.name or "Unknown", ClassForge:FormatUpdatedTime(data.updated))
        end

        if #lines == 0 then
            cacheList:SetText("No cached players yet.")
        else
            cacheList:SetText("Recent entries:\n" .. table.concat(lines, "\n"))
        end
    end

    local browserTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    browserTitle:SetText("Known Players")

    local browserFrame = CreateFrame("ScrollFrame", "ClassForgeKnownPlayersScrollFrame", panel, "UIPanelScrollFrameTemplate")
    browserFrame:SetPoint("TOPLEFT", browserTitle, "BOTTOMLEFT", 0, -8)
    browserFrame:SetWidth(530)
    browserFrame:SetHeight(150)

    local browserContent = CreateFrame("Frame", nil, browserFrame)
    browserContent:SetWidth(510)
    browserContent:SetHeight(150)
    browserFrame:SetScrollChild(browserContent)

    local browserText = browserContent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    browserText:SetPoint("TOPLEFT", 0, 0)
    browserText:SetWidth(500)
    browserText:SetJustifyH("LEFT")
    browserText:SetJustifyV("TOP")

    local function updateKnownPlayersBrowser()
        local entries = {}
        local lines = {
            "Name | Class | Role | Source | Version | Updated",
        }

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
            browserContent:SetHeight(150)
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
        browserContent:SetHeight(math.max(150, browserText:GetStringHeight() + 10))
    end

    local clearStaleButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    clearStaleButton:SetWidth(100)
    clearStaleButton:SetHeight(24)
    clearStaleButton:SetPoint("TOPLEFT", cacheList, "BOTTOMLEFT", 0, -12)
    clearStaleButton:SetText("Clear Stale")
    clearStaleButton:SetScript("OnClick", function()
        local removed = ClassForge:ClearStaleCacheEntries(30 * 24 * 60 * 60)
        updateCacheDisplay()
        updateKnownPlayersBrowser()
        ClassForge:Print("Removed " .. removed .. " stale cache entr" .. (removed == 1 and "y." or "ies."))
    end)

    local clearAllButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    clearAllButton:SetWidth(100)
    clearAllButton:SetHeight(24)
    clearAllButton:SetPoint("LEFT", clearStaleButton, "RIGHT", 8, 0)
    clearAllButton:SetText("Clear All")
    clearAllButton:SetScript("OnClick", function()
        ClassForge:ClearCache(true)
        updateCacheDisplay()
        updateKnownPlayersBrowser()
        ClassForge:Print("Cache cleared.")
    end)

    browserTitle:SetPoint("TOPLEFT", clearStaleButton, "BOTTOMLEFT", 0, -22)

    panel:SetScript("OnShow", function()
        local profile = ClassForge:GetProfile()
        classBox:SetText(profile.className or ClassForge.defaults.profile.className)
        colorBox:SetText(profile.color or ClassForge.defaults.profile.color)
        roleBox:SetText(profile.role or ClassForge.defaults.profile.role)
        orderBox:SetText(profile.order or "")
        minimapToggle:SetChecked(not ClassForge:IsMinimapButtonHidden())
        chatToggle:SetChecked(ClassForge:IsChatDecorationEnabled())
        updatePreview()
        updateCacheDisplay()
        updateKnownPlayersBrowser()
    end)

    InterfaceOptions_AddCategory(panel)
    self.optionsPanel = panel
end
