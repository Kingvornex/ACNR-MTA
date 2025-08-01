# ACNR-MTA
Converting ACNR from SAMP-OPENMP to MTA

# Converting ACNR-OPENMP to MTA


## Key Differences Between SA-MP and MTA

1. **Scripting Language**:
   - SA-MP uses Pawn (a C-like language)
   - MTA uses Lua

2. **Architecture**:
   - SA-MP has a single script file structure
   - MTA uses a resource-based system with multiple files

## Conversion Steps

### 1. Analyze the Original Code
First, you'll need to thoroughly understand the ACNR game mode structure, including:
- Player systems
- Vehicle systems
- Economy
- Commands
- Events and callbacks

### 2. Set Up MTA Resource Structure
Create a basic MTA resource structure:
```
/acnr/
  /meta.xml
  /client/
  /server/
  /shared/
```

### 3. Convert Core Systems

Here's how some common SA-MP functions map to MTA:

| SA-MP Function | MTA Equivalent |
|----------------|----------------|
| `SendClientMessage` | `outputChatBox` |
| `CreateVehicle` | `createVehicle` |
| `GivePlayerMoney` | `givePlayerMoney` |
| `SetPlayerPos` | `setElementPosition` |
| `GetPlayerName` | `getPlayerName` |

### 4. Rewrite Commands
SA-MP commands like:
```pawn
CMD:heal(playerid, params[]) {
    SetPlayerHealth(playerid, 100);
    SendClientMessage(playerid, -1, "You have been healed!");
    return 1;
}
```

Would become in MTA:
```lua
function healPlayer(player, command)
    setElementHealth(player, 100)
    outputChatBox("You have been healed!", player, 255, 255, 255)
end
addCommandHandler("heal", healPlayer)
```

### 5. Adapt Events
SA-MP callbacks like `OnPlayerConnect` would be converted to MTA events like `onPlayerJoin`.

## Challenges You'll Face

1. **Database Integration**: If ACNR uses MySQL, you'll need to adapt it to MTA's database functions
2. **GUI Systems**: MTA has a completely different GUI system using CEGUI
3. **Vehicle Handling**: Vehicle physics and handling may differ between platforms
4. **Synchronization**: Player and entity synchronization works differently

## Recommended Approach

1. Start with basic player management (login, spawn, etc.)
2. Convert core gameplay systems one by one
3. Test thoroughly after each major system conversion
4. Consider using MTA's built-in systems where possible (like the map editor)
