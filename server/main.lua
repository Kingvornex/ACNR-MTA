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

-- Login/Register events
addEvent("onPlayerAttemptLogin", true)
addEventHandler("onPlayerAttemptLogin", root, function(username, password)
    if verifyAccount(username, password) then
        local data = loadPlayerData(username)
        if data then
            playerData[client].money = data.money
            playerData[client].score = data.score
            playerData[client].admin = data.admin
            playerData[client].loggedIn = true
            
            givePlayerMoney(client, data.money)
            triggerClientEvent(client, "onPlayerLoginSuccess", client)
            outputChatBox("Successfully logged in as "..username, client, 0, 255, 0)
        else
            triggerClientEvent(client, "onPlayerLoginError", client, "Failed to load account data")
        end
    else
        triggerClientEvent(client, "onPlayerLoginError", client, "Invalid username or password")
    end
end)

addEvent("onPlayerAttemptRegister", true)
addEventHandler("onPlayerAttemptRegister", root, function(username, password)
    if createAccount(username, password) then
        triggerClientEvent(client, "onPlayerRegisterSuccess", client)
        outputChatBox("Account created successfully! You can now login with /login", client, 0, 255, 0)
    else
        triggerClientEvent(client, "onPlayerRegisterError", client, "Failed to create account")
    end
end)
