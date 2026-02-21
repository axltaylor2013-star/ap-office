---
name: roblox-map-builder
description: Build game worlds and maps for Roblox using server-side Part creation. Covers terrain generation, building construction, themed zones, resource node placement, NPC positioning, and environmental design.
---

# Roblox Map Builder

Reference project: `workspace/projects/roblox-mmo/` (Roscape Runeblocks)
See also: `docs/team-lessons.md`, `docs/CODE-REVIEW-CHECKLIST.md`

## Critical Rules

- **Rojo can't sync Parts** — all map geometry created via server scripts at runtime
- **Dot notation on modules**, no Luau type annotations, requires at TOP
- **Baseplate**: currently 800×800 studs, top surface at Y=0
- **All new areas must fit within baseplate bounds**

## Map Script Timing

Multiple MapSetup scripts run in parallel. Stagger with `task.wait()`:

| Script | Delay | Purpose |
|--------|-------|---------|
| MapSetup.server.lua | 0 (none) | Core terrain, main buildings |
| MapSetup2.server.lua | `task.wait(1)` | Secondary buildings, paths |
| MapSetup3.server.lua | `task.wait(3)` | Wilderness zones |
| MapSetup4.server.lua | `task.wait(5)` | Details, decorations |
| MapSetup5.server.lua | `task.wait(7)` | Far regions, borders |
| MonsterManager.server.lua | `task.wait(4)` | Monster spawns |
| NPCManager.server.lua | `task.wait(12)` | NPC spawns (needs ALL map done) |

## makePart() Helper

```lua
local function makePart(name, size, position, color, material, parent, props)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.BrickColor = BrickColor.new(color)
    p.Material = material or Enum.Material.SmoothPlastic
    p.Parent = parent or workspace
    if props then
        for k, v in pairs(props) do
            p[k] = v
        end
    end
    return p
end
```

## Building Construction Patterns

### makeWall / makeFloor / makeRoof

```lua
local WALL_THICKNESS = 1
local WALL_HEIGHT = 12
local FLOOR_THICKNESS = 1

local function makeFloor(name, width, depth, position, color, material, parent)
    return makePart(name, Vector3.new(width, FLOOR_THICKNESS, depth),
        position + Vector3.new(0, -0.5, 0), color, material, parent)
end

local function makeWall(name, length, position, rotation, color, material, parent)
    local wall = makePart(name, Vector3.new(length, WALL_HEIGHT, WALL_THICKNESS),
        position + Vector3.new(0, WALL_HEIGHT / 2, 0), color, material, parent)
    if rotation then
        wall.CFrame = CFrame.new(wall.Position) * CFrame.Angles(0, math.rad(rotation), 0)
    end
    return wall
end

local function makeRoof(name, width, depth, position, color, material, parent)
    return makePart(name, Vector3.new(width + 2, 1, depth + 2),
        position + Vector3.new(0, WALL_HEIGHT, 0), color, material, parent)
end
```

### Complete Building (Walls + Floor + Roof + Door)

```lua
local function makeBuilding(name, origin, width, depth, wallColor, floorColor, roofColor, parent)
    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = parent or workspace

    makeFloor(name .. "_Floor", width, depth, origin, floorColor, Enum.Material.Wood, folder)

    local hw, hd = width / 2, depth / 2
    -- Back wall (full)
    makeWall(name .. "_BackWall", width, origin + Vector3.new(0, 0, -hd), 0, wallColor, Enum.Material.Brick, folder)
    -- Left wall
    makeWall(name .. "_LeftWall", depth, origin + Vector3.new(-hw, 0, 0), 90, wallColor, Enum.Material.Brick, folder)
    -- Right wall
    makeWall(name .. "_RightWall", depth, origin + Vector3.new(hw, 0, 0), 90, wallColor, Enum.Material.Brick, folder)
    -- Front wall - two segments with door gap
    local doorWidth = 5
    local segWidth = (width - doorWidth) / 2
    makeWall(name .. "_FrontL", segWidth,
        origin + Vector3.new(-hw + segWidth / 2, 0, hd), 0, wallColor, Enum.Material.Brick, folder)
    makeWall(name .. "_FrontR", segWidth,
        origin + Vector3.new(hw - segWidth / 2, 0, hd), 0, wallColor, Enum.Material.Brick, folder)

    makeRoof(name .. "_Roof", width, depth, origin, roofColor, Enum.Material.Slate, folder)

    return folder
end
```

