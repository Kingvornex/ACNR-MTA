
-- ACNR MTA - GUI Management System
-- Converted from ACNR-OPENMP

local guiElements = {}
local windows = {}

-- Initialize GUI system
function initializeGUISystem()
    -- Create fonts
    guiElements.fonts = {
        default = guiCreateFont("assets/fonts/default.ttf", 10),
        title = guiCreateFont("assets/fonts/title.ttf", 14),
        small = guiCreateFont("assets/fonts/small.ttf", 8)
    }
    
    -- Create colors
    guiElements.colors = {
        background = tocolor(0, 0, 0, 200),
        foreground = tocolor(255, 255, 255, 255),
        button = tocolor(0, 100, 200, 255),
        buttonHover = tocolor(0, 150, 255, 255),
        success = tocolor(0, 255, 0, 255),
        error = tocolor(255, 0, 0, 255),
        warning = tocolor(255, 255, 0, 255)
    }
    
    outputDebugString("GUI System Initialized")
end

-- Create login window
function createLoginWindow()
    -- Close existing login window
    if windows.login then
        destroyElement(windows.login.window)
        windows.login = nil
    end
    
    -- Create window
    local screenWidth, screenHeight = guiGetScreenSize()
    local windowWidth, windowHeight = 400, 300
    local x = (screenWidth - windowWidth) / 2
    local y = (screenHeight - windowHeight) / 2
    
    windows.login = {}
    windows.login.window = guiCreateWindow(x, y, windowWidth, windowHeight, "ACNR MTA - Login", false)
    guiWindowSetSizable(windows.login.window, false)
    
    -- Create labels
    guiCreateLabel(20, 30, 360, 20, "Welcome to ACNR MTA!", false, windows.login.window)
    guiLabelSetHorizontalAlign(guiCreateLabel(20, 50, 360, 20, "Please login or register to continue", false, windows.login.window), "center", false)
    
    guiCreateLabel(20, 90, 100, 20, "Username:", false, windows.login.window)
    guiCreateLabel(20, 120, 100, 20, "Password:", false, windows.login.window)
    
    -- Create inputs
    windows.login.username = guiCreateEdit(120, 90, 250, 25, "", false, windows.login.window)
    windows.login.password = guiCreateEdit(120, 120, 250, 25, "", false, windows.login.window)
    guiEditSetMasked(windows.login.password, true)
    
    -- Create buttons
    windows.login.loginBtn = guiCreateButton(20, 160, 110, 30, "Login", false, windows.login.window)
    windows.login.registerBtn = guiCreateButton(140, 160, 110, 30, "Register", false, windows.login.window)
    windows.login.cancelBtn = guiCreateButton(260, 160, 110, 30, "Cancel", false, windows.login.window)
    
    -- Create status label
    windows.login.status = guiCreateLabel(20, 200, 360, 20, "", false, windows.login.window)
    guiLabelSetHorizontalAlign(windows.login.status, "center", false)
    
    -- Add event handlers
    addEventHandler("onClientGUIClick", windows.login.loginBtn, function()
        local username = guiGetText(windows.login.username)
        local password = guiGetText(windows.login.password)
        
        if username == "" or password == "" then
            guiSetText(windows.login.status, "Please enter username and password")
            guiLabelSetColor(windows.login.status, 255, 0, 0)
            return
        end
        
        triggerServerEvent("playerLogin", localPlayer, username, password)
        guiSetText(windows.login.status, "Logging in...")
        guiLabelSetColor(windows.login.status, 255, 255, 0)
    end, false)
    
    addEventHandler("onClientGUIClick", windows.login.registerBtn, function()
        local username = guiGetText(windows.login.username)
        local password = guiGetText(windows.login.password)
        
        if username == "" or password == "" then
            guiSetText(windows.login.status, "Please enter username and password")
            guiLabelSetColor(windows.login.status, 255, 0, 0)
            return
        end
        
        triggerServerEvent("playerRegister", localPlayer, username, password)
        guiSetText(windows.login.status, "Registering...")
        guiLabelSetColor(windows.login.status, 255, 255, 0)
    end, false)
    
    addEventHandler("onClientGUIClick", windows.login.cancelBtn, function()
        destroyElement(windows.login.window)
        windows.login = nil
    end, false)
    
    -- Handle login response
    addEvent("loginResponse", true)
    addEventHandler("loginResponse", rootElement, function(success, message)
        if windows.login then
            guiSetText(windows.login.status, message)
            guiLabelSetColor(windows.login.status, success and 0 or 255, success and 255 or 0, 0)
            
            if success then
                setTimer(function()
                    if windows.login then
                        destroyElement(windows.login.window)
                        windows.login = nil
                    end
                end, 2000, 1)
            end
        end
    end)
    
    -- Show window
    guiSetVisible(windows.login.window, true)
    guiBringToFront(windows.login.window)
    showCursor(true)
