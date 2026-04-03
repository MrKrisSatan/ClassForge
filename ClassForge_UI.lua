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
            self:Print("Usage: /cf setclass Spell Knight")
            return
        end
        ClassForgeDB.profile.className = rest
        self:Print("Class set to: " .. rest)
        self:BroadcastStartup()
        self:UpdateTargetClassTag()
        self:UpdateInspectProfile()
        self:UpdateCharacterFrameClass()
        return
    end

    if cmd == "setshort" then
        if rest == "" then
            self:Print("Usage: /cf setshort SK")
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
        self:Print("Colour updated to: #" .. color)
        self:BroadcastStartup()
        self:UpdateTargetClassTag()
        self:UpdateInspectProfile()
        self:UpdateCharacterFrameClass()
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
        self:UpdateCharacterFrameClass()
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
        self:UpdateCharacterFrameClass()
        return
    end

    if cmd == "show" then
        local data = self:GetMyData()
        self:Print("Class: " .. data.className)
        self:Print("Short: " .. data.shortName)
        self:Print("Colour: #" .. (data.color or "FFFFD100"))
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
            if name then self:BroadcastSelf("WHISPER", name) end
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
        ClassForgeDB.profile.color = "FF0000"   -- red example
        ClassForgeDB.profile.role = "Wanderer"
        ClassForgeDB.profile.order = "Unaffiliated"
        self:Print("Reset to defaults.")
        self:BroadcastStartup()
        self:UpdateTargetClassTag()
        self:UpdateInspectProfile()
        self:UpdateCharacterFrameClass()
        return
    end

    if cmd == "options" then
        InterfaceOptionsFrame_OpenToCategory("ClassForge")
        InterfaceOptionsFrame_OpenToCategory("ClassForge")
        return
    end

    if cmd == "debugguild" then self:DebugGuildFrames() return end
    if cmd == "debugwho" then self:DebugWhoFrames() return end
    if cmd == "debugtarget" then self:DebugTarget() return end
    if cmd == "debugcache" then self:DebugCache() return end

    self:Print("Unknown command. Type /cf help")
end

function ClassForge:CreateOptionsPanel()
    -- ... (your existing panel creation code stays exactly the same until the save button)

    local saveBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    saveBtn:SetSize(120, 30)
    saveBtn:SetPoint("TOPLEFT", preview, "BOTTOMLEFT", 0, -20)
    saveBtn:SetText("Save")
    saveBtn:SetScript("OnClick", function()
        ClassForgeDB.profile.className = ClassForge:Trim(classBox:GetText())
        if ClassForgeDB.profile.className == "" then ClassForgeDB.profile.className = "Hero" end

        ClassForgeDB.profile.shortName = ClassForge:Trim(shortBox:GetText())
        if ClassForgeDB.profile.shortName == "" then ClassForgeDB.profile.shortName = "HERO" end

        ClassForgeDB.profile.color = ClassForge:SanitizeHex(colorBox:GetText()) or "FF0000"

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
        ClassForge:UpdateCharacterFrameClass()
        UpdatePreview()
    end)

    InterfaceOptions_AddCategory(panel)
end

-- ==================== IMPROVED HELPER FUNCTIONS ====================

function ClassForge:Trim(str)
    if not str then return "" end
    return str:match("^%s*(.-)%s*$") or ""
end

function ClassForge:SanitizeHex(hex)
    if not hex then return "FF0000" end
    hex = hex:upper():gsub("#", ""):gsub("0X", "")
    if hex:match("^%x%x%x%x%x%x$") then
        return hex
    elseif hex:match("^%x%x%x$") then
        return hex:sub(1,1)..hex:sub(1,1)..hex:sub(2,2)..hex:sub(2,2)..hex:sub(3,3)..hex:sub(3,3)
    end
    return "FF0000"  -- fallback red
end

function ClassForge:GetMyData()
    local myName = UnitName("player")
    return self:GetDataForName(myName) or ClassForgeDB.profile
end

-- Fixed: Always returns clean |cAARRGGBB text (no extra FF)
function ClassForge:GetColoredClassText(data)
    if not data or not data.className then
        return "|cFFFFFFFFUnknown|r"
    end
    local hex = data.color or "FF0000"
    if #hex == 6 then
        hex = "FF" .. hex   -- ensure full 8-char code
    end
    return "|c" .. hex .. data.className .. "|r"
end

function ClassForge:GetColoredShortText(data)
    if not data or not data.shortName then
        return "|cFFAAAAAA[??]|r"
    end
    local hex = data.color or "FF0000"
    if #hex == 6 then hex = "FF" .. hex end
    return "|c" .. hex .. "[" .. data.shortName .. "]|r"
end