```xml
<meta>
    <info author="Converted from ACNR-OPENMP" type="gamemode" name="ACNR MTA" version="1.0.0" description="Converted ACNR game mode for MTA:SA"/>
    
    <!-- Main scripts -->
    <script src="server/main.lua" type="server" cache="false"/>
    <script src="server/player.lua" type="server" cache="false"/>
    <script src="server/vehicle.lua" type="server" cache="false"/>
    <script src="server/house.lua" type="server" cache="false"/>
    <script src="server/faction.lua" type="server" cache="false"/>
    <script src="server/admin.lua" type="server" cache="false"/>
    <script src="server/database.lua" type="server" cache="false"/>
    
    <script src="client/main.lua" type="client" cache="false"/>
    <script src="client/gui.lua" type="client" cache="false"/>
    <script src="client/hud.lua" type="client" cache="false"/>
    
    <!-- Shared utilities -->
    <script src="shared/utils.lua" type="shared" cache="false"/>
    <script src="shared/config.lua" type="shared" cache="false"/>
    
    <!-- Configuration files -->
    <config src="config/settings.xml" type="server" cache="false"/>
    <config src="config/vehicles.xml" type="server" cache="false"/>
    <config src="config/houses.xml" type="server" cache="false"/>
    
    <!-- Map files -->
    <map src="maps/main.map" dimension="0"/>
    
    <!-- Database files -->
    <export function="executeSQL" type="server"/>
    <export function="getConnection" type="server"/>
    
    <!-- Required resources -->
    <include resource="mysql"/>
    <include resource="scoreboard"/>
    <include resource="mapmanager"/>
    
    <settings>
        <setting name="*mysql_host" value="localhost"/>
        <setting name="*mysql_user" value="root"/>
        <setting name="*mysql_pass" value=""/>
        <setting name="*mysql_db" value="acnr_mta"/>
        <setting name="*spawn_x" value="1958.33"/>
        <setting name="*spawn_y" value="-1684.97"/>
        <setting name="*spawn_z" value="13.54"/>
        <setting name="*spawn_angle" value="269.15"/>
        <setting name="*starting_money" value="5000"/>
        <setting name="*max_players" value="100"/>
    </settings>
</meta>
```