end

-- Create help window
function createHelpWindow()
    -- Close existing help window
    if windows.help then
        destroyElement(windows.help.window)
        windows.help = nil
    end
    
    -- Create window
    local screenWidth, screenHeight = guiGetScreenSize()
    local windowWidth, windowHeight = 600, 400
    local x = (screenWidth - windowWidth) / 2
    local y = (screenHeight - windowHeight) / 2
    
    windows.help = {}
    windows.help.window = guiCreateWindow(x, y, windowWidth, windowHeight, "ACNR MTA - Help", false)
    guiWindowSetSizable(windows.help.window, false)
    
    -- Create tab panel
    windows.help.tabPanel = guiCreateTabPanel(10, 30, windowWidth - 20, windowHeight - 70, false, windows.help.window)
    
    -- Create tabs
    local tabGeneral = guiCreateTab("General", windows.help.tabPanel)
    local tabCommands = guiCreateTab("Commands", windows.help.tabPanel)
    local tabControls = guiCreateTab("Controls", windows.help.tabPanel)
    local tabRules = guiCreateTab("Rules", windows.help.tabPanel)
    
    -- General tab content
    local generalText = [[ACNR MTA - General Information

Welcome to ACNR MTA! This is a converted version of the ACNR-OPENMP game mode, adapted for Multi Theft Auto.

Features:
• Player accounts with statistics
• Vehicle ownership and customization
• House buying and management
• Faction system with ranks
• Economy with money system
• Admin commands for server management

Getting Started:
1. Register an account using /register
2. Login with your credentials
3. Explore the world and interact with other players
4. Buy vehicles and houses to build your empire
5. Join or create factions for group activities

Tips:
• Use F1 to open this help window
• Use F2 to view your statistics
• Use F3 to open inventory (when implemented)
• Use F4 to toggle FPS counter
• Use F5 to open settings

Good luck and have fun!]]
    
    windows.help.generalMemo = guiCreateMemo(10, 10, windowWidth - 40, windowHeight - 110, generalText, false, tabGeneral)
    guiMemoSetReadOnly(windows.help.generalMemo, true)
    
    -- Commands tab content
    local commandsText = [[ACNR MTA - Commands

Player Commands:
• /register [username] [password] - Register new account
• /login [username] [password] - Login to account
• /stats - View your statistics
• /pay [player] [amount] - Send money to another player
• /help - Show this help window

Vehicle Commands:
• /v buy [model] - Buy a vehicle
• /v sell - Sell your current vehicle
• /v list - List your vehicles
• /v spawn [id] - Spawn your vehicle
• /v park - Park your current vehicle
• /v lock - Lock/unlock your vehicle
• /v fix - Repair your vehicle

House Commands:
• /h buy - Buy the house you're at
• /h sell - Sell your current house
• /h list - List your houses
• /h lock - Lock/unlock your house
• /h enter - Enter a house
• /h exit - Exit a house

Faction Commands:
• /f create [name] [tag] - Create a faction ($10000)
• /f invite [player] - Invite player to faction (Leader)
• /f join [faction] - Join a faction
• /f leave - Leave current faction
• /f kick [player] - Kick player from faction (Leader)
• /f promote [player] - Promote faction member (Leader)
• /f demote [player] - Demote faction member (Leader)
• /f info - Show faction information
• /f list - List all factions
• /f chat [message] - Faction chat
• /f deposit [amount] - Deposit money to faction bank
• /f withdraw [amount] - Withdraw money from faction bank (Leader)

Admin Commands:
• /admin - Show admin commands
• /a [command] - Execute admin command
• /kick [player] [reason] - Kick a player
• /ban [player] [reason] - Ban a player
• /mute [player] [time] - Mute a player
• /goto [player] - Teleport to player
• /gethere [player] - Teleport player to you
• /setmoney [player] [amount] - Set player money
• /car [model] - Spawn vehicle
• /god - Toggle god mode
• /announce [message] - Send server announcement]]
    
    windows.help.commandsMemo = guiCreateMemo(10, 10, windowWidth - 40, windowHeight - 110, commandsText, false, tabCommands)
    guiMemoSetReadOnly(windows.help.commandsMemo, true)
    
    -- Controls tab content
    local controlsText = [[ACNR MTA - Controls

Movement:
• W, A, S, D - Move forward, left, backward, right
• Space - Jump
• Left Shift - Sprint
• C - Crouch
• Left Alt - Walk

Vehicle Controls:
• Enter/Exit - Enter/Exit vehicle
• W, S - Accelerate/Brake
• A, D - Turn left/right
• Space - Handbrake
• L - Toggle headlights
• J - Toggle engine
• X - Lock/unlock vehicle
• 2 - Look behind
• H - Horn

Combat:
• Left Mouse - Fire weapon
• Right Mouse - Aim weapon
• R - Reload weapon
• F - Enter/Exit vehicle
• G - Drop weapon
• Tab - Next weapon
• Q, E - Previous/Next weapon

Camera:
• Mouse - Look around
• Mouse Wheel - Zoom in/out
• B - Look behind
• M - Map

Interface:
• F1 - Help window
• F2 - Statistics window
• F3 - Inventory window
• F4 - Toggle FPS counter
• F5 - Settings window
• T - Chat
• ESC - Menu

Voice Chat (if enabled):
• Z - Voice chat (push-to-talk)

Tips:
• Use the mouse to control the camera
• Hold right mouse button to aim weapons
• Use the map (M) to navigate the city
• Press ESC to access the main menu
• Use chat commands to interact with the world]]
    
    windows.help.controlsMemo = guiCreateMemo(10, 10, windowWidth - 40, windowHeight - 110, controlsText, false, tabControls)
    guiMemoSetReadOnly(windows.help.controlsMemo, true)
    
    -- Rules tab content
    local rulesText = [[ACNR MTA - Server Rules

General Rules:
1. Respect all players and staff members
2. No cheating or using exploits
3. No spamming in chat
4. No advertising other servers
5. No inappropriate language or behavior
6. No racism, discrimination, or harassment
7. No threatening other players
8. No sharing personal information

Gameplay Rules:
1. No deathmatching (killing without reason)
2. No camping in spawn areas
3. No exploiting bugs or glitches
4. No using cheats or hacks
5. No evading roleplay situations
6. No powergaming (unrealistic actions)
7. No metagaming (using OOC information IC)
8. No revenge killing (killing after respawn)

Vehicle Rules:
1. No ramming other players without reason
  2. No parking vehicles in spawn areas
3. No destroying vehicles without reason
4. No stealing vehicles without RP reason
5. No using vehicles as weapons
6. No driving recklessly in populated areas

Building Rules:
1. No trespassing in private property
2. No loitering in restricted areas
3. No vandalizing property
4. No blocking entrances/exits
5. No using buildings for illegal activities

Chat Rules:
1. No spamming or flooding
2. No caps lock abuse
3. No advertising or soliciting
4. No sharing links without permission
5. No using inappropriate language
6. No harassing other players
7. No impersonating staff members

Punishments:
• Warning - For minor rule violations
• Mute - For chat-related offenses
• Kick - For repeated minor offenses
• Temporary Ban - For serious offenses
• Permanent Ban - For severe violations

Staff have the final say in all matters. If you disagree with a decision, you may appeal on the forums.

Remember: This is a game meant to be fun for everyone. Play fair, be respectful, and enjoy your time on ACNR MTA!]]
    
    windows.help.rulesMemo = guiCreateMemo(10, 10, windowWidth - 40, windowHeight - 110, rulesText, false, tabRules)
    guiMemoSetReadOnly(windows.help.rulesMemo, true)
    
    -- Create close button
    windows.help.closeBtn = guiCreateButton(windowWidth - 110, windowHeight - 35, 90, 25, "Close", false, windows.help.window)
    
    addEventHandler("onClientGUIClick", windows.help.closeBtn, function()
        destroyElement(windows.help.window)
        windows.help = nil
        showCursor(false)
    end, false)
    
    -- Show window
    guiSetVisible(windows.help.window, true)
    guiBringToFront(windows.help.window)
    showCursor(true)
