---
name: roblox-game-builder
description: Build Roblox games using Rojo for file syncing into Roblox Studio. Write Luau scripts, manage project structure, handle builds and live syncing. Use when creating, modifying, or debugging Roblox game code and project files.
---

# Roblox Game Builder

Build and maintain Roblox games from the filesystem using Rojo for live syncing into Roblox Studio.

## Critical Knowledge

### Rojo Setup
- **Binary**: `C:\Users\alfre\bin\rojo.exe` (v7.6.1)
- **Plugin**: Installed at `%LOCALAPPDATA%\Roblox\Plugins\Rojo.rbxm`
- **Project file**: `default.project.json` in project root

### Rojo File Naming Conventions
- `*.server.lua` → **Script** (runs on server)
- `*.client.lua` → **LocalScript** (runs on client)
- `*.lua` → **ModuleScript** (shared, must return a value)
- `init.server.lua` / `init.client.lua` / `init.lua` → Script inside a folder with the folder's name

### CRITICAL: $ignoreUnknownInstances
**ALWAYS** set `"$ignoreUnknownInstances": true` on Workspace and any service with manually-placed Studio content. Without this, Rojo DELETES everything not in the project file.

Use on: Workspace (always), Lighting, StarterPlayer, any mixed service.

### Rojo Workflow
1. **Build**: `rojo build -o Game.rbxlx` — creates place file
2. **Serve**: `rojo serve` — starts live sync server
3. **Connect**: Studio → Plugins → Rojo → Connect
4. **ALWAYS rebuild before testing** — stale .rbxlx is the #1 "nothing changed" cause

### Project Structure
```
project-root/
  default.project.json
  src/
    ServerScriptService/     ← .server.lua (server scripts)
    ReplicatedStorage/
      Modules/               ← .lua (ModuleScripts — shared logic)
    StarterPlayerScripts/    ← .client.lua (client scripts)
```

## Luau Scripting Rules

### BOM (Byte Order Mark) — CRITICAL ⚠️
- Windows writes UTF-8 BOM (U+FEFF, bytes EF BB BF) to .lua files
- Roblox Luau CANNOT parse BOM — silent failure, no output, line 1 error
- **ALWAYS strip BOM after writing ANY .lua file**:
```powershell
Get-ChildItem "src" -Recurse -Filter "*.lua" | ForEach-Object {
  $b=[System.IO.File]::ReadAllBytes($_.FullName)
  if($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF){
    [System.IO.File]::WriteAllBytes($_.FullName,$b[3..($b.Length-1)])
  }
}
```

### Luau Syntax Traps ⚠️
- **No type annotations**: `:: Type` and `: ReturnType` cause "Ambiguous syntax" parse errors. Strip ALL type annotations.
- **No `PaddingAll`**: UIPadding doesn't have PaddingAll. Set PaddingTop/Bottom/Left/Right individually.
- **`GroupTransparency` only works on `CanvasGroup`**, NOT Frame. Using it on Frame silently fails.
- **TAB key is captured by Roblox** — use B, K, P, J, M or custom buttons for UI toggles.
- **Dot vs colon on modules**: `Module.Func(arg)` NOT `Module:Func(arg)`. Colon passes the module table as first arg, silently breaking everything.

### Client Script Gotchas ⚠️
- **`UIPadding.PaddingAll` does NOT exist in Roblox** — use PaddingTop/Bottom/Left/Right individually
- **A runtime error mid-script kills everything after it** — all event handlers, UI setup, etc. below the error line never run
- **This is why "nothing works" bugs happen** — one bad property kills the whole script
- **Always test UI properties exist before using them**

### Script Architecture (Server-Authoritative)
- **NEVER trust the client** — all game logic on server
- Client: UI, input, camera, visual effects only
- Server: damage, inventory, XP, loot, zone detection
- Shared logic = ModuleScript in ReplicatedStorage/Modules (ONLY ModuleScripts can be `require()`d)

