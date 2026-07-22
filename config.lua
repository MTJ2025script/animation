--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║           MTJ Animation System – config.lua                     ║
    ║  Emotes, Kategorien, Sitzobjekte, Offsets, ox_target            ║
    ╚══════════════════════════════════════════════════════════════════╝

    Neue Sitzmodelle ergänzen:
    ─────────────────────────
    Config.Seats[`model_name`] = {
        type      = "scenario" | "anim",

        -- Für Szenario-Animationen (empfohlen wenn möglich):
        scenario  = "SCENARIO_NAME",

        -- Für manuelle Animationen:
        animDict  = "anim_dict",
        animName  = "anim_name",
        animFlag  = 1,   -- optional, Standard 1 (Loop)

        -- Position relativ zur Objektmitte:
        --   x = seitlich (+ = rechts, − = links)
        --   y = vorwärts (+ = vorne, − = hinten)
        --   z = höhe (+ = hoch, − = tief)
        offset    = vec3(0.0, 0.0, 0.45),

        -- Zusätzliche Drehung in Grad (relativ zur Objektausrichtung)
        rotation  = 180.0,

        -- Optionale Bezeichnung für ox_target-Label
        label     = "Sitzen",
    }

    Tipp: Nutze den In-Game Offset-Editor (Befehl /seatoffset),
    um Offsets live zu testen und in die Config zu kopieren.
]]

Config = {}

-- ─────────────────────────────────────────────────
-- Allgemeine Einstellungen
-- ─────────────────────────────────────────────────
Config.Locale          = 'de'          -- Anzeigesprache (derzeit: de / en)
Config.MenuKey         = 'F3'          -- Taste zum Öffnen des Emote-Menüs
Config.SeatKey         = 'G'           -- Taste zum Sitzen (Proximity, ohne ox_target)
Config.ExitKey         = 'X'           -- Taste zum Aufstehen / Emote beenden
Config.SearchRadius    = 2.0           -- Meter-Radius für Sitzerkennung
Config.UseOxTarget     = true          -- ox_target aktivieren (wenn Resource vorhanden)
Config.OxTargetDist    = 2.5           -- ox_target Interaktionsdistanz
Config.FallbackSeat    = true          -- Fallback für unbekannte Sitzobjekte
Config.FallbackScenario = 'PROP_HUMAN_SEAT_CHAIR' -- Fallback-Szenario
Config.MaxFavorites    = 16            -- Max. Anzahl Favoriten pro Spieler
Config.DevMode         = false         -- Developer-Modus (Offset-Editor, Debug-Ausgaben)
Config.PropCleanupDelay = 500          -- ms, bevor Prop bei Emote-Stop entfernt wird

-- ─────────────────────────────────────────────────
-- Emote-Kategorien
-- ─────────────────────────────────────────────────
Config.Categories = {
    { id = 'all',       label = 'Alle',          icon = '⭐' },
    { id = 'greet',     label = 'Begrüßung',     icon = '👋' },
    { id = 'dance',     label = 'Tanzen',        icon = '🎵' },
    { id = 'sit',       label = 'Sitzen',        icon = '🪑' },
    { id = 'idle',      label = 'Idle/Warten',   icon = '🧍' },
    { id = 'fun',       label = 'Fun',           icon = '🎉' },
    { id = 'taunt',     label = 'Provokation',   icon = '😤' },
    { id = 'prop',      label = 'Mit Prop',      icon = '🎸' },
    { id = 'couple',    label = 'Duo',           icon = '👫' },
    { id = 'favorites', label = 'Favoriten',     icon = '❤️' },
}

