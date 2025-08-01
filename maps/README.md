# MTA Server Maps Folder

This folder contains map files for your Multi Theft Auto (MTA) server. Maps define the game world, including objects, vehicles, spawn points, and gameplay elements for your server's game modes.

## 📁 Folder Structure

```
maps/
├── main_map.map          # Primary server map
├── race_maps/
│   ├── circuit1.map      # Racing map 1
│   ├── circuit2.map      # Racing map 2
│   └── drift.map         # Drifting map
├── dm_maps/
│   ├── arena.map         # Deathmatch arena
│   └── city_war.map      # Urban combat map
└── custom/
    ├── stunt_park.map    # Custom stunt map
    └── roleplay.map      # Roleplay environment
```

## 🗺️ Map File Types

### `.map` Files
- **Primary Format**: XML-based map files
- **Contents**:
  - Object placements (buildings, props)
  - Vehicle spawn points
  - Player spawn positions
  - Pickup locations (weapons, health, armor)
  - Custom markers and zones
- **Editing Tools**:
  - [MTA Map Editor](https://wiki.multitheftauto.com/wiki/Map_Editor)
  - [3rd Party Tools](https://forum.mtasa.com/forum/71-map-editor/) (e.g., 3D Max, Blender with exporters)

### `.map` File Structure Example
```xml
<map>
  <object id="object1" model="1337" posX="0" posY="0" posZ="0" rotX="0" rotY="0" rotZ="0"/>
  <vehicle id="vehicle1" model="411" posX="10" posY="10" posZ="5" rotZ="90"/>
  <spawnpoint id="spawn1" posX="5" posY="5" posZ="3" rot="180"/>
</map>
```

## 🚀 Adding Maps to Your Server

### 1. Manual Installation
1. Place `.map` files in appropriate subfolders
2. Reference maps in your gamemode's meta.xml:
```xml
<meta>
  <map src="maps/main_map.map" />
  <map src="maps/race_maps/circuit1.map" />
</meta>
```

### 2. Using Resources
1. Create a dedicated resource for maps:
```
resources/
└── my_maps/
    ├── meta.xml
    └── maps/
        ├── map1.map
        └── map2.map
```

2. Configure meta.xml:
```xml
<meta>
  <info type="map" name="My Map Pack" author="YourName" version="1.0.0"/>
  <map src="maps/map1.map" />
  <map src="maps/map2.map" />
</meta>
```

### 3. Dynamic Map Loading
Use Lua scripts to load maps dynamically:
```lua
-- Load a map resource
function loadMap(mapName)
  if getResourceState(mapName) ~= "running" then
    startResource(getResourceFromName(mapName))
  end
end

-- Example usage
loadMap("my_maps")
```

## ⚙️ Map Configuration

### Resource Settings (meta.xml)
- **Priority**: Set loading order with `priority` attribute
```xml
<map src="maps/main.map" priority="1" />
<map src="maps/props.map" priority="2" />
```

### Map Filtering
Control which maps load based on game mode:
```xml
<meta>
  <map src="maps/race.map" gamemodes="race" />
  <map src="maps/dm.map" gamemodes="deathmatch" />
</meta>
```

## 🔧 Best Practices

1. **Organization**
   - Group maps by game mode or purpose
   - Use descriptive file names
   - Maintain consistent folder structure

2. **Performance Optimization**
   - Limit objects in high-traffic areas
   - Use LOD (Level of Detail) models for distant objects
   - Combine small objects into larger models where possible

3. **Collaboration**
   - Include README files in map folders
   - Document map requirements and dependencies
   - Version control your map files

4. **Testing**
   - Test maps with multiple players
   - Check for object collisions
   - Verify spawn points and pickups

## ⚠️ Common Issues & Troubleshooting

### Maps Not Loading
- **Check Paths**: Verify file paths in meta.xml
- **Resource State**: Ensure map resource is started
- **Console Errors**: Check server console for error messages

### Missing Objects
- **Model IDs**: Verify all model IDs exist in GTA
- **Custom Models**: Ensure custom DFF/TXD files are properly loaded
- **Object Limits**: Check if you've exceeded object limits

### Performance Problems
- **Object Count**: Reduce number of objects in view
- **Streaming Issues**: Adjust streaming distance in settings
- **Collision Data**: Verify collision models are present

### Map Conflicts
- **Overlapping Elements**: Check for overlapping objects or spawn points
- **Resource Order**: Adjust loading priority in meta.xml
- **Duplicate IDs**: Ensure all elements have unique IDs

## 📚 Additional Resources

- [Map Editor Documentation](https://wiki.multitheftauto.com/wiki/Map_Editor)
- [Creating Custom Maps](https://wiki.multitheftauto.com/wiki/Creating_Maps)
- [Map Resource Guide](https://wiki.multitheftauto.com/wiki/Resources)
- [Performance Optimization Tips](https://forum.mtasa.com/topic/123456-map-optimization-guide/)

## 💡 Tips for Map Creators

1. **Start Small**: Begin with basic layouts before adding details
2. **Test Often**: Regularly test maps during creation
3. **Get Feedback**: Share maps with community for testing
4. **Document Changes**: Keep changelogs for map updates
5. **Backup Work**: Regularly backup your map files

---

For community support and map sharing, visit:
- [MTA Community Maps Section](https://forum.mtasa.com/forum/71-maps/)
- [MTA Resources Repository](https://community.mtasa.com/)

Remember: Well-designed maps significantly enhance player experience and server performance!
