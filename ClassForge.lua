ClassForge = ClassForge or {}

ClassForge.name = "ClassForge"
ClassForge.prefix = "CLASSFORGE"
ClassForge.version = "3.1.0"
ClassForge.dbVersion = 5
ClassForge.homepage = "https://github.com/MrKrisSatan/ClassForge"
ClassForge.releasesPage = "https://github.com/MrKrisSatan/ClassForge/releases"

local addon = CreateFrame("Frame")
ClassForge.frame = addon

ClassForge.defaults = {
    character = {
        className = "Hero",
        color = "FFD100",
        role = "DPS",
    },
    profile = {
        enabled = true,
        locale = "en",
        targetProfilePosition = {
            point = "TOP",
            relativePoint = "BOTTOM",
            x = 0,
            y = -20,
        },
        targetProfile = {
            hidden = false,
            locked = false,
            compact = false,
        },
        minimapButton = {
            angle = 225,
            hidden = false,
        },
        chat = {
            enabled = false,
        },
        names = {
            realmAware = false,
        },
        syncThrottle = {
            broadcast = 10,
            whisper = 20,
            who = 30,
        },
        sync = {
            autoWhoOnLogin = true,
            autoWhoOnGroup = true,
        },
        colors = {
            groupFrames = true,
        },
    },
}

local registeredEvents = {
    "ADDON_LOADED",
    "PLAYER_LOGIN",
    "PLAYER_ENTERING_WORLD",
    "PLAYER_TALENT_UPDATE",
    "PLAYER_ROLES_ASSIGNED",
    "ACTIVE_TALENT_GROUP_CHANGED",
    "CHAT_MSG_ADDON",
    "GROUP_ROSTER_UPDATE",
    "GUILD_ROSTER_UPDATE",
    "PLAYER_GUILD_UPDATE",
    "PLAYER_TARGET_CHANGED",
    "WHO_LIST_UPDATE",
    "FRIENDLIST_UPDATE",
    "INSPECT_READY",
}

for _, eventName in ipairs(registeredEvents) do
    addon:RegisterEvent(eventName)
end

addon:SetScript("OnEvent", function(_, event, ...)
    local handler = ClassForge[event]
    if handler then
        handler(ClassForge, ...)
    end
end)

