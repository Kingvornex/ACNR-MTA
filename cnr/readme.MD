# Cops and Robbers (CnR) Resource

This folder contains the **Cops and Robbers (CnR)** game mode resource for Multi Theft Auto (MTA). The resource implements team-based gameplay where players compete as law enforcement officers or criminals in various missions and challenges.

## 📁 Resource Structure

```
cnr/
├── meta.xml              # Resource configuration file
├── client/               # Client-side scripts & assets
├── server/               # Server-side scripts & logic
└── shared/               # Shared utilities & constants
```

## 🧩 Component Overview

### `meta.xml`
- **Purpose**: Core resource configuration
- **Contents**:
  - Resource metadata (author, version, type)
  - Script declarations (client/server/shared)
  - File dependencies
  - Exported functions
  - Settings & permissions
- **Example Structure**:
```xml
<meta>
    <info author="CnR Team" type="gamemode" name="Cops and Robbers" version="1.0.0"/>
    
    <!-- Client Scripts -->
    <script src="client/main.lua" type="client" cache="false"/>
    <script src="client/ui.lua" type="client"/>
    
    <!-- Server Scripts -->
    <script src="server/main.lua" type="server"/>
    <script src="server/missions.lua" type="server"/>
    
    <!-- Shared Scripts -->
    <script src="shared/constants.lua" type="shared"/>
    <script src="shared/utils.lua" type="shared"/>
    
    <!-- Client Files -->
    <file src="client/images/hud.png"/>
    <file src="client/sounds/radio.mp3"/>
    
    <!-- Exports -->
    <export function="getPlayerTeam" type="server"/>
    
    <!-- Settings -->
    <settings>
        <setting name="*max_players" value="32" />
        <setting name="*round_time" value="600" />
    </settings>
</meta>
```

### `client/` Folder
Contains all client-side components that run on players' machines:
- **Scripts**:
  - UI rendering (HUD, menus, dialogs)
  - Visual effects (markers, shaders)
  - Input handling (keybinds, mouse controls)
  - Client-side event handlers
- **Assets**:
  - Textures (team icons, UI elements)
  - Sound effects (sirens, radio chatter)
  - Custom models (police vehicles, equipment)
- **Key Files**:
  - `main.lua`: Client initialization and core systems
  - `ui.lua`: User interface management
  - `effects.lua`: Visual and audio effects

### `server/` Folder
Contains all server-side logic that manages the game state:
- **Scripts**:
  - Game mode core logic
  - Team management (cops/robbers)
  - Mission systems (heists, pursuits)
  - Player data management
  - Database interactions
  - Anti-cheat measures
- **Key Files**:
  - `main.lua`: Server initialization and core systems
  - `missions.lua`: Mission definitions and logic
  - `teams.lua`: Team management and balancing
  - `database.lua`: Data persistence

### `shared/` Folder
Contains code and data used by both client and server:
- **Scripts**:
  - Constants (team IDs, vehicle models, weapon IDs)
  - Utility functions (math helpers, string operations)
  - Configuration data (mission parameters, game rules)
  - Shared event definitions
- **Key Files**:
  - `constants.lua`: Game constants and enums
  - `utils.lua`: Shared utility functions
  - `config.lua`: Game configuration parameters

## 🚀 Development Workflow

### Adding New Features
1. **Determine Scope**:
   - Client-only? → Add to `client/`
   - Server-only? → Add to `server/`
   - Shared logic? → Add to `shared/`

2. **Create Files**:
   ```bash
   # Example: New mission system
   touch server/missions/heist.lua
   touch client/ui/heist_ui.lua
   touch shared/missions/heist_data.lua
   ```

3. **Update meta.xml**:
   ```xml
   <script src="server/missions/heist.lua" type="server"/>
   <script src="client/ui/heist_ui.lua" type="client"/>
   <script src="shared/missions/heist_data.lua" type="shared"/>
   ```

### Communication Between Sides
Use MTA's event system for client-server communication:

**Server → Client**:
```lua
-- Server (server/missions.lua)
triggerClientEvent(player, "onMissionStart", resourceRoot, missionData)

-- Client (client/main.lua)
addEvent("onMissionStart", true)
addEventHandler("onMissionStart", resourceRoot, function(missionData)
    -- Handle mission start
end)
```

**Client → Server**:
```lua
-- Client (client/ui.lua)
triggerServerEvent("onPlayerReady", resourceRoot)

-- Server (server/main.lua)
addEvent("onPlayerReady", true)
addEventHandler("onPlayerReady", resourceRoot, function()
    -- Initialize player
end)
```

