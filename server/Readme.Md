# MTA Server Server Folder

This directory contains **server-side scripts and resources** that run exclusively on the Multi Theft Auto (MTA) server machine. These files handle core game logic, player management, database operations, security, and all server-side functionality that players never directly access.

## 📁 Folder Structure

```
server/
├── main.lua              # Primary server entry point
├── database/
│   ├── connection.lua    # Database connection handling
│   ├── queries.lua       # SQL query definitions
│   └── migrations/       # Database schema updates
├── managers/
│   ├── players.lua       # Player management system
│   ├── teams.lua         # Team coordination logic
│   ├── vehicles.lua      # Vehicle spawning/control
│   └── missions.lua      # Mission system controller
├── events/
│   ├── player_events.lua # Player-related event handlers
│   ├── vehicle_events.lua # Vehicle-related event handlers
│   └── custom_events.lua # Custom event definitions
├── security/
│   ├── anticheat.lua     # Anti-cheat measures
│   ├── permissions.lua   # Permission verification
│   └── validation.lua    # Input validation
├── utils/
│   ├── math_helpers.lua  # Mathematical utilities
│   ├── string_utils.lua  # String manipulation
│   └── debug_tools.lua   # Debugging utilities
└── config/
    ├── settings.lua      # Server configuration
    └── constants.lua     # Game constants
```

## 🔑 Key Components

### 1. **Core Scripts**
- **`main.lua`**: 
  - Server initialization
  - Resource startup sequence
  - Global event registration
  - Critical system startup

- **`database/`**:
  - Handles all database interactions
  - Manages persistent data storage
  - Contains schema migrations
  - Implements connection pooling

### 2. **Management Systems**
- **Player Management** (`managers/players.lua`):
  - Player login/logout
  - Account creation/management
  - Player state tracking
  - Statistics handling

- **Team System** (`managers/teams.lua`):
  - Team creation/balancing
  - Role assignments
  - Team communication
  - Score tracking

- **Mission Control** (`managers/missions.lua`):
  - Mission lifecycle management
  - Objective tracking
  - Reward distribution
  - Mission state persistence

### 3. **Event Handlers**
- **Player Events** (`events/player_events.lua`):
  - Join/quit handling
  - Death/spawn management
  - Chat/command processing
  - State change notifications

- **Vehicle Events** (`events/vehicle_events.lua`):
  - Vehicle spawning/destruction
  - Ownership tracking
  - Damage handling
  - Custom vehicle systems

### 4. **Security Layer**
- **Anti-Cheat** (`security/anticheat.lua`):
  - Movement validation
  - Resource tampering detection
  - Speed/position checks
  - Suspicious activity logging

- **Permission System** (`security/permissions.lua`):
  - Command access control
  - Resource authorization
  - Admin verification
  - Role-based permissions

## ⚙️ Core Functionality

### Database Integration
```lua
-- database/connection.lua
local db = dbConnect("mysql", "dbname=mta;host=127.0.0.1", "user", "pass")

function executeQuery(query, ...)
    local stmt = dbPrepareString(db, query, ...)
    return dbQuery(db, stmt)
end

-- database/queries.lua
function getPlayerData(playerId)
    return executeQuery("SELECT * FROM players WHERE id = ?", playerId)
end
```

### Player Management
```lua
-- managers/players.lua
local players = {}

function initializePlayer(player)
    players[player] = {
        id = getElementData(player, "account:id"),
        team = nil,
        score = 0,
        state = "lobby"
    }
    triggerClientEvent(player, "onPlayerDataReady", resourceRoot, players[player])
end

addEventHandler("onPlayerJoin", root, initializePlayer)
```

### Mission System
```lua
-- managers/missions.lua
local activeMissions = {}

function startMission(missionType, players)
    local mission = {
        id = #activeMissions + 1,
        type = missionType,
        participants = players,
        startTime = getTickCount(),
        objectives = generateObjectives(missionType)
    }
    activeMissions[mission.id] = mission
    triggerEvent("onMissionStart", root, mission)
    return mission
end
```

### Security Validation
```lua
-- security/validation.lua
function validatePosition(player, newPosition)
    local lastPosition = players[player].lastPosition
    local distance = getDistanceBetweenPoints3D(lastPosition, newPosition)
    local maxDistance = getMaxSpeed(player) * (getTickCount() - players[player].lastUpdate) / 1000
    
    if distance > maxDistance * 1.5 then
        kickPlayer(player, "Position tampering detected")
        return false
    end
    return true
end
```

## 🔧 Best Practices

### 1. **Code Organization**
- **Modular Design**: Split systems into logical modules
- **Single Responsibility**: Each file handles one primary function
- **Dependency Injection**: Pass dependencies explicitly
- **Clear Interfaces**: Define public APIs for each module

