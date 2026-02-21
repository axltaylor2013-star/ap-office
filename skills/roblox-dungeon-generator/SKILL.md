---
name: roblox-dungeon-generator
description: Procedurally generate dungeons and instanced content for Roblox games. Covers room generation, corridor connections, enemy placement, boss rooms, loot chests, and party instances.
---

# Roblox Dungeon Generator

Reference project: `workspace/projects/roblox-mmo/` (Roscape Runeblocks)

## Critical Rules

- **Server-authoritative**: Dungeon generation runs on server. Client gets the result.
- **Seed-based**: Use seeded RNG for reproducible dungeons
- **Dot notation on modules**, no Luau type annotations, requires at TOP

## Room Template System

```lua
-- src/ServerScriptService/DungeonGenerator.lua
local DungeonGenerator = {}

local ROOM_SIZE = 30  -- studs per room unit
local WALL_HEIGHT = 12
local WALL_THICKNESS = 2

local ROOM_TYPES = {
    combat = {weight = 40, minEnemies = 2, maxEnemies = 5},
    treasure = {weight = 15, chests = {1, 2}},
    puzzle = {weight = 10},
    rest = {weight = 10, hasHealPoint = true},
    boss = {weight = 0},  -- placed manually as final room
}

-- Grid-based dungeon: rooms on a 2D grid
-- Each cell = {type, connections = {north, south, east, west}, position}

local function createSeededRandom(seed)
    local rng = Random.new(seed)
    return rng
end
```

## Dungeon Generation Algorithm

```lua
function DungeonGenerator.Generate(config)
    local seed = config.seed or os.time()
    local rng = createSeededRandom(seed)
    local roomCount = config.rooms or 8
    local difficulty = config.difficulty or 1

    local grid = {}  -- [x][y] = room data
    local rooms = {}
    local visited = {}

    -- Start at center
    local startX, startY = 5, 5
    grid[startX] = grid[startX] or {}
    grid[startX][startY] = {type = "rest", x = startX, y = startY, connections = {}}
    table.insert(rooms, grid[startX][startY])

    -- Random walk to place rooms
    local cx, cy = startX, startY
    local directions = {
        {dx = 0, dy = 1, name = "north", opposite = "south"},
        {dx = 0, dy = -1, name = "south", opposite = "north"},
        {dx = 1, dy = 0, name = "east", opposite = "west"},
        {dx = -1, dy = 0, name = "west", opposite = "east"},
    }

    for i = 2, roomCount do
        local dir = directions[rng:NextInteger(1, 4)]
        local nx, ny = cx + dir.dx, cy + dir.dy

        grid[nx] = grid[nx] or {}
        if not grid[nx][ny] then
            -- Pick room type by weight
            local roomType = rollRoomType(rng)
            grid[nx][ny] = {type = roomType, x = nx, y = ny, connections = {}}
            table.insert(rooms, grid[nx][ny])

            -- Connect rooms
            grid[cx][cy].connections[dir.name] = true
            grid[nx][ny].connections[dir.opposite] = true
        end
        cx, cy = nx, ny
    end

    -- Last room = boss room
    rooms[#rooms].type = "boss"

    return {rooms = rooms, grid = grid, seed = seed, difficulty = difficulty}
end

local function rollRoomType(rng)
    local totalWeight = 0
    for _, data in pairs(ROOM_TYPES) do
        totalWeight = totalWeight + data.weight
    end
    local roll = rng:NextNumber() * totalWeight
    local cum = 0
    for typeName, data in pairs(ROOM_TYPES) do
        cum = cum + data.weight
        if roll <= cum then return typeName end
    end
    return "combat"
end
```

## Room Builder (Physical)

```lua
function DungeonGenerator.BuildRoom(room, dungeon)
    local origin = Vector3.new(room.x * ROOM_SIZE, 0, room.y * ROOM_SIZE)
    local model = Instance.new("Model")
    model.Name = "Room_" .. room.x .. "_" .. room.y

    -- Floor
    local floor = Instance.new("Part")
    floor.Size = Vector3.new(ROOM_SIZE, 1, ROOM_SIZE)
    floor.Position = origin + Vector3.new(0, -0.5, 0)
    floor.Anchored = true
    floor.Color = room.type == "boss" and Color3.fromRGB(80, 20, 20) or Color3.fromRGB(60, 60, 60)
    floor.Parent = model

    -- Walls (skip connected sides for doorways)
    local walls = {
        {name = "north", pos = Vector3.new(0, WALL_HEIGHT/2, ROOM_SIZE/2), size = Vector3.new(ROOM_SIZE, WALL_HEIGHT, WALL_THICKNESS)},
        {name = "south", pos = Vector3.new(0, WALL_HEIGHT/2, -ROOM_SIZE/2), size = Vector3.new(ROOM_SIZE, WALL_HEIGHT, WALL_THICKNESS)},
        {name = "east", pos = Vector3.new(ROOM_SIZE/2, WALL_HEIGHT/2, 0), size = Vector3.new(WALL_THICKNESS, WALL_HEIGHT, ROOM_SIZE)},
        {name = "west", pos = Vector3.new(-ROOM_SIZE/2, WALL_HEIGHT/2, 0), size = Vector3.new(WALL_THICKNESS, WALL_HEIGHT, ROOM_SIZE)},
    }

    for _, wall in ipairs(walls) do
        if not room.connections[wall.name] then
            local part = Instance.new("Part")
            part.Size = wall.size
            part.Position = origin + wall.pos
            part.Anchored = true
            part.Color = Color3.fromRGB(40, 40, 40)
            part.Parent = model
        end
        -- If connected: leave opening (doorway)
    end

    model.Parent = workspace.Dungeon
    return model
end
```

