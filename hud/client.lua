local micModes = {"whisper", "normal", "shouting"}
local currentMicModeIndex = 2

local currentHealth = 100
local currentArmor = 0
local currentHunger = 100
local currentThirst = 100
local currentStamina = 100
local currentOxygen = 100
local forceShowOxygen = false
local staminaRestored = false
local wasSprinting = false
local cachedIsUnderwater = false
local staminaFrozen = false
local frozenStaminaValue = 100
local staminaFreezeTime = 0

local lastStatusUpdate = 0
local lastLocationUpdate = 0
local lastUnderwaterCheck = 0
local statusUpdateInterval = 1000
local locationUpdateInterval = 500
local underwaterCheckInterval = 300

local cachedStreetName = ""
local cachedZoneName = ""
local cachedDirection = ""
local cachedCompass = ""
local prevHealth = 100
local prevArmor = 0
local prevHunger = 100
local prevThirst = 100
local prevStamina = 100
local prevOxygen = 100
local prevIsUnderwater = false
local prevIsMicActive = false
local prevMicMode = "normal"
local prevIsInVehicle = false
local prevStreetName = ""
local prevZoneName = ""
local prevDirection = ""
local prevCompass = ""
local prevIsPauseMenuActive = false
local lastArmorUpdate = 0
local lastArmorValue = 0
local updateInterval = 1000
local isCharacterChosen = false 
local hudScale = 1.0


-- ====== MINIMAP ======
local MinimapScaleform = {
    scaleform = nil,
}

function SetMinimapPosition()
    local minimapPosX = 0.025
    local minimapPosY = -0.022
    SetMinimapComponentPosition("minimap", "L", "B", minimapPosX, minimapPosY, 0.150, 0.188888)
    SetMinimapComponentPosition("minimap_mask", "L", "B", minimapPosX + 0.025, 0.050, 0.111, 0.159)
    SetMinimapComponentPosition("minimap_blur", "L", "B", minimapPosX - 0.03, -0.0005, 0.266, 0.237)
end

Citizen.CreateThread(function()
    Wait(2000)
    MinimapScaleform.scaleform = RequestScaleformMovie("minimap")
    RequestStreamedTextureDict("squaremap", false)
    while not HasStreamedTextureDictLoaded("squaremap") do
        Wait(100)
    end
    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "squaremap", "radarmasksm")
    
    SetRadarBigmapEnabled(true, false)
    Wait(100)
    SetRadarBigmapEnabled(false, false)
    SetMinimapPosition()
    DisplayRadar(true)
    
    while true do
        Wait(100)
        BeginScaleformMovieMethod(MinimapScaleform.scaleform, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)

CreateThread(function()
    while true do
        Wait(300)
        if IsPedInAnyVehicle(PlayerPedId()) then
            DisplayRadar(true)
        else
            DisplayRadar(false)
        end
    end
end)

-- ========== DISPLAY HUD AFTER CHARACTER SELECTION==========

RegisterNetEvent('esx:playerLoaded') 
AddEventHandler('esx:playerLoaded', function()
    isCharacterChosen = true
    Wait(1000)
    SendNUIMessage({type = "toggleHUDIcons", visible = true}) 
end)

RegisterNetEvent('esx_multicharacter:characterChosen')
 AddEventHandler('esx_multicharacter:characterChosen', function()
     isCharacterChosen = true
     Wait(1000)
     SendNUIMessage({type = "toggleHUDIcons", visible = true})
 end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    Wait(2000)
    SetRadarBigmapEnabled(true, false)
    Wait(100)
    SetRadarBigmapEnabled(false, false)
    SetMinimapPosition()
    DisplayRadar(true)
    TriggerServerEvent('hud:server:LoadArmor')
    SendNUIMessage({type = "toggleHUDIcons", visible = false}) 
end)

-- ====== ARMOR SAVE DATABASE  ======
AddEventHandler('playerSpawned', function()
    Wait(1000)
    TriggerServerEvent('hud:server:LoadArmor')
    SetMinimapPosition()
end)

CreateThread(function()
    while true do
        local currentTime = GetGameTimer()
        if currentTime - lastArmorUpdate >= updateInterval then
            local playerPed = PlayerPedId()
            local currentArmor = GetPedArmour(playerPed)
            if currentArmor ~= lastArmorValue then
                TriggerServerEvent('hud:server:UpdateArmor', currentArmor)
                lastArmorValue = currentArmor
            end
            lastArmorUpdate = currentTime
        end
        Wait(500) 
    end
end)