### 2. **Performance Optimization**
```lua
-- Use efficient data structures
local playerCache = {}  -- Instead of frequent getElementData calls

-- Batch database operations
function updatePlayerStats(players)
    local query = "UPDATE players SET score = ?, kills = ? WHERE id = ?"
    local stmt = dbPrepareString(db, query)
    for _, player in ipairs(players) do
        dbExec(db, stmt, player.score, player.kills, player.id)
    end
end

-- Use timers wisely
setTimer(function()
    -- Heavy operations here
end, 5000, 0)  -- Every 5 seconds instead of every frame
```

### 3. **Security Measures**
- **Never Trust Client Input**:
```lua
addEvent("onClientRequestAction", true)
addEventHandler("onClientRequestAction", root, function(action, data)
    if not validateAction(source, action, data) then
        cancelEvent()
        return
    end
    -- Process valid action
end)
```

- **Implement Rate Limiting**:
```lua
local actionCounts = {}

function rateLimit(player, action, limit, period)
    local key = player .. action
    if not actionCounts[key] then
        actionCounts[key] = {count = 1, reset = getTickCount() + period}
        return true
    end
    
    if actionCounts[key].count >= limit then
        return false
    end
    
    actionCounts[key].count = actionCounts[key].count + 1
    return true
end
```

### 4. **Error Handling**
```lua
-- Wrap critical operations
function safeCall(fn, ...)
    local success, result = pcall(fn, ...)
    if not success then
        outputDebugString("Error: " .. tostring(result), 1)
        return false
    end
    return result
end

-- Database operation wrapper
function safeQuery(query, ...)
    local qh = executeQuery(query, ...)
    if not qh then
        outputDebugString("Database query failed: " .. query, 2)
        return nil
    end
    return qh
end
```

## 🛠️ Common Tasks

### Adding New Server Functionality
1. Create appropriate file in relevant module
2. Define public interface at top of file
3. Implement required functionality
4. Add event handlers if needed
5. Register exports in `meta.xml`:
```xml
<export function="getMissionData" type="server"/>
```

### Creating Database Migrations
1. Add new file in `database/migrations/`
2. Name with timestamp: `20231101_add_player_stats.lua`
3. Implement upgrade/downgrade functions:
```lua
function upgrade()
    dbExec(db, "ALTER TABLE players ADD COLUMN stats TEXT")
end

function downgrade()
    dbExec(db, "ALTER TABLE players DROP COLUMN stats")
end
```

### Adding New Event Handlers
1. Create file in `events/` directory
2. Register handlers:
```lua
addEventHandler("onPlayerWasted", root, function()
    -- Handle player death
end)
```

## ⚠️ Troubleshooting

### Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Resource won't start | Check `debugscript 3` for syntax errors |
| Database connection fails | Verify credentials and server status |
| Players can't join | Check `acl.xml` permissions and resource dependencies |
| High CPU usage | Profile with `getPerformanceStats()` and optimize loops |
| Memory leaks | Use `collectgarbage()` and check for unreleased resources |

### Debugging Techniques
1. **Enable Debugging**:
```lua
-- In main.lua
setDevelopmentMode(true)
addCommandHandler("debuginfo", function(player)
    outputServerLog("Memory: " .. collectgarbage("count") .. " KB")
    outputServerLog("Players: " .. #getElementsByType("player"))
end)
```

2. **Event Logging**:
```lua
addEventHandler("onSomeEvent", root, function(...)
    outputServerLog("Event triggered: " .. tostring(eventName) .. 
                   " | Args: " .. inspect({...}))
end)
```

3. **State Inspection**:
```lua
addCommandHandler("getstate", function(player, cmd, target)
    local targetPlayer = getPlayerFromName(target)
    if targetPlayer then
        outputChatBox("Player state: " .. players[targetPlayer].state, player)
    end
end)
```

## 📚 Additional Resources

- [Server Scripting Tutorial](https://wiki.multitheftauto.com/wiki/Server_Scripting)
- [Database Integration Guide](https://wiki.multitheftauto.com/wiki/DbConnect)
- [Event System Documentation](https://wiki.multitheftauto.com/wiki/Events)
- [Security Best Practices](https://wiki.multitheftauto.com/wiki/Security)
- [Performance Optimization](https://forum.mtasa.com/topic/123456-server-performance/)

## 💡 Pro Tips

1. **Use Shared Modules**: Place common utilities in `shared/` to avoid duplication
2. **Implement Hot-Reloading**: Use `refresh` and `restart` commands for development
3. **Version Control**: Track all server scripts in Git
4. **Monitor Performance**: Regularly check `getPerformanceStats()`
5. **Document APIs**: Use LuaDoc comments for public functions:
```lua
--- Get player's current team
-- @param player The player element
-- @return Team element or false if not in team
function getPlayerTeam(player)
    -- Implementation
end
```

---

**Remember**: Server-side code is the backbone of your MTA server. Always prioritize security, performance, and maintainability when developing server systems. For community support, visit [MTA Server Development Forum](https://forum.mtasa.com/forum/67-server/).
