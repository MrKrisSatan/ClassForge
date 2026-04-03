function ClassForge:SetupSlashCommands()
    SLASH_CLASSFORGE1 = "/classforge"
    SLASH_CLASSFORGE2 = "/cf"

    SlashCmdList["CLASSFORGE"] = function(msg)
        ClassForge:HandleSlash(msg)
    end
end

function ClassForge:HandleSlash(msg)
    msg = self:Trim(msg or "")
    local cmd, rest = msg:match("^(%S*)%s*(.-)$")
    cmd = string.lower(cmd or "")

    if cmd == "" or cmd == "help" then
        self:Print("/cf setclass <name>")
        self:Print("/cf setshort <tag>")
        self:Print("/cf setcolor <RRGGBB>")
        self:Print("/cf setrole <role>")
        self:Print("/cf setorder <order>")
        self:Print("/cf show")
        self:Print("/cf sync")
        self:Print("/cf who")
        self:Print("/cf reset")
        self:Print("/cf options")
	self:Print("/cf debugguild")
	self:Print("/cf debugwho")
	self:Print("/cf debugtarget")
	self:Print("/cf debugcache")
        return
    end

    if cmd == "setclass" then
        if rest == "" then
            self:Print("Usage: /cf setclass Blood Knight")
            return
        end
        ClassForgeDB.profile.className = rest
        self:Print("Class set to: " .. rest)
        self:BroadcastStartup()
        self:UpdateTargetClassTag()
        self:UpdateInspectProfile()
        return
    end

    if cmd == "setshort" then
        if rest == "" then
            self:Print("Usage: /cf setshort BK")
            return
        end
        ClassForgeDB.profile.shortName = rest
        self:Print("Short tag set to: " .. rest)
        self:BroadcastStartup()
        return
    end

    if cmd == "setcolor" then
        local color = self:SanitizeHex(rest)
        if not color then
            self:Print("Usage: /cf setcolor FF0033")
            return
        end
        ClassForgeDB.profile.color = color
        self:Print("Colour updated to: #" .. string.sub(color, 3))
        self:BroadcastStartup()
        self:UpdateTargetClassTag()
        self:UpdateInspectProfile()
        return
    end

    if cmd == "setrole" then
        if rest == "" then
            self:Print("Usage: /cf setrole Frontline Juggernaut")
            return
        end
        ClassForgeDB.profile.role = rest
        self:Print("Role set to: " .. rest)
        self:BroadcastStartup()
        self:UpdateInspectProfile()
        return
    end

    if cmd == "setorder" then
        if rest == "" then
            self:Print("Usage: /cf setorder Crimson Oath")
            return
        end
        ClassForgeDB.profile.order = rest
        self:Print("Order set to: " .. rest)
        self:BroadcastStartup()
        self:UpdateInspectProfile()
        return
    end

    if cmd == "show" then
        local data = self:GetMyData()
        self:Print("Class: " .. data.className)
        self:Print("Short: " .. data.shortName)
        self:Print("Colour: #" .. string.sub(data.color, 3))
        self:Print("Role: " .. data.role)
        self:Print("Order: " .. data.order)
        return
    end

    if cmd == "sync" then
        self:BroadcastStartup()
        self:RequestSyncFromFriends()
        self:RequestSyncFromWho()

        if UnitExists("target") and UnitIsPlayer("target") then
            local name = UnitName("target")
            if name then
                self:BroadcastSelf("WHISPER", name)
            end
        end

        self:Print("Sync broadcast sent.")
        return
    end

    if cmd == "who" then
        self:RequestSyncFromWho()
        self:UpdateWhoList()
        self:Print("Requested sync from /who players.")
        return
    end

    if cmd == "reset" then
        ClassForgeDB.profile.className = "Hero"
        ClassForgeDB.profile.shortName = "HERO"
        ClassForgeDB.profile.color = "FFFFD100"
        ClassForgeDB.profile.role = "Wanderer"
        ClassForgeDB.profile.order = "Unaffiliated"

        self:Print("Reset to defaults.")
        self:BroadcastStartup()
        self:UpdateTargetClassTag()
        self:UpdateInspectProfile()
        return
    end

    if cmd == "options" then
        InterfaceOptionsFrame_OpenToCategory("ClassForge")
        InterfaceOptionsFrame_OpenToCategory("ClassForge")
        return
    end
if cmd == "debugguild" then
    self:DebugGuildFrames()
    return
end

if cmd == "debugwho" then
    self:DebugWhoFrames()
    return
end

if cmd == "debugtarget" then
    self:DebugTarget()
    return
end

if cmd == "debugcache" then
    self:DebugCache()
    return
