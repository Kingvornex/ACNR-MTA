
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
