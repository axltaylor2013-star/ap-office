---
name: roblox-data-persistence
description: Save/load player data in Roblox using DataStoreService with fallbacks. Covers data schemas, auto-save, session locking, data migration, backups, and in-memory fallback for unpublished places.
---

# Roblox Data Persistence

Reference project: `workspace/projects/roblox-mmo/` (Roscape Runeblocks)
See also: `docs/team-lessons.md`

## Critical Rules

- **pcall EVERYTHING** — DataStoreService crashes on unpublished places (lesson #15)
- **In-memory fallback** — if DataStore fails, store in-memory so game still works
- **Dot notation on modules**, no Luau type annotations, requires at TOP
- **Rate limit**: ~60 requests/min per server. Budget wisely.
- **NEVER save on every change** — batch saves on intervals

## DataStore with pcall + In-Memory Fallback

```lua
-- src/ServerScriptService/DataManager.server.lua (or ModuleScript)
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DataManager = {}

local playerData = {}  -- in-memory cache (ALWAYS used at runtime)
local dataStore = nil
local useDataStore = false

-- Try to get DataStore — fails on unpublished places
local ok, result = pcall(function()
    return DataStoreService:GetDataStore("PlayerData_v1")
end)
if ok then
    dataStore = result
    useDataStore = true
    print("[DataManager] DataStore connected")
else
    warn("[DataManager] DataStore unavailable, using in-memory fallback: " .. tostring(result))
end

local DATA_VERSION = 1
local AUTO_SAVE_INTERVAL = 120  -- seconds
```

## Default Data Schema

```lua
local function getDefaultData()
    return {
        Version = DATA_VERSION,
        Gold = 50,
        Skills = {
            Combat = 0, Mining = 0, Woodcutting = 0,
            Fishing = 0, Cooking = 0, Crafting = 0,
        },
        Inventory = {},  -- {name = string, quantity = number}
        Equipment = {
            Head = "", Body = "", Legs = "",
            Weapon = "", Shield = "", Tool = "",
        },
        Bank = {},
        Quests = {},
        Settings = {},
        PlayTime = 0,
    }
end
```

## Load Player Data

```lua
function DataManager.LoadData(player)
    local data = nil

    if useDataStore then
        local ok, result = pcall(function()
            return dataStore:GetAsync("Player_" .. player.UserId)
        end)
        if ok and result then
            data = result
            print("[DataManager] Loaded data for " .. player.Name)
        elseif not ok then
            warn("[DataManager] Load failed for " .. player.Name .. ": " .. tostring(result))
        end
    end

    if not data then
        data = getDefaultData()
        print("[DataManager] New data for " .. player.Name)
    end

    -- Migration
    data = DataManager.MigrateData(data)

    playerData[player.UserId] = data
    return data
end

function DataManager.GetData(player)
    return playerData[player.UserId]
end
```

## Save Player Data

```lua
function DataManager.SaveData(player)
    local data = playerData[player.UserId]
    if not data or not useDataStore then return false end

    local ok, err = pcall(function()
        dataStore:SetAsync("Player_" .. player.UserId, data)
    end)
    if not ok then
        warn("[DataManager] Save failed for " .. player.Name .. ": " .. tostring(err))
    end
    return ok
end
```

## Auto-Save Loop

```lua
task.spawn(function()
    while true do
        task.wait(AUTO_SAVE_INTERVAL)
        for _, player in ipairs(Players:GetPlayers()) do
            DataManager.SaveData(player)
        end
        print("[DataManager] Auto-save complete")
    end
end)
```

## PlayerRemoving + BindToClose

```lua
Players.PlayerRemoving:Connect(function(player)
    DataManager.SaveData(player)
    playerData[player.UserId] = nil
end)

-- BindToClose: save ALL players on shutdown (30s budget)
game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        DataManager.SaveData(player)
    end
end)
```

## Data Migration

```lua
function DataManager.MigrateData(data)
    if not data.Version then data.Version = 0 end

    if data.Version < 1 then
        -- v0 → v1: add Bank if missing
        data.Bank = data.Bank or {}
        data.Quests = data.Quests or {}
        data.Settings = data.Settings or {}
        data.Version = 1
    end

    -- Add future migrations here:
    -- if data.Version < 2 then ... end

    return data
end
```

## Session Locking (Prevent Duplication)

```lua
-- Use UpdateAsync to atomically check/set a session lock
function DataManager.LoadDataWithLock(player)
    if not useDataStore then
        playerData[player.UserId] = getDefaultData()
        return playerData[player.UserId]
    end

    local data = nil
    local ok, err = pcall(function()
        dataStore:UpdateAsync("Player_" .. player.UserId, function(old)
            if old and old._sessionLock and (os.time() - old._sessionLock) < 300 then
                -- Another server has this player, wait
                return nil  -- abort
            end
            old = old or getDefaultData()
            old._sessionLock = os.time()
            data = old
            return old
        end)
    end)

    if data then
        data = DataManager.MigrateData(data)
        playerData[player.UserId] = data
    else
        warn("[DataManager] Session locked or error for " .. player.Name)
        playerData[player.UserId] = getDefaultData()
    end
    return playerData[player.UserId]
end
```

## OrderedDataStore for Leaderboards

```lua
function DataManager.UpdateLeaderboard(statName, player, value)
    if not useDataStore then return end
    local ok, err = pcall(function()
        local ods = DataStoreService:GetOrderedDataStore("Leaderboard_" .. statName)
        ods:SetAsync("Player_" .. player.UserId, value)
    end)
end

function DataManager.GetTopPlayers(statName, count)
    if not useDataStore then return {} end
    local results = {}
    local ok, err = pcall(function()
        local ods = DataStoreService:GetOrderedDataStore("Leaderboard_" .. statName)
        local pages = ods:GetSortedAsync(false, count)
        local data = pages:GetCurrentPage()
        for _, entry in ipairs(data) do
            table.insert(results, {
                userId = tonumber(string.match(entry.key, "%d+")),
                value = entry.value,
            })
        end
    end)
    return results
end
```

## Data Reset Tool (Admin)

```lua
function DataManager.WipeData(userId)
    if not useDataStore then return false end
    local ok, err = pcall(function()
        dataStore:RemoveAsync("Player_" .. userId)
    end)
    return ok
end
```

## Rate Limit Awareness

| Operation | Budget |
|-----------|--------|
| GetAsync | 60 + 10*playerCount /min |
| SetAsync | 60 + 10*playerCount /min |
| UpdateAsync | 60 + 10*playerCount /min |
| GetSortedAsync | 5 + 2*playerCount /min |
| RemoveAsync | 60 + 10*playerCount /min |

- Batch saves, don't save per-field changes
- Use in-memory cache, only touch DataStore on load/save/interval
- pcall every single call — throttling throws errors

> See also: **roblox-economy-design** for gold/item transaction patterns, **roblox-quest-system** for quest state schema, **roblox-pet-system** for pet data schema

## Common Pitfalls

1. **UpdateAsync vs SetAsync** — Use `UpdateAsync` for atomic read-modify-write (session locking, leaderboards). `SetAsync` can overwrite concurrent changes.
2. **BindToClose has 30s budget** — If you have many players, save in parallel with `task.spawn` per player, not sequential.
3. **Data schema migration is mandatory** — Always check `data.Version` and add missing fields. Players with old saves will crash on nil field access.
4. **Don't save on every change** — Batch into auto-save intervals (120s). DataStore rate limits are real.
