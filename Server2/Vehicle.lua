
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
