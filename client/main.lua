--[[
    MTJ Animation System – client/main.lua
    Key-Bindings, Haupt-Loop, ox_target-Integration
]]

local isMenuOpen    = false
local isSitting     = false
local isPlayingEmote = false
local currentProp   = nil
local favorites     = {}
local hasOxTarget   = false

-- ─────────────────────────────────────────────────
-- Startup
-- ─────────────────────────────────────────────────
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    hasOxTarget = GetResourceState('ox_target') == 'started'

    -- Favoriten vom Server laden
    TriggerServerEvent('mtjanim:loadFavorites')

    -- ox_target Seats registrieren (falls aktiv)
    if hasOxTarget and Config.UseOxTarget then
        RegisterSeatTargets()
    end

    if Config.DevMode then
        print('[MTJAnim] Ressource gestartet | ox_target: ' .. tostring(hasOxTarget))
    end
end)

-- ─────────────────────────────────────────────────
-- Key-Bindings
-- ─────────────────────────────────────────────────
RegisterCommand('emotes', function()
    ToggleMenu()
end, false)

RegisterKeyMapping('emotes', 'Emote-Menü öffnen', 'keyboard', Config.MenuKey)

-- Sitzen (Proximity-Fallback wenn kein ox_target)
RegisterCommand('sit', function()
    if isSitting then
        StandUp()
    else
        TriggerEvent('mtjanim:sitOnNearestSeat')
    end
end, false)

RegisterKeyMapping('sit', 'Sitzen (nächster Stuhl)', 'keyboard', Config.SeatKey)

-- Emote / Sitzen beenden
RegisterCommand('stopemote', function()
    if isSitting then
        StandUp()
    elseif isPlayingEmote then
        StopCurrentEmote()
    end
end, false)

RegisterKeyMapping('stopemote', 'Emote / Sitzen beenden', 'keyboard', Config.ExitKey)

-- ─────────────────────────────────────────────────
-- NUI-Callbacks
-- ─────────────────────────────────────────────────
RegisterNUICallback('close', function(_, cb)
    CloseMenu()
    cb({})
end)

RegisterNUICallback('playEmote', function(data, cb)
    local idx = tonumber(data.index)
    if idx and Config.Emotes[idx] then
        PlayEmote(Config.Emotes[idx])
    end
    cb({})
end)

RegisterNUICallback('stopEmote', function(_, cb)
    StopCurrentEmote()
    cb({})
end)

RegisterNUICallback('saveFavorites', function(data, cb)
    favorites = data.favorites or {}
    TriggerServerEvent('mtjanim:saveFavorites', favorites)
    cb({})
end)

RegisterNUICallback('getFavorites', function(_, cb)
    cb({ favorites = favorites })
end)

-- ─────────────────────────────────────────────────
-- Menu öffnen / schließen
-- ─────────────────────────────────────────────────
function ToggleMenu()
    if isMenuOpen then
        CloseMenu()
    else
        OpenMenu()
    end
end

function OpenMenu()
    isMenuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action    = 'openMenu',
        emotes    = Config.Emotes,
        categories = Config.Categories,
        favorites  = favorites,
        locale    = Config.Locales[Config.Locale] or Config.Locales['de'],
    })
end

function CloseMenu()
    isMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeMenu' })
end

-- ─────────────────────────────────────────────────
-- Server-Events
-- ─────────────────────────────────────────────────
RegisterNetEvent('mtjanim:receiveFavorites', function(data)
    favorites = data or {}
    if isMenuOpen then
        SendNUIMessage({ action = 'updateFavorites', favorites = favorites })
    end
end)

-- ─────────────────────────────────────────────────
-- Getter für andere Client-Module
-- ─────────────────────────────────────────────────
function GetIsSitting()     return isSitting     end
function GetIsPlayingEmote() return isPlayingEmote end
function GetCurrentProp()   return currentProp   end
function GetFavorites()     return favorites      end
function HasOxTarget()      return hasOxTarget    end

function SetIsSitting(val)      isSitting     = val  end
function SetIsPlayingEmote(val) isPlayingEmote = val  end
function SetCurrentProp(val)    currentProp   = val  end