### RemoteEvents ⚠️ CRITICAL
- **ALL RemoteEvents/RemoteFunctions MUST be in `default.project.json` under the Remotes folder** — never create them with Instance.new() in server scripts (causes duplicate events that don't communicate)
- **Server scripts should use `Remotes:WaitForChild("EventName")` to get events from the Remotes folder**, NOT `getOrCreateRemote()` patterns
- **Client scripts already do this correctly with `waitForRemote()`**
- Use RemoteEvent for fire-and-forget (attacks, notifications)
- Use RemoteFunction for request-response (GetStatsPanel, GetSkillData)
- **Legacy note**: EquipmentManager creates remotes at ReplicatedStorage ROOT, not in Remotes folder — always check both locations

### DataManager Field Casing ⚠️
- **UPPERCASE fields**: `data.Skills`, `data.Inventory`, `data.Equipment`, `data.Gold`, `data.Bank`, `data.Quests`
- Skills = raw XP numbers: `data.Skills.Mining = 150`
- Inventory = array of `{name=string, quantity=number}`
- Equipment = `{Head="", Body="", Legs="", Weapon="", Shield="", Tool=""}`
- Use `Config.GetLevelFromXP(xp)` to convert XP to level

### DataStore
- **Requires PUBLISHED place** — unpublished crashes with "must publish to access DataStore"
- **ALWAYS wrap in pcall** with in-memory fallback for testing
- Auto-save every 5 mins + PlayerRemoving + BindToClose

## Map Building

### Via Server Script (Primary Method)
Rojo can't sync Parts — build maps via MapSetup.server.lua that creates all Parts at runtime:
```lua
local function makePart(name, size, position, color, material, parent, props)
  local p = Instance.new("Part")
  p.Name = name; p.Size = size; p.Position = position
  p.Anchored = true; p.BrickColor = BrickColor.new(color)
  p.Material = material; p.Parent = parent
  if props then for k,v in pairs(props) do p[k] = v end end
  return p
end
```

### Y Positioning ⚠️
- Baseplate top = Y 0 (baseplate Size Y=1, Position Y=-0.5)
- Body/part center Y = height/2 for feet on ground
- Monsters/NPCs: spawn at Y=0, NOT Y=3 or Y=5
- NPC body positioning: `origin + Vector3.new(0, legSize.Y + torsoSize.Y/2, 0)` for torso center

### Multi-Script Map Setup
For large maps, split into MapSetup.server.lua + MapSetup2.server.lua with `task.wait(1)` in MapSetup2 to let the first finish.

### Map Building Best Practices
- **Use themed zones with dedicated ground floors instead of random scatter**
- **Each zone needs**: ground floor part, perimeter features, zone-specific decorations, a sign
- **Random `math.random()` decorations look terrible** — use intentional placement arrays
- **Ground layering**: base terrain at y=0.05-0.08, paths at y=0.06-0.12, zone floors at y=0.07-0.18

## Monster/NPC Building

### Monster Model Structure
Monsters are raw Part models (not Humanoid rigs):
- `Body` (PrimaryPart, Block) — center at bodySize.Y/2
- `Head` (Ball) — on top of body
- Extras array for detail parts (eyes, limbs, weapons, armor)
- `extras` items: `{name, shape("Block"/"Ball"), size(V3), offset(V3), color(Color3.fromRGB), material?, transparency?, bodyRelative?, rotation?}`
- `bodyRelative = true` = offset from body center; `false/nil` = offset from head

### NPC Model Structure
NPCs use humanoid-style multi-part bodies:
- Built by `buildBody()`: torso, head, arms, legs
- Accessories via builder functions per NPC
- `makePart({Name, Size, Color, CFrame, Parent, ...})` + `weld(part0, part1)` pattern
- ClickDetectors on ALL parts for interaction
- BillboardGui nametag with name (gold) + role (white)

### Visual Equipment (on players)
- Weapons: multi-part models (handle + pommel + crossguard + blade), welded to RightHand/Right Arm
- Handle CFrame at `(0,0,0)` = at hand position, blade extends DOWNWARD (negative Y)
- Shields: welded to LeftHand/Left Arm
- Helmets: welded to Head
- Body armor: overlay parts on torso + color changes
- R15 fallback to R6: always check `RightHand` then fall back to `Right Arm`
- Use `clearVisual(character, tag)` to remove old visuals before applying new

## Animation System

### TweenService ONLY — No Animation Objects ⚠️
- `rbxassetid://` animations DO NOT WORK in Studio test mode
- Use TweenService to rotate Motor6D C0 properties for character animations:
```lua
local TweenService = game:GetService("TweenService")
local rightShoulder = character.RightUpperArm:FindFirstChildOfClass("Motor6D")
local originalC0 = rightShoulder.C0
local swingCF = originalC0 * CFrame.Angles(math.rad(-90), 0, 0)
TweenService:Create(rightShoulder, TweenInfo.new(0.2), {C0 = swingCF}):Play()
task.delay(0.3, function()
  TweenService:Create(rightShoulder, TweenInfo.new(0.2), {C0 = originalC0}):Play()
end)
```

### Monster Animations
- Tween Body/Head CFrame directly (they're raw Parts, not rigs)
- Lunge: move Body forward briefly, snap back
- Bite: move Head forward
- Magic: scale up neon orb, create projectile part that tweens to target
- Death: tween Body rotation to fall over, fade transparency, destroy

### Monster Animation System (Client-Side)
- **Client-side monster movement animations go in StarterPlayerScripts**
- **MUST filter out player characters using `Players:GetPlayerFromCharacter(model)`** — otherwise the animation script will move the player's body parts
- **Store original part positions and animate OFFSETS, don't set absolute positions**
- **Use RenderStepped for client visual animations, Heartbeat for server logic**

### Combat Visual Effects
- Damage numbers: BillboardGui with TextLabel, tween Position.Y up + TextTransparency to 1
- Hit flash: briefly set all character parts to white, revert after 0.1s
- Swoosh trail: thin neon Part that follows sword arc, fades
- Camera shake: RenderStepped offset with decay
- Shield sparks: small neon parts scattered at impact point

## Resource Node System

### Multi-Charge Nodes
Nodes have a `quantity` parameter (2-8 charges). Each gather uses one charge. Node depletes when charges hit 0. Label shows `[3/5]` counter.
- Low tier (Copper, Oak, Shrimp): 4-8 charges
- Mid tier (Iron, Willow, Trout): 3-5 charges
- High tier (Gold, Yew, Lobster): 2-4 charges
- Top tier (Runite, Magic, Dark Crab): 2-3 charges

### Gathering Tools
- 15 tools: 5 pickaxes, 5 axes, 5 fishing rods (Bronze→Dragon)
- Tool slot in Equipment, gathering requires matching tool type
- Gather time = baseTime * toolSpeed * (1 - levelBonus)
- New players get starter tools (Bronze Pickaxe, Bronze Axe, Wooden Rod)

## UI Design Standards

### Theme: Dark Medieval
- Background: `#1a1a2e` (dark navy)
- Gold accent: `#f0c040` (Color3.fromRGB(240, 192, 64))
- Font: GothamBold for headers, Gotham for body
- All panels: rounded corners (UICorner), gold UIStroke border
- Rarity colors: common=#9d9d9d, uncommon=#1eff00, rare=#0070dd, epic=#a335ee, legendary=#ff8000

### Hotkeys
- B = StatsPanel (Skills/Inventory/Loadout)
- K = SkillTree
- P = PrayerBook
- M = MiniMap toggle
- J = Quest Journal

### Minimap Features
- Circular 200px, heading-up rotation, gold border
- Dot colors: cyan=players, green=NPCs, red=enemies, brown=rocks, green=trees, blue=fish, yellow=loot
- Legend panel below
- Hover tooltips showing names
- Click to zoom (1x/2x)
- Zone indicator with emoji (🏰 SAFE ZONE / ⚠️ WILDERNESS)

## Monetization (Roblox Developer Products)

### XP Boost System
- 2x XP multiplier, time-limited purchases
- Pricing tiers: 10 min ($1), 1 hour ($5), 1 day ($20), 1 week ($99)
- Implement via `Config.XPMultiplier` check + `MarketplaceService.ProcessReceipt`
- Visual indicator on screen when boost active (golden glow border, timer)
- Stack notification: "🔥 2x XP Active! 4:32 remaining"

### DevEx Economics
- DevEx rate: ~$0.0038/Robux (100K minimum = ~$380 payout)
- Top games (Blox Fruits): $50-100M/year
- Target: 1000 daily active for meaningful revenue

## First Reveal Standard 🎯
When building a new game from an idea, the FIRST playable reveal should include:
- 10+ skills with XP/level progression
- 75+ items (weapons, armor, tools, materials, food, drops)
- 10+ monster types with unique visuals and AI
- 14+ NPCs with unique bodies, accessories, dialog, shops
- 10+ quests with story and branching choices
- Full map (800x800+ studs) with safe zone city + wilderness
- Multi-charge resource nodes (3-8 gathers)
- Complete UI suite (StatsPanel, SkillTree, PrayerBook, MiniMap, HealthBar)
- Equipment system with visual weapons/armor on characters
- Banking, trading, crafting, loot drops
- PvP wilderness with full-loot death
- Working minimap with legend, compass, zoom, tooltips
- Attack animation system (sword swings, bow shots, monster attacks, hit effects)
- World animations (torch flicker, tree sway, water shimmer, NPC idle)
- TEST_MODE flag for rapid testing
- Design docs (skills, items, NPCs, quests)
- ~35+ script files, fully playable

## Inventory & Item System Lessons

### Module Require Order ⚠️
ALL `require()` calls MUST be at the TOP of the file, before any function that uses them.
Bad: defining `refreshData()` that uses `ItemVisuals`, then requiring ItemVisuals 300 lines later.
The function captures nil at definition time.

### Item Drop Visuals
- Use ItemVisuals module for consistent emoji, color, and shape per item
- Shape the 3D drop Part to match item type (swords = elongated, ores = cube, fish = flat)
- Color by unique item color, NOT just rarity
- Keep bobbing animation + click-to-pickup + auto-despawn

### Inventory Limit
- 28 slots (RuneScape standard)
- Panel height must accommodate all rows (440px for 7 rows × 4 cols)

### Shift-Click Drop
- Shift+click inventory item → fires DropItem RemoteEvent
- Server validates, removes from inventory, spawns item on ground in front of player
- Anyone can pick up dropped items

### Hotbar Assignment
- Right-click inventory item → sets _G.PendingHotbarItem
- Click hotbar slot → assigns item via _G.HotbarAssignItem
- Ctrl+click + number key as fallback method

### Armor Tiers (Complete)
Every material tier needs ALL slot types:
- Platelegs (Legs): Bronze → Iron → Gold → Runite → Dragon
- Platebody (Body): Bronze → Iron → Gold → Runite → Dragon
- Chainbody (Body, lighter): Iron → Gold → Runite
- Leather/Studded/Dragonhide (ranger gear): Body + Legs variants
- Helmets (Head): Bronze → Iron → Gold → Runite → Dragon
- Shields: Wooden → Iron → Gold → Runite → Dragon

### NPC Accessory Builders ⚠️
Every NPC in NPC_DEFS MUST have a matching entry in the `accessoryBuilders` table AND a builder function. Without it, NPC spawns with a plain body (no hat, no weapon, no unique features).

### Equipment System
- **EquipmentManager checks `itemInfo.equipSlot ~= slotName`** — the client MUST send the correct slot name matching ItemDatabase
- **Equipment slots**: Head, Body, Legs, Weapon, Shield, Tool
- **After equip/unequip, fire BOTH EquipmentUpdate AND InventoryUpdate to client**

## Build Checklist
Every time before telling the user to test:
1. ✅ Run full code review checklist (see `docs/CODE-REVIEW-CHECKLIST.md`)
2. ✅ Strip BOM from ALL .lua files
3. ✅ `rojo build -o Game.rbxlx`
4. ✅ Verify build output says "Built project to..." (no errors)
5. ✅ Remind user to close and reopen the .rbxlx (stale file trap)
6. ✅ Check Output window for errors after Play

## NEVER REPEAT: The Great Debug Disaster (2026-02-18)

### What Happened
Built 30+ new scripts simultaneously (Friend system, Achievements, Leaderboard, etc.). Created cascading failures where every bug broke every other system. Game became completely unplayable despite $100 in debugging effort.

### Root Cause
**Built too much at once.** When System A crashes, it breaks System B, which crashes System C, which prevents System D from initializing. One missing method call becomes 100 error messages.

### CARDINAL RULE: ONE THING AT A TIME
1. **Pick ONE system** (e.g., "Fix NPC positions")
2. **Code ONLY that system**
3. **Test it thoroughly** — works, no errors, no side effects
4. **THEN pick the next system**
5. **Never build multiple systems simultaneously**

### Emergency Recovery Protocol
When everything is broken:
1. **STOP adding features immediately**
2. **Restore last known working build** (if available)
3. **Disable agent automation** (stop the feature factory)
4. **Fix ONE issue at a time** starting with simplest
5. **Test each fix in isolation** before moving on

### Systematic Fix Priority
When debugging cascading failures:
1. **Syntax errors** (prevent script loading)
2. **Missing functions/methods** (nil calls crash everything)
3. **Data type mismatches** (string where table expected)
4. **Spawn/positioning issues** (visual but harmless)
5. **UI polish** (functional but rough)

This disaster taught us: **Slow and steady beats fast and broken.**

## Cross-References

This is the hub skill. For specific systems, see:
- **roblox-combat-system** — damage, AI, death, loot, PvP
- **roblox-animation-system** — TweenService Motor6D animations
- **roblox-ui-builder** — ScreenGui, panels, hotbar, minimap
- **roblox-map-builder** — terrain, buildings, zones
- **roblox-item-system** — ItemDatabase, equipment, loot tables
- **roblox-npc-designer** — NPC bodies, dialog, shops
- **roblox-data-persistence** — DataStore, saves, migration
- **roblox-multiplayer-sync** — RemoteEvents, validation, anti-cheat
- **roblox-quest-system** — quest definitions, tracking, rewards
- **roblox-economy-design** — gold sinks, pricing, trades
- **roblox-pet-system** — pets, hatching, following AI
- **roblox-dungeon-generator** — procedural dungeons, instances
- **roblox-monetization** — GamePasses, DevProducts, battle pass
- **roblox-particle-effects** — VFX, loot glow, weather
- **roblox-sound-design** — SFX, music zones, ambient
- **roblox-qa-tester** — testing, checklists, bug patterns

## Debugging
- **Output window**: View → Output (Ctrl+Shift+Y) — print() and errors
- **Script Analysis**: View → Script Analysis — catches syntax errors
- **Common errors**:
  - "X is not a valid member of Y" → wrong path, use WaitForChild with timeout
  - "Attempt to index nil" → object not found
  - "Cannot require a Script" → shared logic must be ModuleScript
  - No output at all → BOM in file, or script errored on line 1
  - "Ambiguous syntax" → type annotation in code, strip `:: Type`
  - WaitForChild hanging → add timeout + nil check
  - "must publish to access DataStore" → unpublished place, wrap in pcall