RegisterNetEvent('hud:client:ArmorUpdated')
AddEventHandler('hud:client:ArmorUpdated', function(newArmor) end)

RegisterNetEvent('hud:client:UpdateArmor')
AddEventHandler('hud:client:UpdateArmor', function(armorValue)
    local playerPed = PlayerPedId()
    SetPedArmour(playerPed, armorValue)
    currentArmor = armorValue
end)

-- ====== GET DIRECTION ======
local function getDirection()
    local angle = GetEntityHeading(PlayerPedId())
    local direction = ''

    if angle >= 0 and angle < 22.5 then
        direction = 'North'
    elseif angle >= 22.5 and angle < 67.5 then
        direction = 'Northeast'
    elseif angle >= 67.5 and angle < 112.5 then
        direction = 'East'
    elseif angle >= 112.5 and angle < 157.5 then
        direction = 'Southeast'
    elseif angle >= 157.5 and angle < 202.5 then
        direction = 'South'
    elseif angle >= 202.5 and angle < 247.5 then
        direction = 'Southwest'
    elseif angle >= 247.5 and angle < 292.5 then
        direction = 'West'
    elseif angle >= 292.5 and angle < 337.5 then
        direction = 'Northwest'
    else
        direction = 'North'
    end

    return direction
end

-- ====== COMPASS  ======
local function getCompassDirection()
    local angle = GetEntityHeading(PlayerPedId())
    local compass = ''

    if angle >= 315 or angle < 45 then
        compass = 'N'
    elseif angle >= 45 and angle < 135 then
        compass = 'E'
    elseif angle >= 135 and angle < 225 then
        compass = 'S'
    elseif angle >= 225 and angle < 315 then
        compass = 'W'
    end

    return compass
end

-- ====== ESX STATUS  ======
local wasHoldingShiftWhileStill = false
local safeStamina = 100

