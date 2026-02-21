# Roscape Runeblocks — Code Review Checklist

Every sub-agent MUST verify these before declaring work complete.

## Pre-Build Checks

### Luau Syntax
- [ ] No `:: Type` annotations anywhere
- [ ] No return type annotations (`: ReturnType`)
- [ ] No `PaddingAll` — use PaddingTop/Bottom/Left/Right
- [ ] No `GroupTransparency` on Frame — only CanvasGroup
- [ ] All module calls use dot notation: `Module.Func()` not `Module:Func()`
- [ ] All `require()` calls at TOP of file, before functions that use them

### Data Contracts
- [ ] DataManager fields UPPERCASE: Skills, Inventory, Equipment, Gold, Bank, Quests
- [ ] Inventory items: `{name = string, quantity = number}`
- [ ] Equipment: `{Head, Body, Legs, Weapon, Shield, Tool}`
- [ ] Skills are raw XP numbers, not tables

### Remotes
- [ ] All new RemoteEvents added to `default.project.json`
- [ ] WaitForChild with timeout (10s) + nil check on all remote references
- [ ] Check both `Remotes` folder AND ReplicatedStorage root for existing remotes

### Models & Positioning
- [ ] Monster/NPC body center Y = bodyHeight/2 (feet on ground at Y=0)
- [ ] ClickDetectors on ALL parts (not just Body)
- [ ] MaxActivationDistance >= 20 for monsters, >= 14 for items
- [ ] NPCs have accessoryBuilders entry matching NPC_DEFS entry
- [ ] Boss spawn locations have clear walkable paths (no walls blocking)

### Map Scripts
- [ ] Proper task.wait() at top: MapSetup=0, MS2=1, MS3=3, MS4=5, MS5=7
- [ ] NPCManager wait >= 8 seconds
- [ ] MonsterManager wait >= 4 seconds
- [ ] New areas within baseplate bounds (800x800)

### Items & Equipment
- [ ] New items added to ItemDatabase.lua with all fields
- [ ] New items added to ItemVisuals.lua (emoji, color, shape)
- [ ] Equipment items have equipSlot, defense/damage, combatReq
- [ ] Food items have healAmount field
- [ ] Complete tier coverage (Bronze→Dragon for all slot types)

### UI
- [ ] Dark theme: RGB(26,26,46) bg, RGB(240,192,64) gold
- [ ] Font: GothamBold headers, Gotham body
- [ ] UICorner + UIStroke on all panels
- [ ] No TAB key bindings (captured by Roblox)

## Post-Build Checks
- [ ] BOM stripped from ALL .lua files
- [ ] `rojo build` succeeds with no errors
- [ ] Reminded user to reload .rbxlx file
- [ ] Verified file sizes > 0 (not empty writes)