end

-- Create stats window
function createStatsWindow()
    -- Close existing stats window
    if windows.stats then
        destroyElement(windows.stats.window)
        windows.stats = nil
    end
    
    -- Create window
    local screenWidth, screenHeight = guiGetScreenSize()
    local windowWidth, windowHeight = 400, 300
    local x = (screenWidth - windowWidth) / 2
    local y = (screenHeight - windowHeight) / 2
    
    windows.stats = {}
    windows.stats.window = guiCreateWindow(x, y, windowWidth, windowHeight, "ACNR MTA - Statistics", false)
    guiWindowSetSizable(windows.stats.window, false)
    
    -- Create labels
    windows.stats.usernameLabel = guiCreateLabel(20, 30, 360, 20, "Username: Loading...", false, windows.stats.window)
    windows.stats.moneyLabel = guiCreateLabel(20, 60, 360, 20, "Money: Loading...", false, windows.stats.window)
    windows.stats.scoreLabel = guiCreateLabel(20, 90, 360, 20, "Score: Loading...", false, windows.stats.window)
    windows.stats.killsLabel = guiCreateLabel(20, 120, 360, 20, "Kills: Loading...", false, windows.stats.window)
    windows.stats.deathsLabel = guiCreateLabel(20, 150, 360, 20, "Deaths: Loading...", false, windows.stats.window)
    windows.stats.kdLabel = guiCreateLabel(20, 180, 360, 20, "K/D Ratio: Loading...", false, windows.stats.window)
    windows.stats.playtimeLabel = guiCreateLabel(20, 210, 360, 20, "Playtime: Loading...", false, windows.stats.window)
    
    -- Create close button
    windows.stats.closeBtn = guiCreateButton(150, 250, 100, 30, "Close", false, windows.stats.window)
    
    addEventHandler("onClientGUIClick", windows.stats.closeBtn, function()
        destroyElement(windows.stats.window)
        windows.stats = nil
        showCursor(false)
    end, false)
    
    -- Request stats from server
    triggerServerEvent("requestPlayerStats", localPlayer)
    
    -- Handle stats response
    addEvent("receivePlayerStats", true)
    addEventHandler("receivePlayerStats", rootElement, function(stats)
        if windows.stats then
            guiSetText(windows.stats.usernameLabel, "Username: " .. (stats.username or "N/A"))
            guiSetText(windows.stats.moneyLabel, "Money: $" .. (stats.money or 0))
            guiSetText(windows.stats.scoreLabel, "Score: " .. (stats.score or 0))
            guiSetText(windows.stats.killsLabel, "Kills: " .. (stats.kills or 0))
            guiSetText(windows.stats.deathsLabel, "Deaths: " .. (stats.deaths or 0))
            guiSetText(windows.stats.kdLabel, "K/D Ratio: " .. (stats.kdRatio or "0.00"))
            guiSetText(windows.stats.playtimeLabel, "Playtime: " .. (stats.playtime or "0 hours"))
        end
    end)
    
    -- Show window
    guiSetVisible(windows.stats.window, true)
    guiBringToFront(windows.stats.window)
    showCursor(true)
