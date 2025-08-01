
-- ACNR MTA - Database Management System
-- Converted from ACNR-OPENMP

local dbConnection = nil
local dbHost = nil
local dbUser = nil
local dbPass = nil
local dbName = nil

-- Initialize database connection
function initDatabase()
    -- Get database settings from config
    dbHost = get("*mysql_host") or "localhost"
    dbUser = get("*mysql_user") or "root"
    dbPass = get("*mysql_pass") or ""
    dbName = get("*mysql_db") or "acnr_mta"
    
    -- Try to connect to MySQL database
    if not dbConnect then
        outputServerLog("WARNING: MySQL module not available, falling back to SQLite")
        return initSQLite()
    end
    
    dbConnection = dbConnect("mysql", "dbname=" .. dbName .. ";host=" .. dbHost, dbUser, dbPass)
    
    if dbConnection then
        outputServerLog("Connected to MySQL database: " .. dbName)
        return true
    else
        outputServerLog("WARNING: Failed to connect to MySQL, falling back to SQLite")
        return initSQLite()
    end
end

-- Initialize SQLite database
function initSQLite()
    dbConnection = dbConnect("sqlite", "database.db")
    
    if dbConnection then
        outputServerLog("Connected to SQLite database")
        return true
    else
        outputServerLog("ERROR: Failed to connect to SQLite database")
        return false
    end
end

-- Execute SQL query
function executeSQL(query, ...)
    if not dbConnection then
        outputServerLog("ERROR: Database not connected")
        return {}
    end
    
    local args = {...}
    
    -- Prepare query with parameters
    if #args > 0 then
        query = dbPrepareString(dbConnection, query, unpack(args))
    end
    
    -- Execute query
    local result = dbQuery(dbConnection, query)
    local rows = dbPoll(result, -1) -- Wait indefinitely for result
    
    if rows == false then
        outputServerLog("ERROR: SQL query failed: " .. query)
        return {}
    elseif rows == nil then
        return {} -- No results (for INSERT, UPDATE, etc.)
    end
    
    return rows
end

-- Get database connection
function getConnection()
    return dbConnection
end

-- Database utility functions
function escapeString(str)
    if not str then return "" end
    return dbConnection and dbEscapeString(dbConnection, str) or str
end

-- Database maintenance functions
function optimizeDatabase()
    if not dbConnection then return end
    
    if get("*mysql_host") then
        executeSQL("OPTIMIZE TABLE players, vehicles, houses, factions, faction_members")
    else
        executeSQL("VACUUM")
    end
    
    outputServerLog("Database optimized")
end

-- Backup database
function backupDatabase()
    if not dbConnection then return end
    
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local backupFile = "backups/acnr_backup_" .. timestamp .. ".sql"
    
    -- Create backup directory if it doesn't exist
    if not fileExists("backups/") then
        fileCreate("backups/")
    end
    
    if get("*mysql_host") then
        -- MySQL backup (simplified - in production use mysqldump)
        local tables = {"players", "vehicles", "houses", "factions", "faction_members"}
        local backupContent = "-- ACNR MTA Database Backup - " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\n"
        
        for _, tableName in ipairs(tables) do
            backupContent = backupContent .. "-- Table: " .. tableName .. "\n"
            local result = executeSQL("SELECT * FROM " .. tableName)
            
            if #result > 0 then
                local columns = {}
                for k, v in pairs(result[1]) do
                    table.insert(columns, k)
                end
                
                backupContent = backupContent .. "INSERT INTO " .. tableName .. " (" .. table.concat(columns, ", ") .. ") VALUES\n"
                
                for i, row in ipairs(result) do
                    local values = {}
                    for _, column in ipairs(columns) do
                        local value = row[column]
                        if type(value) == "string" then
                            table.insert(values, "'" .. escapeString(value) .. "'")
                        elseif value == nil then
                            table.insert(values, "NULL")
                        else
                            table.insert(values, tostring(value))
                        end
                    end
                    
                    backupContent = backupContent .. "(" .. table.concat(values, ", ") .. ")"
                    if i < #result then
                        backupContent = backupContent .. ",\n"
                    else
                        backupContent = backupContent .. ";\n\n"
                    end
                end
            end
        end
        
        local file = fileCreate(backupFile)
        if file then
            fileWrite(file, backupContent)
            fileClose(file)
            outputServerLog("Database backup created: " .. backupFile)
    else
      outputServerLog("ERROR: Failed to create backup file: " .. backupFile)
        end
    else
        -- SQLite backup
        local sourceFile = fileOpen("database.db")
        if sourceFile then
            local sourceSize = fileGetSize(sourceFile)
            local sourceData = fileRead(sourceFile, sourceSize)
            fileClose(sourceFile)
            
            local backupFile = fileCreate(backupFile)
            if backupFile then
                fileWrite(backupFile, sourceData)
                fileClose(backupFile)
                outputServerLog("Database backup created: " .. backupFile)
            else
                outputServerLog("ERROR: Failed to create backup file: " .. backupFile)
            end
        else
            outputServerLog("ERROR: Failed to open source database file")
        end
    end
