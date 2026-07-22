--[[
    MTJ Animation System – client/emotes.lua
    Emote abspielen, stoppen, Prop-Verwaltung
]]

-- ─────────────────────────────────────────────────
-- Emote abspielen
-- ─────────────────────────────────────────────────
function PlayEmote(emote)
    if not emote then return end

    -- Sitzen beenden wenn aktiv
    if GetIsSitting() then
        StandUp()
        Wait(400)
    end

    -- Laufendes Emote stoppen
    if GetIsPlayingEmote() then
        StopCurrentEmote()
        Wait(100)
    end

    local ped = PlayerPedId()

    if emote.type == 'scenario' then
        PlayScenarioEmote(ped, emote)
    elseif emote.type == 'anim' then
        PlayAnimEmote(ped, emote)
    elseif emote.type == 'prop' then
        PlayPropEmote(ped, emote)    end

    SetIsPlayingEmote(true)

    -- Automatisch stoppen wenn duration gesetzt
    if emote.duration and emote.duration > 0 then
        SetTimeout(emote.duration, function()
            StopCurrentEmote()
        end)
    end
end

-- ─────────────────────────────────────────────────
-- Szenario-Animation
-- ─────────────────────────────────────────────────
function PlayScenarioEmote(ped, emote)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    TaskStartScenarioAtPosition(
        ped,
        emote.scenario,
        coords.x, coords.y, coords.z,
        heading,
        0, true, true
    )
end

-- ─────────────────────────────────────────────────
-- Normale Animation
-- ─────────────────────────────────────────────────
function PlayAnimEmote(ped, emote)
    local dict    = emote.dict
    local anim    = emote.anim
    local flag    = emote.flag or 49
    local timeout = Config.AnimLoadTimeout or 5000

    if not dict or not anim then return end

    RequestAnimDict(dict)
    local elapsed = 0
    while not HasAnimDictLoaded(dict) do
        Wait(10)
        elapsed = elapsed + 10
        if elapsed > timeout then
            if Config.DevMode then
                print('[MTJAnim] Anim-Dict Timeout: ' .. dict)
            end
            return
        end
    end

    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, flag, 0, false, false, false)
end

-- ─────────────────────────────────────────────────
-- Prop-Animation
-- ─────────────────────────────────────────────────
function PlayPropEmote(ped, emote)
    -- Erst Prop spawnen
    local propData = emote.prop
    if not propData then
        PlayAnimEmote(ped, emote)
        return
    end

    local model = type(propData.model) == 'string'
        and joaat(propData.model)
        or propData.model

    RequestModel(model)
    local elapsed = 0
    local timeout = Config.AnimLoadTimeout or 5000
    while not HasModelLoaded(model) do
        Wait(10)
        elapsed = elapsed + 10
        if elapsed > timeout then
            if Config.DevMode then
                print('[MTJAnim] Prop-Modell Timeout: ' .. tostring(propData.model))
            end
            return
        end
    end

    local prop = CreateAndAttachProp(
        model,
        propData.bone   or 60309,
        ped,
        propData.offset or vec3(0, 0, 0),
        propData.rot    or vec3(0, 0, 0),
        true
    )

    SetCurrentProp(prop)
    PlayAnimEmote(ped, emote)
end

-- Prop am Ped-Bone erzeugen und anheften
function CreateAndAttachProp(model, bone, ped, offset, rot, collision)
    local prop = CreateObject(model, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(
        prop, ped,
        GetPedBoneIndex(ped, bone),
        offset.x, offset.y, offset.z,
        rot.x,    rot.y,    rot.z,
        true, true, false, true, 1, true
    )
    SetEntityCollision(prop, collision, true)
    return prop
end

-- ─────────────────────────────────────────────────
-- Emote stoppen
-- ─────────────────────────────────────────────────
function StopCurrentEmote()
    if not GetIsPlayingEmote() then return end

    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)
    SetIsPlayingEmote(false)

    -- Prop entfernen
    local prop = GetCurrentProp()
    if prop and DoesEntityExist(prop) then
        Wait(Config.PropCleanupDelay or 500)
        DetachEntity(prop, true, true)
        DeleteEntity(prop)
        SetCurrentProp(nil)
    end
end