end

-- Create inventory window (placeholder)
function createInventoryWindow()
    -- Close existing inventory window
    if windows.inventory then
        destroyElement(windows.inventory.window)
        windows.inventory = nil
    end
    
    -- Create window
    local screenWidth, screenHeight = guiGetScreenSize()
    local windowWidth, windowHeight = 400, 300
    local x = (screenWidth - windowWidth) / 2
    local y = (screenHeight - windowHeight) / 2
    
    windows.inventory = {}
    windows.inventory.window = guiCreateWindow(x, y, windowWidth, windowHeight, "ACNR MTA - Inventory", false)
    guiWindowSetSizable(windows.inventory.window, false)
    
    -- Create label
    guiCreateLabel(20, 30, 360, 20, "Inventory system coming soon!", false, windows.inventory.window)
    guiCreateLabel(20, 60, 360, 20, "This feature will be implemented in future updates.", false, windows.inventory.window)
    
    -- Create close button
    windows.inventory.closeBtn = guiCreateButton(150, 250, 100, 30, "Close", false, windows.inventory.window)
    
    addEventHandler("onClientGUIClick", windows.inventory.closeBtn, function()
        destroyElement(windows.inventory.window)
        windows.inventory = nil
        showCursor(false)
    end, false)
    
    -- Show window
    guiSetVisible(windows.inventory.window, true)
    guiBringToFront(windows.inventory.window)
    showCursor(true)
