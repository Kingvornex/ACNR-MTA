
-- ACNR MTA - HUD Management System
-- Converted from ACNR-OPENMP

local hudElements = {}
local isHUDEnabled = true
local vehicleHUDEnabled = true

-- Initialize HUD
function createHUD()
    -- Hide default HUD elements
    setPlayerHudComponentVisible("ammo", false)
    setPlayerHudComponentVisible("area_name", false)
    setPlayerHudComponentVisible("armour", false)
    setPlayerHudComponentVisible("breath", false)
    setPlayerHudComponentVisible("clock", false)
    setPlayerHudComponentVisible("health", false)
    setPlayerHudComponentVisible("money", false)
    setPlayerHudComponentVisible("vehicle_name", false)
    setPlayerHudComponentVisible("weapon", false)
    
    -- Initialize HUD elements
    hudElements.health = 100
    hudElements.armor = 0
    hudElements.money = 0
    hudElements.weapon = 0
    hudElements.ammo = 0
    hudElements.vehicle = nil
    hudElements.vehicleHealth = 1000
    hudElements.vehicleFuel = 100
    hudElements.speed = 0
    hudElements.wanted = 0
    hudElements.zone = "Unknown"
    
    -- Create HUD render event
    addEventHandler("onClientRender", rootElement, renderHUD)
    
    outputDebugString("HUD System Initialized")
end

-- Main HUD render function
function renderHUD()
    if not isHUDEnabled then return end
    
    local screenWidth, screenHeight = guiGetScreenSize()
    local baseX = 10
    local baseY = screenHeight - 150
    
    -- Draw HUD background
    dxDrawRectangle(baseX - 5, baseY - 5, 220, 140, tocolor(0, 0, 0, 180))
    dxDrawRectangle(baseX - 5, baseY - 5, 220, 20, tocolor(0, 100, 200, 200))
    
    -- Draw player info
    dxDrawText("ACNR MTA", baseX, baseY - 5, baseX + 220, baseY + 15, tocolor(255, 255, 255, 255), 1, "default-bold", "center", "center")
    
    -- Draw health bar
    local healthY = baseY + 25
    dxDrawText("Health:", baseX, healthY, baseX + 50, healthY + 15, tocolor(255, 255, 255, 255), 1, "default")
    dxDrawRectangle(baseX + 55, healthY, 150, 15, tocolor(50, 50, 50, 200))
    dxDrawRectangle(baseX + 55, healthY, (hudElements.health / 100) * 150, 15, tocolor(255, 0, 0, 200))
    dxDrawText(math.floor(hudElements.health) .. "%", baseX + 55, healthY, baseX + 205, healthY + 15, tocolor(255, 255, 255, 255), 1, "default", "center", "center")
    
    -- Draw armor bar
    local armorY = healthY + 20
    if hudElements.armor > 0 then
        dxDrawText("Armor:", baseX, armorY, baseX + 50, armorY + 15, tocolor(255, 255, 255, 255), 1, "default")
        dxDrawRectangle(baseX + 55, armorY, 150, 15, tocolor(50, 50, 50, 200))
        dxDrawRectangle(baseX + 55, armorY, (hudElements.armor / 100) * 150, 15, tocolor(0, 200, 255, 200))
        dxDrawText(math.floor(hudElements.armor) .. "%", baseX + 55, armorY, baseX + 205, armorY + 15, tocolor(255, 255, 255, 255), 1, "default", "center", "center")
    end
    
    -- Draw money
    local moneyY = armorY + (hudElements.armor > 0 and 20 or 0)
    dxDrawText("Money:", baseX, moneyY, baseX + 50, moneyY + 15, tocolor(255, 255, 255, 255), 1, "default")
    dxDrawText("$" .. hudElements.money, baseX + 55, moneyY, baseX + 205, moneyY + 15, tocolor(0, 255, 0, 255), 1, "default", "left", "center")
    
    -- Draw weapon info
    if hudElements.weapon > 0 then
        local weaponY = moneyY + 20
        local weaponName = getWeaponNameFromID(hudElements.weapon)
        dxDrawText("Weapon:", baseX, weaponY, baseX + 50, weaponY + 15, tocolor(255, 255, 255, 255), 1, "default")
        dxDrawText(weaponName .. " (" .. hudElements.ammo .. ")", baseX + 55, weaponY, baseX + 205, weaponY + 15, tocolor(255, 255, 255, 255), 1, "default", "left", "center")
    end
    
    -- Draw wanted level
    if hudElements.wanted > 0 then
        local wantedX = screenWidth - 60
        local wantedY = 10
        for i = 1, 6 do
            if i <= hudElements.wanted then
                dxDrawImage(wantedX + (i-1) * 25, wantedY, 20, 20, "assets/images/star.png")
            end
        end
    end
    
    -- Draw zone name
    dxDrawText("Zone: " .. hudElements.zone, screenWidth - 150, screenHeight - 30, screenWidth - 10, screenHeight - 10, tocolor(255, 255, 255, 255), 1, "default", "right", "center")
    
    -- Draw vehicle HUD if in vehicle
    if hudElements.vehicle and vehicleHUDEnabled then
        renderVehicleHUD()
    end