end

-- Database cleanup functions
function cleanupInactivePlayers()
    if not dbConnection then return end
    
    -- Remove players who haven't logged in for 30 days
    local cutoffDate = os.date("%Y-%m-%d %H:%M:%S", os.time() - 30 * 24 * 60 * 60)
    local result = executeSQL("DELETE FROM players WHERE last_login < ?", cutoffDate)
    
    outputServerLog("Cleaned up " .. #result .. " inactive players")
end

function cleanupOrphanedData()
    if not dbConnection then return end
    
    -- Remove vehicles without owners
    executeSQL("DELETE FROM vehicles WHERE owner_id NOT IN (SELECT id FROM players)")
    
    -- Remove houses without owners
    executeSQL("DELETE FROM houses WHERE owner_id NOT IN (SELECT id FROM players)")
    
    -- Remove faction memberships without valid players or factions
    executeSQL("DELETE FROM faction_members WHERE player_id NOT IN (SELECT id FROM players)")
    executeSQL("DELETE FROM faction_members WHERE faction_id NOT IN (SELECT id FROM factions)")
    
    outputServerLog("Cleaned up orphaned data")
end

-- Database statistics
function getDatabaseStats()
    if not dbConnection then return nil end
    
    local stats = {}
    
    -- Player count
    local playerResult = executeSQL("SELECT COUNT(*) as count FROM players")
    stats.players = playerResult[1].count
    
    -- Vehicle count
    local vehicleResult = executeSQL("SELECT COUNT(*) as count FROM vehicles")
    stats.vehicles = vehicleResult[1].count
    
    -- House count
    local houseResult = executeSQL("SELECT COUNT(*) as count FROM houses")
    stats.houses = houseResult[1].count
    
    -- Faction count
    local factionResult = executeSQL("SELECT COUNT(*) as count FROM factions")
    stats.factions = factionResult[1].count
    
    -- Total money in economy
    local moneyResult = executeSQL("SELECT SUM(money) as total FROM players")
    stats.totalMoney = moneyResult[1].total or 0
    
    -- Most active players
    local activeResult = executeSQL("SELECT username, playtime FROM players ORDER BY playtime DESC LIMIT 5")
    stats.mostActive = activeResult
    
    return stats
end

-- Scheduled maintenance
setTimer(function()
    -- Run maintenance tasks every hour
    optimizeDatabase()
    
    -- Run cleanup every 24 hours
    if math.random(1, 24) == 1 then
        cleanupInactivePlayers()
        cleanupOrphanedData()
    end
    
    -- Create backup every 6 hours
    if math.random(1, 6) == 1 then
        backupDatabase()
    end
end, 3600000, 0) -- Every hour

-- Database command for admins
addCommandHandler("database", function(player)
    if not players[player] or not players[player].isLoggedIn then
        outputChatBox("You must be logged in to use database commands!", player, 255, 0, 0)
        return
    end
    
    if players[player].adminLevel < 3 then
        outputChatBox("You don't have permission to use database commands!", player, 255, 0, 0)
        return
    end
    
    outputChatBox("=== Database Commands ===", player, 255, 255, 0)
    outputChatBox("/db stats - Show database statistics", player, 255, 255, 255)
    outputChatBox("/db optimize - Optimize database", player, 255, 255, 255)
    outputChatBox("/db backup - Create database backup", player, 255, 255, 255)
    outputChatBox("/db cleanup - Clean up inactive data", player, 255, 255, 255)
    outputChatBox("/db reset [table] - Reset table (DANGEROUS)", player, 255, 255, 255)
end)

addCommandHandler("db", function(player, cmd, subcmd, ...)
    if not players[player] or not players[player].isLoggedIn then
        outputChatBox("You must be logged in to use database commands!", player, 255, 0, 0)
        return
    end
    
    if players[player].adminLevel < 3 then
        outputChatBox("You don't have permission to use database commands!", player, 255, 0, 0)
        return
    end
    
    local args = {...}
    
    if subcmd == "stats" then
        showDatabaseStats(player)
    elseif subcmd == "optimize" then
        optimizeDatabase()
        outputChatBox("Database optimized!", player, 0, 255, 0)
    elseif subcmd == "backup" then
        backupDatabase()
        outputChatBox("Database backup created!", player, 0, 255, 0)
    elseif subcmd == "cleanup" then
        cleanupInactivePlayers()
        cleanupOrphanedData()
        outputChatBox("Database cleanup completed!", player, 0, 255, 0)
    elseif subcmd == "reset" then
        if players[player].adminLevel < 4 then
            outputChatBox("Only owners can reset database tables!", player, 255, 0, 0)
            return
        end
        
        local tableName = args[1]
        if not tableName then
            outputChatBox("Usage: /db reset [table]", player, 255, 255, 0)
            return
        end
        
        local validTables = {"players", "vehicles", "houses", "factions", "faction_members"}
        local isValid = false
        for _, validTable in ipairs(validTables) do
            if validTable == tableName then
                isValid = true
                break
            end
      end
      if not isValid then
            outputChatBox("Invalid table name!", player, 255, 0, 0)
            return
        end
        
        executeSQL("DELETE FROM " .. tableName)
        outputChatBox("Table '" .. tableName .. "' reset!", player, 0, 255, 0)
        outputChatBox("WARNING: This action cannot be undone!", player, 255, 0, 0)
    else
        outputChatBox("Invalid command! Use /database to see available commands.", player, 255, 0, 0)
    end
end)

function showDatabaseStats(player)
    local stats = getDatabaseStats()
    if not stats then
        outputChatBox("Failed to get database statistics!", player, 255, 0, 0)
        return
    end
    
    outputChatBox("=== Database Statistics ===", player, 255, 255, 0)
    outputChatBox("Players: " .. stats.players, player, 255, 255, 255)
    outputChatBox("Vehicles: " .. stats.vehicles, player, 255, 255, 255)
    outputChatBox("Houses: " .. stats.houses, player, 255, 255, 255)
    outputChatBox("Factions: " .. stats.factions, player, 255, 255, 255)
    outputChatBox("Total Money: $" .. stats.totalMoney, player, 255, 255, 255)
    
    outputChatBox("=== Most Active Players ===", player, 255, 255, 0)
    for _, playerData in ipairs(stats.mostActive) do
        local playtimeHours = math.floor(playerData.playtime / 3600)
        outputChatBox(playerData.username .. " - " .. playtimeHours .. " hours", player, 255, 255, 255)
    end
end

-- Export functions
exports("executeSQL", executeSQL)
exports("getConnection", getConnection)