end
    self:Print("Unknown command. Type /cf help")
end

function ClassForge:CreateOptionsPanel()
    local panel = CreateFrame("Frame", "ClassForgeOptionsPanel", InterfaceOptionsFramePanelContainer)
    panel.name = "ClassForge"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("ClassForge - Hero Server Edition")

    local desc = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    desc:SetText("Create and share your custom Hero archetype.")

    local function CreateLabel(text, anchor, y)
        local l = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        l:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, y)
        l:SetText(text)
        return l
    end

    local function CreateBox(name, width, anchor, y, value)
        local box = CreateFrame("EditBox", name, panel, "InputBoxTemplate")
        box:SetSize(width, 30)
        box:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, y)
        box:SetAutoFocus(false)
        box:SetText(value or "")
        return box
    end

    local classLabel = CreateLabel("Class Name", desc, -25)
    local classBox = CreateBox("ClassForgeClassNameBox", 220, classLabel, -8, ClassForgeDB.profile.className)

    local shortLabel = CreateLabel("Short Tag", classBox, -20)
    local shortBox = CreateBox("ClassForgeShortNameBox", 100, shortLabel, -8, ClassForgeDB.profile.shortName)

    local colorLabel = CreateLabel("Colour (Hex)", shortBox, -20)
    local colorBox = CreateBox("ClassForgeColorBox", 100, colorLabel, -8, string.sub(ClassForgeDB.profile.color or "FFFFFFFF", 3))

    local roleLabel = CreateLabel("Role", colorBox, -20)
    local roleBox = CreateBox("ClassForgeRoleBox", 220, roleLabel, -8, ClassForgeDB.profile.role)

    local orderLabel = CreateLabel("Order / Faction", roleBox, -20)
    local orderBox = CreateBox("ClassForgeOrderBox", 220, orderLabel, -8, ClassForgeDB.profile.order)

    local preview = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    preview:SetPoint("TOPLEFT", orderBox, "BOTTOMLEFT", 0, -18)
    preview:SetText("")

    local function UpdatePreview()
        local data = {
            className = classBox:GetText() ~= "" and classBox:GetText() or "Hero",
            shortName = shortBox:GetText() ~= "" and shortBox:GetText() or "HERO",
            color = ClassForge:SanitizeHex(colorBox:GetText()) or "FFFFFFFF",
            role = roleBox:GetText() ~= "" and roleBox:GetText() or "Wanderer",
            order = orderBox:GetText() ~= "" and orderBox:GetText() or "Unaffiliated",
        }

        preview:SetText(
            "Preview: " ..
            ClassForge:GetColoredClassText(data) .. " " ..
            ClassForge:GetColoredShortText(data) ..
            "\nRole: " .. data.role ..
            "\nOrder: " .. data.order
        )
    end

    classBox:SetScript("OnTextChanged", UpdatePreview)
    shortBox:SetScript("OnTextChanged", UpdatePreview)
    colorBox:SetScript("OnTextChanged", UpdatePreview)
    roleBox:SetScript("OnTextChanged", UpdatePreview)
    orderBox:SetScript("OnTextChanged", UpdatePreview)
    UpdatePreview()

    local saveBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    saveBtn:SetSize(120, 30)
    saveBtn:SetPoint("TOPLEFT", preview, "BOTTOMLEFT", 0, -20)
    saveBtn:SetText("Save")

    saveBtn:SetScript("OnClick", function()
        ClassForgeDB.profile.className = ClassForge:Trim(classBox:GetText())
        if ClassForgeDB.profile.className == "" then ClassForgeDB.profile.className = "Hero" end

        ClassForgeDB.profile.shortName = ClassForge:Trim(shortBox:GetText())
        if ClassForgeDB.profile.shortName == "" then ClassForgeDB.profile.shortName = "HERO" end

        ClassForgeDB.profile.color = ClassForge:SanitizeHex(colorBox:GetText()) or "FFFFFFFF"

        ClassForgeDB.profile.role = ClassForge:Trim(roleBox:GetText())
        if ClassForgeDB.profile.role == "" then ClassForgeDB.profile.role = "Wanderer" end

        ClassForgeDB.profile.order = ClassForge:Trim(orderBox:GetText())
        if ClassForgeDB.profile.order == "" then ClassForgeDB.profile.order = "Unaffiliated" end

        ClassForge:Print("Saved Hero profile.")
        ClassForge:BroadcastStartup()
        ClassForge:UpdateTargetClassTag()
        ClassForge:UpdateInspectProfile()
        ClassForge:UpdateWhoList()
        ClassForge:UpdateGuildRoster()
        UpdatePreview()
    end)

    InterfaceOptions_AddCategory(panel)
end