local dbConnection = nil

-- Initialize database connection
function initDatabase()
    dbConnection = dbConnect("mysql", 
        "dbname="..DB_CONFIG.database..";host="..DB_CONFIG.host, 
        DB_CONFIG.user, 
        DB_CONFIG.password,
        "autoreconnect=1"
    )
    
    if not dbConnection then
        outputDebugString("Failed to connect to database!", 1)
        return false
    end
    
    -- Create tables if they don't exist
    dbExec(dbConnection, [[
        CREATE TABLE IF NOT EXISTS players (
            id INT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(50) UNIQUE NOT NULL,
            password VARCHAR(255) NOT NULL,
            money INT DEFAULT 0,
            score INT DEFAULT 0,
            admin INT DEFAULT 0,
            last_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]])
    
    dbExec(dbConnection, [[
        CREATE TABLE IF NOT EXISTS vehicles (
            id INT AUTO_INCREMENT PRIMARY KEY,
            model INT NOT NULL,
            x FLOAT NOT NULL,
            y FLOAT NOT NULL,
            z FLOAT NOT NULL,
            rotation FLOAT NOT NULL,
            owner INT,
            color1 INT DEFAULT 0,
            color2 INT DEFAULT 0,
            parked INT DEFAULT 0
        )
    ]])
    
    return true
end

-- Player account functions
function createAccount(username, password)
    local hashedPass = passwordHash(password, "bcrypt", {})
    local query = dbExec(dbConnection, 
        "INSERT INTO players (username, password, money, score) VALUES (?, ?, ?, ?)",
        username, hashedPass, STARTING_MONEY, 0
    )
    return query
end

function verifyAccount(username, password)
    local qh = dbQuery(dbConnection, 
        "SELECT password FROM players WHERE username = ?", 
        username
    )
    local result = dbPoll(qh, -1)
    
    if result and #result > 0 then
        return passwordVerify(password, result[1].password)
    end
    return false
end

function loadPlayerData(username)
    local qh = dbQuery(dbConnection, 
        "SELECT * FROM players WHERE username = ?", 
        username
    )
    local result = dbPoll(qh, -1)
    
    if result and #result > 0 then
        return result[1]
    end
    return nil
end

function savePlayerData(playerId, data)
    dbExec(dbConnection, [[
        UPDATE players SET 
            money = ?, 
            score = ?, 
            admin = ? 
        WHERE username = ?
    ]], data.money, data.score, data.admin, getPlayerName(playerId))
end

-- Vehicle functions
function loadVehicles()
    local vehicles = {}
    local qh = dbQuery(dbConnection, "SELECT * FROM vehicles")
    local result = dbPoll(qh, -1)
    
    if result then
        for i, row in ipairs(result) do
            local veh = createVehicle(row.model, row.x, row.y, row.z, 0, 0, row.rotation)
            setVehicleColor(veh, row.color1, row.color2, 0, 0)
            setElementData(veh, "owner", row.owner)
            setElementData(veh, "dbid", row.id)
            table.insert(vehicles, veh)
        end
    end
    
    return vehicles
end

function saveVehicle(vehicle)
    local x, y, z = getElementPosition(vehicle)
    local rx, ry, rz = getElementRotation(vehicle)
    local r, g, b = getVehicleColor(vehicle)
    local owner = getElementData(vehicle, "owner") or 0
    local dbid = getElementData(vehicle, "dbid")
    
    if dbid then
        dbExec(dbConnection, [[
            UPDATE vehicles SET 
                x = ?, y = ?, z = ?, rotation = ?, 
                color1 = ?, color2 = ?, owner = ?
            WHERE id = ?
        ]], x, y, z, rz, r, g, owner, dbid)
    else
        dbExec(dbConnection, [[
            INSERT INTO vehicles 
            (model, x, y, z, rotation, color1, color2, owner)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ]], getElementModel(vehicle), x, y, z, rz, r, g, owner)
    end
end
