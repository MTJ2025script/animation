--[[
    MTJ Animation System – client/seats.lua
    Sitzsystem: Proximity-Erkennung + ox_target-Integration
]]

-- ─────────────────────────────────────────────────
-- ox_target: Seats registrieren
-- ─────────────────────────────────────────────────
function RegisterSeatTargets()
    -- Alle Sitzmodelle als ox_target-Optionen registrieren
    for model, seatData in pairs(Config.Seats) do
        exports.ox_target:addModel(model, {
            {
                name     = 'mtjanim_sit_' .. tostring(model),
                icon     = 'fas fa-chair',
                label    = seatData.label or _T('seat_label'),
                onSelect = function(targetData)
                    -- targetData.entity = das angeklickte Objekt
                    local entity = targetData and targetData.entity
                    if entity and DoesEntityExist(entity) then
                        SitOnObject(entity, seatData)
                    end
                end,
                distance = Config.OxTargetDist or 2.5,
                -- Nur anzeigen wenn nicht bereits sitzend
                canInteract = function()
                    return not GetIsSitting()
                end,
            },
        })
    end

    if Config.DevMode then
        print('[MTJAnim] ox_target: ' .. tostring(TableLength(Config.Seats)) .. ' Sitzmodelle registriert')
    end
end

-- ─────────────────────────────────────────────────
-- Proximity-Event (Taste G, Fallback wenn kein ox_target)
-- ─────────────────────────────────────────────────
AddEventHandler('mtjanim:sitOnNearestSeat', function()
    if GetIsSitting() then
        StandUp()
        return
    end

    local ped    = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local radius = Config.SearchRadius or 2.0

    local closestObj  = nil
    local closestDist = radius
    local closestSeat = nil

    -- Alle konfigurierten Modelle prüfen
    for model, seatData in pairs(Config.Seats) do
        local obj = GetClosestObjectOfType(
            coords.x, coords.y, coords.z,
            radius, model, false, false, false
        )
        if obj ~= 0 then
            local objCoords = GetEntityCoords(obj)
            local dist = #(coords - objCoords)
            if dist < closestDist then
                closestDist = dist
                closestObj  = obj
                closestSeat = seatData
            end
        end
    end

    if closestObj and closestSeat then
        SitOnObject(closestObj, closestSeat)
    elseif Config.FallbackSeat then
        -- Fallback: einfach hinsitzen ohne Objekt-Referenz
        SitFallback()
    else
        -- Kein Sitzplatz gefunden
        TriggerEvent('mtjanim:notification', _T('not_near_seat'), 'error')
    end
end)

-- ─────────────────────────────────────────────────
-- Auf Objekt setzen (Kern-Funktion)
-- ─────────────────────────────────────────────────
function SitOnObject(obj, seatData)
    if GetIsSitting() then return end

    local ped       = PlayerPedId()
    local objCoords = GetEntityCoords(obj)
    local objFwd    = GetEntityForwardVector(obj)
    local objHead   = GetEntityHeading(obj)
    local offset    = seatData.offset   or vec3(0.0, 0.0, 0.45)
    local rotation  = seatData.rotation or 180.0

    -- Sitzposition berechnen (relativ zur Objekt-Vorwärtsrichtung)
    local sitPos = vec3(
        objCoords.x + (objFwd.x * offset.y) + (-objFwd.y * offset.x),
        objCoords.y + (objFwd.y * offset.y) + ( objFwd.x * offset.x),
        objCoords.z + offset.z
    )
    local sitHead = (objHead + rotation) % 360.0

    -- Ped positionieren
    SetEntityCoords(ped, sitPos.x, sitPos.y, sitPos.z, false, false, false, false)
    SetEntityHeading(ped, sitHead)
    FreezeEntityPosition(ped, false)

    -- Laufendes Emote stoppen
    if GetIsPlayingEmote() then
        StopCurrentEmote()
        Wait(100)
    end

    -- Animation abspielen
    if seatData.type == 'scenario' then
        TaskStartScenarioAtPosition(
            ped,
            seatData.scenario,
            sitPos.x, sitPos.y, sitPos.z,
            sitHead,
            0, true, true
        )
    elseif seatData.type == 'anim' then
        local dict = seatData.animDict
        local anim = seatData.animName
        local flag = seatData.animFlag or 49

        RequestAnimDict(dict)
        local elapsed = 0
        local timeout = Config.AnimLoadTimeout or 5000
        while not HasAnimDictLoaded(dict) do
            Wait(10)
            elapsed = elapsed + 10
            if elapsed > timeout then break end
        end

        if HasAnimDictLoaded(dict) then
            TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, flag, 0, false, false, false)
        end
    end

    SetIsSitting(true)

    -- Beim Aufstehen ox_target Stand-Up-Option hinzufügen
    if HasOxTarget() and Config.UseOxTarget then
        exports.ox_target:addEntity(obj, {
            {
                name     = 'mtjanim_standup',
                icon     = 'fas fa-person-walking',
                label    = _T('stand_up'),
                onSelect = function()
                    StandUp()
                end,
                distance = Config.OxTargetDist or 2.5,
                canInteract = function()
                    return GetIsSitting()
                end,
            },
        })
    end

    -- Hint anzeigen
    TriggerEvent('mtjanim:notification',
        string.format(_T('sit_hint'), Config.SeatKey, Config.ExitKey),
        'info'
    )

    if Config.DevMode then
        print(string.format(
            '[MTJAnim][Seat] Sitzend bei %.2f / %.2f / %.2f | Typ: %s',
            sitPos.x, sitPos.y, sitPos.z, seatData.type or 'unknown'
        ))
    end