## Enemy Placement

```lua
local function placeEnemies(room, dungeon)
    if room.type ~= "combat" then return end
    local config = ROOM_TYPES.combat
    local rng = createSeededRandom(dungeon.seed + room.x * 100 + room.y)
    local count = rng:NextInteger(config.minEnemies, config.maxEnemies)
    local origin = Vector3.new(room.x * ROOM_SIZE, 0, room.y * ROOM_SIZE)

    local enemies = {}
    for i = 1, count do
        local offset = Vector3.new(
            rng:NextNumber(-10, 10),
            0,
            rng:NextNumber(-10, 10)
        )
        local level = dungeon.difficulty * 5 + rng:NextInteger(0, 3)
        table.insert(enemies, {
            position = origin + offset,
            level = level,
            hp = 20 + level * 10,
            damage = 2 + level * 2,
        })
    end
    return enemies
end
```

## Loot Chest Placement

```lua
local function placeChests(room, dungeon)
    if room.type ~= "treasure" then return end
    local rng = createSeededRandom(dungeon.seed + room.x * 200 + room.y)
    local chestCount = rng:NextInteger(1, 2)
    local origin = Vector3.new(room.x * ROOM_SIZE, 0, room.y * ROOM_SIZE)

    for i = 1, chestCount do
        local pos = origin + Vector3.new(rng:NextNumber(-8, 8), 1, rng:NextNumber(-8, 8))
        -- Create chest model at pos
        -- Chest loot scales with dungeon difficulty
        -- Use drop table from roblox-economy-design skill
    end
end
```

## Boss Room

```lua
local function buildBossRoom(room, dungeon)
    local origin = Vector3.new(room.x * ROOM_SIZE, 0, room.y * ROOM_SIZE)

    -- Larger arena (double size)
    -- Boss spawn at center
    -- Exit portal (locked until boss dies)
    -- Boss stats scale with difficulty tier

    local bossHP = 200 * dungeon.difficulty
    local bossDamage = 10 * dungeon.difficulty

    return {
        position = origin,
        hp = bossHP,
        damage = bossDamage,
        name = "Dungeon Boss Lvl " .. dungeon.difficulty,
    }
end
```

## Party Instances (TeleportService)

```lua
local TeleportService = game:GetService("TeleportService")

-- Create a reserved server for the party
local function createDungeonInstance(players, dungeonConfig)
    local placeId = game.PlaceId  -- or a separate dungeon place
    local ok, code = pcall(function()
        return TeleportService:ReserveServer(placeId)
    end)
    if not ok then
        warn("Failed to reserve server: " .. tostring(code))
        return
    end

    -- Pass dungeon config via TeleportData
    local teleportData = {
        isDungeon = true,
        seed = dungeonConfig.seed,
        difficulty = dungeonConfig.difficulty,
        rooms = dungeonConfig.rooms,
    }

    local ok2, err = pcall(function()
        TeleportService:TeleportToPrivateServer(placeId, code, players, nil, teleportData)
    end)
end
```

## Dungeon Difficulty Tiers

| Tier | Level Range | Rooms | Boss HP | Reward Multiplier |
|------|------------|-------|---------|-------------------|
| 1 - Easy | 1-10 | 6 | 200 | 1x |
| 2 - Medium | 10-25 | 8 | 500 | 2x |
| 3 - Hard | 25-50 | 10 | 1000 | 3.5x |
| 4 - Nightmare | 50+ | 12 | 2500 | 6x |

## Daily/Weekly Rotation

```lua
-- Use date-based seed for daily dungeon
local function getDailyDungeonSeed()
    local date = os.date("*t")
    return date.year * 10000 + date.yday
end

-- Weekly = floor(yday / 7) for weekly rotation
-- All players get same dungeon layout for same day/week
```

## Overworld Entrance

```lua
-- Place a portal in the game world
-- When player interacts:
-- 1. Check level requirement
-- 2. Check party (solo or group)
-- 3. Show difficulty selection UI
-- 4. Generate seed, create instance, teleport
```

> See also: **roblox-combat-system** for enemy AI/damage, **roblox-map-builder** for room construction patterns, **roblox-economy-design** for loot/reward scaling, **roblox-item-system** for loot table design

## Common Pitfalls

1. **TeleportService needs published place** — `ReserveServer` fails on unpublished places. Always pcall and show error UI.
2. **Seed reproducibility** — `Random.new(seed)` is deterministic, but `math.random()` is NOT seeded by this. Use `rng:NextInteger()` exclusively.
3. **Room overlap** — Random walk can revisit cells. Check `grid[nx][ny]` before placing to avoid overwriting.
4. **Boss room must be last** — The algorithm sets last room as boss. If random walk loops back, boss may be adjacent to start. Validate minimum distance.
5. **Dungeon cleanup** — When party leaves, destroy ALL dungeon parts. Use a Folder and `:Destroy()` it.
