ClassForge = ClassForge or {}

ClassForge.name = "ClassForge"
ClassForge.prefix = "CLASSFORGE"
ClassForge.version = "3.6.1"
ClassForge.dbVersion = 8
ClassForge.homepage = "https://github.com/MrKrisSatan/ClassForge"
ClassForge.releasesPage = "https://github.com/MrKrisSatan/ClassForge/releases"

local addon = CreateFrame("Frame")
ClassForge.frame = addon

ClassForge.defaults = {
    character = {
        className = "Hero",
        color = "FFD100",
        role = "DPS",
        description = "",
        spellHistory = {},
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
        meterPosition = {
            point = "CENTER",
            relativePoint = "CENTER",
            x = 320,
            y = 40,
        },
        meterSize = {
            width = 520,
            height = 180,
        },
        minimapButton = {
            angle = 225,
            hidden = false,
        },
        meter = {
            enabled = true,
            locked = false,
            view = "dps",
            persistent = false,
            includePets = true,
            debug = false,
            maxRows = 5,
            showDps = true,
            showTopSpell = true,
            showThreat = true,
            showHealing = true,
            exportType = "PARTY",
            exportChannel = "world",
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
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",
    "COMBAT_LOG_EVENT_UNFILTERED",
    "UNIT_COMBAT",
    "UNIT_SPELLCAST_SUCCEEDED",
    "UNIT_HEALTH",
    "CHAT_MSG_ADDON",
    "CHAT_MSG_COMBAT_SELF_HITS",
    "CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS",
    "CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS",
    "CHAT_MSG_SPELL_SELF_DAMAGE",
    "CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE",
    "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE",
    "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",
    "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE",
    "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE",
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
        meter_tab = "Meter",
        description_tab = "Description",
        class_info_tab = "Class Info",
        options_subtitle = "Custom class identities for Wrath 3.3.5a with sync, cache, and map support.",
        language = "Language",
        english = "English",
        spanish = "Spanish",
        russian = "Russian",
        custom_class_name = "Custom class name",
        class_description = "Class description",
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
        meter_box = "Meter box",
        meter_persistent = "Keep main meter until reset",
        meter_mode_toggle = "Toggle segment/session mode",
        meter_mode_segment = "Current fight",
        meter_mode_session = "Since reset",
        meter_include_pets = "Include pet damage and healing",
        meter_debug = "Enable meter debug messages",
        meter_debug_on = "Meter debug ON",
        meter_debug_off = "Meter debug OFF",
        meter_filter_clear = "Clear selected spell",
        meter_click_segment = "Click a pie segment to focus that spell.",
        hits = "Hits",
        crits = "Crits",
        min = "Min",
        max = "Max",
        meter_view_dps = "Highest DPS",
        meter_view_threat = "Highest Threat",
        meter_view_healing_done = "Top Healing Done",
        meter_view_healing_received = "Top Healing Received",
        lock_meter = "Lock meter position",
        reset_meter = "Reset Meter",
        reset_meter_data = "Reset Data",
        meter_show_dps = "Show DPS rankings",
        meter_show_top_spell = "Show your top damage spell",
        meter_show_threat = "Show highest threat on target",
        meter_show_healing = "Show healing leader",
        meter_max_rows = "Max DPS rows",
        meter_size = "Size",
        meter_export = "Export Meter",
        meter_breakdown = "Spell Breakdown",
        meter_damage_spells = "Damage Spells",
        meter_healing_spells = "Healing Spells",
        meter_personal = "Personal",
        meter_group = "Group",
        inspect_tab = "ClassForge",
        inspect_description = "Description",
        inspect_spells = "Most used spells",
        meter_contribution = "Contribution",
        meter_no_spells = "No spell data yet.",
        meter_export_target = "Export target",
        meter_export_channel = "Channel name",
        export_say = "Say",
        export_party = "Party",
        export_raid = "Raid",
        export_guild = "Guild",
        export_officer = "Officer",
        export_yell = "Yell",
        export_channel = "Channel",
        meter_hint = "Hold Shift and drag to move. Drag the bottom-right corner to resize.",
        meter_waiting = "Waiting for combat data...",
        dps_rankings = "DPS Rankings",
        top_spell = "Top Spell",
        threat_leader = "Threat",
        healing_leader = "Healing",
        none = "None",
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
        meter_tab = "Medidor",
        description_tab = "Descripcion",
        class_info_tab = "Info de clase",
        options_subtitle = "Identidades de clase personalizadas para Wrath 3.3.5a con sincronización, caché y soporte de mapa.",
        language = "Idioma",
        english = "Inglés",
        spanish = "Español",
        russian = "Ruso",
        custom_class_name = "Nombre de clase personalizado",
        class_description = "Descripcion de clase",
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
        meter_box = "Caja del medidor",
        meter_persistent = "Mantener el medidor principal hasta restablecer",
        meter_mode_toggle = "Cambiar modo segmento/sesion",
        meter_mode_segment = "Combate actual",
        meter_mode_session = "Desde reinicio",
        meter_include_pets = "Incluir dano y sanacion de mascotas",
        meter_debug = "Activar mensajes de depuracion del medidor",
        meter_debug_on = "Depuracion del medidor ACTIVADA",
        meter_debug_off = "Depuracion del medidor DESACTIVADA",
        meter_filter_clear = "Quitar hechizo seleccionado",
        meter_click_segment = "Haz clic en un segmento para enfocar ese hechizo.",
        hits = "Golpes",
        crits = "Criticos",
        min = "Min",
        max = "Max",
        meter_view_dps = "Mayor DPS",
        meter_view_threat = "Mayor amenaza",
        meter_view_healing_done = "Más sanación hecha",
        meter_view_healing_received = "Más sanación recibida",
        lock_meter = "Bloquear posición del medidor",
        reset_meter = "Restablecer medidor",
        reset_meter_data = "Restablecer datos",
        meter_show_dps = "Mostrar clasificaciones de DPS",
        meter_show_top_spell = "Mostrar tu hechizo de mayor daño",
        meter_show_threat = "Mostrar mayor amenaza en el objetivo",
        meter_show_healing = "Mostrar líder de sanación",
        meter_max_rows = "Máx. filas de DPS",
        meter_size = "Tamaño",
        meter_export = "Exportar medidor",
        meter_breakdown = "Desglose de hechizos",
        meter_damage_spells = "Hechizos de daño",
        meter_healing_spells = "Hechizos de sanación",
        meter_personal = "Personal",
        meter_group = "Grupo",
        inspect_tab = "ClassForge",
        inspect_description = "Descripcion",
        inspect_spells = "Hechizos mas usados",
        meter_contribution = "Contribución",
        meter_no_spells = "Aún no hay datos de hechizos.",
        meter_export_target = "Destino de exportación",
        meter_export_channel = "Nombre del canal",
        export_say = "Decir",
        export_party = "Grupo",
        export_raid = "Banda",
        export_guild = "Hermandad",
        export_officer = "Oficial",
        export_yell = "Gritar",
        export_channel = "Canal",
        meter_hint = "Mantén Mayús y arrastra para mover. Arrastra la esquina inferior derecha para cambiar el tamaño.",
        meter_waiting = "Esperando datos de combate...",
        dps_rankings = "Clasificación DPS",
        top_spell = "Mejor hechizo",
        threat_leader = "Amenaza",
        healing_leader = "Sanación",
        none = "Ninguno",
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
        meter_tab = "Метр",
        description_tab = "Описание",
        class_info_tab = "Инфо класса",
        options_subtitle = "Пользовательские классы для Wrath 3.3.5a с синхронизацией, кэшем и поддержкой карты.",
        language = "Язык",
        english = "Английский",
        spanish = "Испанский",
        russian = "Русский",
        custom_class_name = "Пользовательское имя класса",
        class_description = "Описание класса",
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
        meter_box = "Окно метра",
        meter_persistent = "Сохранять основной метр до сброса",
        meter_mode_toggle = "Переключить режим сегмент/сессия",
        meter_mode_segment = "Текущий бой",
        meter_mode_session = "С момента сброса",
        meter_include_pets = "Учитывать урон и лечение питомцев",
        meter_debug = "Включить отладку метра",
        meter_debug_on = "Отладка метра ВКЛ",
        meter_debug_off = "Отладка метра ВЫКЛ",
        meter_filter_clear = "Сбросить выбранное заклинание",
        meter_click_segment = "Щелкните по сектору, чтобы выбрать это заклинание.",
        hits = "Попадания",
        crits = "Криты",
        min = "Мин",
        max = "Макс",
        meter_view_dps = "Наивысший DPS",
        meter_view_threat = "Наивысшая угроза",
        meter_view_healing_done = "Лучшее исцеление",
        meter_view_healing_received = "Больше всего получено исцеления",
        lock_meter = "Закрепить положение метра",
        reset_meter = "Сброс метра",
        reset_meter_data = "Сброс данных",
        meter_show_dps = "Показывать рейтинг DPS",
        meter_show_top_spell = "Показывать ваше самое сильное заклинание",
        meter_show_threat = "Показывать лидера угрозы на цели",
        meter_show_healing = "Показывать лидера лечения",
        meter_max_rows = "Макс. строк DPS",
        meter_size = "Размер",
        meter_export = "Экспорт метра",
        meter_breakdown = "Разбор заклинаний",
        meter_damage_spells = "Заклинания урона",
        meter_healing_spells = "Заклинания лечения",
        meter_personal = "Личное",
        meter_group = "Группа",
        inspect_tab = "ClassForge",
        inspect_description = "Описание",
        inspect_spells = "Частые заклинания",
        meter_contribution = "Вклад",
        meter_no_spells = "Пока нет данных по заклинаниям.",
        meter_export_target = "Куда экспортировать",
        meter_export_channel = "Имя канала",
        export_say = "Сказать",
        export_party = "Группа",
        export_raid = "Рейд",
        export_guild = "Гильдия",
        export_officer = "Офицеры",
        export_yell = "Крик",
        export_channel = "Канал",
        meter_hint = "Удерживайте Shift и перетаскивайте для перемещения. Тяните нижний правый угол для изменения размера.",
        meter_waiting = "Ожидание данных боя...",
        dps_rankings = "Рейтинг DPS",
        top_spell = "Лучшее заклинание",
        threat_leader = "Угроза",
        healing_leader = "Лечение",
        none = "Нет",
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
            characterProfile.description = self:Trim(characterProfile.description) ~= "" and characterProfile.description or self:Trim(globalProfile.description)
        end

        characterProfile._migratedFromLegacy = true
    end

    return characterProfile
end

function ClassForge:BuildProfileData()
    local profile = self:GetCharacterProfile()

    return {
        className = self:Trim(profile.className) ~= "" and self:Trim(profile.className) or self.defaults.character.className,
        description = self:Trim(profile.description),
        color = self:SanitizeHex(profile.color) or self.defaults.character.color,
        role = self:GetCurrentRole(),
        faction = self:GetUnitFaction("player") or "",
        topSpells = self.GetPersistentTopSpellsSummary and self:GetPersistentTopSpellsSummary(5) or "",
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
    if self.UpdateMeterPanel then
        self:UpdateMeterPanel()
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
    if self.ResetMeterCombat then
        self:ResetMeterCombat()
    end
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

function ClassForge:PLAYER_REGEN_DISABLED()
    if not self:IsMeterEnabled() then
        return
    end

    if self.ResetMeterCombat and not self:IsMeterPersistent() then
        self:ResetMeterCombat()
    end
    if self.EnsureMeterCombatActive then
        self:EnsureMeterCombatActive()
    end
    if self.SeedMeterParticipants then
        self:SeedMeterParticipants()
    end
    if self.UpdateMeterPanel then
        self:UpdateMeterPanel()
    end
end

function ClassForge:PLAYER_REGEN_ENABLED()
    if not self:IsMeterEnabled() then
        return
    end

    if self.meterState and self.meterState.combat then
        self.meterState.combat.active = false
        self.meterState.combat.ended = (GetTime and GetTime()) or time()
    end
    self.pendingSpellDamage = {}
    if self.UpdateMeterPanel then
        self:UpdateMeterPanel()
    end
end

function ClassForge:ConsumePendingMeleeSpell(destGUID)
    local pending = self.pendingSpellDamage
    if type(pending) ~= "table" or #pending == 0 then
        return nil
    end

    local now = (GetTime and GetTime()) or time()
    for index = #pending, 1, -1 do
        local item = pending[index]
        if (now - (item.started or now)) > 6 then
            table.remove(pending, index)
        elseif (now - (item.started or now)) <= 0.4 and (not destGUID or not item.targetGUID or item.targetGUID == destGUID) then
            table.remove(pending, index)
            return item.spell
        end
    end

    return nil
end

function ClassForge:ConsumeSwingOverride(destGUID, amount)
    local override = self.pendingSwingOverride
    if type(override) ~= "table" then
        return nil, nil
    end

    local now = (GetTime and GetTime()) or time()
    if (override.expires or 0) < now then
        self.pendingSwingOverride = nil
        return nil, nil
    end

    if destGUID and override.targetGUID and override.targetGUID ~= destGUID then
        return nil, nil
    end

    local overrideAmount = tonumber(override.amount) or 0
    local swingAmount = tonumber(amount) or 0
    if overrideAmount > 0 and (swingAmount <= 0 or math.abs(overrideAmount - swingAmount) <= 1) then
        self.pendingSwingOverride = nil
        return override.spell, overrideAmount
    end

    return nil, nil
end

function ClassForge:ProcessPendingSpellDamage(unit)
    local pending = self.pendingSpellDamage
    if type(pending) ~= "table" or #pending == 0 then
        return false
    end

    unit = unit or "target"
    if unit ~= "target" or not UnitExists(unit) then
        return false
    end

    local now = (GetTime and GetTime()) or time()
    local currentGUID = UnitGUID and UnitGUID(unit) or nil
    local currentHealth = UnitHealth and UnitHealth(unit) or nil
    if not currentHealth then
        return false
    end

    for index = #pending, 1, -1 do
        local item = pending[index]
        if (now - (item.started or now)) > 6 then
            table.remove(pending, index)
        elseif item.targetGUID and currentGUID and item.targetGUID ~= currentGUID then
            -- Keep waiting briefly in case the player swaps targets back.
        elseif currentHealth < (item.health or 0) then
            local delta = (item.health or 0) - currentHealth
            if delta > 0 and self.RecordMeterDamage then
                self:RecordMeterDamage(UnitName("player"), item.spell, delta, nil, UnitGUID and UnitGUID("player") or nil)
                self:MeterDebug("health fallback recorded " .. tostring(item.spell) .. " for " .. tostring(delta))
                table.remove(pending, index)
                return true
            end
            table.remove(pending, index)
        end
    end

    return false
end

function ClassForge:TryRecordSelfCombatText(message, periodic)
    if not self:IsMeterEnabled() or not message or message == "" or not self.RecordMeterDamage then
        return false
    end

    local playerName = UnitName("player") or ""
    local escapedPlayerName = string.gsub(playerName, "([^%w])", "%%%1")

    local function firstPositiveInteger(text)
        for numeric in string.gmatch(text or "", "(%d+)") do
            local amount = tonumber(numeric)
            if amount and amount > 0 then
                return amount
            end
        end

        return nil
    end

    local spellName, amount = string.match(message, "^Your (.+) hits .+ for (%d+)")
    if not spellName then
        spellName, amount = string.match(message, "^Your (.+) crits .+ for (%d+)")
    end
    if not spellName then
        spellName, amount = string.match(message, "^Your (.+) drains .+ for (%d+)")
    end
    if not spellName and periodic then
        spellName, amount = string.match(message, "^.+ suffers (%d+) .+ damage from your (.+)%.")
        if spellName and amount then
            spellName, amount = amount, spellName
        end
    end
    if not spellName and escapedPlayerName ~= "" then
        spellName, amount = string.match(message, "^" .. escapedPlayerName .. "'s (.+) hits .+ for (%d+)")
    end
    if not spellName and escapedPlayerName ~= "" then
        spellName, amount = string.match(message, "^" .. escapedPlayerName .. "'s (.+) crits .+ for (%d+)")
    end
    if not spellName and escapedPlayerName ~= "" then
        spellName, amount = string.match(message, "^" .. escapedPlayerName .. "'s (.+) drains .+ for (%d+)")
    end

    local numericAmount = tonumber(amount)
    if spellName and numericAmount and numericAmount > 0 then
        local _, _, _, castTime, _, maxRange = GetSpellInfo and GetSpellInfo(spellName) or nil
        local isMeleeSpecial = false
        if castTime == 0 then
            local lowRange = tonumber(maxRange or 0) <= 5
            local lowerSpell = string.lower(spellName)
            local meleeHint = string.find(lowerSpell, "strike", 1, true)
                or string.find(lowerSpell, "slash", 1, true)
                or string.find(lowerSpell, "stab", 1, true)
            isMeleeSpecial = lowRange or meleeHint
        end

        if isMeleeSpecial then
            self.pendingSwingOverride = {
                spell = spellName,
                amount = numericAmount,
                targetGUID = UnitGUID and UnitGUID("target") or nil,
                expires = ((GetTime and GetTime()) or time()) + 0.6,
            }
            return true
        end

        self:RecordMeterDamage(UnitName("player"), spellName, numericAmount, nil, UnitGUID and UnitGUID("player") or nil)
        self:MeterDebug("chat fallback recorded " .. tostring(spellName) .. " for " .. tostring(numericAmount))
        if self.UpdateMeterPanel then
            self:UpdateMeterPanel()
        end
        return true
    end

    local pending = self.pendingSpellDamage
    if type(pending) == "table" and #pending > 0 then
        local pendingAmount = firstPositiveInteger(message)
        if pendingAmount and pendingAmount > 0 then
            local fallbackIndex = nil
            local fallbackItem = nil
            for index = #pending, 1, -1 do
                local item = pending[index]
                if item and item.spell then
                    local _, _, _, castTime, _, maxRange = GetSpellInfo and GetSpellInfo(item.spell) or nil
                    local isMeleeSpecial = false
                    if castTime == 0 then
                        local lowRange = tonumber(maxRange or 0) <= 5
                        local lowerSpell = string.lower(item.spell)
                        local meleeHint = string.find(lowerSpell, "strike", 1, true)
                            or string.find(lowerSpell, "slash", 1, true)
                            or string.find(lowerSpell, "stab", 1, true)
                        isMeleeSpecial = lowRange or meleeHint
                    end

                    if not fallbackItem and not isMeleeSpecial then
                        fallbackIndex = index
                        fallbackItem = item
                        fallbackItem.isMeleeSpecial = false
                    end
                end
            end

            if fallbackItem then
                table.remove(pending, fallbackIndex)
                self:RecordMeterDamage(UnitName("player"), fallbackItem.spell, pendingAmount, nil, UnitGUID and UnitGUID("player") or nil)
                self:MeterDebug("pending fallback recorded " .. tostring(fallbackItem.spell) .. " for " .. tostring(pendingAmount))
                if self.UpdateMeterPanel then
                    self:UpdateMeterPanel()
                end
                return true
            end
        end
    end

    return false
end

do
    local function toNumber(value)
        return tonumber(value) or 0
    end

    local function normalizePlayerSource(self, sourceGUID, sourceName)
        if not sourceName and UnitGUID and sourceGUID and sourceGUID == UnitGUID("player") then
            sourceName = UnitName("player")
        end

        local playerGUID = UnitGUID and UnitGUID("player") or nil
        local playerName = UnitName("player")
        if sourceName and (sourceName == "You" or sourceName == self:L("you")) and playerName then
            sourceName = playerName
        end
        if not sourceGUID and playerGUID and sourceName and playerName and self:NormalizePlayerName(sourceName) == self:NormalizePlayerName(playerName) then
            sourceGUID = playerGUID
        end

        return sourceGUID, sourceName
    end

    local function recordSwingDamage(self, _, _, sourceGUID, sourceName, sourceFlags, destGUID, _, _, ...)
        local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
        local damageAmount = toNumber(amount)
        local swingLabel = "Melee"

        if (sourceGUID and UnitGUID and sourceGUID == UnitGUID("player"))
            or (sourceName and UnitName("player") and self:NormalizePlayerName(sourceName) == self:NormalizePlayerName(UnitName("player"))) then
            local overrideLabel, overrideAmount = nil, nil
            if self.ConsumeSwingOverride then
                overrideLabel, overrideAmount = self:ConsumeSwingOverride(destGUID, damageAmount)
            end
            if overrideLabel then
                swingLabel = overrideLabel
                damageAmount = overrideAmount or damageAmount
            elseif self.ConsumePendingMeleeSpell then
                swingLabel = self:ConsumePendingMeleeSpell(destGUID) or swingLabel
            end
        end

        self:RecordMeterDamage(sourceName, swingLabel, damageAmount, sourceFlags, sourceGUID, {
            spellID = 6603,
            school = 1,
            overkill = toNumber(overkill),
            resisted = toNumber(resisted),
            blocked = toNumber(blocked),
            absorbed = toNumber(absorbed),
            critical = critical,
            glancing = glancing,
            crushing = crushing,
        })
    end

    local function recordSpellDamage(self, _, _, sourceGUID, sourceName, sourceFlags, _, _, _, ...)
        local spellID, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
        self:RecordMeterDamage(sourceName, spellName, toNumber(amount), sourceFlags, sourceGUID, {
            spellID = spellID,
            school = spellSchool or school,
            overkill = toNumber(overkill),
            resisted = toNumber(resisted),
            blocked = toNumber(blocked),
            absorbed = toNumber(absorbed),
            critical = critical,
            glancing = glancing,
            crushing = crushing,
        })
    end

    local function recordSpellHeal(self, _, _, sourceGUID, sourceName, sourceFlags, _, destName, _, ...)
        local spellID, spellName, spellSchool, amount, overheal, absorbed, critical = ...
        self:RecordMeterHealing(sourceName, toNumber(amount), sourceFlags, sourceGUID, destName, spellName, {
            spellID = spellID,
            school = spellSchool,
            overheal = toNumber(overheal),
            absorbed = toNumber(absorbed),
            critical = critical,
        })
    end

    local function recordSpellMiss(self, _, _, sourceGUID, sourceName, sourceFlags, _, _, _, ...)
        local spellID, spellName, spellSchool, missType = ...
        if self.RecordMeterMiss then
            self:RecordMeterMiss(sourceName, spellName, sourceFlags, sourceGUID, {
                spellID = spellID,
                school = spellSchool,
                missed = missType,
            })
        end
    end

    local function recordSwingMiss(self, _, _, sourceGUID, sourceName, sourceFlags, _, _, _, ...)
        local missType = ...
        if self.RecordMeterMiss then
            self:RecordMeterMiss(sourceName, "Melee", sourceFlags, sourceGUID, {
                spellID = 6603,
                school = 1,
                missed = missType,
            })
        end
    end

    local meterCLEUHandlers = {
        SWING_DAMAGE = recordSwingDamage,
        SPELL_DAMAGE = recordSpellDamage,
        SPELL_PERIODIC_DAMAGE = recordSpellDamage,
        SPELL_BUILDING_DAMAGE = recordSpellDamage,
        RANGE_DAMAGE = recordSpellDamage,
        DAMAGE_SHIELD = recordSpellDamage,
        DAMAGE_SPLIT = recordSpellDamage,
        SPELL_HEAL = recordSpellHeal,
        SPELL_PERIODIC_HEAL = recordSpellHeal,
        SPELL_MISSED = recordSpellMiss,
        SPELL_PERIODIC_MISSED = recordSpellMiss,
        SPELL_BUILDING_MISSED = recordSpellMiss,
        RANGE_MISSED = recordSpellMiss,
        SWING_MISSED = recordSwingMiss,
    }

    function ClassForge:DispatchMeterCombatEvent(timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
        local handler = meterCLEUHandlers[eventType]
        if not handler then
            return false
        end

        sourceGUID, sourceName = normalizePlayerSource(self, sourceGUID, sourceName)
        handler(self, timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
        return true
    end
end

function ClassForge:COMBAT_LOG_EVENT_UNFILTERED(...)
    if not self:IsMeterEnabled() then
        return
    end

    if not self.RecordMeterDamage or not self.RecordMeterHealing then
        return
    end

    local payload = { ... }
    local timestamp = nil
    local eventType = nil
    local sourceGUID = nil
    local sourceName = nil
    local sourceFlags = nil
    local destGUID = nil
    local destName = nil
    local destFlags = nil
    local extras = {}

    local function normalizeCombatPayload(raw)
        local normalized = {
            timestamp = raw[1],
            eventType = raw[2],
            sourceGUID = nil,
            sourceName = nil,
            sourceFlags = nil,
            destGUID = nil,
            destName = nil,
            destFlags = nil,
            extras = {},
        }

        if type(raw[3]) == "boolean" then
            normalized.sourceGUID = raw[4]
            normalized.sourceName = raw[5]
            normalized.sourceFlags = raw[6]
            normalized.destGUID = raw[8]
            normalized.destName = raw[9]
            normalized.destFlags = raw[10]
            for index = 12, #raw do
                normalized.extras[#normalized.extras + 1] = raw[index]
            end
        else
            normalized.sourceGUID = raw[3]
            normalized.sourceName = raw[4]
            normalized.sourceFlags = raw[5]
            normalized.destGUID = raw[6]
            normalized.destName = raw[7]
            normalized.destFlags = raw[8]
            for index = 9, #raw do
                normalized.extras[#normalized.extras + 1] = raw[index]
            end
        end

        return normalized
    end

    local normalized = normalizeCombatPayload(payload)
    timestamp = normalized.timestamp
    eventType = normalized.eventType
    sourceGUID = normalized.sourceGUID
    sourceName = normalized.sourceName
    sourceFlags = normalized.sourceFlags
    destGUID = normalized.destGUID
    destName = normalized.destName
    destFlags = normalized.destFlags
    extras = normalized.extras

    if not eventType and _G.arg2 then
        local raw = {}
        for index = 1, 30 do
            raw[index] = _G["arg" .. index]
        end
        normalized = normalizeCombatPayload(raw)
        timestamp = normalized.timestamp
        eventType = normalized.eventType
        sourceGUID = normalized.sourceGUID
        sourceName = normalized.sourceName
        sourceFlags = normalized.sourceFlags
        destGUID = normalized.destGUID
        destName = normalized.destName
        destFlags = normalized.destFlags
        extras = normalized.extras
    end

    if not eventType then
        return
    end

    if self.DispatchMeterCombatEvent then
        self:DispatchMeterCombatEvent(timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, unpack(extras))
    end

    if self.UpdateMeterPanel then
        self:UpdateMeterPanel()
    end
end

function ClassForge:UNIT_COMBAT(unit, action, descriptor, amount, damageType, ...)
    if not self:IsMeterEnabled() then
        return
    end

    if not unit or not self.RecordMeterDamage or not self.RecordMeterHealing then
        return
    end

    local isTrackedUnit = (unit == "player")
    if not isTrackedUnit then
        if string.find(unit, "^party%d+$") or string.find(unit, "^raid%d+$") then
            isTrackedUnit = true
        end
    end

    if not isTrackedUnit or not UnitExists(unit) or not UnitIsPlayer(unit) then
        return
    end

    local sourceName = UnitName(unit)
    local sourceGUID = UnitGUID and UnitGUID(unit) or nil
    local normalizedAction = self:Trim(action):upper()
    local args = { descriptor, amount, damageType, ... }
    local value = 0
    local label = nil

    for _, candidate in ipairs(args) do
        if value <= 0 then
            local numeric = tonumber(candidate)
            if numeric and numeric > 0 then
                value = numeric
            end
        end

        if not label and type(candidate) == "string" then
            local trimmed = self:Trim(candidate)
            if trimmed ~= "" and trimmed ~= unit and string.upper(trimmed) ~= normalizedAction then
                label = trimmed
            end
        end
    end

    label = label or (self:Trim(descriptor) ~= "" and self:Trim(descriptor)) or "Melee"

    if value <= 0 then
        return
    end

    if normalizedAction == "WOUND" then
        return
    elseif string.find(normalizedAction, "HEAL", 1, true) then
        self:RecordMeterHealing(sourceName, value, nil, sourceGUID, unit, label)
    elseif string.find(normalizedAction, "DAMAGE", 1, true)
        or normalizedAction == "SPELL"
        or normalizedAction == "HIT" then
        self:RecordMeterDamage(sourceName, label, value, nil, sourceGUID)
    else
        self:RecordMeterDamage(sourceName, label, value, nil, sourceGUID)
    end

    if self.UpdateMeterPanel then
        self:UpdateMeterPanel()
    end
end

function ClassForge:UNIT_SPELLCAST_SUCCEEDED(unit, spellName)
    if not self:IsMeterEnabled() or unit ~= "player" then
        return
    end

    if not spellName or self:Trim(spellName) == "" then
        return
    end

    if not UnitExists("target") or not UnitCanAttack("player", "target") or UnitIsDead("target") then
        return
    end

    local targetGUID = UnitGUID and UnitGUID("target") or nil
    local targetName = UnitName("target")
    local targetHealth = UnitHealth and UnitHealth("target") or nil
    local targetMaxHealth = UnitHealthMax and UnitHealthMax("target") or nil
    if not targetGUID or not targetName or not targetHealth or targetHealth <= 0 then
        return
    end

    self.pendingSpellDamage = type(self.pendingSpellDamage) == "table" and self.pendingSpellDamage or {}
    self.pendingSpellDamage[#self.pendingSpellDamage + 1] = {
        spell = spellName,
        targetGUID = targetGUID,
        targetName = targetName,
        health = targetHealth,
        maxHealth = targetMaxHealth or 0,
        started = (GetTime and GetTime()) or time(),
    }
end

function ClassForge:UNIT_HEALTH(unit)
    if not self:IsMeterEnabled() then
        return
    end

    if self.ProcessPendingSpellDamage and self:ProcessPendingSpellDamage(unit) then
        if self.UpdateMeterPanel then
            self:UpdateMeterPanel()
        end
    end
end

function ClassForge:CHAT_MSG_SPELL_SELF_DAMAGE(message)
    self:TryRecordSelfCombatText(message, false)
end

function ClassForge:CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE(message)
    self:TryRecordSelfCombatText(message, false)
end

function ClassForge:CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE(message)
    self:TryRecordSelfCombatText(message, false)
end

function ClassForge:CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE(message)
    self:TryRecordSelfCombatText(message, true)
end

function ClassForge:CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE(message)
    self:TryRecordSelfCombatText(message, true)
end

function ClassForge:CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE(message)
    self:TryRecordSelfCombatText(message, true)
end

function ClassForge:CHAT_MSG_COMBAT_SELF_HITS(message)
    self:TryRecordSelfCombatText(message, false)
end

function ClassForge:CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS(message)
    self:TryRecordSelfCombatText(message, false)
end

function ClassForge:CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS(message)
    self:TryRecordSelfCombatText(message, false)
end
