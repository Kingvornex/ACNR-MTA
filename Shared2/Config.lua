
-- ACNR MTA - Configuration File
-- Converted from ACNR-OPENMP

-- Server Configuration
config = {
    server = {
        name = "ACNR MTA",
        description = "Converted ACNR game mode for Multi Theft Auto",
        version = "1.0.0",
        maxPlayers = 100,
        password = "",
        port = 22003,
        httpPort = 22005,
        queryPort = 22126
    },
    
    -- Database Configuration
    database = {
        type = "sqlite", -- sqlite or mysql
        host = "localhost",
        port = 3306,
        username = "root",
        password = "",
        database = "acnr_mta",
        autoBackup = true,
        backupInterval = 3600, -- 1 hour
        cleanupInterval = 86400 -- 24 hours
    },
    
    -- Game Configuration
    game = {
        startingMoney = 5000,
        startingSkin = 0,
        spawnHealth = 100,
        spawnArmor = 0,
        deathRespawnTime = 3000, -- 3 seconds
        maxHousesPerPlayer = 3,
        maxVehiclesPerPlayer = 5,
        vehicleRespawnTime = 30000, -- 30 seconds
        houseEnterRadius = 5,
        vehicleParkRadius = 10,
        chatRadius = 20,
        adminChatRadius = 0, -- Global
        factionChatRadius = 0, -- Global
        enableVoiceChat = false,
        enableMinimap = true,
        enableRadar = true,
        enableHud = true,
        enableVehicleHud = true
    },
    
    -- Economy Configuration
    economy = {
        houseSellRatio = 0.7, -- 70% of original price
        vehicleRepairCost = 500,
        vehicleSellRatio = 0.6, -- 60% of original price
        factionCreateCost = 10000,
        killMoneyMin = 100,
        killMoneyMax = 500,
        payDayInterval = 3600, -- 1 hour
        payDayAmount = 100,
        vipPayDayMultiplier = 2,
        adminPayDayMultiplier = 1.5
    },
    
    -- Admin Configuration
    admin = {
        levels = {
            [0] = "Player",
            [1] = "Moderator",
            [2] = "Administrator", 
            [3] = "Super Administrator",
            [4] = "Owner"
        },
        permissions = {
            [1] = { -- Moderator
                kick = true,
                mute = true,
                goto = true,
                gethere = true,
                freeze = true,
                slap = true,
                heal = true,
                armor = true,
                vehicle = true,
                repair = true,
                flip = true,
                jetpack = true
            },
            [2] = { -- Administrator
                ban = true,
                setmoney = true,
                givemoney = true,
                sethealth = true,
                setarmor = true,
                setskin = true,
                weapons = true,
                announce = true,
                weather = true,
                time = true,
                setstats = true,
                resetstats = true,
                database = true
            },
            [3] = { -- Super Administrator
                promote = true,
                demote = true,
                withdraw = true,
                godmode = true,
                invisible = true,
                reset = true
            },
            [4] = { -- Owner
                setadmin = true,
                all = true
            }
        }
    },


  -- Vehicle Configuration
    vehicles = {
        -- Vehicle prices (model: price)
        prices = {
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
            [551] = 18000, -- Merit
            [552] = 35000, -- Uranus
            [554] = 28000, -- Yosemite
            [555] = 24000, -- Windsor
            [558] = 32000, -- Uranus
            [559] = 38000, -- Jester
            [560] = 36000, -- Sultan
            [561] = 34000, -- Stratum
            [562] = 70000, -- Elegy
            [565] = 26000, -- Flash
            [566] = 24000, -- Tahoma
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
            [605] = 24000 -- Sadler
        },
        
        -- Vehicle spawn positions
        spawnPositions = {
            {x = 1958.33, y = -1684.97, z = 13.54, angle = 269.15}, -- Main spawn
            {x = 2040.00, y = -1680.00, z = 13.50, angle = 90.00}, -- Alternative spawn 1
            {x = 2100.00, y = -1680.00, z = 13.50, angle = 90.00}, -- Alternative spawn 2
            {x = 1950.00, y = -1720.00, z = 13.50, angle = 0.00}, -- Alternative spawn 3
            {x = 1900.00, y = -1680.00, z = 13.50, angle = 270.00} -- Alternative spawn 4
        }
    },
    
    -- House Configuration
    houses = {
        -- House interiors
        interiors = {
            {x = 2233.69, y = -1115.41, z = 1050.88, int = 5}, -- House interior 1
            {x = 2262.83, y = -1137.71, z = 1050.63, int = 10}, -- House interior 2
            {x = 2196.15, y = -1204.35, z = 1049.02, int = 1}, -- House interior 3
            {x = 2282.91, y = -1139.48, z = 1050.90, int = 11}, -- House interior 4
            {x = 2237.58, y = -1081.55, z = 1049.02, int = 2} -- House interior 5
        },
        
        -- Default house locations
        defaultHouses = {
            {name = "Small House", x = 1950.00, y = -1700.00, z = 15.00, price = 50000},
            {name = "Medium House", x = 2000.00, y = -1750.00, z = 15.00, price = 100000},
            {name = "Large House", x = 2050.00, y = -1800.00, z = 15.00, price = 200000},
            {name = "Luxury House", x = 2100.00, y = -1850.00, z = 15.00, price = 500000},
            {name = "Mansion", x = 2150.00, y = -1900.00, z = 15.00, price = 1000000}
        }
    },
    
    -- Faction Configuration
    factions = {
        -- Default factions
        defaultFactions = {
            {name = "Los Santos Police", tag = "LSPD", color = 0x0000FF, description = "Law enforcement agency"},
            {name = "Grove Street", tag = "GS", color = 0x00FF00, description = "Street gang from Grove Street"},
            {name = "Ballas", tag = "B", color = 0xFF00FF, description = "Rival street gang"},
            {name = "Vagos", tag = "V", color = 0xFFFF00, description = "Hispanic street gang"},
            {name = "The Triads", tag = "T", color = 0xFF0000, description = "Chinese crime organization"}
        },
        
        -- Faction ranks
        ranks = {
            [1] = "Member",
            [2] = "Veteran", 
            [3] = "Leader"
        },
        
        -- Faction permissions
        permissions = {
            [1] = { -- Member
                invite = false,
                kick = false,
                promote = false,
                demote = false,
                withdraw = false,
                chat = true,
                deposit = true
            },
            [2] = { -- Veteran
                invite = true,
                kick = false,
                promote = false,
                demote = false,
                withdraw = false,
                chat = true,
                deposit = true
            },
            [3] = { -- Leader
                invite = true,
                kick = true,
                promote = true,
                demote = true,
                withdraw = true,
                chat = true,
                deposit = true
            }
        }
    },

  -- GUI Configuration
    gui = {
        colors = {
            background = tocolor(0, 0, 0, 200),
            foreground = tocolor(255, 255, 255, 255),
            button = tocolor(0, 100, 200, 255),
            buttonHover = tocolor(0, 150, 255, 255),
            success = tocolor(0, 255, 0, 255),
            error = tocolor(255, 0, 0, 255),
            warning = tocolor(255, 255, 0, 255)
        },
        fonts = {
            default = "default",
            defaultBold = "default-bold",
            clear = "clear",
            arial = "arial",
            sans = "sans"
        },
        positions = {
            login = {width = 400, height = 300},
            help = {width = 600, height = 400},
            stats = {width = 400, height = 300},
            inventory = {width = 400, height = 300},
            settings = {width = 400, height = 350}
        }
    },
    
    -- HUD Configuration
    hud = {
        enabled = true,
        vehicleHUD = true,
        position = "bottom-left",
        opacity = 0.8,
        scale = 1.0,
        showHealth = true,
        showArmor = true,
        showMoney = true,
        showWeapon = true,
        showWanted = true,
        showZone = true,
        showVehicleHealth = true,
        showVehicleFuel = true,
        showVehicleSpeed = true,
        showVehicleEngine = true,
        updateInterval = 100 -- milliseconds
    },
    
    -- Chat Configuration
    chat = {
        enabled = true,
        showTimestamps = false,
        maxHistory = 100,
        fadeTime = 10000, -- 10 seconds
        colors = {
            normal = tocolor(255, 255, 255, 255),
            me = tocolor(255, 255, 0, 255),
            admin = tocolor(255, 0, 0, 255),
            faction = tocolor(0, 255, 0, 255),
            system = tocolor(0, 150, 255, 255),
            error = tocolor(255, 0, 0, 255),
            success = tocolor(0, 255, 0, 255)
        }
    },
    
    -- Security Configuration
    security = {
        enableAntiCheat = true,
        maxLoginAttempts = 3,
        loginTimeout = 300, -- 5 minutes
        passwordMinLength = 6,
        passwordMaxLength = 32,
        usernameMinLength = 3,
        usernameMaxLength = 20,
        allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_",
        enableIPBan = true,
        enableSerialBan = true,
        enableAccountBan = true,
        logCommands = true,
        logConnections = true,
        logDisconnections = true,
        logAdminActions = true
    },
    
    -- Performance Configuration
    performance = {
        maxObjects = 500,
        maxVehicles = 200,
        maxPeds = 100,
        maxMarkers = 50,
        maxPickups = 100,
        maxBlips = 200,
        maxColshapes = 100,
        maxLabels = 100,
        maxRadarAreas = 50,
        streamingDistance = 300,
        lodDistance = 500,
        drawDistance = 300,
        updateInterval = 50 -- milliseconds
    },
    
    -- Debug Configuration
    debug = {
        enabled = false,
        level = 1, -- 0 = off, 1 = basic, 2 = detailed, 3 = verbose
        logToFile = true,
        logToConsole = true,
        logToChat = false,
        showFPS = false,
        showMemory = false,
        showNetworkStats = false,
        showPlayerStats = false
    }
}

