--[[
    MTJ Animation System – server/main.lua
    Favoriten-Persistenz – Identifikation via License/Steam-ID
    Für echte DB-Persistenz: oxmysql / ghmattimysql anpassen
]]

local playerFavorites = {}

-- Persistente Spieler-ID (License > Steam > Server-ID als Fallback)
local function GetPlayerKey(src)
    local identifiers = GetPlayerIdentifiers(src)
    for _, id in ipairs(identifiers) do
        if string.sub(id, 1, 8) == 'license:' then return id end
    end
    for _, id in ipairs(identifiers) do
        if string.sub(id, 1, 6) == 'steam:' then return id end
    end
    -- Letzter Fallback: Server-ID (nicht persistent über Reconnects)
    return tostring(src)
end

-- ─────────────────────────────────────────────────
-- Favoriten laden
-- ─────────────────────────────────────────────────
RegisterNetEvent('mtjanim:loadFavorites', function()
    local src = source
    local key = GetPlayerKey(src)
    local stored = playerFavorites[key] or {}
    TriggerClientEvent('mtjanim:receiveFavorites', src, stored)
end)

-- ─────────────────────────────────────────────────
-- Favoriten speichern
-- ─────────────────────────────────────────────────
RegisterNetEvent('mtjanim:saveFavorites', function(data)
    local src = source
    if type(data) ~= 'table' then return end

    -- Sicherheitscheck: Max. Favoriten begrenzen
    local maxFav = Config and Config.MaxFavorites or 16
    local cleaned = {}
    local count   = 0
    for _, v in ipairs(data) do
        if count >= maxFav then break end
        -- Nur positive Ganzzahlen (Emote-Indizes) speichern
        if type(v) == 'number' and math.floor(v) == v and v > 0 then
            table.insert(cleaned, v)
            count = count + 1
        end
    end

    local key = GetPlayerKey(src)
    playerFavorites[key] = cleaned

    -- Optional: In Datenbank schreiben
    -- MySQL.update('UPDATE users SET emote_favorites = ? WHERE identifier = ?',
    --     { json.encode(cleaned), key })
end)

-- ─────────────────────────────────────────────────
-- Cleanup beim Disconnect (nur temporärer In-Memory-Cache)
-- Die Daten bleiben über key erhalten wenn DB genutzt wird
-- ─────────────────────────────────────────────────
AddEventHandler('playerDropped', function()
    -- In-Memory bleibt erhalten für Reconnects innerhalb der Session
    -- playerFavorites[GetPlayerKey(source)] = nil  -- optional leeren
end)