-- ─────────────────────────────────────────────────
-- Emote-Datenbank
-- ─────────────────────────────────────────────────
--[[
    Emote-Eintrag:
    {
        label    = "Anzeigename",
        category = "kategorie-id",
        type     = "scenario" | "anim" | "prop",
        dict     = "anim_dictionary",      -- bei type "anim" / "prop"
        anim     = "animation_name",       -- bei type "anim" / "prop"
        scenario = "SCENARIO_NAME",        -- bei type "scenario"
        flag     = 49,                     -- AnimFlag (49 = loop, 0 = einmalig)
        prop = {                           -- nur bei type "prop"
            model  = "prop_model_name",
            bone   = 60309,               -- Ped-Bone (60309 = rechte Hand)
            offset = vec3(0,0,0),
            rot    = vec3(0,0,0),
        },
        duration = -1,                     -- ms, -1 = unendlich
    }
]]
Config.Emotes = {
    -- ── Begrüßung ──
    {
        label    = 'Winken',
        category = 'greet',
        type     = 'anim',
        dict     = 'anim@mp_player_intmenu@key_fob@',
        anim     = 'fob_click',
        flag     = 49,
    },
    {
        label    = 'Hi sagen',
        category = 'greet',
        type     = 'anim',
        dict     = 'gestures@m@standing@casual@mouth_ops@smoking_joint@',
        anim     = 'gesture_hand_up',
        flag     = 0,
    },
    {
        label    = 'Klatschen',
        category = 'greet',
        type     = 'anim',
        dict     = 'anim@mp_player_intcelebrationmale@ped_ground@clap',
        anim     = 'clap',
        flag     = 49,
    },
    {
        label    = 'Daumen hoch',
        category = 'greet',
        type     = 'anim',
        dict     = 'anim@mp_player_intmenu@key_fob@',
        anim     = 'fob_click_fp',
        flag     = 0,
    },
    {
        label    = 'Jubeln',
        category = 'greet',
        type     = 'anim',
        dict     = 'anim@mp_player_intcelebrationmale@ped_ground@cheer',
        anim     = 'cheer',
        flag     = 49,
    },
    {
        label    = 'Nicken',
        category = 'greet',
        type     = 'anim',
        dict     = 'anim@mp_player_intmenu@key_fob@',
        anim     = 'fob_click_fp',
        flag     = 0,
    },
    -- ── Tanzen ──
    {
        label    = 'Tanzen (Gangnam)',
        category = 'dance',
        type     = 'scenario',
        scenario = 'WORLD_HUMAN_PARTYING',
        flag     = 49,
    },
    {
        label    = 'Tanzen (freestyle)',
        category = 'dance',
        type     = 'anim',
        dict     = 'anim@amb@nightclub@dancers@crowddance_facingdj@hi_intensity',
        anim     = 'hi_dance_facingdj_17_v1_male^1',
        flag     = 49,
    },
    {
        label    = 'Tanzen (Shuffle)',
        category = 'dance',
        type     = 'anim',
        dict     = 'anim@amb@nightclub@dancers@crowddance_facingdj@',
        anim     = 'hi_dance_facingdj_15_v1_male^4',
        flag     = 49,
    },
    {
        label    = 'Tanzen (sexy)',
        category = 'dance',
        type     = 'anim',
        dict     = 'anim@amb@nightclub@dancers@crowddance_facingdj@',
        anim     = 'hi_dance_facingdj_09_v1_female^1',
        flag     = 49,
    },
    -- ── Sitzen ──
    {
        label    = 'Sitzen (Boden)',
        category = 'sit',
        type     = 'scenario',
        scenario = 'WORLD_HUMAN_PICNIC',
        flag     = 49,
    },
    {
        label    = 'Sitzen (Stuhl)',
        category = 'sit',
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_CHAIR',
        flag     = 49,
    },
    {
        label    = 'Sitzen (Bank)',
        category = 'sit',
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_BENCH',
        flag     = 49,
    },
    {
        label    = 'Sitzen (Mauer)',
        category = 'sit',
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_WALL',
        flag     = 49,
    },
    {
        label    = 'Lehnen (Wand)',
        category = 'sit',
        type     = 'scenario',
        scenario = 'WORLD_HUMAN_LEANING',
        flag     = 49,
    },
    -- ── Idle / Warten ──
    {
        label    = 'Auf Handy schauen',
        category = 'idle',
        type     = 'scenario',
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        flag     = 49,
    },
    {
        label    = 'Rauchen',
        category = 'idle',
        type     = 'scenario',
        scenario = 'WORLD_HUMAN_SMOKING',
        flag     = 49,
    },
    {
        label    = 'Trinken',
        category = 'idle',
        type     = 'scenario',
        scenario = 'WORLD_HUMAN_DRINKING',
        flag     = 49,
    },
    {
        label    = 'Arme verschränken',
        category = 'idle',
        type     = 'scenario',
        scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
        flag     = 49,
    },
    {
        label    = 'Hände in Taschen',
        category = 'idle',
        type     = 'scenario',
        scenario = 'WORLD_HUMAN_STAND_IMPATIENT_UPRIGHT',
        flag     = 49,
    },
    {
        label    = 'Bücken',
        category = 'idle',
        type     = 'anim',
        dict     = 'random@domestic',
        anim     = 'pickup_low',
        flag     = 0,
    },
    -- ── Fun ──
    {
        label    = 'Lachen',
        category = 'fun',
        type     = 'anim',
        dict     = 'anim@mp_player_intcelebrationmale@ped_ground@laughing',
        anim     = 'laughing',
        flag     = 49,
    },
    {
        label    = 'Facepalm',
        category = 'fun',
        type     = 'anim',
        dict     = 'anim@mp_player_intcelebrationmale@ped_ground@facepalm',
        anim     = 'facepalm',
        flag     = 0,
    },
    {
        label    = 'Luftküsschen',
        category = 'fun',
        type     = 'anim',
        dict     = 'anim@mp_player_intcelebrationmale@ped_ground@blowkiss',
        anim     = 'blowkiss',
        flag     = 0,
    },
    {
        label    = 'Schlafen (Boden)',
        category = 'fun',
        type     = 'anim',
        dict     = 'anim@am_sleep@',
        anim     = 'mo_sleep_loop_main',
        flag     = 49,
    },
    -- ── Provokation ──
    {
        label    = 'Mittelfinger',
        category = 'taunt',
        type     = 'anim',
        dict     = 'anim@mp_player_intcelebrationmale@ped_ground@middle_finger',
        anim     = 'middle_finger',
        flag     = 0,
    },
    {
        label    = 'Auslachen',
        category = 'taunt',
        type     = 'anim',
        dict     = 'anim@mp_player_intcelebrationmale@ped_ground@point_and_laugh',
        anim     = 'point_and_laugh',
        flag     = 49,
    },
    {
        label    = 'Aufforderung',
        category = 'taunt',
        type     = 'anim',
        dict     = 'anim@mp_player_intcelebrationmale@ped_ground@beckon',
        anim     = 'beckon',
        flag     = 0,
    },
    -- ── Mit Prop ──
    {
        label    = 'Gitarre spielen',
        category = 'prop',
        type     = 'prop',
        dict     = 'amb@world_human_musician@guitar@male@base',
        anim     = 'base',
        flag     = 49,
        prop = {
            model  = 'prop_acc_guitar_01',
            bone   = 57005,
            offset = vec3(0.0, 0.0, 0.0),
            rot    = vec3(0.0, 0.0, 0.0),
        },
    },
    {
        label    = 'Bierkasten halten',
        category = 'prop',
        type     = 'prop',
        dict     = 'anim@heists@fleeca@security_guard',
        anim     = 'idle',
        flag     = 49,
        prop = {
            model  = 'prop_beer_bottle',
            bone   = 60309,
            offset = vec3(0.0, 0.0, 0.0),
            rot    = vec3(0.0, 0.0, 0.0),
        },
    },
    {
        label    = 'Kaffee trinken',
        category = 'prop',
        type     = 'prop',
        dict     = 'amb@world_human_drinking@coffee@male@idle_a',
        anim     = 'idle_a',
        flag     = 49,
        prop = {
            model  = 'prop_take_away_cup',
            bone   = 60309,
            offset = vec3(0.0, 0.0, 0.0),
            rot    = vec3(0.0, 0.0, 0.0),
        },
    },
    {
        label    = 'Zeitung lesen',
        category = 'prop',
        type     = 'prop',
        dict     = 'amb@world_human_seat_bench@male@idle_a',
        anim     = 'idle_a',
        flag     = 49,
        prop = {
            model  = 'prop_newspaper_01',
            bone   = 60309,
            offset = vec3(0.0, 0.0, 0.0),
            rot    = vec3(0.0, 0.0, 0.0),
        },
    },
    -- ── Duo ──
    {
        label    = 'Händeschütteln',
        category = 'couple',
        type     = 'anim',
        dict     = 'mp_common_heist_str',
        anim     = 'meet_exit',
        flag     = 0,
    },
    {
        label    = 'Umarmen',
        category = 'couple',
        type     = 'anim',
        dict     = 'mp_common_heist_str',
        anim     = 'meet_loop_a',
        flag     = 49,
    },
}

