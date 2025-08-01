-- Initialize the game mode
addEventHandler("onResourceStart", resourceRoot, function()
    -- Initialize database
    if not initDatabase() then
        outputDebugString("Failed to initialize database! Shutting down resource.", 1)
        return
    end
    
    outputDebugString("ACNR Game Mode Started Successfully")
    outputChatBox("Welcome to ACNR! Type /help for commands.", root, 0, 255, 255)
end)

-- Handle player death
addEventHandler("onPlayerWasted", root, function(ammo, killer, weapon, bodypart)
    if killer and getElementType(killer) == "player" then
        -- Award money to killer
        local reward = 100
        givePlayerMoney(killer, reward)
        outputChatBox("You killed "..getPlayerName(source).." and earned $"..reward, killer, 0, 255, 0)
        
        -- Update scores
        if playerData[killer] then
            playerData[killer].score = playerData[killer].score + 1
        end
    end
    
    -- Respawn player
    setTimer(spawnPlayer, 2000, 1, source, SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_ANGLE)
end)

-- Periodic data saving
setTimer(function()
    for player, data in pairs(playerData) do
        if data.loggedIn then
            savePlayerData(player, data)
        end
    end
    outputDebugString("Saved player data to database")
end, 300000, 0) -- Save every 5 minutes