end
-- Create settings window
function createSettingsWindow()
    -- Close existing settings window
    if windows.settings then
        destroyElement(windows.settings.window)
        windows.settings = nil
    end
    
    -- Create window
    local screenWidth, screenHeight = guiGetScreenSize()
    local windowWidth, windowHeight = 400, 350
    local x = (screenWidth - windowWidth) / 2
    local y = (screenHeight - windowHeight) / 2
    
    windows.settings = {}
    windows.settings.window = guiCreateWindow(x, y, windowWidth, windowHeight, "ACNR MTA - Settings", false)
    guiWindowSetSizable(windows.settings.window, false)
    
    -- Create settings options
    guiCreateLabel(20, 30, 360, 20, "Video Settings", false, windows.settings.window)
    windows.settings.showFPS = guiCreateCheckBox(20, 60, 200, 20, "Show FPS Counter", getElementData(localPlayer, "showFPS") or false, false, windows.settings.window)
    
    guiCreateLabel(20, 100, 360, 20, "Audio Settings", false, windows.settings.window)
    windows.settings.soundEnabled = guiCreateCheckBox(20, 130, 200, 20, "Sound Enabled", isSoundEnabled(), false, windows.settings.window)
    
    guiCreateLabel(20, 170, 360, 20, "Chat Settings", false, windows.settings.window)
    windows.settings.chatTimestamps = guiCreateCheckBox(20, 200, 200, 20, "Show Timestamps", false, false, windows.settings.window)
    
    guiCreateLabel(20, 240, 360, 20, "Other Settings", false, windows.settings.window)
    windows.settings.autoLogin = guiCreateCheckBox(20, 270, 200, 20, "Auto Login (Coming Soon)", false, false, windows.settings.window)
    
    -- Create buttons
    windows.settings.saveBtn = guiCreateButton(20, 310, 100, 30, "Save", false, windows.settings.window)
    windows.settings.cancelBtn = guiCreateButton(280, 310, 100, 30, "Cancel", false, windows.settings.window)
    
    addEventHandler("onClientGUIClick", windows.settings.saveBtn, function()
        -- Save settings
        setElementData(localPlayer, "showFPS", guiCheckBoxGetSelected(windows.settings.showFPS))
        setSoundEnabled(guiCheckBoxGetSelected(windows.settings.soundEnabled))
        
        destroyElement(windows.settings.window)
        windows.settings = nil
        showCursor(false)
        outputChatBox("Settings saved!", 0, 255, 0)
    end, false)
    
    addEventHandler("onClientGUIClick", windows.settings.cancelBtn, function()
        destroyElement(windows.settings.window)
        windows.settings = nil
        showCursor(false)
    end, false)
    
    -- Show window
    guiSetVisible(windows.settings.window, true)
    guiBringToFront(windows.settings.window)
    showCursor(true)
end

-- Cleanup GUI
function cleanupGUI()
    -- Destroy all windows
    for _, windowData in pairs(windows) do
        if windowData.window and isElement(windowData.window) then
            destroyElement(windowData.window)
        end
    end
    windows = {}
    
    -- Hide cursor
    showCursor(false)
    
    outputDebugString("GUI System Cleaned Up")
end