ClassForge.translations = {
    en = {
        loaded = "Loaded. Type |cffffff00/cf help|r for commands.",
        class_label = "Class",
        role_label = "Role",
        role_auto_hint = "Uses your Blizzard-selected group role when available.",
        faction_label = "Faction",
        source_label = "Source",
        updated_label = "Updated",
        version_label = "Version",
        color_label = "Color",
        downloads_label = "Downloads",
        preview_label = "Preview",
        profile_tab = "Profile",
        display_tab = "Display",
        cache_tab = "Cache",
        options_subtitle = "Custom class identities for Wrath 3.3.5a with sync, cache, and map support.",
        language = "Language",
        english = "English",
        spanish = "Spanish",
        russian = "Russian",
        custom_class_name = "Custom class name",
        class_color_hex = "Class color hex",
        presets = "Presets",
        pick = "Pick",
        save = "Save",
        sync = "Sync",
        reset = "Reset",
        refresh = "Refresh",
        tank = "Tank",
        healer = "Healer",
        damage = "Damage",
        alliance = "Alliance",
        horde = "Horde",
        you = "You",
        addon = "Addon",
        observed = "Observed",
        unknown = "Unknown",
        yes = "Yes",
        no = "No",
        on = "On",
        off = "Off",
        shown = "Shown",
        hidden = "Hidden",
        locked = "Locked",
        shift_drag = "Shift-drag",
        left_click_open = "Left-click: Open options",
        drag_move_button = "Drag: Move button",
        show_minimap_button = "Show minimap button",
        reset_minimap = "Reset Minimap",
        show_chat_tags = "Show custom class tags in party, raid, guild, and whisper chat",
        use_realm_aware = "Use realm-aware names when a realm suffix is present",
        auto_who_login = "Run background /who sync on login",
        auto_who_group = "Run background /who sync on group changes",
        show_target_panel = "Show target profile panel",
        lock_target_panel = "Lock target profile panel position",
        compact_target_panel = "Use compact target profile panel",
        color_group_frames = "Color party and raid frame names with custom class color",
        reset_panel = "Reset Panel",
        panel_hint = "Hold Shift and drag the target profile when it is unlocked.",
        cached_players = "Cached players",
        database_schema = "Database schema",
        no_cached_players = "No cached players yet.",
        recent_entries = "Recent entries",
        clear_stale = "Clear Stale",
        clear_all = "Clear All",
        known_players = "Known Players",
        no_known_players = "No known players yet.",
        no_matching_players = "No matching players found.",
        addon_version = "Addon version",
        sync_protocol = "Sync protocol",
        last_sync = "Last sync",
        last_who = "Last /who",
        addon_users = "Addon users",
        use_sync_hint = "Use /cf sync to refresh your record and query nearby players.",
        minimap_button = "Minimap button",
        target_profile = "Target profile",
        compact = "Compact",
        group_colors = "Group colors",
        realm_aware_names = "Realm-aware names",
        profile_saved = "Profile saved.",
        language_updated = "Language updated.",
        out_of_date = "Your ClassForge version is out of date. Latest seen: %s. You are on %s.",
        newer_user = "%s is using ClassForge %s. Your version is %s.",
    },
    es = {
        loaded = "Cargado. Escribe |cffffff00/cf help|r para ver los comandos.",
        class_label = "Clase",
        role_label = "Rol",
        role_auto_hint = "Usa tu rol de grupo seleccionado en Blizzard cuando exista.",
        faction_label = "Facción",
        source_label = "Fuente",
        updated_label = "Actualizado",
        version_label = "Versión",
        color_label = "Color",
        downloads_label = "Descargas",
        preview_label = "Vista previa",
        profile_tab = "Perfil",
        display_tab = "Pantalla",
        cache_tab = "Caché",
        options_subtitle = "Identidades de clase personalizadas para Wrath 3.3.5a con sincronización, caché y soporte de mapa.",
        language = "Idioma",
        english = "Inglés",
        spanish = "Español",
        russian = "Ruso",
        custom_class_name = "Nombre de clase personalizado",
        class_color_hex = "Hex de color de clase",
        presets = "Predefinidos",
        pick = "Elegir",
        save = "Guardar",
        sync = "Sincronizar",
        reset = "Restablecer",
        refresh = "Actualizar",
        tank = "Tanque",
        healer = "Sanador",
        damage = "Daño",
        alliance = "Alianza",
        horde = "Horda",
        you = "Tú",
        addon = "Addon",
        observed = "Observado",
        unknown = "Desconocido",
        yes = "Sí",
        no = "No",
        on = "Activado",
        off = "Desactivado",
        shown = "Mostrado",
        hidden = "Oculto",
        locked = "Bloqueado",
        shift_drag = "Mayús-arrastrar",
        left_click_open = "Clic izquierdo: Abrir opciones",
        drag_move_button = "Arrastrar: Mover botón",
        show_minimap_button = "Mostrar botón del minimapa",
        reset_minimap = "Restablecer minimapa",
        show_chat_tags = "Mostrar etiquetas de clase personalizada en chat de grupo, banda, hermandad y susurros",
        use_realm_aware = "Usar nombres con reino cuando haya un sufijo de reino",
        auto_who_login = "Ejecutar sincronización /who en segundo plano al entrar",
        auto_who_group = "Ejecutar sincronización /who en segundo plano al cambiar de grupo",
        show_target_panel = "Mostrar panel del objetivo",
        lock_target_panel = "Bloquear posición del panel del objetivo",
        compact_target_panel = "Usar panel de objetivo compacto",
        color_group_frames = "Colorear nombres de grupo y banda con el color de clase personalizado",
        reset_panel = "Restablecer panel",
        panel_hint = "Mantén Mayús y arrastra el perfil del objetivo cuando esté desbloqueado.",
        cached_players = "Jugadores en caché",
        database_schema = "Esquema de base de datos",
        no_cached_players = "Todavía no hay jugadores en caché.",
        recent_entries = "Entradas recientes",
        clear_stale = "Limpiar antiguas",
        clear_all = "Limpiar todo",
        known_players = "Jugadores conocidos",
        no_known_players = "Todavía no hay jugadores conocidos.",
        no_matching_players = "No se encontraron jugadores coincidentes.",
        addon_version = "Versión del addon",
        sync_protocol = "Protocolo de sincronización",
        last_sync = "Última sincronización",
        last_who = "Último /who",
        addon_users = "Usuarios del addon",
        use_sync_hint = "Usa /cf sync para actualizar tu registro y consultar jugadores cercanos.",
        minimap_button = "Botón del minimapa",
        target_profile = "Perfil del objetivo",
        compact = "Compacto",
        group_colors = "Colores de grupo",
        realm_aware_names = "Nombres con reino",
        profile_saved = "Perfil guardado.",
        language_updated = "Idioma actualizado.",
        out_of_date = "Tu versión de ClassForge está desactualizada. La más nueva detectada es %s. Tú tienes %s.",
        newer_user = "%s está usando ClassForge %s. Tu versión es %s.",
    },
    ru = {
        loaded = "Аддон загружен. Введите |cffffff00/cf help|r для списка команд.",
        class_label = "Класс",
        role_label = "Роль",
        role_auto_hint = "Использует выбранную в Blizzard роль группы, если она задана.",
        faction_label = "Фракция",
        source_label = "Источник",
        updated_label = "Обновлено",
        version_label = "Версия",
        color_label = "Цвет",
        downloads_label = "Загрузка",
        preview_label = "Предпросмотр",
        profile_tab = "Профиль",
        display_tab = "Отображение",
        cache_tab = "Кэш",
        options_subtitle = "Пользовательские классы для Wrath 3.3.5a с синхронизацией, кэшем и поддержкой карты.",
        language = "Язык",
        english = "Английский",
        spanish = "Испанский",
        russian = "Русский",
        custom_class_name = "Пользовательское имя класса",
        class_color_hex = "Hex цвета класса",
        presets = "Пресеты",
        pick = "Выбрать",
        save = "Сохранить",
        sync = "Синхронизация",
        reset = "Сброс",
        refresh = "Обновить",
        tank = "Танк",
        healer = "Лекарь",
        damage = "Урон",
        alliance = "Альянс",
        horde = "Орда",
        you = "Вы",
        addon = "Addon",
        observed = "Наблюдение",
        unknown = "Неизвестно",
        yes = "Да",
        no = "Нет",
        on = "Включено",
        off = "Выключено",
        shown = "Показано",
        hidden = "Скрыто",
        locked = "Закреплено",
        shift_drag = "Shift-перетащить",
        left_click_open = "Левый клик: открыть настройки",
        drag_move_button = "Перетаскивание: двигать кнопку",
        show_minimap_button = "Показывать кнопку у миникарты",
        reset_minimap = "Сброс миникарты",
        show_chat_tags = "Показывать метки пользовательского класса в группе, рейде, гильдии и шепоте",
        use_realm_aware = "Использовать имена с миром при наличии суффикса мира",
        auto_who_login = "Запуск фонового /who при входе",
        auto_who_group = "Запуск фонового /who при изменении группы",
        show_target_panel = "Показывать панель цели",
        lock_target_panel = "Закрепить панель цели",
        compact_target_panel = "Использовать компактную панель цели",
        color_group_frames = "Красить имена группы и рейда цветом пользовательского класса",
        reset_panel = "Сброс панели",
        panel_hint = "Удерживайте Shift и перетаскивайте профиль цели, когда он не закреплен.",
        cached_players = "Игроки в кэше",
        database_schema = "Схема базы данных",
        no_cached_players = "Пока нет игроков в кэше.",
        recent_entries = "Последние записи",
        clear_stale = "Очистить старое",
        clear_all = "Очистить все",
        known_players = "Известные игроки",
        no_known_players = "Пока нет известных игроков.",
        no_matching_players = "Совпадений не найдено.",
        addon_version = "Версия аддона",
        sync_protocol = "Протокол синхронизации",
        last_sync = "Последняя синхронизация",
        last_who = "Последний /who",
        addon_users = "Пользователи аддона",
        use_sync_hint = "Используйте /cf sync для обновления своей записи и поиска ближайших игроков.",
        minimap_button = "Кнопка миникарты",
        target_profile = "Профиль цели",
        compact = "Компактно",
        group_colors = "Цвета группы",
        realm_aware_names = "Имена с миром",
        profile_saved = "Профиль сохранен.",
        language_updated = "Язык обновлен.",
        out_of_date = "Ваша версия ClassForge устарела. Самая новая замеченная: %s. У вас %s.",
        newer_user = "%s использует ClassForge %s. Ваша версия %s.",
    },
}