## Themed Zone Design

### Zone Materials & Colors

| Zone | Ground Material | Ground Color | Accent |
|------|----------------|--------------|--------|
| Town/Safe | Cobblestone | Medium stone grey | Brick buildings |
| Farmland | Grass | Bright green | Dirt paths (brown) |
| Forest | Grass | Dark green | Bark (dark brown) |
| Mine | Slate | Dark grey | Ore veins (varied) |
| Swamp | Mud | Dark olive | Water pools |
| Snow | Snow | White | Ice (blue tint) |
| Volcanic | Rock | Dark red/black | Lava (neon orange) |
| Desert | Sand | Tan | Sandstone buildings |

### Water

```lua
makePart("Pond", Vector3.new(30, 1, 30), Vector3.new(x, -0.3, z),
    "Bright blue", Enum.Material.Water, parent, {Transparency = 0.3})
```

### Wilderness Border

```lua
-- Semi-transparent crimson wall marking wilderness edge
makePart("WildernessBorder", Vector3.new(800, 20, 2), Vector3.new(0, 10, borderZ),
    "Dark red", Enum.Material.ForceField, workspace, {Transparency = 0.5})
```

## Resource Node Placement

### Guidelines
- **Spacing**: At least 8-10 studs between nodes of same type
- **Accessibility**: Clear path to every node, no walls blocking
- **Level progression**: Low-tier near town, high-tier deep in wilderness
- **Clustering**: 3-5 nodes per cluster, related to zone theme

### Example Layout

```lua
-- Copper rocks near town (level 1)
local copperPositions = {
    Vector3.new(50, 0, 30),
    Vector3.new(58, 0, 35),
    Vector3.new(45, 0, 40),
}
for i, pos in ipairs(copperPositions) do
    spawnResourceNode("Copper Rock", pos, {
        skill = "Mining", level = 1, xp = 20,
        gatherTime = 3, charges = 6,
        itemDrop = "Copper Ore",
    })
end
```

> See also: **roblox-npc-designer** for NPC body construction, **roblox-combat-system** for monster spawn tables

## NPC Positioning

- **Y = 0** for ground level (feet on baseplate surface)
- Verify NPC is inside buildings (between walls), not clipping through
- Leave space around NPC for player interaction (ClickDetector range ~14 studs)
- Face NPCs toward door/entrance when inside buildings

```lua
-- NPC at ground level inside a building
local npcOrigin = Vector3.new(buildingX, 0, buildingZ + 2) -- slightly back from door
```

## Monster Spawn Points

- **Check no walls blocking access** — players must be able to walk to them
- Spawn at Y=0 (body center = bodyHeight/2 is handled by spawner)
- Space spawns 15-25 studs apart for same monster type
- Boss areas need clear approach paths

## Trees, Rocks & Decorations

```lua
-- Simple tree
local function makeTree(position, height, parent)
    local trunk = makePart("Trunk", Vector3.new(2, height, 2),
        position + Vector3.new(0, height / 2, 0), "Reddish brown", Enum.Material.Wood, parent)
    local canopy = makePart("Canopy", Vector3.new(8, 6, 8),
        position + Vector3.new(0, height + 3, 0), "Forest green", Enum.Material.Grass, parent,
        {Shape = Enum.PartType.Ball})
    return trunk, canopy
end

-- Rock formation
local function makeRock(position, size, parent)
    return makePart("Rock", size, position + Vector3.new(0, size.Y / 2, 0),
        "Dark stone grey", Enum.Material.Slate, parent)
end
```

## Paths & Roads

```lua
local function makePath(startPos, endPos, width, parent)
    local mid = (startPos + endPos) / 2
    local dir = endPos - startPos
    local length = dir.Magnitude
    local angle = math.atan2(dir.X, dir.Z)
    local path = makePart("Path", Vector3.new(width, 0.2, length),
        mid + Vector3.new(0, 0.1, 0), "Brown", Enum.Material.Cobblestone, parent)
    path.CFrame = CFrame.new(path.Position) * CFrame.Angles(0, angle, 0)
    return path
end
```
