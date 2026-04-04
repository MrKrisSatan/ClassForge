function ClassForge:CopyDefaults(source, destination)
    if type(source) ~= "table" then
        return destination
    end

    if type(destination) ~= "table" then
        destination = {}
    end

    for key, value in pairs(source) do
        if type(value) == "table" then
            destination[key] = self:CopyDefaults(value, destination[key])
        elseif destination[key] == nil then
            destination[key] = value
        end
    end

    return destination
end

function ClassForge:Trim(value)
    if not value then
        return ""
    end

    return (tostring(value):gsub("^%s*(.-)%s*$", "%1"))
end

function ClassForge:NormalizePlayerName(name)
    name = self:Trim(name)
    if name == "" then
        return nil
    end

    name = name:gsub("%-.+$", "")
    if name == "" then
        return nil
    end

    return name:sub(1, 1):upper() .. name:sub(2):lower()
end

function ClassForge:GetPlayerKey(name)
    local normalized = self:NormalizePlayerName(name)
    if not normalized then
        return nil
    end

    return string.lower(normalized)
end

function ClassForge:SanitizeHex(hex)
    hex = self:Trim(hex):upper():gsub("#", ""):gsub("^0X", "")
    if hex == "" then
        return nil
    end

    if hex:match("^%x%x%x$") then
        return hex:sub(1, 1) .. hex:sub(1, 1) .. hex:sub(2, 2) .. hex:sub(2, 2) .. hex:sub(3, 3) .. hex:sub(3, 3)
    end

    if hex:match("^%x%x%x%x%x%x$") then
        return hex
    end

    if hex:match("^%x%x%x%x%x%x%x%x$") then
        return hex:sub(3)
    end

    return nil
end

function ClassForge:NormalizeRole(role)
    role = self:Trim(role)
    if role == "" then
        return nil
    end

    local lower = string.lower(role)
    if lower == "heal" or lower == "healer" then
        return "Heal"
    end
    if lower == "tank" then
        return "Tank"
    end
    if lower == "dps" or lower == "damage" then
        return "DPS"
    end

    return nil
end

function ClassForge:HexToRGB(hex)
    local clean = self:SanitizeHex(hex) or "FFFFFF"
    local r = tonumber(clean:sub(1, 2), 16) or 255
    local g = tonumber(clean:sub(3, 4), 16) or 255
    local b = tonumber(clean:sub(5, 6), 16) or 255

    return r / 255, g / 255, b / 255
end

function ClassForge:GetColoredClassText(data)
    if not data or not data.className then
        return "|cffffffffUnknown|r"
    end

    return string.format("|cff%s%s|r", self:SanitizeHex(data.color) or "FFFFFF", data.className)
end

function ClassForge:FormatUpdatedTime(timestamp)
    local numeric = tonumber(timestamp)
    if not numeric or numeric <= 0 then
        return "Unknown"
    end

    local diff = time() - numeric
    if diff <= 0 then
        return "Just now"
    end
    if diff < 60 then
        return diff .. "s ago"
    end
    if diff < 3600 then
        return math.floor(diff / 60) .. "m ago"
    end
    if diff < 86400 then
        return math.floor(diff / 3600) .. "h ago"
    end
    if diff < 604800 then
        return math.floor(diff / 86400) .. "d ago"
    end

    return date("%Y-%m-%d %H:%M", numeric)
end

function ClassForge:GetSourceLabel(data)
    local source = data and data.source or nil

    if source == "self" then
        return "You"
    end
    if source == "addon" then
        return "Addon"
    end
    if source == "who" then
        return "/who"
    end
    if source == "observed" then
        return "Observed"
    end

    return "Unknown"
end

function ClassForge:IsConfirmedAddonUser(data)
    return data and (data.source == "addon" or data.source == "self")
end

function ClassForge:GetCacheEntryCount()
    local total = 0

    if not ClassForgeCache then
        return total
    end

    for _ in pairs(ClassForgeCache) do
        total = total + 1
    end

    return total