CreateThread(function()
    while true do
        if isCharacterChosen then
            local currentTime = GetGameTimer()
            local playerPed = PlayerPedId()
            local playerId = PlayerId()
            currentHealth = GetEntityHealth(playerPed) - 100
            currentArmor = GetPedArmour(playerPed)

            -- Statusy hunger/thirst
            if currentTime - lastStatusUpdate > statusUpdateInterval then
                TriggerEvent('esx_status:getStatus', 'hunger', function(status)
                    currentHunger = math.floor((status.val / 1000000) * 100)
                end)

                TriggerEvent('esx_status:getStatus', 'thirst', function(status)
                    currentThirst = math.floor((status.val / 1000000) * 100)
                end)
                lastStatusUpdate = currentTime
            end

            -- STAMINA LOGIKA
            local isShiftHeld = IsControlPressed(0, 21)
            local speed = GetEntitySpeed(playerPed)
            local isSprinting = isShiftHeld and speed > 1.5
            local isStandingStill = isShiftHeld and speed < 0.1
            local currentStamina = GetPlayerStamina(playerId)

            if isSprinting then
                wasHoldingShiftWhileStill = false
                safeStamina = currentStamina - 1.0
                safeStamina = math.max(0, safeStamina)
                SetPlayerStamina(playerId, safeStamina)

            elseif isStandingStill then
                if not wasHoldingShiftWhileStill then
                    safeStamina = currentStamina
                    wasHoldingShiftWhileStill = true
                end
                SetPlayerStamina(playerId, safeStamina)

            else
                wasHoldingShiftWhileStill = false
                safeStamina = currentStamina
            end

            currentStamina = math.floor(safeStamina)
            SetPlayerMaxStamina(playerId, 100.0)

            -- OXYGEN SYSTÉM
            local isInVehicle = IsPedInAnyVehicle(playerPed, false)
            local isUnderwater = cachedIsUnderwater
            if currentTime - lastUnderwaterCheck > underwaterCheckInterval then
                local playerCoords = GetEntityCoords(playerPed)
                if not isInVehicle then
                    local waterLevel = GetWaterHeight(playerCoords.x, playerCoords.y, playerCoords.z)
                    isUnderwater = waterLevel and playerCoords.z < (waterLevel - 2.0)
                else
                    isUnderwater = false
                end
                cachedIsUnderwater = isUnderwater
                lastUnderwaterCheck = currentTime
            end

            if isUnderwater then
                if currentOxygen > 0 then
                    currentOxygen = math.max(0, currentOxygen - 1.0)
                end
            else
                if currentOxygen < 100 then
                    currentOxygen = math.min(100, currentOxygen + 0.6)
                end
            end

            -- POZICE A KOMPAS
            local streetName, zoneName, direction, compass
            if currentTime - lastLocationUpdate > locationUpdateInterval then
                local playerCoords = GetEntityCoords(playerPed)
                local streetHash = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
                streetName = GetStreetNameFromHashKey(streetHash)
                if streetName then
                    streetName = string.gsub(streetName, "<[^>]*>", "")
                    cachedStreetName = streetName
                else
                    streetName = cachedStreetName
                end
                local zoneHash = GetNameOfZone(playerCoords.x, playerCoords.y, playerCoords.z)
                zoneName = GetLabelText(zoneHash)
                if zoneName then
                    zoneName = string.gsub(zoneName, "<[^>]*>", "")
                end
                if zoneName == "NULL" or zoneName == "" then
                    zoneName = "Neznámá oblast"
                end
                cachedZoneName = zoneName
                direction = getDirection()
                compass = getCompassDirection()
                cachedDirection = direction
                cachedCompass = compass
                lastLocationUpdate = currentTime
            else
                streetName = cachedStreetName
                zoneName = cachedZoneName
                direction = cachedDirection
                compass = cachedCompass
            end

            local healthRounded = math.floor(currentHealth)
            local armorRounded = math.floor(currentArmor)
            local staminaRounded = math.floor(currentStamina)
            local oxygenRounded = math.floor(currentOxygen)
            local isMicActive = NetworkIsPlayerTalking(PlayerId())
            local micMode = micModes[currentMicModeIndex]
            local isPauseMenuActive = IsPauseMenuActive()

            DisplayRadar(isInVehicle)

            if healthRounded ~= prevHealth or
               armorRounded ~= prevArmor or
               currentHunger ~= prevHunger or
               currentThirst ~= prevThirst or
               staminaRounded ~= prevStamina or
               oxygenRounded ~= prevOxygen or
               isUnderwater ~= prevIsUnderwater or
               isMicActive ~= prevIsMicActive or
               micMode ~= prevMicMode or
               isInVehicle ~= prevIsInVehicle or
               streetName ~= prevStreetName or
               zoneName ~= prevZoneName or
               direction ~= prevDirection or
               compass ~= prevCompass or
               isPauseMenuActive ~= prevIsPauseMenuActive then

                SendNUIMessage({
                    type = "toggleHUDIcons",
                    visible = not isPauseMenuActive
                })

                SendNUIMessage({
                    type = "updateHUD",
                    health = healthRounded,
                    armor = armorRounded,
                    hunger = currentHunger,
                    thirst = currentThirst,
                    stamina = staminaRounded,
                    oxygen = oxygenRounded,
                    isUnderwater = isUnderwater or forceShowOxygen,
                    isMicActive = isMicActive,
                    micMode = micMode,
                    isInVehicle = isInVehicle,
                    street = streetName,
                    direction = direction,
                    compass = compass,
                    location = zoneName,
                    area = zoneName
                })

                prevHealth = healthRounded
                prevArmor = armorRounded
                prevHunger = currentHunger
                prevThirst = currentThirst
                prevStamina = staminaRounded
                prevOxygen = oxygenRounded
                prevIsUnderwater = isUnderwater
                prevIsMicActive = isMicActive
                prevMicMode = micMode
                prevIsInVehicle = isInVehicle
                prevStreetName = streetName
                prevZoneName = zoneName
                prevDirection = direction
                prevCompass = compass
                prevIsPauseMenuActive = isPauseMenuActive
            end
        end
        Wait(100)
    end
end)




-- ====== PMA VOICE  ======
local function changeMicMode()
    currentMicModeIndex = currentMicModeIndex + 1
    if currentMicModeIndex > #micModes then
        currentMicModeIndex = 1
    end

    local newMicMode = micModes[currentMicModeIndex]

    lib.notify({
        title = 'Změna režimu mikrofonu',
        description = 'Režim mikrofonu byl nastaven na ' .. newMicMode,
        type = 'success'
    })

    SendNUIMessage({
        type = "updateMicMode",
        micMode = newMicMode,
    })
end

RegisterCommand('toggleMicMode', function()
    changeMicMode()
end, false)

RegisterKeyMapping('toggleMicMode', 'Toggle Microphone Mode', 'keyboard', 'f11')