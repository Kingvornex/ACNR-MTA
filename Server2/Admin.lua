-- ACNR MTA - Admin Management System
-- Converted from ACNR-OPENMP

local adminLevels = {
    [0] = "Player",
    [1] = "Moderator",
    [2] = "Administrator",
    [3] = "Super Administrator",
    [4] = "Owner"
}

-- Admin commands
addCommandHandler("admin", function(player)
    if not players[player] or not players[player].isLoggedIn then
        outputChatBox("You must be logged in to use admin commands!", player, 255, 0, 0)
        return
    end
    
    if players[player].adminLevel < 1 then
        outputChatBox("You don't have admin permissions!", player, 255, 0, 0)
        return
    end
    
    outputChatBox("=== Admin Commands ===", player, 255, 255, 0)
    outputChatBox("/kick [player] [reason] - Kick a player", player, 255, 255, 255)
    outputChatBox("/ban [player] [reason] - Ban a player", player, 255, 255, 255)
    outputChatBox("/mute [player] [time] - Mute a player", player, 255, 255, 255)
    outputChatBox("/unmute [player] - Unmute a player", player, 255, 255, 255)
    outputChatBox("/goto [player] - Teleport to player", player, 255, 255, 255)
    outputChatBox("/gethere [player] - Teleport player to you", player, 255, 255, 255)
    outputChatBox("/setmoney [player] [amount] - Set player money", player, 255, 255, 255)
    outputChatBox("/givemoney [player] [amount] - Give money to player", player, 255, 255, 255)
    outputChatBox("/sethealth [player] [health] - Set player health", player, 255, 255, 255)
    outputChatBox("/setarmor [player] [armor] - Set player armor", player, 255, 255, 255)
    outputChatBox("/setskin [player] [skin] - Set player skin", player, 255, 255, 255)
    outputChatBox("/setadmin [player] [level] - Set admin level", player, 255, 255, 255)
    outputChatBox("/announce [message] - Send server announcement", player, 255, 255, 255)
    outputChatBox("/freeze [player] - Freeze/unfreeze player", player, 255, 255, 255)
    outputChatBox("/slap [player] - Slap player", player, 255, 255, 255)
    outputChatBox("/kill [player] - Kill player", player, 255, 255, 255)
    outputChatBox("/heal [player] - Heal player", player, 255, 255, 255)
    outputChatBox("/armor [player] - Give armor to player", player, 255, 255, 255)
    outputChatBox("/weaps [player] - Give weapons to player", player, 255, 255, 255)
    outputChatBox("/car [model] - Spawn vehicle", player, 255, 255, 255)
    outputChatBox("/repair - Repair current vehicle", player, 255, 255, 255)
    outputChatBox("/flip - Flip current vehicle", player, 255, 255, 255)
    outputChatBox("/god - Toggle god mode", player, 255, 255, 255)
    outputChatBox("/invisible - Toggle invisibility", player, 255, 255, 255)
    outputChatBox("/jetpack - Give/remove jetpack", player, 255, 255, 255)
    outputChatBox("/weather [id] - Change weather", player, 255, 255, 255)
    outputChatBox("/time [hour] [minute] - Set time", player, 255, 255, 255)
    outputChatBox("/setstats [player] - Set player stats", player, 255, 255, 255)
    outputChatBox("/resetstats [player] - Reset player stats", player, 255, 255, 255)
    outputChatBox("/admins - Show online admins", player, 255, 255, 255)
    outputChatBox("/players - Show online players", player, 255, 255, 255)
    outputChatBox("/serverinfo - Show server information", player, 255, 255, 255)
end)