### Shared Data Access
Use shared constants for consistency:
```lua
-- shared/constants.lua
TEAM_COPS = 1
TEAM_ROBBERS = 2

VEHICLE_POLICE = 596
VEHICLE_GETAWAY = 567
```

Access in both client and server scripts:
```lua
-- client/ui.lua or server/teams.lua
local teamName = (playerTeam == TEAM_COPS) and "Police" or "Robbers"
```

## ⚙️ Configuration

### Game Settings
Modify in `meta.xml` or via server console:
```xml
<settings>
    <setting name="*round_duration" value="600" friendlyname="Round Duration" group="Gameplay" accept="60-1800"/>
    <setting name="*max_cops" value="10" friendlyname="Max Cops" group="Teams" accept="1-32"/>
</settings>
```

### Balancing Parameters
Adjust in `shared/config.lua`:
```lua
-- Mission rewards
MISSION_REWARD = {
    heist = 5000,
    pursuit = 2000,
    arrest = 1000
}

-- Team balancing
TEAM_BALANCE = {
    copRatio = 0.4, -- 40% cops, 60% robbers
    minPlayers = 4   -- Minimum players to start
}
```

## 🔧 Best Practices

### Code Organization
1. **Modular Design**:
   - Split systems into separate files
   - Use logical folder structure
   - Implement clear interfaces

2. **Naming Conventions**:
   ```lua
   -- Functions: camelCase
   function getPlayerTeamData(player)
   
   -- Constants: UPPER_SNAKE_CASE
   local MAX_PLAYERS = 32
   
   -- Events: onActionNoun
   addEvent("onPlayerArrested", true)
   ```

3. **Error Handling**:
   ```lua
   -- Server-side
   function safeArrestPlayer(officer, suspect)
       if not isElement(officer) or not isElement(suspect) then
           outputDebugString("Invalid arrest attempt", 1)
           return false
       end
       -- Arrest logic
   end
   ```

### Performance Optimization
1. **Client-Side**:
   - Use `onClientRender` sparingly
   - Implement object pooling for UI elements
   - Optimize texture sizes

2. **Server-Side**:
   - Cache frequently accessed data
   - Use efficient database queries
   - Implement rate limiting for actions

### Security Considerations
1. **Client Validation**:
   - Never trust client input
   - Validate all actions server-side
   - Use `triggerServerEvent` for critical actions

2. **Anti-Cheat**:
   - Implement server-side checks
   - Monitor player behavior
   - Use MTA's built-in anti-cheat features

## 🐛 Debugging

### Client-Side Debugging
1. Use debug console (`F8`):
   ```lua
   outputDebugString("Client: Player joined team "..teamName)
   iprint("Player data:", playerData)
   ```

2. Visual debugging:
   ```lua
   -- Show debug markers
   function showDebugMarker(x, y, z)
       local marker = createMarker(x, y, z, "corona", 2, 255, 0, 0, 150)
       setTimer(destroyElement, 5000, 1, marker)
   end
   ```

### Server-Side Debugging
1. Log to console:
   ```lua
   outputServerLog("Mission started: "..missionName)
   outputChatBox("DEBUG: "..message, root, 255, 255, 0)
   ```

2. State inspection:
   ```lua
   -- Print current game state
   function debugGameState()
       outputChatBox("Cops: "..#getPlayersInTeam(TEAM_COPS))
       outputChatBox("Robbers: "..#getPlayersInTeam(TEAM_ROBBERS))
   end
   ```

## 📚 Additional Resources

- [MTA Scripting Introduction](https://wiki.multitheftauto.com/wiki/Scripting_Introduction)
- [Client-Server Communication](https://wiki.multitheftauto.com/wiki/TriggerServerEvent)
- [Game Mode Development Guide](https://wiki.multitheftauto.com/wiki/Game_modes)
- [Performance Optimization Tips](https://forum.mtasa.com/topic/123456-performance-optimization/)

## 💡 Contributing

1. **Fork the repository**
2. **Create feature branch**: `git checkout -b feature/new-mission`
3. **Follow coding standards**:
   - Use consistent indentation
   - Add comments for complex logic
   - Test with multiple players
4. **Submit pull request** with detailed description

---

**Remember**: This is a collaborative resource. Always test changes thoroughly and communicate with the team before implementing major gameplay changes! For support, visit our [development forum](https://forum.mtasa.com/forum/cnr-development/).
