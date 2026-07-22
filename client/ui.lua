--[[
    MTJ Animation System – client/ui.lua
    Benachrichtigungen und UI-Hilfsfunktionen
]]

-- ─────────────────────────────────────────────────
-- Benachrichtigungen
-- ─────────────────────────────────────────────────
AddEventHandler('mtjanim:notification', function(msg, msgType)
    -- ox_lib falls vorhanden
    if GetResourceState('ox_lib') == 'started' then
        lib.notify({
            title       = 'Animationen',
            description = msg,
            type        = msgType or 'info',
            duration    = 4000,
        })
        return
    end

    -- ESX-Fallback
    if GetResourceState('es_extended') == 'started' then
        local ESX = exports['es_extended']:getSharedObject()
        if ESX and ESX.ShowNotification then
            ESX.ShowNotification(msg)
            return
        end
    end

    -- QBCore-Fallback
    if GetResourceState('qb-core') == 'started' then
        local QBCore = exports['qb-core']:GetCoreObject()
        if QBCore and QBCore.Functions and QBCore.Functions.Notify then
            QBCore.Functions.Notify(msg, msgType or 'primary')
            return
        end
    end

    -- GTA-Standard-Benachrichtigung
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, true)
end)

-- ─────────────────────────────────────────────────
-- NUI-Callback für Escape (ausgelöst vom JS-Keyboard-Handler)
-- Das Menü schließen wird primär im JS über das keydown-Event gehandelt.
-- Dieser Callback erlaubt es Lua, den Fokus korrekt zurückzusetzen.
-- ─────────────────────────────────────────────────
RegisterNUICallback('close', function(_, cb)
    -- Wird bereits in main.lua registriert; hier nur Schutz falls
    -- ui.lua vor main.lua geladen wird.
    cb({})
end)