end

function ClassForge:ClearCache(resetSelf)
    ClassForgeCache = {}

    if resetSelf then
        self:RefreshPlayerCache()
    end

    self:RefreshAllDisplays()
end

function ClassForge:ClearStaleCacheEntries(maxAgeSeconds)
    if not ClassForgeCache then
        return 0
    end

    local cutoff = time() - (tonumber(maxAgeSeconds) or 0)
    local removed = 0

    for key, data in pairs(ClassForgeCache) do
        local updated = tonumber(data and data.updated) or 0
        if updated > 0 and updated < cutoff then
            ClassForgeCache[key] = nil
            removed = removed + 1
        end
    end

    self:RefreshPlayerCache()
    self:RefreshAllDisplays()

    return removed
end

function ClassForge:GetDataForName(name)
    local key = self:GetPlayerKey(name)
    if not key or not ClassForgeCache then
        return nil
    end

    return ClassForgeCache[key]
end

function ClassForge:GetDataForUnit(unit)
    if not UnitExists(unit) or not UnitIsPlayer(unit) then
        return nil
    end

    if UnitIsUnit(unit, "player") then
        return self:BuildProfileData()
    end

    return self:GetDataForName(UnitName(unit))
end

function ClassForge:SetDataForName(name, data)
    local key = self:GetPlayerKey(name)
    local normalized = self:NormalizePlayerName(name)
    if not key or not normalized or not data then
        return nil
    end

    local existing = ClassForgeCache[key] or {}
    local incomingUpdated = tonumber(data.updated) or time()
    local existingUpdated = tonumber(existing.updated) or 0

    if existing.source == "addon" and data.source ~= "addon" and existingUpdated > incomingUpdated then
        return existing
    end

    ClassForgeCache[key] = {
        name = normalized,
        className = self:Trim(data.className) ~= "" and self:Trim(data.className) or existing.className or self.defaults.profile.className,
        color = self:SanitizeHex(data.color) or existing.color or self.defaults.profile.color,
        role = self:NormalizeRole(data.role) or existing.role or self.defaults.profile.role,
        order = self:Trim(data.order) ~= "" and self:Trim(data.order) or (data.source == "addon" and "" or existing.order or ""),
        addonVersion = self:Trim(data.addonVersion) ~= "" and self:Trim(data.addonVersion) or existing.addonVersion or "",
        updated = incomingUpdated,
        source = data.source or "observed",
    }

    return ClassForgeCache[key]
end

function ClassForge:GuessClassToken(className)
    local name = self:Trim(className)
    if name == "" then
        return nil
    end

    if RAID_CLASS_COLORS[name] then
        return name
    end

    local lowerName = string.lower(name)

    if LOCALIZED_CLASS_NAMES_MALE then
        for token, localized in pairs(LOCALIZED_CLASS_NAMES_MALE) do
            if string.lower(localized) == lowerName then
                return token
            end
        end
    end

    if LOCALIZED_CLASS_NAMES_FEMALE then
        for token, localized in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
            if string.lower(localized) == lowerName then
                return token
            end
        end
    end

    return nil
end

function ClassForge:GuessRoleFromClass(className)
    local token = self:GuessClassToken(className)

    local fallbackByToken = {
        DEATHKNIGHT = "Tank",
        DRUID = "Tank",
        HUNTER = "DPS",
        MAGE = "DPS",
        PALADIN = "Tank",
        PRIEST = "Heal",
        ROGUE = "DPS",
        SHAMAN = "Heal",
        WARLOCK = "DPS",
        WARRIOR = "Tank",
    }

    return fallbackByToken[token] or "DPS"
end

function ClassForge:GuessColorFromClass(className)
    local token = self:GuessClassToken(className)
    local color = token and RAID_CLASS_COLORS[token] or nil

    if color then
        return string.format("%02X%02X%02X", color.r * 255, color.g * 255, color.b * 255)
    end

    return self.defaults.profile.color
end
