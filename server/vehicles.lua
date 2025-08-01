local vehicleRespawnTimers = {}

-- Initialize vehicles when resource starts
addEventHandler("onResourceStart", resourceRoot, function()
    local vehicles = loadVehicles()
    outputDebugString("Loaded "..#vehicles.." vehicles from database")
end)

-- Handle vehicle destruction
addEventHandler("onVehicleExplode", root, function()
    if vehicleRespawnTimers[source] then
        killTimer(vehicleRespawnTimers[source])
    end
    
    vehicleRespawnTimers[source] = setTimer(function(vehicle)
        local x, y, z = getElementPosition(vehicle)
        local rx, ry, rz = getElementRotation(vehicle)
        fixVehicle(vehicle)
        setVehicleEngineState(vehicle, false)
        setElementPosition(vehicle, x, y, z)
        setElementRotation(vehicle, rx, ry, rz)
    end, VEHICLE_RESPAWN_TIME, 1, source)
end)

-- Save vehicle when resource stops
addEventHandler("onResourceStop", resourceRoot, function()
    for _, vehicle in ipairs(getElementsByType("vehicle")) do
        saveVehicle(vehicle)
    end
end)

-- Vehicle ownership functions
function buyVehicle(player, model, price)
    if not playerData[player] or not playerData[player].loggedIn then
        outputChatBox("You must be logged in to buy a vehicle!", player, 255, 0, 0)
        return false
    end
    
    if playerData[player].money < price then
        outputChatBox("You don't have enough money! ($"..price.." needed)", player, 255, 0, 0)
        return false
    end
    
    local x, y, z = getElementPosition(player)
    local vehicle = createVehicle(model, x + 5, y, z)
    
    if vehicle then
        takePlayerMoney(player, price)
        setElementData(vehicle, "owner", getPlayerName(player))
        setVehicleColor(vehicle, math.random(0, 126), math.random(0, 126), 0, 0)
        saveVehicle(vehicle)
        outputChatBox("You bought a "..getVehicleNameFromModel(model).." for $"..price, player, 0, 255, 0)
        return true
    end
    
    return false
end