-- Main admin command handler
addCommandHandler("a", function(player, cmd, subcmd, ...)
    if not players[player] or not players[player].isLoggedIn then
        outputChatBox("You must be logged in to use admin commands!", player, 255, 0, 0)
        return
    end
    
    if players[player].adminLevel < 1 then
        outputChatBox("You don't have admin permissions!", player, 255, 0, 0)
        return
    end
    
    local args = {...}
    
    if subcmd == "kick" then
        local targetName = args[1]
        local reason = table.concat(args, " ", 2)
        if not targetName then
            outputChatBox("Usage: /a kick [player] [reason]", player, 255, 255, 0)
            return
        end
        kickPlayer(player, targetName, reason)
    elseif subcmd == "ban" then
        local targetName = args[1]
        local reason = table.concat(args, " ", 2)
        if not targetName then
            outputChatBox("Usage: /a ban [player] [reason]", player, 255, 255, 0)
            return
        end
        banPlayer(player, targetName, reason)
    elseif subcmd == "mute" then
        local targetName = args[1]
        local time = args[2]
        if not targetName then
            outputChatBox("Usage: /a mute [player] [time]", player, 255, 255, 0)
            return
        end
        mutePlayer(player, targetName, tonumber(time) or 300)
    elseif subcmd == "unmute" then
        local targetName = args[1]
        if not targetName then
            outputChatBox("Usage: /a unmute [player]", player, 255, 255, 0)
            return
        end
        unmutePlayer(player, targetName)
    elseif subcmd == "goto" then
        local targetName = args[1]
        if not targetName then
            outputChatBox("Usage: /a goto [player]", player, 255, 255, 0)
            return
        end
        gotoPlayer(player, targetName)
    elseif subcmd == "gethere" then
        local targetName = args[1]
        if not targetName then
            outputChatBox("Usage: /a gethere [player]", player, 255, 255, 0)
            return
        end
        getHerePlayer(player, targetName)
    elseif subcmd == "setmoney" then
        local targetName = args[1]
        local amount = args[2]
        if not targetName or not amount then
            outputChatBox("Usage: /a setmoney [player] [amount]", player, 255, 255, 0)
            return
        end
        setPlayerMoneyAdmin(player, targetName, tonumber(amount))
    elseif subcmd == "givemoney" then
        local targetName = args[1]
        local amount = args[2]
        if not targetName or not amount then
            outputChatBox("Usage: /a givemoney [player] [amount]", player, 255, 255, 0)
            return
        end
        givePlayerMoneyAdmin(player, targetName, tonumber(amount))
    elseif subcmd == "sethealth" then
        local targetName = args[1]
        local health = args[2]
        if not targetName or not health then
            outputChatBox("Usage: /a sethealth [player] [health]", player, 255, 255, 0)
            return
        end
        setPlayerHealthAdmin(player, targetName, tonumber(health))
    elseif subcmd == "setarmor" then
        local targetName = args[1]
        local armor = args[2]
        if not targetName or not armor then
            outputChatBox("Usage: /a setarmor [player] [armor]", player, 255, 255, 0)
            return
        end
        setPlayerArmorAdmin(player, targetName, tonumber(armor))
    elseif subcmd == "setskin" then
        local targetName = args[1]
        local skin = args[2]
        if not targetName or not skin then
            outputChatBox("Usage: /a setskin [player] [skin]", player, 255, 255, 0)
            return
        end
        setPlayerSkinAdmin(player, targetName, tonumber(skin))
    elseif subcmd == "setadmin" then
        if players[player].adminLevel < 4 then
outputChatBox("Only owners can set admin levels!", player, 255, 0, 0)
            return
        end
        local targetName = args[1]
        local level = args[2]
        if not targetName or not level then
            outputChatBox("Usage: /a setadmin [player] [level]", player, 255, 255, 0)
            return
        end
        setPlayerAdminLevel(player, targetName, tonumber(level))
    elseif subcmd == "announce" then
        local message = table.concat(args, " ")
        if not message then
            outputChatBox("Usage: /a announce [message]", player, 255, 255, 0)
            return
        end
        announceMessage(player, message)
    elseif subcmd == "freeze" then
        local targetName = args[1]
        if not targetName then
            outputChatBox("Usage: /a freeze [player]", player, 255, 255, 0)
            return
        end
        freezePlayer(player, targetName)
    elseif subcmd == "slap" then
        local targetName = args[1]
        if not targetName then
            outputChatBox("Usage: /a slap [player]", player, 255, 255, 0)
            return
        end
        slapPlayer(player, targetName)
    elseif subcmd == "kill" then
        local targetName = args[1]
        if not targetName then
            outputChatBox("Usage: /a kill [player]", player, 255, 255, 0)
            return
        end
        killPlayerAdmin(player, targetName)
    elseif subcmd == "heal" then
        local targetName = args[1]
        if not targetName then
            outputChatBox("Usage: /a heal [player]", player, 255, 255, 0)
            return
        end
        healPlayer(player, targetName)
    elseif subcmd == "armor" then
        local targetName = args[1]
        if not targetName then
            outputChatBox("Usage: /a armor [player]", player, 255, 255, 0)
            return
        end
        armorPlayer(player, targetName)
    elseif subcmd == "weaps" then
        local targetName = args[1]
        if not targetName then
            outputChatBox("Usage: /a weap [player]", player, 255, 255, 0)
            return
        end
        giveWeaponsPlayer(player, targetName)
    elseif subcmd == "car" then
        local model = args[1]
        if not model then
            outputChatBox("Usage: /a car [model]", player, 255, 255, 0)
            return
        end
        spawnVehicleAdmin(player, tonumber(model))
    elseif subcmd == "repair" then
        repairVehicleAdmin(player)
    elseif subcmd == "flip" then
        flipVehicleAdmin(player)
    elseif subcmd == "god" then
        toggleGodMode(player)
    elseif subcmd == "invisible" then
        toggleInvisibility(player)
    elseif subcmd == "jetpack" then
        toggleJetpack(player)
    elseif subcmd == "weather" then
        local weather = args[1]
        if not weather then
            outputChatBox("Usage: /a weather [id]", player, 255, 255, 0)
            return
        end
        setWeatherAdmin(player, tonumber(weather))
    elseif subcmd == "time" then
        local hour = args[1]
        local minute = args[2]
        if not hour then
            outputChatBox("Usage: /a time [hour] [minute]", player, 255, 255, 0)
            return
        end
        setTimeAdmin(player, tonumber(hour), tonumber(minute) or 0)
    elseif subcmd == "setstats" then
        local targetName = args[1]
        if not targetName then
            outputChatBox("Usage: /a setstats [player]", player, 255, 255, 0)
            return
        end
        setPlayerStatsAdmin(player, targetName)
    elseif subcmd == "resetstats" then
        local targetName = args[1]
        if not targetName then
            outputChatBox("Usage: /a resetstats [player]", player, 255, 255, 0)
            return
        end
        resetPlayerStatsAdmin(player, targetName)
    elseif subcmd == "admins" then
        showOnlineAdmins(player)
    elseif subcmd == "players" then
        showOnlinePlayers(player)
    elseif subcmd == "serverinfo" then
        showServerInfo(player)
    else
        outputChatBox("Invalid command! Use /admin to see available commands.", player, 255, 0, 0)
    end
end)

