---
name: roblox-combat-system
description: Design and implement combat systems for Roblox games. Covers melee/ranged/magic attacks, damage calculation, hit detection, attack animations via TweenService, monster AI, health bars, death handling, loot drops, XP awards, and PvP zones.
---

# Roblox Combat System

Reference project: `workspace/projects/roblox-mmo/` (Roscape Runeblocks)
See also: `docs/team-lessons.md`, `docs/CODE-REVIEW-CHECKLIST.md`

## Critical Rules

- **Dot notation on modules**: `Module.Func(arg)` NOT `Module:Func(arg)`
- **No Luau type annotations**: Zero `:: Type` or `: ReturnType`
- **All requires at TOP of file** before any function definitions
- **Server-authoritative**: ALL damage, HP, loot, XP calculated on server. Client only sends intent.

## Server-Authoritative Damage Model

```lua
-- TOP of file: all requires
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(ReplicatedStorage.Modules.DataManager)
local ItemDatabase = require(ReplicatedStorage.Modules.ItemDatabase)
local Config = require(ReplicatedStorage.Modules.Config)

-- Client fires: AttackMonster(monsterId)
-- Server validates range, calculates damage, applies it
local function calculateDamage(player)
    local data = DataManager.GetData(player)
    if not data then return 1 end
    local weaponName = data.Equipment.Weapon
    if weaponName == "" then return 1 end -- unarmed
    local item = ItemDatabase.GetItem(weaponName)
    if not item then return 1 end
    local baseDamage = item.damage or 1
    local combatXP = data.Skills.Combat or 0
    local level = Config.GetLevelFromXP(combatXP)
    local levelBonus = math.floor(level / 10)
    return baseDamage + levelBonus + math.random(0, 2)
end
```

## ClickDetector + RemoteEvent Attack Pattern

```lua
-- Server: MonsterManager.server.lua
local attackRemote = ReplicatedStorage:WaitForChild("Remotes", 10)
    and ReplicatedStorage.Remotes:WaitForChild("AttackMonster", 10)

if attackRemote then
    attackRemote.OnServerEvent:Connect(function(player, monsterId)
        local monster = activeMonsters[monsterId]
        if not monster then return end
        local char = player.Character
        if not char then return end
        local dist = (char.PrimaryPart.Position - monster.body.Position).Magnitude
        if dist > 12 then return end -- range check
        local dmg = calculateDamage(player)
        monster.hp = monster.hp - dmg
        -- Broadcast visual to all clients
        attackVisualRemote:FireAllClients(player, monsterId, dmg)
        if monster.hp <= 0 then
            handleMonsterDeath(monster, player)
        end
    end)
end

-- Client: sends attack intent on click
clickDetector.MouseClick:Connect(function(player)
    attackRemote:FireServer(monsterId)
end)
```

## TweenService Motor6D Animation (No rbxassetid!)

rbxassetid:// animations DO NOT WORK in Studio test. Use TweenService on Motor6D C0:

```lua
local TweenService = game:GetService("TweenService")

local function playSwingAnimation(character)
    local rightArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")
    if not rightArm then return end
    local motor = rightArm:FindFirstChildOfClass("Motor6D")
    if not motor then return end
    local originalC0 = motor.C0
    local swingCF = originalC0 * CFrame.Angles(math.rad(-90), 0, 0)
    local tweenDown = TweenService:Create(motor, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {C0 = swingCF})
    tweenDown:Play()
    task.delay(0.2, function()
        TweenService:Create(motor, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {C0 = originalC0}):Play()
    end)
end
```

## Monster AI State Machine

States: `idle → wander → chase → attack → returning`

```lua
local AGGRO_RANGE = 30
local DEAGGRO_RANGE = 50
local LEASH_RANGE = 80  -- max distance from spawn before forced return
local ATTACK_RANGE = 6
local WANDER_RANGE = 15

local function updateMonsterAI(monster, dt)
    local state = monster.state
    local spawnPos = monster.spawnPosition
    local bodyPos = monster.body.Position

    if state == "idle" then
        -- Check for nearby players
        local target = findNearestPlayer(bodyPos, AGGRO_RANGE)
        if target then
            monster.target = target
            monster.state = "chase"
        elseif tick() - monster.lastWander > 5 then
            monster.state = "wander"
            monster.wanderTarget = spawnPos + Vector3.new(
                math.random(-WANDER_RANGE, WANDER_RANGE), 0,
                math.random(-WANDER_RANGE, WANDER_RANGE)
            )
        end

    elseif state == "wander" then
        moveToward(monster, monster.wanderTarget, monster.speed * 0.5, dt)
        if (bodyPos - monster.wanderTarget).Magnitude < 3 then
            monster.state = "idle"
            monster.lastWander = tick()
        end
        -- Still check for aggro while wandering
        local target = findNearestPlayer(bodyPos, AGGRO_RANGE)
        if target then
            monster.target = target
            monster.state = "chase"
        end

    elseif state == "chase" then
        local target = monster.target
        if not target or not target.Character or not target.Character.PrimaryPart then
            monster.state = "returning"
            return
        end
        local targetPos = target.Character.PrimaryPart.Position
        local distToTarget = (bodyPos - targetPos).Magnitude
        local distToSpawn = (bodyPos - spawnPos).Magnitude

        if distToSpawn > LEASH_RANGE then
            monster.state = "returning"
        elseif distToTarget > DEAGGRO_RANGE then
            monster.state = "returning"
        elseif distToTarget <= ATTACK_RANGE then
            monster.state = "attack"
        else
            moveToward(monster, targetPos, monster.speed, dt)
        end

    elseif state == "attack" then
        local target = monster.target
        if not target or not target.Character then
            monster.state = "returning"
            return
        end
        if tick() - monster.lastAttack >= monster.attackSpeed then
            dealDamageToPlayer(target, monster.damage)
            monster.lastAttack = tick()
            playMonsterAttackAnim(monster)
        end
        local dist = (bodyPos - target.Character.PrimaryPart.Position).Magnitude
        if dist > ATTACK_RANGE then
            monster.state = "chase"
        end

    elseif state == "returning" then
        monster.target = nil
        moveToward(monster, spawnPos, monster.speed, dt)
        -- Heal while returning
        monster.hp = math.min(monster.hp + 1, monster.maxHp)
        if (bodyPos - spawnPos).Magnitude < 3 then
            monster.hp = monster.maxHp
            monster.state = "idle"
        end
    end
end
```

