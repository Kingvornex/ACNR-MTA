-- ACNR MTA - Shared Utilities
-- Converted from ACNR-OPENMP

-- Math utilities
function math.round(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function math.clamp(num, min, max)
    return math.min(math.max(num, min), max)
end

function math.lerp(a, b, t)
    return a + (b - a) * t
end

function math.distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function math.distance3d(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
end

function math.angle(x1, y1, x2, y2)
    return math.deg(math.atan2(y2 - y1, x2 - x1))
end

-- String utilities
function string.trim(str)
    return str:match("^%s*(.-)%s*$")
end

function string.split(str, sep)
    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields + 1] = c end)
    return fields
end

function string.startsWith(str, prefix)
    return str:sub(1, #prefix) == prefix
end

function string.endsWith(str, suffix)
    return str:sub(-#suffix) == suffix
end

function string.contains(str, substr)
    return str:find(substr, 1, true) ~= nil
end

function string.capitalize(str)
    return str:gsub("^%l", string.upper)
end

function string.formatNumber(num)
    local formatted = tostring(num)
    local k
    while true do
        formatted, k = formatted:reverse():gsub("^%d%d%d", "%1,")
        if k == 0 then
            break
        end
    end
    return formatted:reverse()
end

function string.formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    
    if hours > 0 then
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    else
        return string.format("%02d:%02d", minutes, secs)
    end
end

-- Table utilities
function table.contains(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function table.indexOf(table, value)
    for i, v in ipairs(table) do
        if v == value then
            return i
        end
    end
    return -1
end

function table.removeValue(table, value)
    for i, v in ipairs(table) do
        if v == value then
            table.remove(table, i)
            return true
        end
    end
    return false
end

function table.copy(table)
    local copy = {}
    for k, v in pairs(table) do
        if type(v) == "table" then
            copy[k] = table.copy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function table.merge(table1, table2)
    local merged = table.copy(table1)
    for k, v in pairs(table2) do
        merged[k] = v
    end
    return merged
end

function table.keys(table)
    local keys = {}
    for k, _ in pairs(table) do
        table.insert(keys, k)
    end
    return keys
end

function table.values(table)
    local values = {}
    for _, v in pairs(table) do
        table.insert(values, v)
    end
    return values
end

function table.count(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

function table.isEmpty(table)
    return next(table) == nil
end

-- Color utilities
function color.rgba(r, g, b, a)
    return tocolor(r, g, b, a or 255)
end

function color.rgb(r, g, b)
    return tocolor(r, g, b, 255)
end

function color.hex(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    local a = tonumber(hex:sub(7, 8), 16) or 255
    return tocolor(r, g, b, a)
end

function color.fromName(name)
    local colors = {
        red = tocolor(255, 0, 0, 255),
        green = tocolor(0, 255, 0, 255),
        blue = tocolor(0, 0, 255, 255),
        yellow = tocolor(255, 255, 0, 255),
        orange = tocolor(255, 165, 0, 255),
        purple = tocolor(128, 0, 128, 255),
        pink = tocolor(255, 192, 203, 255),
        brown = tocolor(165, 42, 42, 255),
        black = tocolor(0, 0, 0, 255),
        white = tocolor(255, 255, 255, 255),
        gray = tocolor(128, 128, 128, 255),
        cyan = tocolor(0, 255, 255, 255),
        magenta = tocolor(255, 0, 255, 255),
        lime = tocolor(0, 255, 0, 255),
        navy = tocolor(0, 0, 128, 255),
        teal = tocolor(0, 128, 128, 255),
        gold = tocolor(255, 215, 0, 255)
    }
    return colors[string.lower(name)] or tocolor(255, 255, 255, 255)
end

-- Date and time utilities
function time.timestamp()
    return os.time()
end

function time.formatTimestamp(timestamp, format)
    format = format or "%Y-%m-%d %H:%M:%S"
    return os.date(format, timestamp)
end

function time.getTimeString()
    local hours, minutes = getTime()
    return string.format("%02d:%02d", hours, minutes)
end

function time.getDateString()
    local month, day, year = getRealTime()
    return string.format("%04d-%02d-%02d", year + 1900, month + 1, day)
end

-- File utilities
function file.exists(path)
    return fileExists(path)
end

function file.read(path)
    local handle = fileOpen(path, true)
    if not handle then return nil end
    
    local size = fileGetSize(handle)
    local content = fileRead(handle, size)
    fileClose(handle)
    
    return content
end

function file.write(path, content)
    local handle = fileCreate(path)
    if not handle then return false end
    
    fileWrite(handle, content)
    fileClose(handle)
    
    return true
end

function file.append(path, content)
    local handle = fileOpen(path)
    if not handle then
        handle = fileCreate(path)
        if not handle then return false end
    end
    
    fileSetPos(handle, fileGetSize(handle))
    fileWrite(handle, content)
    fileClose(handle)
    
    return true
end

function file.delete(path)
    return fileDelete(path)
end

-- Debug utilities
function debug.log(message)
    outputDebugString(message)
end

function debug.table(table, indent)
    indent = indent or 0
    local prefix = string.rep("  ", indent)
    
    for k, v in pairs(table) do
        if type(v) == "table" then
            outputDebugString(prefix .. tostring(k) .. " = {")
            debug.table(v, indent + 1)
            outputDebugString(prefix .. "}")
        else
            outputDebugString(prefix .. tostring(k) .. " = " .. tostring(v))
        end
    end
end

function debug.vars()
    local vars = {}
    for k, v in pairs(_G) do
        if not string.startsWith(k, "_") then
            vars[k] = type(v)
        end
    end
    debug.table(vars)
end

-- Validation utilities
function validation.isEmail(email)
    return email:match("^[%w%-%.]+@[%w%-%.]+%.%w%w%w?%w?$") ~= nil
end

function validation.isUsername(username)
    return username:match("^[%w_%-%s]+$") ~= nil and #username >= 3 and #username <= 20
end

function validation.isPassword(password)
    return #password >= 6 and #password <= 32
end

function validation.isNumber(num)
    return tonumber(num) ~= nil
end

function validation.isInteger(num)
    return validation.isNumber(num) and math.floor(tonumber(num)) == tonumber(num)
end

function validation.isPositive(num)
    return validation.isNumber(num) and tonumber(num) > 0
end

function validation.isInRange(num, min, max)
    return validation.isNumber(num) and tonumber(num) >= min and tonumber(num) <= max
end

-- Security utilities
function security.hash(str)
    -- Simple hash function (in production, use proper hashing)
    local hash = 0
    for i = 1, #str do
        hash = hash * 31 + string.byte(str, i)
    end
    return math.abs(hash)
end

function security.sanitize(str)
    -- Basic string sanitization
    str = str:gsub("<", "&lt;")
    str = str:gsub(">", "&gt;")
    str = str:gsub("\"", "&quot;")
    str = str:gsub("'", "&apos;")
    str = str:gsub("&", "&amp;")
    return str
end

function security.generateToken(length)
    length = length or 32
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local token = ""
    for i = 1, length do
        token = token .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return token
end

-- Network utilities
function network.ping()
    -- This would typically return the player's ping
    return getPlayerPing(localPlayer)
end

function network.isConnected()
    -- Check if player is connected to server
    return isElement(localPlayer) and getElementType(localPlayer) == "player"
end

-- Conversion utilities
function conversion.kmToMiles(km)
    return km * 0.621371
end

function conversion.milesToKm(miles)
    return miles * 1.60934
end

function conversion.metersToFeet(meters)
    return meters * 3.28084
end

function conversion.feetToMeters(feet)
    return feet * 0.3048
end

function conversion.celsiusToFahrenheit(celsius)
    return (celsius * 9/5) + 32
end

function conversion.fahrenheitToCelsius(fahrenheit)
    return (fahrenheit - 32) * 5/9
end

-- Game-specific utilities
function game.getWeaponName(weaponID)
    local weapons = {
        [0] = "Fist", [1] = "Brass Knuckles", [2] = "Golf Club", [3] = "Night Stick",
        [4] = "Knife", [5] = "Baseball Bat", [6] = "Shovel", [7] = "Pool Cue",
        [8] = "Katana", [9] = "Chainsaw", [10] = "Purple Dildo", [11] = "Dildo",
        [12] = "Vibrator", [13] = "Vibrator", [14] = "Flowers", [15] = "Cane",
        [16] = "Grenade", [17] = "Tear Gas", [18] = "Molotov", [22] = "Pistol",
        [23] = "Silenced Pistol", [24] = "Desert Eagle", [25] = "Shotgun",
        [26] = "Sawnoff Shotgun", [27] = "Combat Shotgun", [28] = "Uzi", [29] = "MP5",
        [30] = "AK-47", [31] = "M4", [32] = "Tec-9", [33] = "Country Rifle",
        [34] = "Sniper Rifle", [35] = "RPG", [36] = "HS Rocket", [37] = "Flamethrower",
        [38] = "Minigun", [39] = "Satchel Charge", [40] = "Detonator", [41] = "Spraycan",
        [42] = "Fire Extinguisher", [43] = "Camera", [44] = "Night Vision",
        [45] = "Infrared Vision", [46] = "Parachute", [100] = "Jetpack"
    }
    return weapons[weaponID] or "Unknown"
end

function game.getVehicleName(vehicleID)
    local vehicles = {
        [400] = "Landstalker", [401] = "Bravura", [402] = "Buffalo", [403] = "Linerunner",
        [404] = "Perennial", [405] = "Sentinel", [406] = "Dumper", [407] = "Firetruck",
        [408] = "Trashmaster", [409] = "Stretch", [410] = "Manana", [411] = "Infernus",
        [412] = "Voodoo", [413] = "Pony", [414] = "Mule", [415] = "Cheetah",
        [416] = "Ambulance", [417] = "Leviathan", [418] = "Moonbeam", [419] = "Esperanto",
        [420] = "Taxi", [421] = "Washington", [422] = "Bobcat", [423] = "Mr. Whoopee",
        [424] = "BF Injection", [425] = "Hunter", [426] = "Premier", [427] = "Enforcer",
        [428] = "Securicar", [429] = "Banshee", [430] = "Predator", [431] = "Bus",
        [432] = "Rhino", [433] = "Barracks", [434] = "Hotknife", [435] = "Article Trailer",
        [436] = "Previon", [437] = "Coach", [438] = "Cabbie", [439] = "Stallion",
        [440] = "Rumpo", [441] = "RC Bandit", [442] = "Romero", [443] = "Packer",
        [444] = "Monster Truck", [445] = "Admiral", [446] = "Squalo", [447] = "Seasparrow",
        [448] = "Pizzaboy", [449] = "Tram", [450] = "Article Trailer 2", [451] = "Turismo",
        [452] = "Speeder", [453] = "Reefer", [454] = "Tropic", [455] = "Flatbed",
        [456] = "Yankee", [457] = "Caddy", [458] = "Solair", [459] = "Berkley's RC Van",
        [460] = "Skimmer", [461] = "PCJ-600", [462] = "Faggio", [463] = "Freeway",
        [464] = "RC Baron", [465] = "RC Raider", [466] = "Glendale", [467] = "Oceanic",
        [468] = "Sanchez", [469] = "Sparrow", [470] = "Patriot", [471] = "Quad",
        [472] = "Coastguard", [473] = "Dinghy", [474] = "Hermes", [475] = "Sabre",
        [476] = "Rustler", [477] = "ZR-350", [478] = "Walton", [479] = "Regina",
        [480] = "Comet", [481] = "BMX", [482] = "Burrito", [483] = "Camper",
        [484] = "Marquis", [485] = "Baggage", [486] = "Dozer", [487] = "Maverick",
        [488] = "SAN News Chopper", [489] = "Rancher", [490] = "FBI Rancher",
        [491] = "Virgo", [492] = "Greenwood", [493] = "Jetmax", [494] = "Hotring Racer",
        [495] = "Sandking", [496] = "Blista Compact", [497] = "Police Maverick",
        [498] = "Boxville", [499] = "Benson", [500] = "Mesa", [501] = "RC Goblin",
        [502] = "Hotring Racer 2", [503] = "Hotring Racer 3", [504] = "Bloodring Banger",
        [505] = "Rancher Lure", [506] = "Super GT", [507] = "Elegant", [508] = "Journey",
        [509] = "Bike", [510] = "Mountain Bike", [511] = "Beagle", [512] = "Cropduster",
        [513] = "Stuntplane", [514] = "Tanker", [515] = "Roadtrain", [516] = "Nebula",
        [517] = "Majestic", [518] = "Buccaneer", [519] = "Shamal", [520] = "Hydra",
        [521] = "FCR-900", [522] = "NRG-500", [523] = "HPV1000", [524] = "Cement Truck",
        [525] = "Tow Truck", [526] = "Fortune", [527] = "Cadrona", [528] = "FBI Truck",
        [529] = "Willard", [530] = "Forklift", [531] = "Tractor", [532] = "Combine Harvester",
        [533] = "Feltzer", [534] = "Remington", [535] = "Slamvan", [536] = "Blade",
        [537] = "Freight", [538] = "Streak", [539] = "Vortex", [540] = "Vincent",
        [541] = "Bullet", [542] = "Clover", [543] = "Sadler", [544] = "Firetruck Ladder",
        [545] = "Hustler", [546] = "Intruder", [547] = "Primo", [548] = "Cargobob",
        [549] = "Tampa", [550] = "Sunrise", [551] = "Merit", [552] = "Utility Van",
        [553] = "Nevada", [554] = "Yosemite", [555] = "Windsor", [556] = "Monster Truck 2",
        [557] = "Monster Truck 3", [558] = "Uranus", [559] = "Jester", [560] = "Sultan",
        [561] = "Stratum", [562] = "Elegy", [563] = "Raindance", [564] = "RC Tiger",
        [565] = "Flash", [566] = "Tahoma", [567] = "Savanna", [568] = "Bandito",
        [569] = "Freight Flat", [570] = "Streak Carriage", [571] = "Kart",
        [572] = "Mower", [573] = "Dune", [574] = "Sweeper", [575] = "Broadway",
        [576] = "Tornado", [577] = "AT-400", [578] = "DFT-30", [579] = "Huntley",
        [580] = "Stafford", [581] = "BF-400", [582] = "Newsvan", [583] = "Tug",
        [584] = "Petrol Trailer", [585] = "Emperor", [586] = "Wayfarer", [587] = "Euros",
        [588] = "Hotdog", [589] = "Club", [590] = "Freight Box", [591] = "Trailer 3",
        [592] = "Andromada", [593] = "Dodo", [594] = "RC Cam", [595] = "Launch",
        [596] = "Police Car (LSPD)", [597] = "Police Car (SFPD)", [598] = "Police Car (LVPD)",
        [599] = "Police Ranger", [600] = "Picador", [601] = "S.W.A.T. Van", [602] = "Alpha",
        [603] = "Phoenix", [604] = "Glendale Shit", [605] = "Sadler Shit", [606] = "Baggage Trailer",
        [607] = "Tug Stairs Trailer", [608] = "Boxville", [609] = "Farm Trailer", [610] = "Street Cleaner"
    }
    return vehicles[vehicleID] or "Unknown"
end

function game.getZoneName(x, y, z)
    return getZoneName(x, y, z)
end

function game.getCityName(x, y, z)
    return getZoneName(x, y, z, true)
end

-- Export utilities
function export.getUtils()
    return {
        math = {
            round = math.round,
            clamp = math.clamp,
            lerp = math.lerp,
            distance = math.distance,
            distance3d = math.distance3d,
            angle = math.angle
        },
        string = {
            trim = string.trim,
            split = string.split,
            startsWith = string.startsWith,
            endsWith = string.endsWith,
            contains = string.contains,
            capitalize = string.capitalize,
            formatNumber = string.formatNumber,
            formatTime = string.formatTime
        },
        table = {
            contains = table.contains,
            indexOf = table.indexOf,
            removeValue = table.removeValue,
            copy = table.copy,
            merge = table.merge,
            keys = table.keys,
            values = table.values,
            count = table.count,
            isEmpty = table.isEmpty
        },
        color = {
            rgba = color.rgba,
            rgb = color.rgb,
            hex = color.hex,
            fromName = color.fromName
        },
        time = {
            timestamp = time.timestamp,
            formatTimestamp = time.formatTimestamp,
            getTimeString = time.getTimeString,
            getDateString = time.getDateString
        },
        file = {
            exists = file.exists,
            read = file.read,
            write = file.write,
            append = file.append,
            delete = file.delete
        },
        validation = {
            isEmail = validation.isEmail,
            isUsername = validation.isUsername,
            isPassword = validation.isPassword,
            isNumber = validation.isNumber,
            isInteger = validation.isInteger,
            isPositive = validation.isPositive,
            isInRange = validation.isInRange
        },
        security = {
            hash = security.hash,
            sanitize = security.sanitize,
            generateToken = security.generateToken
        },
        conversion = {
            kmToMiles = conversion.kmToMiles,
            milesToKm = conversion.milesToKm,
            metersToFeet = conversion.metersToFeet,
            feetToMeters = conversion.feetToMeters,
            celsiusToFahrenheit = conversion.celsiusToFahrenheit,
            fahrenheitToCelsius = conversion.fahrenheitToCelsius
        },
        game = {
            getWeaponName = game.getWeaponName,
            getVehicleName = game.getVehicleName,
            getZoneName = game.getZoneName,
            getCityName = game.getCityName
        }
    }
end
