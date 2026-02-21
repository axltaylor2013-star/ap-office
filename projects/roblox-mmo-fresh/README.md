# Roblox MMO - Fresh Start

**Goal:** Build a clean, minimal foundation with working map + UI systems
**Approach:** ONE system at a time, test thoroughly before moving on

## Phase 1: Map & Spawning System ✅
- Simple terrain with ground at Y=0
- Spawn platform at Y=2.5
- SpawnLocation at Y=3.5 (on top of platform)
- PlayerSpawn script ensures proper spawning
- Basic lighting and visual effects

## Phase 2: UI System (Next)
- Inventory panel
- Stats panel  
- Hotbar
- No conflicts between UI elements

## Rules Followed:
1. **ONE SYSTEM AT A TIME** - Map first, test, then UI
2. **Proper Y positioning** - Ground at 0, spawn at 3.5
3. **$ignoreUnknownInstances** - Set on Workspace, Lighting, StarterPlayer
4. **Simple and clean** - No complex systems, no NPCs, no combat
5. **Testable** - Ready for Jeremy to test at 9pm EST

## File Structure:
```
roblox-mmo-fresh/
├── default.project.json    # Rojo project config
├── README.md              # This file
└── src/
    ├── ServerScriptService/
    │   ├── MapSetup.server.lua     # Creates terrain
    │   └── PlayerSpawn.server.lua  # Handles spawning
    ├── StarterPlayerScripts/       # (Phase 2: UI)
    └── ReplicatedStorage/Modules/  # (Phase 2: Shared modules)
```

## Testing Instructions:
1. Run `rojo build -o build.rbxlx` to create place file
2. Open in Roblox Studio
3. Test Play mode - players should spawn on ground, not fall from sky
4. Verify spawn position is correct (Y ≈ 3.5)