function ClassForge:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffClassForge|r: " .. tostring(message))
end

function ClassForge:GetLanguage()
    local profile = self:GetProfile()
    local locale = profile and profile.locale or nil
    if self.translations[locale] then
        return locale
    end
    return "en"
end

function ClassForge:SetLanguage(locale)
    if not self.translations[locale] then
        locale = "en"
    end
    ClassForgeDB.profile.locale = locale
end

function ClassForge:L(key)
    local locale = self:GetLanguage()
    local tableForLocale = self.translations[locale] or self.translations.en
    return (tableForLocale and tableForLocale[key]) or (self.translations.en and self.translations.en[key]) or key
end

function ClassForge:GetRoleDisplayText(role)
    local normalized = self:NormalizeRole(role) or self.defaults.character.role
    if normalized == "Tank" then
        return self:L("tank")
    end
    if normalized == "Heal" then
        return self:L("healer")
    end

    return self:L("damage")
end

function ClassForge:GetProfile()
    return ClassForgeDB and ClassForgeDB.profile or self.defaults.profile
end

function ClassForge:GetCurrentCharacterKey()
    local playerName = UnitName("player")
    local realmName = GetRealmName and GetRealmName() or nil

    playerName = self:Trim(playerName)
    realmName = self:GetNormalizedRealmName(realmName)

    if playerName == "" then
        return nil
    end

    if realmName and realmName ~= "" then
        return playerName .. "-" .. realmName
    end

    return playerName