## AttackVisualHandler Broadcast Pattern

Server fires to ALL clients so everyone sees the attack:

```lua
-- Server
attackVisualRemote:FireAllClients(attackerName, targetId, damage, isCrit)

-- Client: AttackVisualHandler.client.lua
attackVisualRemote.OnClientEvent:Connect(function(attackerName, targetId, damage, isCrit)
    showDamageNumber(targetId, damage, isCrit)
    playHitFlash(targetId)
    if attackerName == localPlayer.Name then
        playCameraShake()
    end
end)
```

## Damage Number Popups (BillboardGui)

```lua
local function showDamageNumber(targetPart, damage, isCrit)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(math.random(-2, 2), 3, 0)
    billboard.Adornee = targetPart
    billboard.AlwaysOnTop = true
    billboard.Parent = targetPart

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = isCrit and damage .. "!" or tostring(damage)
    label.TextColor3 = isCrit and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    -- Float up and fade
    local TweenService = game:GetService("TweenService")
    TweenService:Create(billboard, TweenInfo.new(1), {
        StudsOffset = billboard.StudsOffset + Vector3.new(0, 3, 0)
    }):Play()
    TweenService:Create(label, TweenInfo.new(1), {TextTransparency = 1}):Play()
    task.delay(1.1, function() billboard:Destroy() end)
end
```

## HP Bar Update Pattern

```lua
local function updateHPBar(monster)
    local hpBar = monster.body:FindFirstChild("HPBar")
    if not hpBar then return end
    local bg = hpBar:FindFirstChild("Background")
    local fill = bg and bg:FindFirstChild("Fill")
    if not fill then return end
    local pct = math.clamp(monster.hp / monster.maxHp, 0, 1)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = pct > 0.5 and Color3.fromRGB(0, 200, 0)
        or pct > 0.25 and Color3.fromRGB(255, 200, 0)
        or Color3.fromRGB(255, 0, 0)
end
```

## Death Animation + Loot Drop

```lua
local function handleMonsterDeath(monster, killer)
    monster.state = "dead"

    -- XP award
    local data = DataManager.GetData(killer)
    if data then
        data.Skills.Combat = (data.Skills.Combat or 0) + monster.xpReward
    end

    -- Death animation: fall over + fade
    local TweenService = game:GetService("TweenService")
    local body = monster.body
    local fallCF = body.CFrame * CFrame.Angles(math.rad(90), 0, 0)
    TweenService:Create(body, TweenInfo.new(0.5), {CFrame = fallCF}):Play()
    task.delay(0.5, function()
        for _, part in pairs(monster.model:GetDescendants()) do
            if part:IsA("BasePart") then
                TweenService:Create(part, TweenInfo.new(1), {Transparency = 1}):Play()
            end
        end
    end)

    -- Loot drops
    task.delay(0.3, function()
        for _, drop in ipairs(rollLootTable(monster.lootTable)) do
            spawnItemDrop(body.Position, drop.name, drop.quantity)
        end
    end)

    -- Cleanup
    task.delay(2, function()
        monster.model:Destroy()
        activeMonsters[monster.id] = nil
    end)

    -- Respawn timer
    task.delay(monster.respawnTime, function()
        spawnMonster(monster.defId, monster.spawnPosition)
    end)
end
```

> See also: **roblox-animation-system** skill for Motor6D tween patterns, **roblox-particle-effects** for hit VFX, **roblox-sound-design** for combat SFX, **roblox-multiplayer-sync** for RemoteEvent validation patterns

## Common Pitfalls

1. **Weapon type affects animation** — EquipmentManager detects weapon type from name (`sword`, `bow`, `crossbow`) and sends it to client via `EquipmentInfoRemote`. Animation system must read this to pick the right swing/draw animation.
2. **getOrCreateRemote pattern** — MonsterManager creates remotes if missing rather than relying on `default.project.json`. Safer for iteration:
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
3. **BindableEvent for cross-script updates** — When equipment changes, fire `EquipmentChanged` BindableEvent so VisualEquipment script updates character appearance without polling.
4. **Spawn table pattern** — Use declarative tables for monster placement instead of hardcoded spawn calls:
```lua
local spawnTable = {
    { key = "Goblin", count = 4, xMin = -30, xMax = 30, zMin = 170, zMax = 200 },
}
for _, entry in spawnTable do
    for i = 1, entry.count do
        spawnMonster(entry.key, randomPointInRect(entry.xMin, entry.xMax, entry.zMin, entry.zMax))
    end
end
```

## PvP Zones

```lua
-- Zone check on server before allowing PvP damage
local function isInWilderness(position)
    -- Wilderness = outside safe zone bounds
    return math.abs(position.X) > SAFE_ZONE_RADIUS
        or math.abs(position.Z) > SAFE_ZONE_RADIUS
end

-- On player attack player:
if not isInWilderness(attacker.Character.PrimaryPart.Position) then
    return -- no PvP in safe zone
end
if not isInWilderness(target.Character.PrimaryPart.Position) then
    return -- target in safe zone
end
```
