--[[
    MTJ Animation System – server/main.lua
    Favoriten-Persistenz (einfache In-Memory-Lösung)
    Für echte DB-Persistenz: oxmysql / ghmattimysql anpassen
]]

local playerFavorites = {}

-- ─────────────────────────────────────────────────
-- Favoriten laden
-- ─────────────────────────────────────────────────
RegisterNetEvent('mtjanim:loadFavorites', function()
    local src = source
    local stored = playerFavorites[src] or {}
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
        -- Nur Zahlen (Emote-Indizes) speichern
        if type(v) == 'number' and v > 0 then
            table.insert(cleaned, v)
            count = count + 1
        end
    end

    playerFavorites[src] = cleaned

    -- Optional: In Datenbank schreiben
    -- MySQL.update('UPDATE users SET emote_favorites = ? WHERE identifier = ?',
    --     { json.encode(cleaned), GetPlayerIdentifier(src, 0) })
end)

-- ─────────────────────────────────────────────────
-- Cleanup beim Disconnect
-- ─────────────────────────────────────────────────
AddEventHandler('playerDropped', function()
    local src = source
    playerFavorites[src] = nil
end)