end

-- ─────────────────────────────────────────────────
-- Fallback-Sitzen (ohne konkretes Objekt)
-- ─────────────────────────────────────────────────
function SitFallback()
    local ped  = PlayerPedId()
    local pos  = GetEntityCoords(ped)
    local head = GetEntityHeading(ped)

    if GetIsPlayingEmote() then
        StopCurrentEmote()
        Wait(100)
    end

    TaskStartScenarioAtPosition(
        ped,
        Config.FallbackScenario or 'PROP_HUMAN_SEAT_CHAIR',
        pos.x, pos.y, pos.z,
        head,
        0, true, true
    )

    SetIsSitting(true)

    TriggerEvent('mtjanim:notification',
        string.format(_T('sit_hint'), Config.SeatKey, Config.ExitKey),
        'info'
    )
end

-- ─────────────────────────────────────────────────
-- Aufstehen
-- ─────────────────────────────────────────────────
function StandUp()
    if not GetIsSitting() then return end

    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)
    FreezeEntityPosition(ped, false)
    SetIsSitting(false)

    if Config.DevMode then
        print('[MTJAnim][Seat] Aufgestanden')
    end
end

-- ─────────────────────────────────────────────────
-- Dev: Offset-Editor
-- ─────────────────────────────────────────────────
if Config.DevMode then
    local devOffset = vec3(0.0, 0.0, 0.45)
    local devObj    = nil

    RegisterCommand('seatoffset', function(_, args)
        if #args >= 3 then
            devOffset = vec3(
                tonumber(args[1]) or 0.0,
                tonumber(args[2]) or 0.0,
                tonumber(args[3]) or 0.45
            )
            print(string.format(
                '[MTJAnim][DevOffset] Neuer Offset: %.2f / %.2f / %.2f',
                devOffset.x, devOffset.y, devOffset.z
            ))
        else
            print('[MTJAnim][DevOffset] Aktueller Offset: ' ..
                devOffset.x .. ' / ' .. devOffset.y .. ' / ' .. devOffset.z)
            print('Nutzung: /seatoffset <x> <y> <z>')
        end
    end, false)

    RegisterCommand('seattest', function()
        local ped    = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for model, data in pairs(Config.Seats) do
            local obj = GetClosestObjectOfType(
                coords.x, coords.y, coords.z,
                3.0, model, false, false, false
            )
            if obj ~= 0 then
                devObj = obj
                local testData = {
                    type     = data.type,
                    scenario = data.scenario,
                    animDict = data.animDict,
                    animName = data.animName,
                    animFlag = data.animFlag,
                    offset   = devOffset,
                    rotation = data.rotation,
                    label    = data.label,
                }
                print('[MTJAnim][DevTest] Teste Modell: ' .. tostring(model))
                SitOnObject(obj, testData)
                return
            end
        end
        print('[MTJAnim][DevTest] Kein bekanntes Sitzobjekt in der Nähe.')
    end, false)
end

-- ─────────────────────────────────────────────────
-- Hilfsfunktion
-- ─────────────────────────────────────────────────
function TableLength(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end