end

-- Vehicle HUD render function
function renderVehicleHUD()
    if not hudElements.vehicle then return end
    
    local screenWidth, screenHeight = guiGetScreenSize()
    local baseX = screenWidth - 250
    local baseY = screenHeight - 150
    
    -- Draw vehicle HUD background
    dxDrawRectangle(baseX - 5, baseY - 5, 240, 120, tocolor(0, 0, 0, 180))
    dxDrawRectangle(baseX - 5, baseY - 5, 240, 20, tocolor(0, 150, 0, 200))
    
    -- Draw vehicle info
    local vehicleName = getVehicleName(hudElements.vehicle)
    dxDrawText(vehicleName, baseX, baseY - 5, baseX + 240, baseY + 15, tocolor(255, 255, 255, 255), 1, "default-bold", "center", "center")
    
    -- Draw vehicle health bar
    local healthY = baseY + 25
    dxDrawText("Health:", baseX, healthY, baseX + 60, healthY + 15, tocolor(255, 255, 255, 255), 1, "default")
    dxDrawRectangle(baseX + 65, healthY, 160, 15, tocolor(50, 50, 50, 200))
    local healthPercent = hudElements.vehicleHealth / 1000
    local healthColor = healthPercent > 0.5 and tocolor(0, 255, 0, 200) or healthPercent > 0.25 and tocolor(255, 255, 0, 200) or tocolor(255, 0, 0, 200)
    dxDrawRectangle(baseX + 65, healthY, healthPercent * 160, 15, healthColor)
    dxDrawText(math.floor(healthPercent * 100) .. "%", baseX + 65, healthY, baseX + 225, healthY + 15, tocolor(255, 255, 255, 255), 1, "default", "center", "center")
    
    -- Draw fuel bar
    local fuelY = healthY + 20
    dxDrawText("Fuel:", baseX, fuelY, baseX + 60, fuelY + 15, tocolor(255, 255, 255, 255), 1, "default")
    dxDrawRectangle(baseX + 65, fuelY, 160, 15, tocolor(50, 50, 50, 200))
    local fuelColor = hudElements.vehicleFuel > 25 and tocolor(255, 200, 0, 200) or tocolor(255, 0, 0, 200)
    dxDrawRectangle(baseX + 65, fuelY, (hudElements.vehicleFuel / 100) * 160, 15, fuelColor)
    dxDrawText(hudElements.vehicleFuel .. "%", baseX + 65, fuelY, baseX + 225, fuelY + 15, tocolor(255, 255, 255, 255), 1, "default", "center", "center")
    
    -- Draw speed
    local speedY = fuelY + 20
    dxDrawText("Speed:", baseX, speedY, baseX + 60, speedY + 15, tocolor(255, 255, 255, 255), 1, "default")
    dxDrawText(math.floor(hudElements.speed) .. " km/h", baseX + 65, speedY, baseX + 225, speedY + 15, tocolor(255, 255, 255, 255), 1, "default", "left", "center")
    
    -- Draw engine state
    local engineY = speedY + 20
    local engineState = getVehicleEngineState(hudElements.vehicle)
    dxDrawText("Engine:", baseX, engineY, baseX + 60, engineY + 15, tocolor(255, 255, 255, 255), 1, "default")
    dxDrawText(engineState and "ON" or "OFF", baseX + 65, engineY, baseX + 225, engineY + 15, engineState and tocolor(0, 255, 0, 255) or tocolor(255, 0, 0, 255), 1, "default", "left", "center")
