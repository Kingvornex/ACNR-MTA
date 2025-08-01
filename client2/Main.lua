-- ACNR MTA - Main Client Script
-- Converted from ACNR-OPENMP

local rootElement = getRootElement()
local localPlayer = getLocalPlayer()

-- Initialize client
addEventHandler("onClientResourceStart", resourceRoot, function()
    outputChatBox("ACNR MTA Client Loaded", 0, 255, 0)
    
    -- Initialize GUI
    initializeGUI()
    
    -- Initialize HUD
    initializeHUD()
    
    -- Show login screen if not logged in
    triggerServerEvent("requestLoginState", localPlayer)
end)

-- Handle login state request
addEvent("requestLoginState", true)
addEventHandler("requestLoginState", rootElement, function()
    -- This will be handled by the server
end)

-- Show authentication GUI
addEvent("showAuthGUI", true)
addEventHandler("showAuthGUI", rootElement, function()
    showLoginWindow()
end)

-- Player state updates
addEventHandler("onClientPlayerSpawn", rootElement, function()
    -- Update HUD when player spawns
    updateHUD()
end)

addEventHandler("onClientPlayerDamage", rootElement, function()
    -- Update health display
    updateHUD()
end)

addEventHandler("onClientPlayerWasted", rootElement, function()
    -- Show death message
    outputChatBox("You died! Respawning in 3 seconds...", 255, 0, 0)
end)

-- Vehicle state updates
addEventHandler("onClientPlayerVehicleEnter", rootElement, function(vehicle)
    -- Update vehicle HUD
    updateVehicleHUD(vehicle)
end)

addEventHandler("onClientPlayerVehicleExit", rootElement, function()
    -- Hide vehicle HUD
    hideVehicleHUD()
end)

addEventHandler("onClientVehicleDamage", rootElement, function()
    -- Update vehicle health display
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if vehicle then
        updateVehicleHUD(vehicle)
    end
end)

-- Money updates
addEventHandler("onClientPlayerMoneyChange", rootElement, function()
    -- Update money display
    updateHUD()
end)

-- Utility functions
function outputChatBox(message, r, g, b)
    -- Override to ensure proper color formatting
    outputChatBox(message, r or 255, g or 255, b or 255)
end

function debugMessage(message)
    outputDebugString(message)
end

-- Network event handlers
addEvent("displayServerMessage", true)
addEventHandler("displayServerMessage", rootElement, function(message, r, g, b)
    outputChatBox(message, r or 255, g or 255, b or 255)
end)

addEvent("displayErrorMessage", true)
addEventHandler("displayErrorMessage", rootElement, function(message)
    outputChatBox("ERROR: " .. message, 255, 0, 0)
end)

addEvent("displaySuccessMessage", true)
addEventHandler("displaySuccessMessage", rootElement, function(message)
    outputChatBox(message, 0, 255, 0)
end)

-- Performance monitoring
local lastFPSUpdate = 0
local currentFPS = 0

addEventHandler("onClientRender", rootElement, function()
    -- Calculate FPS
    local currentTime = getTickCount()
    if currentTime - lastFPSUpdate >= 1000 then
        currentFPS = math.floor(1 / (getTickCount() - lastFrameTime) * 1000)
        lastFPSUpdate = currentTime
    end
    lastFrameTime = currentTime
    
    -- Update FPS counter if enabled
    if getElementData(localPlayer, "showFPS") then
        dxDrawText("FPS: " .. currentFPS, 10, 200, 200, 220, tocolor(255, 255, 255, 255), 1, "default")
    end
end)

-- Key bindings
bindKey("F1", "down", function()
    -- Show help window
    showHelpWindow()
end)

bindKey("F2", "down", function()
    -- Show stats window
    showStatsWindow()
end)

bindKey("F3", "down", function()
    -- Show inventory window
    showInventoryWindow()
end)

bindKey("F4", "down", function()
    -- Toggle FPS counter
    local showFPS = getElementData(localPlayer, "showFPS") or false
    setElementData(localPlayer, "showFPS", not showFPS)
    outputChatBox("FPS counter " .. (not showFPS and "enabled" or "disabled"), 255, 255, 0)
end)

bindKey("F5", "down", function()
    -- Show settings window
    showSettingsWindow()
end)

bindKey("l", "down", function()
    -- Toggle vehicle lights if in vehicle
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if vehicle then
        local lightsOn = getVehicleOverrideLights(vehicle)
        if lightsOn == 2 then
            setVehicleOverrideLights(vehicle, 1)
        else
            setVehicleOverrideLights(vehicle, 2)
        end
    end
end)

bindKey("j", "down", function()
    -- Toggle vehicle engine if in vehicle
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if vehicle then
        local engineState = getVehicleEngineState(vehicle)
        setVehicleEngineState(vehicle, not engineState)
        outputChatBox("Vehicle engine " .. (not engineState and "started" or "stopped"), 255, 255, 0)
    end
end)

bindKey("x", "down", function()
    -- Toggle vehicle lock if in vehicle
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if vehicle then
        triggerServerEvent("toggleVehicleLock", localPlayer, vehicle)
    end
end)

-- Window management functions
function showLoginWindow()
    -- This will be implemented in gui.lua
    if createLoginWindow then
        createLoginWindow()
    end
end

function showHelpWindow()
    -- This will be implemented in gui.lua
    if createHelpWindow then
        createHelpWindow()
    end
end

function showStatsWindow()
    -- This will be implemented in gui.lua
    if createStatsWindow then
        createStatsWindow()
    end
end

function showInventoryWindow()
    -- This will be implemented in gui.lua
    if createInventoryWindow then
        createInventoryWindow()
    end
end

function showSettingsWindow()
    -- This will be implemented in gui.lua
    if createSettingsWindow then
        createSettingsWindow()
    end
end

-- HUD management functions
function initializeHUD()
    -- This will be implemented in hud.lua
    if createHUD then
        createHUD()
    end
end

function updateHUD()
    -- This will be implemented in hud.lua
    if updateHUDDisplay then
        updateHUDDisplay()
    end
end

function updateVehicleHUD(vehicle)
    -- This will be implemented in hud.lua
    if updateVehicleHUDDisplay then
        updateVehicleHUDDisplay(vehicle)
    end
end

function hideVehicleHUD()
    -- This will be implemented in hud.lua
    if hideVehicleHUDDisplay then
        hideVehicleHUDDisplay()
    end
end

-- GUI management functions
function initializeGUI()
    -- This will be implemented in gui.lua
    if initializeGUISystem then
        initializeGUISystem()
    end
end

-- Error handling
addEventHandler("onClientError", rootElement, function(resource, error)
    outputDebugString("Client Error in " .. tostring(resource) .. ": " .. tostring(error))
end)

-- Resource stop cleanup
addEventHandler("onClientResourceStop", resourceRoot, function()
    -- Clean up GUI elements
    if cleanupGUI then
        cleanupGUI()
    end
    
    -- Clean up HUD
    if cleanupHUD then
        cleanupHUD()
    end
    
    outputChatBox("ACNR MTA Client Unloaded", 255, 0, 0)
end)
