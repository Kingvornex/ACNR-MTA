
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
function withdrawFr
