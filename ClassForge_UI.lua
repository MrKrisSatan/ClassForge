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
        return
    end

    if command == "sync" then
        self:RefreshPlayerCache()
        self:BroadcastStartup()
        self:RequestSyncFromFriends()
        self:PerformWhoSync()
        self:Print("Sync started.")
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

    panel:SetScript("OnShow", function()
        local profile = ClassForge:GetProfile()
        classBox:SetText(profile.className or ClassForge.defaults.profile.className)
        colorBox:SetText(profile.color or ClassForge.defaults.profile.color)
        roleBox:SetText(profile.role or ClassForge.defaults.profile.role)
        orderBox:SetText(profile.order or "")
        updatePreview()
    end)

    InterfaceOptions_AddCategory(panel)
    self.optionsPanel = panel
end