end

function ClassForge:GetCharacterProfile()
    if not ClassForgeDB then
        return self.defaults.character
    end

    ClassForgeDB.characters = ClassForgeDB.characters or {}

    local characterKey = self:GetCurrentCharacterKey()
    if not characterKey then
        return self.defaults.character
    end

    ClassForgeDB.characters[characterKey] = self:CopyDefaults(self.defaults.character, ClassForgeDB.characters[characterKey] or {})
    return ClassForgeDB.characters[characterKey]
end

function ClassForge:EnsureCurrentCharacterProfile()
    local characterProfile = self:GetCharacterProfile()
    local globalProfile = self:GetProfile()

    if not characterProfile._migratedFromLegacy then
        local hasLegacyIdentity = globalProfile and (
            self:Trim(globalProfile.className) ~= ""
            or self:SanitizeHex(globalProfile.color)
            or self:NormalizeRole(globalProfile.role)
        )

        if hasLegacyIdentity then
            characterProfile.className = self:Trim(characterProfile.className) ~= "" and characterProfile.className or (self:Trim(globalProfile.className) ~= "" and self:Trim(globalProfile.className) or self.defaults.character.className)
            characterProfile.color = self:SanitizeHex(characterProfile.color) or self:SanitizeHex(globalProfile.color) or self.defaults.character.color
            characterProfile.role = self:NormalizeRole(characterProfile.role) or self:NormalizeRole(globalProfile.role) or self.defaults.character.role
        end

        characterProfile._migratedFromLegacy = true
    end

    return characterProfile
end

function ClassForge:BuildProfileData()
    local profile = self:GetCharacterProfile()

    return {
        className = self:Trim(profile.className) ~= "" and self:Trim(profile.className) or self.defaults.character.className,
        color = self:SanitizeHex(profile.color) or self.defaults.character.color,
        role = self:GetCurrentRole(),
        faction = self:GetUnitFaction("player") or "",
        addonVersion = self.version,
        updated = time(),
        source = "self",
    }
end

function ClassForge:RefreshPlayerCache()
    local playerName = UnitName("player")
    if not playerName then
        return nil
    end

    local data = self:BuildProfileData()
    self:SetDataForName(playerName, data)

    return data
end

function ClassForge:RefreshAllDisplays()
    if self.UpdateCharacterPanel then
        self:UpdateCharacterPanel()
    end
    if self.UpdateWhoList then
        self:UpdateWhoList()
    end
    if self.UpdateGuildRoster then
        self:UpdateGuildRoster()
    end
    if self.UpdateFriendsList then
        self:UpdateFriendsList()
    end
    if self.UpdatePartyFrameColors then
        self:UpdatePartyFrameColors()
    end
    if self.UpdateRaidBrowser then
        self:UpdateRaidBrowser()
    end
    if self.UpdateTargetClassTag then
        self:UpdateTargetClassTag()
    end
    if self.UpdateTargetProfile then
        self:UpdateTargetProfile()
    end
    if self.UpdateInspectFrame then
        self:UpdateInspectFrame()
    end
    if self.UpdateMapMemberColors then
        self:UpdateMapMemberColors()
    end
    if self.ScheduleMapMemberUpdate then
        self:ScheduleMapMemberUpdate(0)
    end
