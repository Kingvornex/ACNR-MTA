-- Login command
addCommandHandler("login", function(player, _, username, password)
    if playerData[player].loggedIn then
        outputChatBox("You're already logged in!", player, 255, 0, 0)
        return
    end
    
    if not username or not password then
        outputChatBox("Usage: /login [username] [password]", player, 255, 255, 0)
        return
    end
    
    if verifyAccount(username, password) then
        local data = loadPlayerData(username)
        if data then
            playerData[player].money = data.money
            playerData[player].score = data.score
            playerData[player].admin = data.admin
            playerData[player].loggedIn = true
            
            givePlayerMoney(player, data.money)
            outputChatBox("Successfully logged in as "..username, player, 0, 255, 0)
        else
            outputChatBox("Failed to load your account data!", player, 255, 0, 0)
        end
    else
        outputChatBox("Invalid username or password!", player, 255, 0, 0)
    end
end)

-- Register command
addCommandHandler("register", function(player, _, username, password)
    if playerData[player].loggedIn then
        outputChatBox("You're already logged in!", player, 255, 0, 0)
        return
    end
    
    if not username or not password then
        outputChatBox("Usage: /register [username] [password]", player, 255, 255, 0)
        return
    end
    
    if createAccount(username, password) then
        outputChatBox("Account created successfully! You can now login with /login", player, 0, 255, 0)
    else
        outputChatBox("Failed to create account! Username might be taken.", player, 255, 0, 0)
    end
end)

-- Admin commands
addCommandHandler("admin", function(player, _, cmd, target, ...)
    if not playerData[player].loggedIn or playerData[player].admin < 1 then
        outputChatBox("You're not authorized to use admin commands!", player, 255, 0, 0)
        return
    end
    
    if cmd == "heal" then
        local targetPlayer = getPlayerFromName(target)
        if targetPlayer then
            setElementHealth(targetPlayer, 100)
            setPedArmor(targetPlayer, 100)
            outputChatBox("You healed "..getPlayerName(targetPlayer), player, 0, 255, 0)
            outputChatBox("Admin healed you!", targetPlayer, 0, 255, 0)
        else
            outputChatBox("Player not found!", player, 255, 0, 0)
        end
    elseif cmd == "money" then
        local targetPlayer = getPlayerFromName(target)
        local amount = tonumber((...))
        
        if targetPlayer and amount then
            givePlayerMoney(targetPlayer, amount)
            outputChatBox("You gave $"..amount.." to "..getPlayerName(targetPlayer), player, 0, 255, 0)
            outputChatBox("Admin gave you $"..amount, targetPlayer, 0, 255, 0)
        else
            outputChatBox("Usage: /admin money [player] [amount]", player, 255, 255, 0)
        end
    end
end)

-- Vehicle commands
addCommandHandler("buy", function(player, _, model)
    if not playerData[player].loggedIn then
        outputChatBox("You must be logged in to buy vehicles!", player, 255, 0, 0)
        return
    end
    
    local vehicleModels = {
        ["infernus"] = {id = 411, price = 100000},
        ["turismo"] = {id = 451, price = 120000},
        ["bullet"] = {id = 541, price = 95000},
        ["cheetah"] = {id = 415, price = 85000},
        ["banshee"] = {id = 429, price = 75000}
    }
    
    local vehicle = vehicleModels[model:lower()]
    if vehicle then
        buyVehicle(player, vehicle.id, vehicle.price)
    else
        outputChatBox("Available vehicles: infernus, turismo, bullet, cheetah, banshee", player, 255, 255, 0)
    end
end)

-- Basic commands
addCommandHandler("stats", function(player)
    if playerData[player].loggedIn then
        outputChatBox("=== YOUR STATS ===", player, 0, 255, 255)
        outputChatBox("Money: $"..playerData[player].money, player, 255, 255, 255)
        outputChatBox("Score: "..playerData[player].score, player, 255, 255, 255)
        outputChatBox("Admin Level: "..playerData[player].admin, player, 255, 255, 255)
    else
        outputChatBox("You must be logged in to view stats!", player, 255, 0, 0)
    end
end)

addCommandHandler("help", function(player)
    outputChatBox("=== ACNR HELP ===", player, 0, 255, 255)
    outputChatBox("/login [username] [password] - Login to your account", player, 255, 255, 255)
    outputChatBox("/register [username] [password] - Create new account", player, 255, 255, 255)
    outputChatBox("/buy [vehicle] - Buy a vehicle", player, 255, 255, 255)
    outputChatBox("/stats - View your stats", player, 255, 255, 255)
    outputChatBox("/help - Show this help", player, 255, 255, 255)
end)
