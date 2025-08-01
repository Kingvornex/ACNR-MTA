local playerData = {}

-- Initialize player when they join
addEventHandler("onPlayerJoin", root, function()
    playerData[source] = {
        money = STARTING_MONEY,
        score = 0,
        admin = 0,
        loggedIn = false,
        vehicle = nil
    }
    
    fadeCamera(source, true)
    setCameraTarget(source, source)
    spawnPlayer(source, SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_ANGLE)
    setElementHealth(source, STARTING_HEALTH)
    setPedArmor(source, STARTING_ARMOR)
    
    outputChatBox("Welcome to ACNR! Use /login to access your account or /register to create one.", source, 0, 255, 255)
end)

-- Clean up when player quits
addEventHandler("onPlayerQuit", root, function()
    if playerData[source] and playerData[source].loggedIn then
        savePlayerData(source, playerData[source])
    end
    playerData[source] = nil
end)

-- Player spawn handling
addEventHandler("onPlayerSpawn", root, function()
    if playerData[source] and playerData[source].loggedIn then
        givePlayerMoney(source, playerData[source].money)
    end
end)

-- Money management
addEventHandler("onPlayerMoneyChange", root, function(_, oldAmount, newAmount)
    if playerData[source] and playerData[source].loggedIn then
        playerData[source].money = newAmount
    end
end)

-- Player data export functions
function getPlayerData(player)
    return playerData[player] or {}
end

function setPlayerData(player, key, value)
    if playerData[player] then
        playerData[player][key] = value
    end
end