```lua
-- ACNR MTA - Main Server Script
-- Converted from ACNR-OPENMP

local resourceRoot = getResourceRootElement(getThisResource())
local rootElement = getRootElement()

-- Initialize the game mode
addEventHandler("onResourceStart", resourceRoot, function()
    outputServerLog("ACNR MTA Game Mode Starting...")
    
    -- Initialize database connection
    if not initDatabase() then
        outputServerLog("ERROR: Failed to initialize database!")
        return
    end
    
    -- Load configurations
    loadConfigurations()
    
    -- Initialize systems
    initializePlayerSystem()
    initializeVehicleSystem()
    initializeHouseSystem()
    initializeFactionSystem()
    
    outputServerLog("ACNR MTA Game Mode Started Successfully!")
end)

-- Handle player join
addEventHandler("onPlayerJoin", rootElement, function()
    local player = source
    local playerName = getPlayerName(player)
    
    outputChatBox("* " .. playerName .. " has joined the server.", rootElement, 255, 100, 100)
    
    -- Show login/register GUI
    triggerClientEvent(player, "showAuthGUI", player)
end)

-- Handle player quit
addEventHandler("onPlayerQuit", rootElement, function(reason)
    local player = source
    local playerName = getPlayerName(player)
    
    -- Save player data
    savePlayerData(player)
    
    outputChatBox("* " .. playerName .. " has left the server (" .. reason .. ")", rootElement, 255, 100, 100)
end)

-- Handle player spawn
addEventHandler("onPlayerSpawn", rootElement, function()
    local player = source
    
    -- Set initial player state
    setPlayerMoney(player, getPlayerData(player, "money") or 5000)
    
    -- Apply player skin
    local skin = getPlayerData(player, "skin")
    if skin then
        setElementModel(player, tonumber(skin))
    end
    
    -- Show welcome message
    outputChatBox("Welcome to ACNR MTA! Use /help for commands.", player, 0, 255, 0)
end)

-- Command handlers
addCommandHandler("register", function(player, cmd, username, password)
    if not username or not password then
        outputChatBox("Usage: /register [username] [password]", player, 255, 255, 0)
        return
    end
    
    -- Register player account
    local success = registerPlayer(player, username, password)
    if success then
        outputChatBox("Account registered successfully! You can now login.", player, 0, 255, 0)
    else
        outputChatBox("Registration failed. Username may already exist.", player, 255, 0, 0)
    end
end)

addCommandHandler("login", function(player, cmd, username, password)
    if not username or not password then
        outputChatBox("Usage: /login [username] [password]", player, 255, 255, 0)
        return
    end
    
    -- Login player
    local success = loginPlayer(player, username, password)
    if success then
        outputChatBox("Logged in successfully!", player, 0, 255, 0)
        spawnPlayer(player)
    else
        outputChatBox("Login failed. Invalid username or password.", player, 255, 0, 0)
    end
end)

addCommandHandler("help", function(player)
    outputChatBox("=== ACNR MTA Commands ===", player, 255, 255, 0)
    outputChatBox("/register [username] [password] - Register new account", player, 255, 255, 255)
    outputChatBox("/login [username] [password] - Login to account", player, 255, 255, 255)
    outputChatBox("/stats - View your statistics", player, 255, 255, 255)
    outputChatBox("/vehicles - View vehicle commands", player, 255, 255, 255)
    outputChatBox("/houses - View house commands", player, 255, 255, 255)
    outputChatBox("/factions - View faction commands", player, 255, 255, 255)
end)

-- Utility functions
function outputServerLog(message)
    outputDebugString(message)
end

function loadConfigurations()
    -- Load server configurations
    outputServerLog("Configurations loaded")
end

-- Export functions
function getGameModeInfo()
    return {
        name = "ACNR MTA",
        version = "1.0.0",
        author = "Converted from ACNR-OPENMP",
        description = "Converted ACNR game mode for MTA:SA"
    }
end
```
```lua
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

```
```lua
-- ACNR MTA - Vehicle Management System
-- Converted from ACNR-OPENMP

local vehicles = {} -- Vehicle data cache
local playerVehicles = {} -- Player owned vehicles

-- Initialize vehicle system
function initializeVehicleSystem()
    -- Create vehicle data table
    executeSQL([[CREATE TABLE IF NOT EXISTS vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner_id INTEGER,
        model INTEGER NOT NULL,
        x REAL NOT NULL,
        y REAL NOT NULL,
        z REAL NOT NULL,
        rx REAL DEFAULT 0,
        ry REAL DEFAULT 0,
        rz REAL DEFAULT 0,
        color1 INTEGER DEFAULT 0,
        color2 INTEGER DEFAULT 0,
        health INTEGER DEFAULT 1000,
        fuel INTEGER DEFAULT 100,
        locked INTEGER DEFAULT 0,
        plate TEXT DEFAULT 'ACNR',
        purchase_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (owner_id) REFERENCES players(id)
    )]])
    
    -- Load existing vehicles
    loadVehicles()
    
    outputServerLog("Vehicle system initialized")
end

-- Load vehicles from database
function loadVehicles()
    local result = executeSQL("SELECT * FROM vehicles")
    for _, vehicleData in ipairs(result) do
        local vehicle = createVehicle(vehicleData.model, 
            vehicleData.x, vehicleData.y, vehicleData.z,
            vehicleData.rx, vehicleData.ry, vehicleData.rz,
            vehicleData.plate)
        
        if vehicle then
            -- Set vehicle properties
            setVehicleColor(vehicle, vehicleData.color1, vehicleData.color2, 0, 0)
            setVehicleEngineState(vehicle, false)
            setVehicleLocked(vehicle, vehicleData.locked == 1)
            setElementHealth(vehicle, vehicleData.health)
            
            -- Store vehicle data
            vehicles[vehicle] = {
                id = vehicleData.id,
                ownerId = vehicleData.owner_id,
                model = vehicleData.model,
                fuel = vehicleData.fuel,
                plate = vehicleData.plate
            }
            
            -- Add to player vehicles if owned
            if vehicleData.owner_id then
                if not playerVehicles[vehicleData.owner_id] then
                    playerVehicles[vehicleData.owner_id] = {}
                end
                table.insert(playerVehicles[vehicleData.owner_id], vehicle)
            end
        end
    end
end

-- Vehicle commands
addCommandHandler("vehicles", function(player)
    outputChatBox("=== Vehicle Commands ===", player, 255, 255, 0)
    outputChatBox("/v buy [model] - Buy a vehicle", player, 255, 255, 255)
    outputChatBox("/v sell - Sell your current vehicle", player, 255, 255, 255)
    outputChatBox("/v list - List your vehicles", player, 255, 255, 255)
    outputChatBox("/v spawn [id] - Spawn your vehicle", player, 255, 255, 255)
    outputChatBox("/v park - Park your current vehicle", player, 255, 255, 255)
    outputChatBox("/v lock - Lock/unlock your vehicle", player, 255, 255, 255)
    outputChatBox("/v fix - Repair your vehicle", player, 255, 255, 255)
end)

-- Buy vehicle command
addCommandHandler("v", function(player, cmd, subcmd, ...)
    if not players[player] or not players[player].isLoggedIn then
        outputChatBox("You must be logged in to use vehicle commands!", player, 255, 0, 0)
        return
    end
    
    local args = {...}
    
    if subcmd == "buy" then
        local model = args[1]
        if not model then
            outputChatBox("Usage: /v buy [model]", player, 255, 255, 0)
            return
        end
        
        buyVehicle(player, model)
    elseif subcmd == "sell" then
        sellVehicle(player)
    elseif subcmd == "list" then
        listPlayerVehicles(player)
    elseif subcmd == "spawn" then
        local vehicleId = args[1]
        if not vehicleId then
            outputChatBox("Usage: /v spawn [vehicle_id]", player, 255, 255, 0)
            return
        end
        spawnPlayerVehicle(player, tonumber(vehicleId))
    elseif subcmd == "park" then
        parkVehicle(player)
    elseif subcmd == "lock" then
        lockVehicle(player)
    elseif subcmd == "fix" then
        fixVehicle(player)
    else
        outputChatBox("Invalid command! Use /vehicles to see available commands.", player, 255, 0, 0)
    end
end)

-- Buy vehicle function
function buyVehicle(player, model)
    local modelNum = tonumber(model)
    if not modelNum then
        outputChatBox("Invalid vehicle model!", player, 255, 0, 0)
        return
    end
    -- Vehicle prices (simplified)
    local vehiclePrices = {
        [400] = 20000, -- Landstalker
        [401] = 15000, -- Bravura
        [402] = 35000, -- Buffalo
        [404] = 18000, -- Perennial
        [405] = 25000, -- Sentinel
        [410] = 12000, -- Manana
        [411] = 100000, -- Infernus
        [412] = 30000, -- Voodoo
        [415] = 45000, -- Cheetah
        [420] = 15000, -- Taxi
        [426] = 22000, -- Premier
        [429] = 80000, -- Banshee
        [436] = 16000, -- Previon
        [439] = 14000, -- Stallion
        [445] = 28000, -- Admiral
        [451] = 95000, -- Turismo
        [466] = 17000, -- Glendale
        [467] = 19000, -- Oceanic
        [474] = 13000, -- Hermes
        [475] = 24000, -- Sabre
        [479] = 21000, -- Regina
        [480] = 16000, -- Camper
        [491] = 15000, -- Virgo
        [492] = 20000, -- Greenwood
        [496] = 18000, -- Blista Compact
        [500] = 14000, -- Mesa
        [505] = 22000, -- Rancher
        [506] = 75000, -- Super GT
        [507] = 32000, -- Elegant
        [516] = 20000, -- Nebula
        [517] = 18000, -- Majestic
        [518] = 16000, -- Buccaneer
        [526] = 24000, -- Fortune
        [527] = 23000, -- Cadrona
        [529] = 26000, -- Willard
        [534] = 19000, -- Remington
        [535] = 21000, -- Slamvan
        [536] = 20000, -- Blade
        [540] = 22000, -- Vincent
        [541] = 85000, -- Bullet
        [542] = 28000, -- Cloak
        [545] = 25000, -- Hustler
        [546] = 19000, -- Intruder
        [547] = 27000, -- Primo
        [549] = 23000, -- Tampa
        [550] = 20000, -- Sunrise
        [551] = 18000, --Merit
        [552] = 35000, -- Uranus
        [554] = 28000, -- Yosemite
        [555] = 24000, -- Windsor
        [558] = 32000, -- Uranus
        [559] = 38000, -- Jester
        [560] = 36000, -- Sultan
        [561] = 34000, -- Stratum
        [562] = 70000, -- Elegy
        [565] = 26000, -- Flash
        [566] = 24000, --Tahoma
        [567] = 28000, -- Savanna
        [575] = 22000, -- Broadway
        [576] = 20000, -- Tornado
        [579] = 30000, -- Huntley
        [580] = 25000, -- Stafford
        [585] = 23000, -- Emperor
        [587] = 27000, -- Euros
        [589] = 29000, -- Club
        [600] = 16000, -- Picador
        [602] = 18000, -- Alpha
        [603] = 20000, -- Phoenix
        [604] = 22000, -- Glendale
        [605] = 24000, -- Sadler
    }
    
    local price = vehiclePrices[modelNum] or 25000
    
    if players[player].money < price then
        outputChatBox("You need $" .. price .. " to buy this vehicle!", player, 255, 0, 0)
        return
    end
    
    -- Get player position
    local x, y, z = getElementPosition(player)
    local rx, ry, rz = getElementRotation(player)
    
    -- Create vehicle
    local vehicle = createVehicle(modelNum, x + 5, y, z, rx, ry, rz)
    if not vehicle then
        outputChatBox("Failed to create vehicle!", player, 255, 0, 0)
        return
    end
    
    -- Insert into database
    executeSQL([[INSERT INTO vehicles (owner_id, model, x, y, z, rx, ry, rz, plate)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)]], 
        players[player].id, modelNum, x + 5, y, z, rx, ry, rz, "ACNR" .. math.random(1000, 9999))
    
    -- Get vehicle ID
    local result = executeSQL("SELECT last_insert_rowid() as id")
    local vehicleId = result[1].id
    
    -- Store vehicle data
    vehicles[vehicle] = {
        id = vehicleId,
        ownerId = players[player].id,
        model = modelNum,
        fuel = 100,
        plate = "ACNR" .. math.random(1000, 9999)
    }
    
    -- Add to player vehicles
    if not playerVehicles[players[player].id] then
        playerVehicles[players[player].id] = {}
    end
    table.insert(playerVehicles[players[player].id], vehicle)
    
    -- Deduct money
    players[player].money = players[player].money - price
    setPlayerMoney(player, players[player].money)
    
    outputChatBox("Vehicle purchased successfully for $" .. price .. "!", player, 0, 255, 0)
    outputChatBox("Use /v park to save your vehicle position.", player, 255, 255, 0)
end

-- List player vehicles
function listPlayerVehicles(player)
    local playerId = players[player].id
    if not playerVehicles[playerId] or #playerVehicles[playerId] == 0 then
        outputChatBox("You don't own any vehicles!", player, 255, 0, 0)
        return
    end
    
    outputChatBox("=== Your Vehicles ===", player, 255, 255, 0)
    for i, vehicle in ipairs(playerVehicles[playerId]) do
        local vData = vehicles[vehicle]
        if vData then
            local vehicleName = getVehicleName(vehicle)
            outputChatBox(string.format("%d. %s (ID: %d)", i, vehicleName, vData.id), player, 255, 255, 255)
        end
    end
end

-- Spawn player vehicle
function spawnPlayerVehicle(player, vehicleId)
    local playerId = players[player].id
    if not playerVehicles[playerId] then
        outputChatBox("You don't own any vehicles!", player, 255, 0, 0)
        return
    end
    
    local targetVehicle = nil
    for _, vehicle in ipairs(playerVehicles[playerId]) do
        if vehicles[vehicle] and vehicles[vehicle].id == vehicleId then
            targetVehicle = vehicle
            break
        end
    end
    
    if not targetVehicle then
        outputChatBox("Vehicle not found!", player, 255, 0, 0)
        return
    end
    
    -- Get player position
    local x, y, z = getElementPosition(player)
    
    -- Respawn vehicle
    local rx, ry, rz = getElementRotation(targetVehicle)
    setElementPosition(targetVehicle, x + 5, y, z)
    setElementRotation(targetVehicle, rx, ry, rz)
    fixVehicle(targetVehicle)
    
    outputChatBox("Vehicle spawned!", player, 0, 255, 0)
end

-- Park vehicle
function parkVehicle(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("You must be in a vehicle to park it!", player, 255, 0, 0)
        return
    end
    
    if not vehicles[vehicle] or vehicles[vehicle].ownerId ~= players[player].id then
        outputChatBox("This vehicle doesn't belong to you!", player, 255, 0, 0)
        return
    end
    
    -- Get vehicle position
    local x, y, z = getElementPosition(vehicle)
    local rx, ry, rz = getElementRotation(vehicle)
    
    -- Update database
    executeSQL([[UPDATE vehicles SET x = ?, y = ?, z = ?, rx = ?, ry = ?, rz = ?
        WHERE id = ?]], x, y, z, rx, ry, rz, vehicles[vehicle].id)
    
    outputChatBox("Vehicle parked! Position saved.", player, 0, 255, 0)
end

-- Lock/unlock vehicle
function lockVehicle(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("You must be in a vehicle to lock it!", player, 255, 0, 0)
        return
    end
    
    if not vehicles[vehicle] or vehicles[vehicle].ownerId ~= players[player].id then
        outputChatBox("This vehicle doesn't belong to you!", player, 255, 0, 0)
        return
    end
    
    local currentLock = isVehicleLocked(vehicle)
    setVehicleLocked(vehicle, not currentLock)
    
    -- Update database
    executeSQL("UPDATE vehicles SET locked = ? WHERE id = ?", not currentLock and 1 or 0, vehicles[vehicle].id)
    
    outputChatBox("Vehicle " .. (not currentLock and "locked" or "unlocked") .. "!", player, 0, 255, 0)
end

-- Fix vehicle
function fixVehicle(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("You must be in a vehicle to fix it!", player, 255, 0, 0)
        return
    end
    
    if not vehicles[vehicle] or vehicles[vehicle].ownerId ~= players[player].id then
        outputChatBox("This vehicle doesn't belong to you!", player, 255, 0, 0)
        return
    end
    
    local fixCost = 500
    if players[player].money < fixCost then
        outputChatBox("You need $" .. fixCost .. " to fix your vehicle!", player, 255, 0, 0)
        return
    end
    
    -- Fix vehicle
    fixVehicle(vehicle)
    setElementHealth(vehicle, 1000)
    
    -- Update database
    executeSQL("UPDATE vehicles SET health = 1000 WHERE id = ?", vehicles[vehicle].id)
    
    -- Deduct money
    players[player].money = players[player].money - fixCost
    setPlayerMoney(player, players[player].money)
    
    outputChatBox("Vehicle fixed for $" .. fixCost .. "!", player, 0, 255, 0)
end

-- Handle vehicle destroy
addEventHandler("onVehicleExplode", rootElement, function()
    local vehicle = source
    if vehicles[vehicle] then
        -- Schedule vehicle respawn
        setTimer(function()
            if isElement(vehicle) then
                fixVehicle(vehicle)
                setElementHealth(vehicle, 1000)
                executeSQL("UPDATE vehicles SET health = 1000 WHERE id = ?", vehicles[vehicle].id)
            end
        end, 30000, 1)
    end
end)
```
```lua
-- ACNR MTA - House Management System
-- Converted from ACNR-OPENMP

local houses = {} -- House data cache
local playerHouses = {} -- Player owned houses
local housePickups = {} -- House pickup elements

-- Initialize house system
function initializeHouseSystem()
    -- Create house data table
    executeSQL([[CREATE TABLE IF NOT EXISTS houses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner_id INTEGER,
        name TEXT NOT NULL,
        x REAL NOT NULL,
        y REAL NOT NULL,
        z REAL NOT NULL,
        interior INTEGER DEFAULT 0,
        price INTEGER NOT NULL,
        locked INTEGER DEFAULT 0,
        purchase_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (owner_id) REFERENCES players(id)
    )]])
    
    -- Load existing houses
    loadHouses()
    
    outputServerLog("House system initialized")
end

-- Load houses from database
function loadHouses()
    local result = executeSQL("SELECT * FROM houses")
    for _, houseData in ipairs(result) do
        local house = {
            id = houseData.id,
            ownerId = houseData.owner_id,
            name = houseData.name,
            x = houseData.x,
            y = houseData.y,
            z = houseData.z,
            interior = houseData.interior,
            price = houseData.price,
            locked = houseData.locked == 1
        }
        
        houses[houseData.id] = house
        
        -- Create pickup for house
        local pickup = createPickup(house.x, house.y, house.z, 3, 1273)
        housePickups[houseData.id] = pickup
        
        -- Add to player houses if owned
        if houseData.owner_id then
            if not playerHouses[houseData.owner_id] then
                playerHouses[houseData.owner_id] = {}
            end
            table.insert(playerHouses[houseData.owner_id], houseData.id)
        end
    end
end

-- House commands
addCommandHandler("houses", function(player)
    outputChatBox("=== House Commands ===", player, 255, 255, 0)
    outputChatBox("/h buy - Buy the house you're at", player, 255, 255, 255)
    outputChatBox("/h sell - Sell your current house", player, 255, 255, 255)
    outputChatBox("/h list - List your houses", player, 255, 255, 255)
    outputChatBox("/h lock - Lock/unlock your house", player, 255, 255, 255)
    outputChatBox("/h enter - Enter a house", player, 255, 255, 255)
    outputChatBox("/h exit - Exit a house", player, 255, 255, 255)
    outputChatBox("/h create [name] [price] - Create a house (Admin)", player, 255, 255, 255)
end)

-- House command handler
addCommandHandler("h", function(player, cmd, subcmd, ...)
    if not players[player] or not players[player].isLoggedIn then
        outputChatBox("You must be logged in to use house commands!", player, 255, 0, 0)
        return
    end
    
    local args = {...}
    
    if subcmd == "buy" then
        buyHouse(player)
    elseif subcmd == "sell" then
        sellHouse(player)
    elseif subcmd == "list" then
        listPlayerHouses(player)
    elseif subcmd == "lock" then
        lockHouse(player)
    elseif subcmd == "enter" then
        enterHouse(player)
    elseif subcmd == "exit" then
        exitHouse(player)
    elseif subcmd == "create" then
        if players[player].adminLevel < 1 then
            outputChatBox("You don't have permission to use this command!", player, 255, 0, 0)
            return
        end
        local name = args[1]
        local price = args[2]
        if not name or not price then
            outputChatBox("Usage: /h create [name] [price]", player, 255, 255, 0)
            return
        end
        createHouse(player, name, tonumber(price))
    else
        outputChatBox("Invalid command! Use /houses to see available commands.", player, 255, 0, 0)
    end
end)

-- Buy house function
function buyHouse(player)
    local x, y, z = getElementPosition(player)
    
    -- Find nearest house
    local nearestHouse = nil
    local nearestDistance = 10 -- Maximum distance to interact
    
    for _, house in pairs(houses) do
        local distance = getDistanceBetweenPoints3D(x, y, z, house.x, house.y, house.z)
        if distance < nearestDistance then
            nearestDistance = distance
            nearestHouse = house
        end
    end
    
    if not nearestHouse then
        outputChatBox("No house nearby! Move closer to a house pickup.", player, 255, 0, 0)
        return
    end
    
    if nearestHouse.ownerId then
        outputChatBox("This house is already owned!", player, 255, 0, 0)
        return
    end
    
    if players[player].money < nearestHouse.price then
        outputChatBox("You need $" .. nearestHouse.price .. " to buy this house!", player, 255, 0, 0)
        return
    end
    
    -- Update database
    executeSQL("UPDATE houses SET owner_id = ? WHERE id = ?", players[player].id, nearestHouse.id)
    
    -- Update house data
    nearestHouse.ownerId = players[player].id
    
    -- Add to player houses
    if not playerHouses[players[player].id] then
        playerHouses[players[player].id] = {}
    end
    table.insert(playerHouses[players[player].id], nearestHouse.id)
    
    -- Deduct money
    players[player].money = players[player].money - nearestHouse.price
    setPlayerMoney(player, players[player].money)
    
    outputChatBox("House '" .. nearestHouse.name .. "' purchased for $" .. nearestHouse.price .. "!", player, 0, 255, 0)
    outputChatBox("Use /h enter to enter your house.", player, 255, 255, 0)
end

-- Sell house function
function sellHouse(player)
    local x, y, z = getElementPosition(player)
    
    -- Find nearest house owned by player
    local nearestHouse = nil
    local nearestDistance = 10
    
    for _, house in pairs(houses) do
        if house.ownerId == players[player].id then
            local distance = getDistanceBetweenPoints3D(x, y, z, house.x, house.y, house.z)
            if distance < nearestDistance then
                nearestDistance = distance
                nearestHouse = house
            end
        end
    end
    
    if not nearestHouse then
        outputChatBox("You don't own any house nearby!", player, 255, 0, 0)
        return
    end
    
    -- Calculate sell price (70% of original price)
    local sellPrice = math.floor(nearestHouse.price * 0.7)
    
    -- Update database
    executeSQL("UPDATE houses SET owner_id = NULL WHERE id = ?", nearestHouse.id)
    
    -- Update house data
    nearestHouse.ownerId = nil
    
    -- Remove from player houses
    if playerHouses[players[player].id] then
        for i, houseId in ipairs(playerHouses[players[player].id]) do
            if houseId == nearestHouse.id then
                table.remove(playerHouses[players[player].id], i)
                break
            end
        end
    end
    
    -- Add money
    players[player].money = players[player].money + sellPrice
    setPlayerMoney(player, players[player].money)
    
    outputChatBox("House '" .. nearestHouse.name .. "' sold for $" .. sellPrice .. "!", player, 0, 255, 0)
end

-- List player houses
function listPlayerHouses(player)
    local playerId = players[player].id
    if not playerHouses[playerId] or #playerHouses[playerId] == 0 then
        outputChatBox("You don't own any houses!", player, 255, 0, 0)
        return
    end
    
    outputChatBox("=== Your Houses ===", player, 255, 255, 0)
    for i, houseId in ipairs(playerHouses[playerId]) do
        local house = houses[houseId]
        if house then
            outputChatBox(string.format("%d. %s (Price: $%d)", i, house.name, house.price), player, 255, 255, 255)
        end
    end
end

-- Lock/unlock house
function lockHouse(player)
    local x, y, z = getElementPosition(player)
    
    -- Find nearest house owned by player
    local nearestHouse = nil
    local nearestDistance = 10
    
    for _, house in pairs(houses) do
        if house.ownerId == players[player].id then
            local distance = getDistanceBetweenPoints3D(x, y, z, house.x, house.y, house.z)
            if distance < nearestDistance then
                nearestDistance = distance
                nearestHouse = house
            end
        end
    end
    
    if not nearestHouse then
        outputChatBox("You don't own any house nearby!", player, 255, 0, 0)
        return
    end
    
    -- Toggle lock
    nearestHouse.locked = not nearestHouse.locked
    
    -- Update database
    executeSQL("UPDATE houses SET locked = ? WHERE id = ?", nearestHouse.locked and 1 or 0, nearestHouse.id)
    
    outputChatBox("House '" .. nearestHouse.name .. "' " .. (nearestHouse.locked and "locked" or "unlocked") .. "!", player, 0, 255, 0)
end

-- Enter house
function enterHouse(player)
    local x, y, z = getElementPosition(player)
    
    -- Find nearest house
    local nearestHouse = nil
    local nearestDistance = 5
    
    for _, house in pairs(houses) do
        local distance = getDistanceBetweenPoints3D(x, y, z, house.x, house.y, house.z)
        if distance < nearestDistance then
            nearestDistance = distance
            nearestHouse = house
        end
    end
    
    if not nearestHouse then
        outputChatBox("No house nearby!", player, 255, 0, 0)
        return
    end
    
    -- Check if house is locked and player doesn't own it
    if nearestHouse.locked and nearestHouse.ownerId ~= players[player].id then
        outputChatBox("This house is locked!", player, 255, 0, 0)
        return
    end
    
    -- Set interior (simplified - using predefined interiors)
    local interiors = {
        {x = 2233.69, y = -1115.41, z = 1050.88, int = 5}, -- House interior 1
        {x = 2262.83, y = -1137.71, z = 1050.63, int = 10}, -- House interior 2
        {x = 2196.15, y = -1204.35, z = 1049.02, int = 1}, -- House interior 3
        {x = 2282.91, y = -1139.48, z = 1050.90, int = 11}, -- House interior 4
        {x = 2237.58, y = -1081.55, z = 1049.02, int = 2} -- House interior 5
    }
    
    local interior = interiors[(nearestHouse.id % #interiors) + 1]
    
    -- Set player position and interior
    setElementPosition(player, interior.x, interior.y, interior.z)
    setElementInterior(player, interior.int)
    
    -- Store house ID for exit
    setElementData(player, "currentHouse", nearestHouse.id)
    
    outputChatBox("You entered '" .. nearestHouse.name .. "'", player, 0, 255, 0)
end

-- Exit house
function exitHouse(player)
    local houseId = getElementData(player, "currentHouse")
    if not houseId then
        outputChatBox("You're not in a house!", player, 255, 0, 0)
        return
    end
    
    local house = houses[houseId]
    if not house then
        outputChatBox("House not found!", player, 255, 0, 0)
        return
    end
    
    -- Set player position outside house
    setElementPosition(player, house.x + 2, house.y, house.z)
    setElementInterior(player, 0)
    
    -- Remove house data
    removeElementData(player, "currentHouse")
    
    outputChatBox("You exited '" .. house.name .. "'", player, 0, 255, 0)
end

-- Create house (admin only)
function createHouse(player, name, price)
    if not name or not price or price <= 0 then
        outputChatBox("Invalid house data!", player, 255, 0, 0)
        return
    end
    
    local x, y, z = getElementPosition(player)
    
    -- Insert into database
    executeSQL([[INSERT INTO houses (name, x, y, z, price)
        VALUES (?, ?, ?, ?, ?)]], name, x, y, z, price)
    
    -- Get house ID
    local result = executeSQL("SELECT last_insert_rowid() as id")
    local houseId = result[1].id
    
    -- Create house data
    local house = {
        id = houseId,
        ownerId = nil,
        name = name,
        x = x,
        y = y,
        z = z,
        interior = 0,
        price = price,
        locked = false
    }
    
    houses[houseId] = house
    
    -- Create pickup
    local pickup = createPickup(x, y, z, 3, 1273)
    housePickups[houseId] = pickup
    
    outputChatBox("House '" .. name .. "' created with price $" .. price, player, 0, 255, 0)
end

-- Handle pickup hit
addEventHandler("onPickupHit", rootElement, function(player)
    local pickup = source
    local houseId = nil
    
    -- Find house associated with pickup
    for id, housePickup in pairs(housePickups) do
        if housePickup == pickup then
            houseId = id
            break
        end
    end
    
    if houseId and houses[houseId] then
        local house = houses[houseId]
        local status = house.ownerId and "Owned" or "For Sale"
        local price = house.ownerId and "N/A" or "$" .. house.price
        
        outputChatBox("=== House Info ===", player, 255, 255, 0)
        outputChatBox("Name: " .. house.name, player, 255, 255, 255)
        outputChatBox("Status: " .. status, player, 255, 255, 255)
        outputChatBox("Price: " .. price, player, 255, 255, 255)
        
        if not house.ownerId then
            outputChatBox("Use /h buy to purchase this house.", player, 255, 255, 0)
        end
    end
end)
```
```lua
-- ACNR MTA - Faction Management System
-- Converted from ACNR-OPENMP

local factions = {} -- Faction data cache
local playerFactions = {} -- Player faction memberships
local factionRanks = {
    [1] = "Member",
    [2] = "Veteran", 
    [3] = "Leader"
}

-- Initialize faction system
function initializeFactionSystem()
    -- Create faction data table
    executeSQL([[CREATE TABLE IF NOT EXISTS factions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        tag TEXT NOT NULL,
        color INTEGER DEFAULT 0xFFFFFF,
        description TEXT,
        bank_balance INTEGER DEFAULT 0,
        creation_date DATETIME DEFAULT CURRENT_TIMESTAMP
    )]])
    
    -- Create faction membership table
    executeSQL([[CREATE TABLE IF NOT EXISTS faction_members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        faction_id INTEGER NOT NULL,
        player_id INTEGER NOT NULL,
        rank INTEGER DEFAULT 1,
        join_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (faction_id) REFERENCES factions(id),
        FOREIGN KEY (player_id) REFERENCES players(id),
        UNIQUE(faction_id, player_id)
    )]])
    
    -- Load existing factions
    loadFactions()
    
    -- Create default factions if none exist
    if #factions == 0 then
        createDefaultFactions()
    end
    
    outputServerLog("Faction system initialized")
end

-- Load factions from database
function loadFactions()
    local result = executeSQL("SELECT * FROM factions")
    for _, factionData in ipairs(result) do
        local faction = {
            id = factionData.id,
            name = factionData.name,
            tag = factionData.tag,
            color = factionData.color,
            description = factionData.description,
            bankBalance = factionData.bank_balance,
            members = {}
        }
        
        factions[factionData.id] = faction
    end
    
    -- Load faction members
    local memberResult = executeSQL("SELECT * FROM faction_members")
    for _, memberData in ipairs(memberResult) do
        if factions[memberData.faction_id] then
            table.insert(factions[memberData.faction_id].members, {
                playerId = memberData.player_id,
                rank = memberData.rank,
                joinDate = memberData.join_date
            })
            
            -- Add to player factions mapping
            if not playerFactions[memberData.player_id] then
                playerFactions[memberData.player_id] = {}
            end
            playerFactions[memberData.player_id] = memberData.faction_id
        end
    end
end

-- Create default factions
function createDefaultFactions()
    local defaultFactions = {
        {name = "Los Santos Police", tag = "LSPD", color = 0x0000FF, description = "Law enforcement agency"},
        {name = "Grove Street", tag = "GS", color = 0x00FF00, description = "Street gang from Grove Street"},
        {name = "Ballas", tag = "B", color = 0xFF00FF, description = "Rival street gang"},
        {name = "Vagos", tag = "V", color = 0xFFFF00, description = "Hispanic street gang"},
        {name = "The Triads", tag = "T", color = 0xFF0000, description = "Chinese crime organization"}
    }
    
    for _, factionData in ipairs(defaultFactions) do
        executeSQL([[INSERT INTO factions (name, tag, color, description)
            VALUES (?, ?, ?, ?)]], 
            factionData.name, factionData.tag, factionData.color, factionData.description)
    end
    
    -- Reload factions
    loadFactions()
end

-- Faction commands
addCommandHandler("factions", function(player)
    outputChatBox("=== Faction Commands ===", player, 255, 255, 0)
    outputChatBox("/f create [name] [tag] - Create a faction ($10000)", player, 255, 255, 255)
    outputChatBox("/f invite [player] - Invite player to faction (Leader)", player, 255, 255, 255)
    outputChatBox("/f join [faction] - Join a faction", player, 255, 255, 255)
    outputChatBox("/f leave - Leave current faction", player, 255, 255, 255)
    outputChatBox("/f kick [player] - Kick player from faction (Leader)", player, 255, 255, 255)
    outputChatBox("/f promote [player] - Promote faction member (Leader)", player, 255, 255, 255)
    outputChatBox("/f demote [player] - Demote faction member (Leader)", player, 255, 255, 255)
    outputChatBox("/f info - Show faction information", player, 255, 255, 255)
    outputChatBox("/f list - List all factions", player, 255, 255, 255)
    outputChatBox("/f chat [message] - Faction chat", player, 255, 255, 255)
    outputChatBox("/f deposit [amount] - Deposit money to faction bank", player, 255, 255, 255)
    outputChatBox("/f withdraw [amount] - Withdraw money from faction bank (Leader)", player, 255, 255, 255)
end)

-- Faction command handler
addCommandHandler("f", function(player, cmd, subcmd, ...)
    if not players[player] or not players[player].isLoggedIn then
        outputChatBox("You must be logged in to use faction commands!", player, 255, 0, 0)
        return
    end
    
    local args = {...}
    
    if subcmd == "create" then
        local name = args[1]
        local tag = args[2]
        if not name or not tag then
            outputChatBox("Usage: /f create [name] [tag]", player, 255, 255, 0)
            return
        end
        createFaction(player, name, tag)
    elseif subcmd == "invite" then
        local targetName = args[1]
        if not targetName then
            outputChatBox("Usage: /f invite [player]", player, 255, 255, 0)
            return
        end
        inviteToFaction(player, targetName)
    elseif subcmd == "join" then
        local factionName = table.concat(args, " ")
        if not factionName then
            outputChatBox("Usage: /f join [faction name]", player, 255, 255, 0)
            return
        end
        joinFaction(player, factionName)
    elseif subcmd == "leave" then
        leaveFaction(player)
    elseif subcmd == "kick" then
        local targetName = args[1]
        if not targetName then
            outputChatBox("Usage: /f kick [player]", player, 255, 255, 0)
            return
        end
        kickFromFaction(player, targetName)
    elseif subcmd == "promote" then
        local targetName = args[1]
        if not targetName then
            outputChatBox("Usage: /f promote [player]", player, 255, 255, 0)
            return
        end
        promoteMember(player, targetName)
elseif subcmd == "demote" then
        local targetName = args[1]
        if not targetName then
            outputChatBox("Usage: /f demote [player]", player, 255, 255, 0)
            return
        end
        demoteMember(player, targetName)
    elseif subcmd == "info" then
        showFactionInfo(player)
    elseif subcmd == "list" then
        listFactions(player)
    elseif subcmd == "chat" then
        local message = table.concat(args, " ")
        if not message then
            outputChatBox("Usage: /f chat [message]", player, 255, 255, 0)
            return
        end
        factionChat(player, message)
    elseif subcmd == "deposit" then
        local amount = args[1]
        if not amount then
            outputChatBox("Usage: /f deposit [amount]", player, 255, 255, 0)
            return
        end
        depositToFaction(player, tonumber(amount))
    elseif subcmd == "withdraw" then
        local amount = args[1]
        if not amount then
            outputChatBox("Usage: /f withdraw [amount]", player, 255, 255, 0)
            return
        end
        withdrawFromFaction(player, tonumber(amount))
    else
        outputChatBox("Invalid command! Use /factions to see available commands.", player, 255, 0, 0)
    end
end)

-- Create faction function
function createFaction(player, name, tag)
    if players[player].money < 10000 then
        outputChatBox("You need $10000 to create a faction!", player, 255, 0, 0)
        return
    end
    
    -- Check if faction name already exists
    local result = executeSQL("SELECT id FROM factions WHERE name = ? OR tag = ?", name, tag)
    if #result > 0 then
        outputChatBox("A faction with this name or tag already exists!", player, 255, 0, 0)
        return
    end
    
    -- Insert into database
    executeSQL([[INSERT INTO factions (name, tag, color, description)
        VALUES (?, ?, ?, ?)]], name, tag, 0xFFFFFF, "Custom faction")
    
    -- Get faction ID
    local result = executeSQL("SELECT last_insert_rowid() as id")
    local factionId = result[1].id
    
    -- Create faction data
    local faction = {
        id = factionId,
        name = name,
        tag = tag,
        color = 0xFFFFFF,
        description = "Custom faction",
        bankBalance = 0,
        members = {}
    }
    
    factions[factionId] = faction
    
    -- Add creator as leader
    executeSQL([[INSERT INTO faction_members (faction_id, player_id, rank)
        VALUES (?, ?, ?)]], factionId, players[player].id, 3)
    
    table.insert(faction.members, {
        playerId = players[player].id,
        rank = 3,
        joinDate = os.date("%Y-%m-%d %H:%M:%S")
    })
    
    playerFactions[players[player].id] = factionId
    
    -- Deduct money
    players[player].money = players[player].money - 10000
    setPlayerMoney(player, players[player].money)
    
    outputChatBox("Faction '" .. name .. "' created successfully!", player, 0, 255, 0)
    outputChatBox("You are now the leader of " .. name, player, 0, 255, 0)
end

-- Invite to faction function
function inviteToFaction(player, targetName)
    local playerId = players[player].id
    if not playerFactions[playerId] then
        outputChatBox("You're not in a faction!", player, 255, 0, 0)
        return
    end
    
    local faction = factions[playerFactions[playerId]]
    local playerRank = getFactionRank(playerId, faction.id)
    
    if playerRank < 3 then
        outputChatBox("Only faction leaders can invite members!", player, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", player, 255, 0, 0)
        return
    end
    
    if not players[target] or not players[target].isLoggedIn then
        outputChatBox("Target player is not logged in!", player, 255, 0, 0)
        return
    end
    
    if playerFactions[players[target].id] then
        outputChatBox("This player is already in a faction!", player, 255, 0, 0)
        return
    end
    
    -- Send invitation
    setElementData(target, "factionInvite", {factionId = faction.id, inviter = player})
    outputChatBox("You invited " .. getPlayerName(target) .. " to " .. faction.name, player, 0, 255, 0)
    outputChatBox(getPlayerName(player) .. " invited you to join " .. faction.name .. ". Use /f join " .. faction.name .. " to accept.", target, 0, 255, 0)
end

-- Join faction function
function joinFaction(player, factionName)
    if playerFactions[players[player].id] then
        outputChatBox("You're already in a faction! Use /f leave to leave first.", player, 255, 0, 0)
        return
    end
    
    -- Check for invitation
    local invite = getElementData(player, "factionInvite")
    if not invite then
        outputChatBox("You haven't been invited to any faction!", player, 255, 0, 0)
        return
    end
    
    local faction = factions[invite.factionId]
    if not faction or faction.name ~= factionName then
        outputChatBox("Invalid faction name or invitation expired!", player, 255, 0, 0)
        return
    end
    
    -- Add to faction
    executeSQL([[INSERT INTO faction_members (faction_id, player_id, rank)
        VALUES (?, ?, ?)]], faction.id, players[player].id, 1)
    
    table.insert(faction.members, {
        playerId = players[player].id,
        rank = 1,
        joinDate = os.date("%Y-%m-%d %H:%M:%S")
    })
    
    playerFactions[players[player].id] = faction.id
    -- Remove invitation
    removeElementData(player, "factionInvite")
    
    outputChatBox("You joined " .. faction.name .. "!", player, 0, 255, 0)
    
    -- Notify faction members
    for _, member in ipairs(faction.members) do
        local memberPlayer = getPlayerById(member.playerId)
        if memberPlayer and memberPlayer ~= player then
            outputChatBox(getPlayerName(player) .. " joined the faction!", memberPlayer, 0, 255, 0)
        end
    end
end

-- Leave faction function
function leaveFaction(player)
    local playerId = players[player].id
    if not playerFactions[playerId] then
        outputChatBox("You're not in a faction!", player, 255, 0, 0)
        return
    end
    
    local faction = factions[playerFactions[playerId]]
    local playerRank = getFactionRank(playerId, faction.id)
    
    if playerRank == 3 and #faction.members > 1 then
        outputChatBox("You must promote another member to leader before leaving!", player, 255, 0, 0)
        return
    end
    
    -- Remove from faction
    executeSQL("DELETE FROM faction_members WHERE faction_id = ? AND player_id = ?", faction.id, playerId)
    
    -- Remove from faction data
    for i, member in ipairs(faction.members) do
        if member.playerId == playerId then
            table.remove(faction.members, i)
            break
        end
    end
    
    playerFactions[playerId] = nil
    
    -- If faction is empty, delete it
    if #faction.members == 0 then
        executeSQL("DELETE FROM factions WHERE id = ?", faction.id)
        factions[faction.id] = nil
        outputChatBox("You left " .. faction.name .. ". The faction has been disbanded.", player, 255, 255, 0)
    else
        outputChatBox("You left " .. faction.name .. "!", player, 255, 255, 0)
        
        -- Notify faction members
        for _, member in ipairs(faction.members) do
            local memberPlayer = getPlayerById(member.playerId)
            if memberPlayer then
                outputChatBox(getPlayerName(player) .. " left the faction!", memberPlayer, 255, 255, 0)
            end
        end
    end
end

-- Kick from faction function
function kickFromFaction(player, targetName)
    local playerId = players[player].id
    if not playerFactions[playerId] then
        outputChatBox("You're not in a faction!", player, 255, 0, 0)
        return
    end
    
    local faction = factions[playerFactions[playerId]]
    local playerRank = getFactionRank(playerId, faction.id)
    
    if playerRank < 3 then
        outputChatBox("Only faction leaders can kick members!", player, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", player, 255, 0, 0)
        return
    end
    
    if not players[target] or not players[target].isLoggedIn then
        outputChatBox("Target player is not logged in!", player, 255, 0, 0)
        return
    end
    
    if playerFactions[players[target].id] ~= faction.id then
        outputChatBox("This player is not in your faction!", player, 255, 0, 0)
        return
    end
    
    if players[target].id == playerId then
        outputChatBox("You can't kick yourself!", player, 255, 0, 0)
        return
    end
    
    -- Remove from faction
    executeSQL("DELETE FROM faction_members WHERE faction_id = ? AND player_id = ?", faction.id, players[target].id)
    
    -- Remove from faction data
    for i, member in ipairs(faction.members) do
        if member.playerId == players[target].id then
            table.remove(faction.members, i)
            break
        end
    end
    
    playerFactions[players[target].id] = nil
    
    outputChatBox("You kicked " .. getPlayerName(target) .. " from the faction!", player, 255, 255, 0)
    outputChatBox("You were kicked from " .. faction.name .. "!", target, 255, 0, 0)
    
    -- Notify faction members
    for _, member in ipairs(faction.members) do
        local memberPlayer = getPlayerById(member.playerId)
        if memberPlayer and memberPlayer ~= player and memberPlayer ~= target then
            outputChatBox(getPlayerName(target) .. " was kicked from the faction!", memberPlayer, 255, 255, 0)
        end
    end
end

-- Show faction info function
function showFactionInfo(player)
    local playerId = players[player].id
    if not playerFactions[playerId] then
        outputChatBox("You're not in a faction!", player, 255, 0, 0)
        return
    end
    
    local faction = factions[playerFactions[playerId]]
    local playerRank = getFactionRank(playerId, faction.id)
    
    outputChatBox("=== Faction Information ===", player, 255, 255, 0)
    outputChatBox("Name: " .. faction.name, player, 255, 255, 255)
    outputChatBox("Tag: " .. faction.tag, player, 255, 255, 255)
    outputChatBox("Description: " .. (faction.description or "N/A"), player, 255, 255, 255)
    outputChatBox("Members: " .. #faction.members, player, 255, 255, 255)
    outputChatBox("Bank Balance: $" .. faction.bankBalance, player, 255, 255, 255)
    outputChatBox("Your Rank: " .. factionRanks[playerRank], player, 255, 255, 255)
end

-- List factions function
function listFactions(player)
    outputChatBox("=== Active Factions ===", player, 255, 255, 0)
    for _, faction in pairs(factions) do
        outputChatBox(faction.name .. " [" .. faction.tag .. "] - " .. #faction.members .. " members", player, 255, 255, 255)
    end
end

-- Faction chat function
function factionChat(player, message)
    local playerId = players[player].id
    if not playerFactions[playerId] then
        outputChatBox("You're not in a faction!", player, 255, 0, 0)
        return
    end
    
    local faction = factions[playerFactions[playerId]]
    local playerRank = getFactionRank(playerId, faction.id)
    
    local chatMessage = string.format("[%s] %s (%s): %s", 
        faction.tag, getPlayerName(player), factionRanks[playerRank], message)
    
    -- Send to all faction members
    for _, member in ipairs(faction.members) do
        local memberPlayer = getPlayerById(member.
local memberPlayer = getPlayerById(member.playerId)
        if memberPlayer then
            outputChatBox(chatMessage, memberPlayer, faction.color)
        end
    end
end

-- Utility functions
function getFactionRank(playerId, factionId)
    for _, member in ipairs(factions[factionId].members) do
        if member.playerId == playerId then
            return member.rank
        end
    end
    return 0
end

function getPlayerById(playerId)
    for _, player in ipairs(getElementsByType("player")) do
        if players[player] and players[player].id == playerId then
            return player
        end
    end
    return nil
end

-- Deposit to faction function
function depositToFaction(player, amount)
    local playerId = players[player].id
    if not playerFactions[playerId] then
        outputChatBox("You're not in a faction!", player, 255, 0, 0)
        return
    end
    
    if not amount or amount <= 0 then
        outputChatBox("Invalid amount!", player, 255, 0, 0)
        return
    end
    
    if players[player].money < amount then
        outputChatBox("You don't have enough money!", player, 255, 0, 0)
        return
    end
    
    local faction = factions[playerFactions[playerId]]
    
    -- Update faction bank
    faction.bankBalance = faction.bankBalance + amount
    executeSQL("UPDATE factions SET bank_balance = ? WHERE id = ?", faction.bankBalance, faction.id)
    
    -- Deduct from player
    players[player].money = players[player].money - amount
    setPlayerMoney(player, players[player].money)
    
    outputChatBox("You deposited $" .. amount .. " to " .. faction.name .. " bank!", player, 0, 255, 0)
    
    -- Notify faction members
    for _, member in ipairs(faction.members) do
        local memberPlayer = getPlayerById(member.playerId)
        if memberPlayer and memberPlayer ~= player then
            outputChatBox(getPlayerName(player) .. " deposited $" .. amount .. " to faction bank!", memberPlayer, 0, 255, 0)
        end
    end
end

-- Withdraw from faction function
function withdrawFromFaction(player, amount)
    local playerId = players[player].id
    if not playerFactions[playerId] then
        outputChatBox("You're not in a faction!", player, 255, 0, 0)
        return
    end
    
    local faction = factions[playerFactions[playerId]]
    local playerRank = getFactionRank(playerId, faction.id)
    
    if playerRank < 3 then
        outputChatBox("Only faction leaders can withdraw from faction bank!", player, 255, 0, 0)
        return
    end
    
    if not amount or amount <= 0 then
        outputChatBox("Invalid amount!", player, 255, 0, 0)
        return
    end
    
    if faction.bankBalance < amount then
        outputChatBox("Faction bank doesn't have enough money!", player, 255, 0, 0)
        return
    end
    
    -- Update faction bank
    faction.bankBalance = faction.bankBalance - amount
    executeSQL("UPDATE factions SET bank_balance = ? WHERE id = ?", faction.bankBalance, faction.id)
    
    -- Add to player
    players[player].money = players[player].money + amount
    setPlayerMoney(player, players[player].money)
    
    outputChatBox("You withdrew $" .. amount .. " from " .. faction.name .. " bank!", player, 0, 255, 0)
    
    -- Notify faction members
    for _, member in ipairs(faction.members) do
        local memberPlayer = getPlayerById(member.playerId)
        if memberPlayer and memberPlayer ~= player then
            outputChatBox(getPlayerName(player) .. " withdrew $" .. amount .. " from faction bank!", memberPlayer, 255, 255, 0)
        end
    end
end
```
```lua

```
```

```
```

```
```

```
```

```
```

```
```

```