-- Configuration utility functions
function config.get(path)
    local keys = string.split(path, ".")
    local value = config
    
    for _, key in ipairs(keys) do
        if type(value) == "table" and value[key] then
            value = value[key]
        else
            return nil
        end
    end
    
    return value
end

function config.set(path, value)
    local keys = string.split(path, ".")
    local current = config
    
    for i, key in ipairs(keys) do
        if i == #keys then
            current[key] = value
        else
            if type(current[key]) ~= "table" then
                current[key] = {}
            end
            current = current[key]
        end
    end
end

function config.load()
    -- Load configuration from file if it exists
    local configFile = fileExists("config/settings.xml")
    if configFile then
        local xml = xmlLoadFile("config/settings.xml")
        if xml then
            -- Parse XML and update config
            xmlUnloadFile(xml)
        end
    end
end

function config.save()
-- Save configuration to file
    local xml = xmlCreateFile("config/settings.xml", "config")
    if xml then
        -- Save config to XML
        xmlSaveFile(xml)
        xmlUnloadFile(xml)
    end
end

function config.reset()
    -- Reset to default configuration
    config = config.getDefault()
end

function config.getDefault()
    -- Return default configuration
    return {
        server = {
            name = "ACNR MTA",
            description = "Converted ACNR game mode for Multi Theft Auto",
            version = "1.0.0",
            maxPlayers = 100,
            password = "",
            port = 22003,
            httpPort = 22005,
            queryPort = 22126
        },
        database = {
            type = "sqlite",
            host = "localhost",
            port = 3306,
            username = "root",
            password = "",
            database = "acnr_mta",
            autoBackup = true,
            backupInterval = 3600,
            cleanupInterval = 86400
        },
        game = {
            startingMoney = 5000,
            startingSkin = 0,
            spawnHealth = 100,
            spawnArmor = 0,
            deathRespawnTime = 3000,
            maxHousesPerPlayer = 3,
            maxVehiclesPerPlayer = 5,
            vehicleRespawnTime = 30000,
            houseEnterRadius = 5,
            vehicleParkRadius = 10,
            chatRadius = 20,
            adminChatRadius = 0,
            factionChatRadius = 0,
            enableVoiceChat = false,
            enableMinimap = true,
            enableRadar = true,
            enableHud = true,
            enableVehicleHud = true
        },
        economy = {
            houseSellRatio = 0.7,
            vehicleRepairCost = 500,
            vehicleSellRatio = 0.6,
            factionCreateCost = 10000,
            killMoneyMin = 100,
            killMoneyMax = 500,
            payDayInterval = 3600,
            payDayAmount = 100,
            vipPayDayMultiplier = 2,
            adminPayDayMultiplier = 1.5
        }
    }
end

-- Initialize configuration
config.load()

-- Export configuration functions
function export.getConfig()
    return config
end

function export.getConfigValue(path)
    return config.get(path)
end

function export.setConfigValue(path, value)
    config.set(path, value)
end

function export.saveConfig()
    config.save()
end

function export.resetConfig()
    config.reset()
end
