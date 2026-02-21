# Roscape Runeblocks — Team Lessons Learned

## Hard-Won Bug Fixes (Never Repeat These)

### 1. BOM Kills Everything
Windows writes UTF-8 BOM (EF BB BF) to .lua files. Roblox can't parse it. Script silently fails.
**Rule**: Strip BOM after EVERY file write. No exceptions.

### 2. Sword Grip Direction
Handle at CFrame(0,0,0), blade extends NEGATIVE Y. But createModelOnLimb multiplies by hand CFrame.
Need 180° Z rotation when attaching: `limb.CFrame * CFrame.Angles(0, 0, math.rad(180)) * rootPart.CFrame`

### 3. Module Require Order
If you `local ItemVisuals = require(...)` AFTER defining `refreshData()`, the function captures nil.
**Rule**: ALL module requires at TOP of file, before any function definitions.

### 4. Dot vs Colon
`DataManager:GetData(player)` passes DataManager as first arg → silent failure.
**Rule**: ALWAYS `DataManager.GetData(player)` (dot notation).

### 5. Type Annotations Break Luau
`:: Type` and return type annotations cause "Ambiguous syntax" in Roblox.
**Rule**: Zero type annotations in any .lua file.

### 6. ClickDetector Coverage
Putting ClickDetector only on Body = terrible hitbox. Players can't click heads, legs, extras.
**Rule**: Add ClickDetectors to ALL parts of interactive models.

### 7. Monster/NPC Y Positioning
Baseplate top = Y 0. Body center = bodyHeight/2. Spawn at Y=0.
**Rule**: Never hardcode Y=3 or Y=5. Calculate from body dimensions.

### 8. Stale .rbxlx
If Jeremy says "nothing changed" → he's running old file. Always rebuild first.

### 9. GroupTransparency / PaddingAll
GroupTransparency only on CanvasGroup. PaddingAll doesn't exist.
**Rule**: Use individual padding properties. Use CanvasGroup for transparency.

### 10. NPC Accessory Builders
NPCs in NPC_DEFS without matching accessoryBuilders entries → spawn with plain bodies.
**Rule**: Every NPC in NPC_DEFS needs a builder function AND an entry in accessoryBuilders table.

### 11. Map Script Timing
MapSetup scripts run in parallel. Later scripts must wait for earlier ones.
**Rule**: MapSetup=0, MapSetup2=task.wait(1), MapSetup3=task.wait(3), MapSetup4=task.wait(5), MapSetup5=task.wait(7), NPCManager=task.wait(8), MonsterManager=task.wait(4).

### 12. Wall Gaps for Access
If you put a boss behind a wall area, players need a path to get there.
**Rule**: Always verify walkable paths to every spawn point.

### 13. PowerShell && Operator
Not available in older PowerShell versions. Use `;` semicolon instead.

### 14. RemoteEvent Locations
EquipmentManager creates remotes at ReplicatedStorage root, not in Remotes folder.
**Rule**: Always check BOTH locations when looking for remotes.

### 15. DataStore Requires Published Place
Crashes on unpublished local files. Always pcall with in-memory fallback.
