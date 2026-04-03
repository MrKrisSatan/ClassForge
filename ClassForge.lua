ClassForge = {}
ClassForge.prefix = "CLASSFORGE2"
ClassForge.version = "0.2.1"  -- bumped version slightly

local addon = CreateFrame("Frame")
ClassForge.frame = addon

addon:RegisterEvent("ADDON_LOADED")
addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:RegisterEvent("CHAT_MSG_ADDON")
addon:RegisterEvent("GROUP_ROSTER_UPDATE")
addon:RegisterEvent("GUILD_ROSTER_UPDATE")
addon:RegisterEvent("PLAYER_TARGET_CHANGED")
addon:RegisterEvent("WHO_LIST_UPDATE")
addon:RegisterEvent("FRIENDLIST_UPDATE")
addon:RegisterEvent("PLAYER_GUILD_UPDATE")
addon:RegisterEvent("PLAYER_REGEN_ENABLED")

-- Hook for Character Frame
hooksecurefunc("CharacterFrame_ShowSubFrame", function()
    ClassForge:UpdateCharacterFrameClass()
end)

function ClassForge:NormalizePlayerName(name)
    if not name or name == "" then return nil end
    name = string.gsub(name, "%-.+$", "")
    name = string.gsub(name, "^%s+", "")
    name = string.gsub(name, "%s+$", "")
    return name
end

function ClassForge:GetDataForName(name)
    if not name or not ClassForgeCache then return nil end
    local cleanName = self:NormalizePlayerName(name)
    if not cleanName then return nil end

    if ClassForgeCache[cleanName] then
        return ClassForgeCache[cleanName]
    end

    local lowerClean = string.lower(cleanName)
    for cachedName, data in pairs(ClassForgeCache) do
        local cachedClean = self:NormalizePlayerName(cachedName)
        if cachedClean and string.lower(cachedClean) == lowerClean then
            return data
        end
    end
    return nil
end

-- Helper: Get your own data
function ClassForge:GetMyData()
    local myName = UnitName("player")
    return self:GetDataForName(myName) or ClassForgeDB.profile
end

-- Helper: Get colored class text (reused from your Display file if possible)
function ClassForge:GetColoredClassText(data)
    if not data or not data.className then
        return "|cFFFFFFFFUnknown|r"
    end
    local color = data.color or "FFFFD100"
    return "|cFF" .. color .. data.className .. "|r"
end

local defaults = {
    profile = {
        enabled = true,
        className = "Hero",
        shortName = "HERO",
        color = "FFFFD100",
        role = "Wanderer",
        order = "Unaffiliated",
    }
}

local function CopyDefaults(src, dst)
    if type(src) ~= "table" then return {} end
    if type(dst) ~= "table" then dst = {} end
    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = CopyDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
    return dst
end

addon:SetScript("OnEvent", function(self, event, ...)
    if ClassForge[event] then
        ClassForge[event](ClassForge, ...)
    end
end)

function ClassForge:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffClassForge|r: " .. tostring(msg))
end

function ClassForge:ADDON_LOADED(name)
    if name ~= "ClassForge" then return end
    ClassForgeDB = CopyDefaults(defaults, ClassForgeDB or {})
    ClassForgeCache = ClassForgeCache or {}
end

function ClassForge:PLAYER_LOGIN()
    if RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix(self.prefix)
    end
    self:SetupSlashCommands()
    self:CreateOptionsPanel()
    self:InitDisplay()
    self:BroadcastStartup()
    self:UpdateCharacterFrameClass()   -- Initial update
    self:Print("Hero Server Edition loaded. Type |cffffff00/cf|r for commands.")
end

function ClassForge:PLAYER_ENTERING_WORLD()
    self:RequestSyncFromVisibleSources()
end

function ClassForge:GROUP_ROSTER_UPDATE()
    self:BroadcastSelf("PARTY")
    self:BroadcastSelf("RAID")
end

function ClassForge:GUILD_ROSTER_UPDATE()
    self:BroadcastSelf("GUILD")
    self:UpdateGuildRoster()
end

function ClassForge:PLAYER_GUILD_UPDATE()
    self:BroadcastSelf("GUILD")
    self:UpdateGuildRoster()
end

function ClassForge:PLAYER_TARGET_CHANGED()
    if UnitExists("target") and UnitIsPlayer("target") then
        local name = UnitName("target")
        if name then
            self:BroadcastSelf("WHISPER", name)
            self:UpdateTargetClassTag()
            self:UpdateInspectProfile()
        end
    else
        self:UpdateTargetClassTag()
        self:UpdateInspectProfile()
    end
end

function ClassForge:WHO_LIST_UPDATE()
    self:UpdateWhoList()
end

function ClassForge:FRIENDLIST_UPDATE()
    self:RequestSyncFromFriends()
end

function ClassForge:BroadcastStartup()
    self:BroadcastSelf("GUILD")
    self:BroadcastSelf("PARTY")
    self:BroadcastSelf("RAID")
end

function ClassForge:RequestSyncFromVisibleSources()
    self:RequestSyncFromFriends()
    self:RequestSyncFromWho()
    self:BroadcastStartup()
end

-- ==================== Character Frame Custom Class Display (Fixed Color + Layout) ====================
function ClassForge:UpdateCharacterFrameClass()
    if not PaperDollFrame or not PaperDollFrame:IsShown() then
        return
    end

    local myData = self:GetMyData()
    if not myData or not myData.className then
        return
    end

    -- Hide default Blizzard level/race/class line
    if CharacterLevelText then
        CharacterLevelText:Hide()
    end

    -- Create / update the fontstring
    if not PaperDollFrame.ClassForgeClassText then
        local f = PaperDollFrame:CreateFontString(nil, "DIALOG", "GameFontNormal")
        f:SetPoint("TOP", PaperDollFrame, "TOP", 0, -32)
        f:SetJustifyH("CENTER")
        f:SetSpacing(6)
        f:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
        f:SetShadowOffset(1, -1)
        PaperDollFrame.ClassForgeClassText = f
    end

    local level = UnitLevel("player") or 1
    local race  = UnitRace("player") or ""
    local className = myData.className or "Hero"

    -- Build clean colored class (no extra "FF" prefix)
    local hexColor = myData.color or "FFFFD100"
    if string.len(hexColor) == 6 then
        hexColor = "FF" .. hexColor   -- ensure full |cAARRGGBB format
    end
    local coloredClass = "|c" .. hexColor .. className .. "|r"

    local extra = ""
    if myData.role and myData.role ~= "Wanderer" then
        extra = extra .. myData.role
    end
    if myData.order and myData.order ~= "Unaffiliated" then
        if extra ~= "" then extra = extra .. " - " end
        extra = extra .. myData.order
    end

    -- Layout:
    -- Line 1: Level XX Race
    -- Line 2: Spell Knight (in your chosen color)
    -- Line 3: Role - Order (white)
    local displayText = string.format("Level %d %s\n%s\n%s",
        level,
        race,
        coloredClass,
        extra ~= "" and extra or ""
    )

    local fs = PaperDollFrame.ClassForgeClassText
    fs:SetText(displayText)

    -- Force the class line to use your chosen color (this fixes white color issue)
    -- We apply a default white first, then override with your color for the class part
    fs:SetTextColor(1, 1, 1)   -- default for whole text
end