-- ─────────────────────────────────────────────────
-- Sitz-Datenbank
-- ─────────────────────────────────────────────────
--[[
    Wie neue Sitzmodelle ergänzt werden:
    ─────────────────────────────────────
    1. Modellnamen herausfinden (z.B. mit MenyooSP, CodeWalker oder /seatoffset)
    2. Eintrag in Config.Seats ergänzen:

       Config.Seats[`dein_modellname`] = {
           type     = "scenario",        -- oder "anim"
           scenario = "SCENARIO_NAME",   -- z.B. PROP_HUMAN_SEAT_CHAIR
           offset   = vec3(x, y, z),     -- Position relativ zum Objekt
           rotation = 180.0,             -- Drehung in Grad (meist 180°)
           label    = "Sitzen",          -- ox_target Label
       }

    3. /seatoffset-Befehl im Spiel nutzen (Config.DevMode = true):
       - Zeigt aktuelle Offset-Werte an
       - Offsets live per /seatoffset x y z anpassen
       - Wert kopieren und in Config eintragen

    Hinweis: Offset z = 0.45 funktioniert für die meisten Standard-Stühle.
    Sofas brauchen oft z ≈ 0.35–0.45, Barhocker z ≈ 0.65–0.80.
]]

Config.Seats = {
    -- ── Standardstühle ──
    [`prop_chair_01a`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_CHAIR',
        offset   = vec3(0.0, 0.0, 0.45),
        rotation = 180.0,
        label    = 'Sitzen',
    },
    [`prop_chair_02`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_CHAIR',
        offset   = vec3(0.0, 0.0, 0.45),
        rotation = 180.0,
        label    = 'Sitzen',
    },
    [`prop_chair_03`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_CHAIR',
        offset   = vec3(0.0, 0.0, 0.45),
        rotation = 180.0,
        label    = 'Sitzen',
    },
    [`prop_chair_04`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_CHAIR',
        offset   = vec3(0.0, 0.0, 0.45),
        rotation = 180.0,
        label    = 'Sitzen',
    },
    [`prop_chair_05`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_CHAIR',
        offset   = vec3(0.0, 0.0, 0.45),
        rotation = 180.0,
        label    = 'Sitzen',
    },
    [`prop_chair_06`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_CHAIR',
        offset   = vec3(0.0, 0.0, 0.45),
        rotation = 180.0,
        label    = 'Sitzen',
    },
    [`prop_chair_07`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_CHAIR',
        offset   = vec3(0.0, 0.0, 0.45),
        rotation = 180.0,
        label    = 'Sitzen',
    },
    [`prop_chair_08`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_CHAIR',
        offset   = vec3(0.0, 0.0, 0.45),
        rotation = 180.0,
        label    = 'Sitzen',
    },
    [`prop_chair_09`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_CHAIR',
        offset   = vec3(0.0, 0.0, 0.45),
        rotation = 180.0,
        label    = 'Sitzen',
    },
    [`prop_chair_10`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_CHAIR',
        offset   = vec3(0.0, 0.0, 0.45),
        rotation = 180.0,
        label    = 'Sitzen',
    },
    -- ── Bürostühle ──
    [`prop_off_chair_01`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_CHAIR',
        offset   = vec3(0.0, 0.0, 0.50),
        rotation = 180.0,
        label    = 'Sitzen',
    },
    [`prop_off_chair_02`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_CHAIR',
        offset   = vec3(0.0, 0.0, 0.50),
        rotation = 180.0,
        label    = 'Sitzen',
    },
    -- ── Bänke ──
    [`prop_bench_01a`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_BENCH',
        offset   = vec3(0.0, 0.0, 0.50),
        rotation = 180.0,
        label    = 'Hinsetzen',
    },
    [`prop_bench_02`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_BENCH',
        offset   = vec3(0.0, 0.0, 0.50),
        rotation = 180.0,
        label    = 'Hinsetzen',
    },
    [`prop_bench_03`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_BENCH',
        offset   = vec3(0.0, 0.0, 0.50),
        rotation = 180.0,
        label    = 'Hinsetzen',
    },
    [`prop_bench_04`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_BENCH',
        offset   = vec3(0.0, 0.0, 0.50),
        rotation = 180.0,
        label    = 'Hinsetzen',
    },
    [`prop_bench_05`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_BENCH',
        offset   = vec3(0.0, 0.0, 0.50),
        rotation = 180.0,
        label    = 'Hinsetzen',
    },
    -- ── Sofas / Sessel ──
    [`v_res_tre_sofa`] = {
        type     = 'anim',
        animDict = 'timetable@ron@ig_5_p3',
        animName = 'ig_5_p3_base',
        animFlag = 49,
        offset   = vec3(0.0, 0.0, 0.35),
        rotation = 180.0,
        label    = 'Hinsetzen',
    },
    [`v_res_tre_sofa2`] = {
        type     = 'anim',
        animDict = 'timetable@ron@ig_5_p3',
        animName = 'ig_5_p3_base',
        animFlag = 49,
        offset   = vec3(0.0, 0.0, 0.35),
        rotation = 180.0,
        label    = 'Hinsetzen',
    },
    [`prop_couch_01`] = {
        type     = 'anim',
        animDict = 'timetable@ron@ig_5_p3',
        animName = 'ig_5_p3_base',
        animFlag = 49,
        offset   = vec3(0.0, 0.0, 0.35),
        rotation = 180.0,
        label    = 'Hinsetzen',
    },
    [`prop_couch_02`] = {
        type     = 'anim',
        animDict = 'timetable@ron@ig_5_p3',
        animName = 'ig_5_p3_base',
        animFlag = 49,
        offset   = vec3(0.0, 0.0, 0.35),
        rotation = 180.0,
        label    = 'Hinsetzen',
    },
    [`prop_couch_03`] = {
        type     = 'anim',
        animDict = 'timetable@ron@ig_5_p3',
        animName = 'ig_5_p3_base',
        animFlag = 49,
        offset   = vec3(0.0, 0.0, 0.35),
        rotation = 180.0,
        label    = 'Hinsetzen',
    },
    [`prop_couch_leath_01`] = {
        type     = 'anim',
        animDict = 'timetable@ron@ig_5_p3',
        animName = 'ig_5_p3_base',
        animFlag = 49,
        offset   = vec3(0.0, 0.0, 0.40),
        rotation = 180.0,
        label    = 'Hinsetzen',
    },
    [`prop_couch_leath_02`] = {
        type     = 'anim',
        animDict = 'timetable@ron@ig_5_p3',
        animName = 'ig_5_p3_base',
        animFlag = 49,
        offset   = vec3(0.0, 0.0, 0.40),
        rotation = 180.0,
        label    = 'Hinsetzen',
    },
    -- ── Barhocker ──
    [`prop_barstool_01`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_CHAIR',
        offset   = vec3(0.0, 0.0, 0.75),
        rotation = 180.0,
        label    = 'Draufsetzen',
    },
    [`prop_barstool_02`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_CHAIR',
        offset   = vec3(0.0, 0.0, 0.75),
        rotation = 180.0,
        label    = 'Draufsetzen',
    },
    -- ── Klapp-/Plastikstühle ──
    [`prop_plastic_chair_01`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_CHAIR',
        offset   = vec3(0.0, 0.0, 0.45),
        rotation = 180.0,
        label    = 'Sitzen',
    },
    -- ── Auto-Sitze (für Szenen) ──
    [`prop_drinkcan_01`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_CHAIR',
        offset   = vec3(0.0, 0.0, 0.45),
        rotation = 180.0,
        label    = 'Sitzen',
    },
    -- ── Innenraum-Stühle (v_) ──
    [`v_res_p_sofa1`] = {
        type     = 'anim',
        animDict = 'timetable@ron@ig_5_p3',
        animName = 'ig_5_p3_base',
        animFlag = 49,
        offset   = vec3(0.0, 0.0, 0.40),
        rotation = 180.0,
        label    = 'Hinsetzen',
    },
    [`v_res_p_sofa2`] = {
        type     = 'anim',
        animDict = 'timetable@ron@ig_5_p3',
        animName = 'ig_5_p3_base',
        animFlag = 49,
        offset   = vec3(0.0, 0.0, 0.40),
        rotation = 180.0,
        label    = 'Hinsetzen',
    },
    [`v_res_p_sofa3`] = {
        type     = 'anim',
        animDict = 'timetable@ron@ig_5_p3',
        animName = 'ig_5_p3_base',
        animFlag = 49,
        offset   = vec3(0.0, 0.0, 0.40),
        rotation = 180.0,
        label    = 'Hinsetzen',
    },
    -- ── Polizeistühle ──
    [`p_int_s_chair_01`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_CHAIR',
        offset   = vec3(0.0, 0.0, 0.45),
        rotation = 180.0,
        label    = 'Sitzen',
    },
    [`p_int_chair_01`] = {
        type     = 'scenario',
        scenario = 'PROP_HUMAN_SEAT_CHAIR',
        offset   = vec3(0.0, 0.0, 0.45),
        rotation = 180.0,
        label    = 'Sitzen',
    },
}

