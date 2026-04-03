function ClassForge:GetPlayerKey(name)
    return string.lower(name or "unknown")
end

function ClassForge:UnitFullName(unit)
    if not UnitExists(unit) then return nil end
    local name = UnitName(unit)
    return name
end

function ClassForge:HexToRGB(hex)
    if not hex then return 1, 1, 1 end
    hex = hex:gsub("#", "")
    if string.len(hex) == 8 then
        hex = string.sub(hex, 3)
    end

    local r = tonumber(string.sub(hex, 1, 2), 16) or 255
    local g = tonumber(string.sub(hex, 3, 4), 16) or 255
    local b = tonumber(string.sub(hex, 5, 6), 16) or 255

    return r / 255, g / 255, b / 255
end

function ClassForge:SanitizeHex(hex)
    if not hex then return nil end
    hex = hex:gsub("#", "")
    hex = string.upper(hex)

    if string.len(hex) == 6 and hex:match("^[0-9A-F]+$") then
        return "FF" .. hex
    elseif string.len(hex) == 8 and hex:match("^[0-9A-F]+$") then
        return hex
    end

    return nil
end

function ClassForge:Trim(str)
    if not str then return "" end
    return (str:gsub("^%s*(.-)%s*$", "%1"))
end

function ClassForge:GetMyData()
    return {
        className = ClassForgeDB.profile.className or "Hero",
        shortName = ClassForgeDB.profile.shortName or "HERO",
        color = ClassForgeDB.profile.color or "FFFFD100",
        role = ClassForgeDB.profile.role or "Wanderer",
        order = ClassForgeDB.profile.order or "Unaffiliated",
        updated = time(),
    }
end

function ClassForge:SetDataForName(name, data)
    if not name then return end
    local key = self:GetPlayerKey(name)
    ClassForgeCache[key] = {
        className = data.className or "Hero",
        shortName = data.shortName or "HERO",
        color = data.color or "FFFFD100",
        role = data.role or "Wanderer",
        order = data.order or "Unaffiliated",
        updated = data.updated or time(),
    }
end

function ClassForge:GetDataForName(name)
    if not name or not ClassForgeCache then return nil end

    -- Exact match
    if ClassForgeCache[name] then
        return ClassForgeCache[name]
    end

    -- Strip realm if present
    local shortName = name:gsub("%-.+$", "")
    if ClassForgeCache[shortName] then
        return ClassForgeCache[shortName]
    end

    -- Lowercase exact
    local lowerName = string.lower(name)
    for cachedName, data in pairs(ClassForgeCache) do
        if string.lower(cachedName) == lowerName then
            return data
        end
    end

    -- Lowercase stripped realm
    local lowerShort = string.lower(shortName)
    for cachedName, data in pairs(ClassForgeCache) do
        local cachedShort = cachedName:gsub("%-.+$", "")
        if string.lower(cachedShort) == lowerShort then
            return data
        end
    end

    return nil
end

function ClassForge:GetColoredClassText(data)
    if not data then return nil end
    local color = data.color or "FFFFFFFF"
    local className = data.className or "Hero"
    return string.format("|cff%s%s|r", string.sub(color, 3), className)
end

function ClassForge:GetColoredShortText(data)
    if not data then return nil end
    local color = data.color or "FFFFFFFF"
    local shortName = data.shortName or "HERO"
    return string.format("|cff%s[%s]|r", string.sub(color, 3), shortName)
end