end

function ClassForge:ADDON_LOADED(name)
    if name == self.name then
        ClassForgeDB = self:CopyDefaults(self.defaults, ClassForgeDB or {})
        ClassForgeCache = ClassForgeCache or {}
        self:MigrateDatabase()
        return
    end

    if name == "Blizzard_InspectUI" and self.SetupInspectHooks then
        self:SetupInspectHooks()
        self:UpdateInspectFrame()
    end
end

function ClassForge:PLAYER_LOGIN()
    if RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix(self.prefix)
    end

    self.syncState = {
        broadcasts = {},
        whispers = {},
        who = {
            lastRun = 0,
            lastComplete = 0,
        },
        lastSync = 0,
    }

    self:EnsureCurrentCharacterProfile()
    self:SetupSlashCommands()
    self:CreateOptionsPanel()
    self:InitDisplay()
    self:RefreshPlayerCache()
    self:BroadcastStartup()
    self:RefreshAllDisplays()
    self:Print(self:L("loaded"))
end

function ClassForge:PLAYER_ENTERING_WORLD()
    if ShowFriends then
        ShowFriends()
    end
    if IsInGuild and IsInGuild() and GuildRoster then
        GuildRoster()
    end
    self:RequestSyncFromFriends()
    self:RequestSyncFromGuild()
    self:RequestSyncFromGroup()
    if self:IsAutoWhoOnLoginEnabled() then
        self:PerformWhoSync()
    end
end

function ClassForge:GROUP_ROSTER_UPDATE()
    self:BroadcastSelf("PARTY")
    self:BroadcastSelf("RAID")
    self:RequestSyncFromGroup()
    if self:IsAutoWhoOnGroupEnabled() then
        self:PerformWhoSync()
    end
    if self.ScheduleMapMemberUpdate then
        self:ScheduleMapMemberUpdate(0.05)
    end
end

function ClassForge:GUILD_ROSTER_UPDATE()
    if self.RequestSyncFromGuild then
        self:RequestSyncFromGuild()
    end
    self:UpdateGuildRoster()
end

function ClassForge:PLAYER_GUILD_UPDATE()
    self:BroadcastSelf("GUILD")
    if IsInGuild and IsInGuild() and GuildRoster then
        GuildRoster()
    end
    self:UpdateGuildRoster()
end

function ClassForge:PLAYER_TARGET_CHANGED()
    self:UpdateTargetClassTag()
    self:UpdateTargetProfile()
    self:UpdateInspectFrame()

    if UnitExists("target") and UnitIsPlayer("target") then
        local targetName = UnitName("target")
        if targetName then
            self:RequestSyncFromName(targetName)
        end
    end

    if self.ScheduleMapMemberUpdate then
        self:ScheduleMapMemberUpdate(0)
    end
end

function ClassForge:WHO_LIST_UPDATE()
    self:ProcessWhoResults()
    if self.RestoreSilentWhoSync then
        self:RestoreSilentWhoSync()
    end
    self:UpdateWhoList()
end

function ClassForge:FRIENDLIST_UPDATE()
    if self.RequestSyncFromFriends then
        self:RequestSyncFromFriends()
    end
    self:UpdateFriendsList()
end

function ClassForge:INSPECT_READY()
    self:UpdateInspectFrame()
end

function ClassForge:RefreshRoleFromBlizzard()
    local role = self:GetAssignedGroupRole("player")
    if not role then
        return
    end

    local characterProfile = self:GetCharacterProfile()
    if characterProfile.role ~= role then
        characterProfile.role = role
        self:RefreshPlayerCache()
        self:BroadcastStartup()
        self:RefreshAllDisplays()
    else
        self:RefreshAllDisplays()
    end
end

function ClassForge:PLAYER_TALENT_UPDATE()
    self:RefreshRoleFromBlizzard()
end

function ClassForge:PLAYER_ROLES_ASSIGNED()
    self:RefreshRoleFromBlizzard()
end

function ClassForge:ACTIVE_TALENT_GROUP_CHANGED()
    self:RefreshRoleFromBlizzard()
end
