-- ACNR MTA - Player Management System
-- Converted from ACNR-OPENMP

local players = {} -- Player data cache

-- Initialize player system
function initializePlayerSystem()
    -- Create player data table if it doesn't exist
    executeSQL([[CREATE TABLE IF NOT EXISTS players (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        money INTEGER DEFAULT 5000,
        skin INTEGER DEFAULT 0,
        admin_level INTEGER DEFAULT 0,
        score INTEGER DEFAULT 0,
        deaths INTEGER DEFAULT 0,
        kills INTEGER DEFAULT 0,
        playtime INTEGER DEFAULT 0,
        last_login DATETIME DEFAULT CURRENT_TIMESTAMP,
        registration_date DATETIME DEFAULT CURRENT_TIMESTAMP
    )]])
    
    outputServerLog("Player system initialized")
end

-- Register new player
function registerPlayer(player, username, password)
    -- Check if username already exists
    local result = executeSQL("SELECT id FROM players WHERE username = ?", username)
    if #result > 0 then
        return false
    end
    
    -- Hash password (simple implementation - in production use proper hashing)
    local hashedPassword = hashPassword(password)
    
    -- Insert new player
    executeSQL([[INSERT INTO players (username, password, money, skin, admin_level, score, deaths, kills, playtime)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)]], 
        username, hashedPassword, 5000, 0, 0, 0, 0, 0, 0)
    
    return true
end

-- Login player
function loginPlayer(player, username, password)
    -- Get player data
    local result = executeSQL("SELECT * FROM players WHERE username = ?", username)
    if #result == 0 then
        return false
    end
    
    local playerData = result[1]
    
    -- Verify password
    if not verifyPassword(password, playerData.password) then
        return false
    end
    
    -- Cache player data
    players[player] = {
        id = playerData.id,
        username = playerData.username,
        money = playerData.money,
        skin = playerData.skin,
        adminLevel = playerData.admin_level,
        score = playerData.score,
        deaths = playerData.deaths,
        kills = playerData.kills,
        playtime = playerData.playtime,
        isLoggedIn = true
    }
    
    -- Update last login
    executeSQL("UPDATE players SET last_login = CURRENT_TIMESTAMP WHERE id = ?", playerData.id)
    
    return true
end


-- Save player data
function savePlayerData(player)
    if not players[player] then return end
    
    local pData = players[player]
    executeSQL([[UPDATE players SET 
        money = ?, skin = ?, admin_level = ?, score = ?, 
        deaths = ?, kills = ?, playtime = ? 
        WHERE id = ?]], 
        pData.money, pData.skin, pData.adminLevel, pData.score,
        pData.deaths, pData.kills, pData.playtime, pData.id)
end

-- Get player data
function getPlayerData(player, key)
    if not players[player] then return nil end
    return players[player][key]
end

-- Set player data
function setPlayerData(player, key, value)
    if not players[player] then return false end
    players[player][key] = value
    return true
end

-- Handle player death
addEventHandler("onPlayerWasted", rootElement, function(ammo, attacker, weapon, bodypart)
    local player = source
    
    -- Update death stats
    if players[player] then
        players[player].deaths = players[player].deaths + 1
        players[player].score = math.max(0, players[player].score - 1)
    end
    
    -- Update killer stats
    if attacker and getElementType(attacker) == "player" and attacker ~= player then
        if players[attacker] then
            players[attacker].kills = players[attacker].kills + 1
            players[attacker].score = players[attacker].score + 2
            
            -- Give money for kill
            local bonusMoney = math.random(100, 500)
            players[attacker].money = players[attacker].money + bonusMoney
            setPlayerMoney(attacker, players[attacker].money)
            
            outputChatBox("You killed " .. getPlayerName(player) .. " and earned $" .. bonusMoney .. "!", attacker, 0, 255, 0)
        end
    end
    
    -- Respawn player after delay
    setTimer(function()
        spawnPlayer(player)
    end, 3000, 1)
end)

-- Stats command
addCommandHandler("stats", function(player)
    if not players[player] or not players[player].isLoggedIn then
        outputChatBox("You must be logged in to view stats!", player, 255, 0, 0)
        return
    end
    
    local pData = players[player]
    outputChatBox("=== Player Statistics ===", player, 255, 255, 0)
    outputChatBox("Username: " .. pData.username, player, 255, 255, 255)
    outputChatBox("Money: $" .. pData.money, player, 255, 255, 255)
    outputChatBox("Score: " .. pData.score, player, 255, 255, 255)
    outputChatBox("Kills: " .. pData.kills, player, 255, 255, 255)
    outputChatBox("Deaths: " .. pData.deaths, player, 255, 255, 255)
    outputChatBox("K/D Ratio: " .. (pData.deaths > 0 and string.format("%.2f", pData.kills / pData.deaths) or "0.00"), player, 255, 255, 255)
    outputChatBox("Playtime: " .. math.floor(pData.playtime / 3600) .. " hours", player, 255, 255, 255)
end)

-- Money transfer command
addCommandHandler("pay", function(player, cmd, targetName, amount)
    if not players[player] or not players[player].isLoggedIn then
        outputChatBox("You must be logged in to use this command!", player, 255, 0, 0)
        return
    end
    
    if not targetName or not amount then
        outputChatBox("Usage: /pay [playername] [amount]", player, 255, 255, 0)
        return
    end
    
    local amountNum = tonumber(amount)
    if not amountNum or amountNum <= 0 then
        outputChatBox("Invalid amount!", player, 255, 0, 0)
        return
    end
    
    if players[player].money < amountNum then
        outputChatBox("You don't have enough money!", player, 255, 0, 0)
        return
    end
    
    -- Find target player
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", player, 255, 0, 0)
        return
    end
    
    if not players[target] or not players[target].isLoggedIn then
        outputChatBox("Target player is not logged in!", player, 255, 0, 0)
        return
    end
    
    -- Transfer money
    players[player].money = players[player].money - amountNum
    players[target].money = players[target].money + amountNum
    
    setPlayerMoney(player, players[player].money)
    setPlayerMoney(target, players[target].money)
    
    outputChatBox("You paid $" .. amountNum .. " to " .. getPlayerName(target), player, 0, 255, 0)
    outputChatBox(getPlayerName(player) .. " paid you $" .. amountNum, target, 0, 255, 0)
end)

-- Utility functions
function findPlayerByName(name)
    local nameLower = string.lower(name)
    for _, player in ipairs(getElementsByType("player")) do
        if string.lower(getPlayerName(player)):find(nameLower) then
            return player
        end
    end
    return nil
end

function hashPassword(password)
    -- Simple hash function - in production use proper hashing like bcrypt
    return string.format("%08x", tonumber(string.sub(md5(password), 1, 8)))
end

function verifyPassword(password, hash)
    return hashPassword(password) == hash
end

-- Update playtime
setTimer(function()
    for player, pData in pairs(players) do
        if pData.isLoggedIn then
            pData.playtime = pData.playtime + 60 -- Add 60 seconds every minute
        end
    end
end, 60000, 0)