-- Admin command implementations
function kickPlayer(admin, targetName, reason)
    if players[admin].adminLevel < 1 then
        outputChatBox("You don't have permission to kick players!", admin, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", admin, 255, 0, 0)
        return
    end
    
    if players[target].adminLevel >= players[admin].adminLevel then
        outputChatBox("You can't kick players with equal or higher admin level!", admin, 255, 0, 0)
        return
    end
    
    local kickReason = reason or "No reason specified"
    kickPlayer(target, kickReason)
    
    outputChatBox("You kicked " .. getPlayerName(target) .. " (" .. kickReason .. ")", admin, 0, 255, 0)
    outputChatBox(getPlayerName(admin) .. " kicked " .. getPlayerName(target) .. " (" .. kickReason .. ")", rootElement, 255, 100, 100)
end

function banPlayer(admin, targetName, reason)
    if players[admin].adminLevel < 2 then
        outputChatBox("You don't have permission to ban players!", admin, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", admin, 255, 0, 0)
        return
  end
  if players[target].adminLevel >= players[admin].adminLevel then
        outputChatBox("You can't ban players with equal or higher admin level!", admin, 255, 0, 0)
        return
    end
    
    local banReason = reason or "No reason specified"
    local serial = getPlayerSerial(target)
    local ip = getPlayerIP(target)
    
    -- Add to ban list
    addBan(ip, nil, serial, admin, banReason)
    
    outputChatBox("You banned " .. getPlayerName(target) .. " (" .. banReason .. ")", admin, 0, 255, 0)
    outputChatBox(getPlayerName(admin) .. " banned " .. getPlayerName(target) .. " (" .. banReason .. ")", rootElement, 255, 0, 0)
    
    kickPlayer(target, banReason)
end

function mutePlayer(admin, targetName, time)
    if players[admin].adminLevel < 1 then
        outputChatBox("You don't have permission to mute players!", admin, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", admin, 255, 0, 0)
        return
    end
    
    if players[target].adminLevel >= players[admin].adminLevel then
        outputChatBox("You can't mute players with equal or higher admin level!", admin, 255, 0, 0)
        return
    end
    
    setElementData(target, "muted", true)
    setElementData(target, "muteTime", getTickCount() + (time * 1000))
    
    outputChatBox("You muted " .. getPlayerName(target) .. " for " .. time .. " seconds", admin, 0, 255, 0)
    outputChatBox("You were muted by " .. getPlayerName(admin) .. " for " .. time .. " seconds", target, 255, 0, 0)
end

function unmutePlayer(admin, targetName)
    if players[admin].adminLevel < 1 then
        outputChatBox("You don't have permission to unmute players!", admin, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", admin, 255, 0, 0)
        return
    end
    
    if not getElementData(target, "muted") then
        outputChatBox("This player is not muted!", admin, 255, 0, 0)
        return
    end
    
    removeElementData(target, "muted")
    removeElementData(target, "muteTime")
    
    outputChatBox("You unmuted " .. getPlayerName(target), admin, 0, 255, 0)
    outputChatBox("You were unmuted by " .. getPlayerName(admin), target, 0, 255, 0)
end

function gotoPlayer(admin, targetName)
    if players[admin].adminLevel < 1 then
        outputChatBox("You don't have permission to teleport!", admin, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", admin, 255, 0, 0)
        return
    end
    
    local x, y, z = getElementPosition(target)
    setElementPosition(admin, x + 2, y, z)
    
    outputChatBox("You teleported to " .. getPlayerName(target), admin, 0, 255, 0)
end

function getHerePlayer(admin, targetName)
    if players[admin].adminLevel < 1 then
        outputChatBox("You don't have permission to teleport players!", admin, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", admin, 255, 0, 0)
        return
    end
    
    if players[target].adminLevel >= players[admin].adminLevel then
        outputChatBox("You can't teleport players with equal or higher admin level!", admin, 255, 0, 0)
        return
    end
    
    local x, y, z = getElementPosition(admin)
    setElementPosition(target, x + 2, y, z)
    
    outputChatBox("You teleported " .. getPlayerName(target) .. " to you", admin, 0, 255, 0)
    outputChatBox("You were teleported to " .. getPlayerName(admin), target, 0, 255, 0)
end

function setPlayerMoneyAdmin(admin, targetName, amount)
    if players[admin].adminLevel < 2 then
        outputChatBox("You don't have permission to set player money!", admin, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", admin, 255, 0, 0)
        return
    end
    
    if not amount or amount < 0 then
        outputChatBox("Invalid amount!", admin, 255, 0, 0)
        return
    end
    
    players[target].money = amount
    setPlayerMoney(target, amount)
    
    outputChatBox("You set " .. getPlayerName(target) .. "'s money to $" .. amount, admin, 0, 255, 0)
    outputChatBox(getPlayerName(admin) .. " set your money to $" .. amount, target, 0, 255, 0)
end

function givePlayerMoneyAdmin(admin, targetName, amount)
    if players[admin].adminLevel < 2 then
        outputChatBox("You don't have permission to give player money!", admin, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", admin, 255, 0, 0)
        return
    end
    
    if not amount or amount <= 0 then
        outputChatBox("Invalid amount!", admin, 255, 0, 0)
        return
    end
    
    players[target].money = players[target].money + amount
    setPlayerMoney(target, players[target].money)
    
    outputChatBox("You gave " .. getPlayerName(target) .. " $" .. amount, admin, 0, 255, 0)
    outputChatBox(getPlayerName(admin) .. " gave you $" .. amount, target, 0, 255, 0)
end

function setPlayerHealthAdmin(admin, targetName, health)
    if players[admin].adminLevel < 1 then
        outputChatBox("You don't have permission to set player health!", admin, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", admin, 255, 0, 0)
        return
    end
    if not health or health < 0 or health > 200 then
        outputChatBox("Health must be between 0 and 200!", admin, 255, 0, 0)
        return
    end
    
    setElementHealth(target, health)
    
    outputChatBox("You set " .. getPlayerName(target) .. "'s health to " .. health, admin, 0, 255, 0)
    outputChatBox(getPlayerName(admin) .. " set your health to " .. health, target, 0, 255, 0)
end

function setPlayerArmorAdmin(admin, targetName, armor)
    if players[admin].adminLevel < 1 then
        outputChatBox("You don't have permission to set player armor!", admin, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", admin, 255, 0, 0)
        return
    end
    
    if not armor or armor < 0 or armor > 100 then
        outputChatBox("Armor must be between 0 and 100!", admin, 255, 0, 0)
        return
    end
    
    setPedArmor(target, armor)
    
    outputChatBox("You set " .. getPlayerName(target) .. "'s armor to " .. armor, admin, 0, 255, 0)
    outputChatBox(getPlayerName(admin) .. " set your armor to " .. armor, target, 0, 255, 0)
end

function setPlayerSkinAdmin(admin, targetName, skin)
    if players[admin].adminLevel < 1 then
        outputChatBox("You don't have permission to set player skin!", admin, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", admin, 255, 0, 0)
        return
    end
    
    if not skin or skin < 0 or skin > 312 then
        outputChatBox("Invalid skin ID!", admin, 255, 0, 0)
        return
    end
    
    setElementModel(target, skin)
    players[target].skin = skin
    
    outputChatBox("You set " .. getPlayerName(target) .. "'s skin to " .. skin, admin, 0, 255, 0)
    outputChatBox(getPlayerName(admin) .. " set your skin to " .. skin, target, 0, 255, 0)
end

function setPlayerAdminLevel(admin, targetName, level)
    if players[admin].adminLevel < 4 then
        outputChatBox("Only owners can set admin levels!", admin, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", admin, 255, 0, 0)
        return
    end
    
    if not level or level < 0 or level > 4 then
        outputChatBox("Admin level must be between 0 and 4!", admin, 255, 0, 0)
        return
    end
    
    players[target].adminLevel = level
    executeSQL("UPDATE players SET admin_level = ? WHERE id = ?", level, players[target].id)
    
    outputChatBox("You set " .. getPlayerName(target) .. "'s admin level to " .. adminLevels[level], admin, 0, 255, 0)
    outputChatBox(getPlayerName(admin) .. " set your admin level to " .. adminLevels[level], target, 0, 255, 0)
end

function announceMessage(admin, message)
    if players[admin].adminLevel < 2 then
        outputChatBox("You don't have permission to make announcements!", admin, 255, 0, 0)
        return
    end
    
    outputChatBox("=== SERVER ANNOUNCEMENT ===", rootElement, 255, 255, 0)
    outputChatBox(message, rootElement, 255, 255, 255)
    outputChatBox("============================", rootElement, 255, 255, 0)
end

function freezePlayer(admin, targetName)
    if players[admin].adminLevel < 1 then
        outputChatBox("You don't have permission to freeze players!", admin, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", admin, 255, 0, 0)
        return
    end
    
    if players[target].adminLevel >= players[admin].adminLevel then
        outputChatBox("You can't freeze players with equal or higher admin level!", admin, 255, 0, 0)
        return
    end
    
    local frozen = isElementFrozen(target)
    setElementFrozen(target, not frozen)
    
    outputChatBox("You " .. (not frozen and "froze" or "unfroze") .. " " .. getPlayerName(target), admin, 0, 255, 0)
    outputChatBox("You were " .. (not frozen and "frozen" or "unfrozen") .. " by " .. getPlayerName(admin), target, 255, 255, 0)
end

function slapPlayer(admin, targetName)
    if players[admin].adminLevel < 1 then
        outputChatBox("You don't have permission to slap players!", admin, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", admin, 255, 0, 0)
        return
    end
    
    if players[target].adminLevel >= players[admin].adminLevel then
        outputChatBox("You can't slap players with equal or higher admin level!", admin, 255, 0, 0)
        return
    end
    
    local x, y, z = getElementPosition(target)
    setElementPosition(target, x, y, z + 10)
    
    outputChatBox("You slapped " .. getPlayerName(target), admin, 0, 255, 0)
    outputChatBox("You were slapped by " .. getPlayerName(admin), target, 255, 0, 0)
end

function killPlayerAdmin(admin, targetName)
    if players[admin].adminLevel < 1 then
        outputChatBox("You don't have permission to kill players!", admin, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", admin, 255, 0, 0)
        return
    end
    
    if players[target].adminLevel >= players[admin].adminLevel then
        outputChatBox("You can't kill players with equal or higher admin level!", admin, 255, 0, 0)
        return
    end
    
    killPed(target)
    
    outputChatBox("You killed " .. getPlayerName(target), admin, 0, 255, 0)
    outputChatBox("You were killed by " .. getPlayerName(admin), target, 255, 0, 0)
end

function healPlayer(admin, targetName)
    if players[admin].adminLevel < 1 then
        outputChatBox("You don't have permission to heal players!", admin, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", admin, 255, 0, 0)
        return
  end
  setElementHealth(target, 200)
    
    outputChatBox("You healed " .. getPlayerName(target), admin, 0, 255, 0)
    outputChatBox("You were healed by " .. getPlayerName(admin), target, 0, 255, 0)
end

function armorPlayer(admin, targetName)
    if players[admin].adminLevel < 1 then
        outputChatBox("You don't have permission to give armor!", admin, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", admin, 255, 0, 0)
        return
    end
    
    setPedArmor(target, 100)
    
    outputChatBox("You gave armor to " .. getPlayerName(target), admin, 0, 255, 0)
    outputChatBox("You were given armor by " .. getPlayerName(admin), target, 0, 255, 0)
end

function giveWeaponsPlayer(admin, targetName)
    if players[admin].adminLevel < 2 then
        outputChatBox("You don't have permission to give weapons!", admin, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", admin, 255, 0, 0)
        return
    end
    
    -- Give basic weapons
    giveWeapon(target, 24, 100) -- Desert Eagle
    giveWeapon(target, 25, 50) -- Shotgun
    giveWeapon(target, 31, 200) -- M4
    giveWeapon(target, 34, 20) -- Sniper Rifle
    
    outputChatBox("You gave weapons to " .. getPlayerName(target), admin, 0, 255, 0)
    outputChatBox("You were given weapons by " .. getPlayerName(admin), target, 0, 255, 0)
end

function spawnVehicleAdmin(admin, model)
    if players[admin].adminLevel < 1 then
        outputChatBox("You don't have permission to spawn vehicles!", admin, 255, 0, 0)
        return
    end
    
    if not model or model < 400 or model > 611 then
        outputChatBox("Invalid vehicle model!", admin, 255, 0, 0)
        return
    end
    
    local x, y, z = getElementPosition(admin)
    local vehicle = createVehicle(model, x + 5, y, z)
    
    if vehicle then
        outputChatBox("Vehicle spawned!", admin, 0, 255, 0)
    else
        outputChatBox("Failed to spawn vehicle!", admin, 255, 0, 0)
    end
end

function repairVehicleAdmin(admin)
    if players[admin].adminLevel < 1 then
        outputChatBox("You don't have permission to repair vehicles!", admin, 255, 0, 0)
        return
    end
    
    local vehicle = getPedOccupiedVehicle(admin)
    if not vehicle then
        outputChatBox("You must be in a vehicle!", admin, 255, 0, 0)
        return
    end
    
    fixVehicle(vehicle)
    setElementHealth(vehicle, 1000)
    
    outputChatBox("Vehicle repaired!", admin, 0, 255, 0)
end

function flipVehicleAdmin(admin)
    if players[admin].adminLevel < 1 then
        outputChatBox("You don't have permission to flip vehicles!", admin, 255, 0, 0)
        return
    end
    
    local vehicle = getPedOccupiedVehicle(admin)
    if not vehicle then
        outputChatBox("You must be in a vehicle!", admin, 255, 0, 0)
        return
    end
    
    local rx, ry, rz = getElementRotation(vehicle)
    setElementRotation(vehicle, 0, 0, rz)
    
    outputChatBox("Vehicle flipped!", admin, 0, 255, 0)
end

function toggleGodMode(admin)
    if players[admin].adminLevel < 2 then
        outputChatBox("You don't have permission to use god mode!", admin, 255, 0, 0)
        return
    end
    
    local godMode = getElementData(admin, "godMode") or false
    setElementData(admin, "godMode", not godMode)
    
    if not godMode then
        outputChatBox("God mode enabled!", admin, 0, 255, 0)
    else
        outputChatBox("God mode disabled!", admin, 255, 0, 0)
    end
end

function toggleInvisibility(admin)
    if players[admin].adminLevel < 2 then
        outputChatBox("You don't have permission to use invisibility!", admin, 255, 0, 0)
        return
    end
    
    local invisible = getElementData(admin, "invisible") or false
    setElementData(admin, "invisible", not invisible)
    setElementAlpha(admin, not invisible and 0 or 255)
    
    if not invisible then
        outputChatBox("Invisibility enabled!", admin, 0, 255, 0)
    else
        outputChatBox("Invisibility disabled!", admin, 255, 0, 0)
    end
end

function toggleJetpack(admin)
    if players[admin].adminLevel < 1 then
        outputChatBox("You don't have permission to use jetpack!", admin, 255, 0, 0)
        return
    end
    
    if doesPedHaveJetPack(admin) then
        removePedJetPack(admin)
        outputChatBox("Jetpack removed!", admin, 255, 0, 0)
    else
        givePedJetPack(admin)
        outputChatBox("Jetpack given!", admin, 0, 255, 0)
    end
end

function setWeatherAdmin(admin, weather)
    if players[admin].adminLevel < 2 then
        outputChatBox("You don't have permission to change weather!", admin, 255, 0, 0)
        return
    end
    
    if not weather or weather < 0 or weather > 45 then
        outputChatBox("Weather ID must be between 0 and 45!", admin, 255, 0, 0)
        return
    end
    
    setWeather(weather)
    outputChatBox("Weather changed to " .. weather, admin, 0, 255, 0)
end

function setTimeAdmin(admin, hour, minute)
    if players[admin].adminLevel < 2 then
        outputChatBox("You don't have permission to change time!", admin, 255, 0, 0)
        return
    end
    
    if not hour or hour < 0 or hour > 23 then
        outputChatBox("Hour must be between 0 and 23!", admin, 255, 0, 0)
        return
    end
    
    setTime(hour, minute or 0)
    outputChatBox("Time changed to " .. hour .. ":" .. string.format("%02d", minute or 0), admin, 0, 255, 0)
end

function setPlayerStatsAdmin(admin, targetName)
    if players[admin].adminLevel < 2 then
        outputChatBox("You don't have permission to set player stats!", admin, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", admin, 255, 0, 0)
        return
    end
    
    -- Set all stats to maximum
    for stat = 0, 230 do
        setPedStat(target, stat, 1000)
    end
    
    outputChatBox("You set " .. getPlayerName(target) .. "'s stats to maximum", admin, 0, 255, 0)
    outputChatBox(getPlayerName(admin) .. " set your stats to maximum", target, 0, 255, 0)
end

function resetPlayerStatsAdmin(admin, targetName)
    if players[admin].adminLevel < 2 then
        outputChatBox("You don't have permission to reset player stats!", admin, 255, 0, 0)
        return
    end
    
    local target = findPlayerByName(targetName)
    if not target then
        outputChatBox("Player not found!", admin, 255, 0, 0)
        return
    end
    
    -- Reset all stats to minimum
    for stat = 0, 230 do
        setPedStat(target, stat, 0)
    end
    
    outputChatBox("You reset " .. getPlayerName(target) .. "'s stats", admin, 0, 255, 0)
    outputChatBox(getPlayerName(admin) .. " reset your stats", target, 255, 255, 0)
end

function showOnlineAdmins(admin)
    local adminCount = 0
    outputChatBox("=== Online Admins ===", admin, 255, 255, 0)
    
    for _, player in ipairs(getElementsByType("player")) do
        if players[player] and players[player].isLoggedIn and players[player].adminLevel > 0 then
            outputChatBox(getPlayerName(player) .. " - " .. adminLevels[players[player].adminLevel], admin, 255, 255, 255)
            adminCount = adminCount + 1
        end
    end
    
    if adminCount == 0 then
        outputChatBox("No admins online!", admin, 255, 0, 0)
    end
end

function showOnlinePlayers(admin)
    local playerCount = 0
    outputChatBox("=== Online Players ===", admin, 255, 255, 0)
    
    for _, player in ipairs(getElementsByType("player")) do
        if players[player] and players[player].isLoggedIn then
            local x, y, z = getElementPosition(player)
            local health = math.floor(getElementHealth(player))
            local armor = math.floor(getPedArmor(player))
            local money = players[player].money or 0
            
            outputChatBox(string.format("%s - Health: %d, Armor: %d, Money: $%d", 
                getPlayerName(player), health, armor, money), admin, 255, 255, 255)
            playerCount = playerCount + 1
        end
    end
    
    outputChatBox("Total players: " .. playerCount, admin, 255, 255, 255)
end

function showServerInfo(admin)
    outputChatBox("=== Server Information ===", admin, 255, 255, 0)
    outputChatBox("Game Mode: ACNR MTA", admin, 255, 255, 255)
    outputChatBox("Version: 1.0.0", admin, 255, 255, 255)
    outputChatBox("Players: " .. #getElementsByType("player"), admin, 255, 255, 255)
    outputChatBox("Max Players: " .. getMaxPlayers(), admin, 255, 255, 255)
    outputChatBox("Password: " .. (getServerPassword() or "None"), admin, 255, 255, 255)
    outputChatBox("Uptime: " .. math.floor(getTickCount() / 1000) .. " seconds", admin, 255, 255, 255)
end

-- Handle god mode damage
addEventHandler("onPlayerDamage", rootElement, function()
    local player = source
    if getElementData(player, "godMode") then
        cancelEvent()
    end
end)

-- Handle mute system
addEventHandler("onPlayerChat", rootElement, function(message, messageType)
    local player = source
    if getElementData(player, "muted") then
        local muteTime = getElementData(player, "muteTime")
        if muteTime and getTickCount() < muteTime then
            outputChatBox("You are muted! Time remaining: " .. math.floor((muteTime - getTickCount()) / 1000) .. " seconds", player, 255, 0, 0)
            cancelEvent()
        else
            removeElementData(player, "muted")
            removeElementData(player, "muteTime")
        end
    end
end)