-- ─────────────────────────────────────────────────
-- Lokalisierung
-- ─────────────────────────────────────────────────
Config.Locales = {
    de = {
        menu_title       = 'Animationen',
        search_hint      = 'Suchen…',
        no_results       = 'Keine Emotes gefunden',
        favorites_empty  = 'Noch keine Favoriten gespeichert',
        sit_hint         = '[%s] Sitzen · [%s] Aufstehen',
        not_near_seat    = 'Du bist nicht in der Nähe eines Sitzplatzes.',
        already_sitting  = 'Du sitzt bereits.',
        emote_started    = 'Emote gestartet.',
        emote_stopped    = 'Emote gestoppt.',
        add_favorite     = 'Zu Favoriten hinzufügen',
        rem_favorite     = 'Aus Favoriten entfernen',
        seat_label       = 'Sitzen',
        stand_up         = 'Aufstehen',
    },
    en = {
        menu_title       = 'Animations',
        search_hint      = 'Search…',
        no_results       = 'No emotes found',
        favorites_empty  = 'No favorites saved yet',
        sit_hint         = '[%s] Sit · [%s] Stand up',
        not_near_seat    = 'You are not near a seat.',
        already_sitting  = 'You are already sitting.',
        emote_started    = 'Emote started.',
        emote_stopped    = 'Emote stopped.',
        add_favorite     = 'Add to favorites',
        rem_favorite     = 'Remove from favorites',
        seat_label       = 'Sit',
        stand_up         = 'Stand up',
    },
}

-- Helper: aktuelle Übersetzung abrufen
function _T(key)
    local lang = Config.Locales[Config.Locale] or Config.Locales['de']
    return lang[key] or key
end