end
-- Update HUD display
function updateHUDDisplay()
    if not isHUDEnabled then return end
    
    -- Update player stats
    hudElements.health = getElementHealth(localPlayer)
    hudElements.armor = getPedArmor(localPlayer)
    hudElements.money = getPlayerMoney(localPlayer)
    hudElements.wanted = getPlayerWantedLevel(localPlayer)
    
    -- Update weapon info
    local weapon = getPedWeapon(localPlayer)
    local ammo = getPedTotalAmmo(localPlayer)
    if weapon and weapon > 0 then
        hudElements.weapon = weapon
        hudElements.ammo = ammo
    else
        hudElements.weapon = 0
        hudElements.ammo = 0
    end
    
    -- Update zone
    local zoneName = getZoneName(getElementPosition(localPlayer))
    if zoneName then
        hudElements.zone = zoneName
    end
    
    -- Update vehicle info
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if vehicle then
        hudElements.vehicle = vehicle
        updateVehicleHUDDisplay(vehicle)
    else
        hudElements.vehicle = nil
    end
end

-- Update vehicle HUD display
function updateVehicleHUDDisplay(vehicle)
    if not vehicle or not vehicleHUDEnabled then return end
    
    hudElements.vehicle = vehicle
    hudElements.vehicleHealth = getElementHealth(vehicle)
    hudElements.vehicleFuel = getElementData(vehicle, "fuel") or 100
    
    -- Calculate speed
    local vx, vy, vz = getElementVelocity(vehicle)
    hudElements.speed = math.sqrt(vx*vx + vy*vy + vz*vz) * 180
end

-- Hide vehicle HUD
function hideVehicleHUDDisplay()
    hudElements.vehicle = nil
end

-- Toggle HUD
function toggleHUD()
    isHUDEnabled = not isHUDEnabled
    if isHUDEnabled then
        outputChatBox("HUD enabled", 0, 255, 0)
    else
        outputChatBox("HUD disabled", 255, 0, 0)
    end
end

-- Toggle vehicle HUD
function toggleVehicleHUD()
    vehicleHUDEnabled = not vehicleHUDEnabled
    if vehicleHUDEnabled then
        outputChatBox("Vehicle HUD enabled", 0, 255, 0)
    else
        outputChatBox("Vehicle HUD disabled", 255, 0, 0)
    end
end

-- HUD update timer
setTimer(function()
    updateHUDDisplay()
end, 100, 0) -- Update every 100ms

-- Add HUD toggle commands
addCommandHandler("togglehud", function()
    toggleHUD()
end)

addCommandHandler("togglevehiclehud", function()
    toggleVehicleHUD()
end)

-- Cleanup HUD
function cleanupHUD()
    -- Show default HUD elements
    setPlayerHudComponentVisible("ammo", true)
    setPlayerHudComponentVisible("area_name", true)
    setPlayerHudComponentVisible("armour", true)
    setPlayerHudComponentVisible("breath", true)
    setPlayerHudComponentVisible("clock", true)
    setPlayerHudComponentVisible("health", true)
    setPlayerHudComponentVisible("money", true)
    setPlayerHudComponentVisible("vehicle_name", true)
    setPlayerHudComponentVisible("weapon", true)
    
    -- Remove render event
    removeEventHandler("onClientRender", rootElement, renderHUD)
    
    outputDebugString("HUD System Cleaned Up")
end

-- Utility function to get weapon name
function getWeaponNameFromID(weaponID)
    local weaponNames = {
        [0] = "Fist",
        [1] = "Brass Knuckles",
        [2] = "Golf Club",
        [3] = "Night Stick",
        [4] = "Knife",
        [5] = "Baseball Bat",
        [6] = "Shovel",
        [7] = "Pool Cue",
        [8] = "Katana",
        [9] = "Chainsaw",
        [10] = "Purple Dildo",
        [11] = "Dildo",
        [12] = "Vibrator",
        [13] = "Vibrator",
        [14] = "Flowers",
        [15] = "Cane",
        [16] = "Grenade",
        [17] = "Tear Gas",
        [18] = "Molotov",
        [22] = "Pistol",
        [23] = "Silenced Pistol",
        [24] = "Desert Eagle",
        [25] = "Shotgun",
        [26] = "Sawnoff Shotgun",
        [27] = "Combat Shotgun",
        [28] = "Uzi",
        [29] = "MP5",
        [30] = "AK-47",
        [31] = "M4",
        [32] = "Tec-9",
        [33] = "Country Rifle",
        [34] = "Sniper Rifle",
        [35] = "RPG",
        [36] = "HS Rocket",
        [37] = "Flamethrower",
        [38] = "Minigun",
        [39] = "Satchel Charge",
        [40] = "Detonator",
        [41] = "Spraycan",
        [42] = "Fire Extinguisher",
        [43] = "Camera",
        [44] = "Night Vision",
        [45] = "Infrared Vision",
        [46] = "Parachute",
        [100] = "Jetpack"
    }
    
    return weaponNames[weaponID] or "Unknown"
end
