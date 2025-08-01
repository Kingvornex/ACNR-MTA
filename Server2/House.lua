
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
