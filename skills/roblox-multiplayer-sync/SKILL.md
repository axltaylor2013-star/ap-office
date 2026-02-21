---
name: roblox-multiplayer-sync
description: Handle multiplayer synchronization in Roblox. Covers RemoteEvents, RemoteFunctions, server authority, client prediction, replication, and anti-cheat patterns.
---

# Roblox Multiplayer Sync

Reference project: `workspace/projects/roblox-mmo/` (Roscape Runeblocks)

## Critical Rules

- **NEVER trust client data** — server is the authority on everything
- **RemoteEvent**: fire-and-forget (client→server or server→client)
- **RemoteFunction**: request-response (client→server ONLY — never server→client, it hangs if client leaves)
- **Dot notation on modules**, no Luau type annotations, requires at TOP

## RemoteEvent vs RemoteFunction

| Use Case | Type | Why |
|----------|------|-----|
| Attack request | RemoteEvent | Don't need response, server broadcasts result |
| Buy item | RemoteFunction | Client needs success/fail response |
| Chat message | RemoteEvent | Fire and forget |
| Get shop inventory | RemoteFunction | Need data back |
| Player moved | RemoteEvent | Frequent, no response needed |
| Update all clients | RemoteEvent (FireAllClients) | Broadcast |

## Server-Authoritative Pattern

```lua
-- CLIENT: sends intent only
local attackRemote = ReplicatedStorage.Remotes:WaitForChild("AttackMonster", 10)
attackRemote:FireServer(targetMonsterId)
-- Client does NOT calculate damage, does NOT modify HP

-- SERVER: validates and executes
attackRemote.OnServerEvent:Connect(function(player, monsterId)
    -- 1. Validate monster exists
    local monster = monsters[monsterId]
    if not monster then return end

    -- 2. Validate distance (anti-teleport exploit)
    local char = player.Character
    if not char then return end
    local dist = (char.PrimaryPart.Position - monster.model.PrimaryPart.Position).Magnitude
    if dist > 15 then return end  -- too far

    -- 3. Validate cooldown
    local now = tick()
    local lastAttack = playerCooldowns[player.UserId] or 0
    if now - lastAttack < 0.6 then return end  -- attack speed limit
    playerCooldowns[player.UserId] = now

    -- 4. Calculate and apply (server-side only)
    local damage = calculateDamage(player)
    monster.hp = monster.hp - damage

    -- 5. Broadcast result to all clients
    damageRemote:FireAllClients(monsterId, damage, monster.hp)
end)
```

## Input Validation Checklist

```lua
-- ALWAYS validate on server:
-- 1. Type check: is the argument the right type?
if type(monsterId) ~= "string" then return end

-- 2. Existence: does the target exist?
if not monsters[monsterId] then return end

-- 3. Distance: is player close enough?
if dist > MAX_RANGE then return end

-- 4. Cooldown: is player spamming?
if now - lastAction < COOLDOWN then return end

-- 5. State: is player alive? Not in menu? Not stunned?
if not char or char:FindFirstChild("Stunned") then return end

-- 6. Quantity: is value in sane range?
quantity = math.clamp(math.floor(quantity), 1, 99)
```

## Rate Limiting Remote Calls

```lua
local callCounts = {}  -- [userId] = {remote = count}

local function rateLimitCheck(player, remoteName, maxPerSecond)
    local uid = player.UserId
    callCounts[uid] = callCounts[uid] or {}
    callCounts[uid][remoteName] = (callCounts[uid][remoteName] or 0) + 1
    if callCounts[uid][remoteName] > maxPerSecond then
        warn("[AntiExploit] Rate limit: " .. player.Name .. " on " .. remoteName)
        return false
    end
    return true
end

-- Reset counts every second
task.spawn(function()
    while true do
        task.wait(1)
        callCounts = {}
    end
end)
```

## Replication Strategy

```
ReplicatedStorage/       ← Both client AND server can access
  Modules/               ← Shared ModuleScripts (ItemDatabase, Config)
  Remotes/               ← RemoteEvents and RemoteFunctions
  Assets/                ← Models, effects both sides need

ServerStorage/           ← Server ONLY (clients cannot see)
  SecretData/            ← Drop tables, admin tools, server configs
  ServerModules/         ← Server-only logic

ServerScriptService/     ← Server scripts that run
StarterPlayerScripts/    ← Client scripts (copied to each player)
```

## WaitForChild with Timeout

```lua
-- ALWAYS use timeout to prevent infinite yield
local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
if not remotes then
    warn("Remotes folder not found!")
    return
end

local attackRemote = remotes:WaitForChild("AttackMonster", 10)
if not attackRemote then
    warn("AttackMonster remote not found!")
    return
end
```

## Shared Module Pattern

```lua
-- ReplicatedStorage/Modules/Config.lua
-- Used by BOTH client and server
local Config = {}

Config.MAX_INVENTORY_SIZE = 28
Config.ATTACK_RANGE = 12
Config.XP_TABLE = {0, 83, 174, 276, 388, ...}

function Config.GetLevelFromXP(xp)
    for i = #Config.XP_TABLE, 1, -1 do
        if xp >= Config.XP_TABLE[i] then return i end
    end
    return 1
end

return Config
```

## FireAllClients vs FireClient

```lua
-- FireAllClients: broadcast to everyone (monster HP update, chat, world event)
damageRemote:FireAllClients(monsterId, damage, newHp)

-- FireClient: send to one player (personal inventory update, quest progress)
inventoryRemote:FireClient(player, newInventory)

-- Prefer FireClient when data is player-specific (less bandwidth)
-- Prefer FireAllClients when all players need the same update
```

> See also: **roblox-combat-system** for server-authoritative damage, **roblox-data-persistence** for save patterns, **roblox-economy-design** for trade validation

## Common Pitfalls

1. **Remotes in TWO locations** — EquipmentManager creates remotes at ReplicatedStorage root, not in Remotes folder. Always check both:
```lua
local function waitForRemote(name)
    local r = Remotes:FindFirstChild(name)
    if r then return r end
    r = ReplicatedStorage:FindFirstChild(name)
    if r then return r end
    r = Remotes:FindFirstChild(name) or ReplicatedStorage:WaitForChild(name, 5)
    return r
end
```
2. **getOrCreateRemote** — Server scripts should create remotes if missing rather than hard-failing:
```lua
local function getOrCreateRemote(name)
    local existing = ReplicatedStorage:FindFirstChild(name)
    if existing then return existing end
    local re = Instance.new("RemoteEvent")
    re.Name = name
    re.Parent = ReplicatedStorage
    return re
end
```
3. **Never RemoteFunction server→client** — Hangs forever if client disconnects. Use RemoteEvent + callback pattern instead.
4. **BindableEvent for server↔server** — Use BindableEvent (not RemoteEvent) for communication between server scripts (e.g., EquipmentChanged notification).

## Bandwidth Optimization

```lua
-- 1. Send IDs not full objects
-- BAD: FireAllClients(monsterModel, fullData)
-- GOOD: FireAllClients(monsterId, hp)

-- 2. Batch updates
local pendingUpdates = {}
task.spawn(function()
    while true do
        task.wait(0.1)  -- 10 updates/sec max
        if #pendingUpdates > 0 then
            updateRemote:FireAllClients(pendingUpdates)
            pendingUpdates = {}
        end
    end
end)

-- 3. Delta compression: only send what changed
-- Instead of full inventory, send {action="add", item="Iron Ore", qty=1}
```
