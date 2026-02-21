---
name: roblox-pet-system
description: Design and implement pet/companion systems for Roblox games. Covers pet following, abilities, leveling, hatching, trading, and visual customization.
---

# Roblox Pet System

Reference project: `workspace/projects/roblox-mmo/` (Roscape Runeblocks)

## Critical Rules

- **Server-authoritative**: Pet ownership, abilities, hatching all validated on server
- **Dot notation on modules**, no Luau type annotations, requires at TOP
- **Pet models are simple**: Small Part-based creatures, not complex meshes

## Pet Database

```lua
-- src/ReplicatedStorage/Modules/PetDatabase.lua
local PetDatabase = {}

local pets = {
    ["Baby Dragon"] = {
        name = "Baby Dragon", rarity = "rare",
        baseAbility = "combat_assist", abilityValue = 0.05,  -- 5% damage boost
        maxLevel = 20,
        bodyColor = Color3.fromRGB(200, 50, 30),
        size = Vector3.new(1.5, 1.2, 2),
    },
    ["Mining Mole"] = {
        name = "Mining Mole", rarity = "uncommon",
        baseAbility = "gathering_boost", abilityValue = 0.10,  -- 10% faster gathering
        maxLevel = 15,
        bodyColor = Color3.fromRGB(139, 90, 43),
        size = Vector3.new(1, 0.8, 1.5),
    },
    ["Lucky Cat"] = {
        name = "Lucky Cat", rarity = "epic",
        baseAbility = "xp_bonus", abilityValue = 0.10,  -- 10% XP boost
        maxLevel = 25,
        bodyColor = Color3.fromRGB(255, 215, 0),
        size = Vector3.new(1, 1, 1.2),
    },
    ["Loot Sprite"] = {
        name = "Loot Sprite", rarity = "legendary",
        baseAbility = "item_pickup", abilityValue = 8,  -- pickup radius in studs
        maxLevel = 30,
        bodyColor = Color3.fromRGB(150, 255, 150),
        size = Vector3.new(0.8, 0.8, 0.8),
    },
}

function PetDatabase.GetPet(name)
    return pets[name]
end

return PetDatabase
```

## Pet Data in Player Save

```lua
-- data.Pets = {
--     owned = {
--         {name = "Baby Dragon", level = 5, xp = 230, nickname = "Blaze", color = nil},
--         {name = "Mining Mole", level = 1, xp = 0, nickname = nil, color = nil},
--     },
--     active = 1,  -- index into owned (nil = no pet summoned)
--     slots = 3,   -- max owned pets (upgradeable)
-- }
```

## Pet Following AI

```lua
-- Server or Client (client for smoothness, server for authority)
local function updatePetFollow(petModel, ownerCharacter)
    local root = ownerCharacter:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local petRoot = petModel.PrimaryPart
    if not petRoot then return end

    local targetOffset = root.CFrame * CFrame.new(-3, 0, -2)  -- behind-left
    local targetPos = targetOffset.Position
    local currentPos = petRoot.Position

    local dist = (targetPos - currentPos).Magnitude

    if dist > 30 then
        -- Teleport if too far
        petModel:SetPrimaryPartCFrame(CFrame.new(targetPos))
    elseif dist > 2 then
        -- Move toward owner
        local direction = (targetPos - currentPos).Unit
        local speed = math.min(dist * 2, 20)  -- faster when further
        local newPos = currentPos + direction * speed * 0.03  -- per frame step
        -- Look at owner
        local lookCF = CFrame.lookAt(newPos, Vector3.new(root.Position.X, newPos.Y, root.Position.Z))
        petModel:SetPrimaryPartCFrame(lookCF)
    end
end

-- Run in Heartbeat or Stepped loop
```

## Pet Model Builder

```lua
local function buildPetModel(petDef, position)
    local model = Instance.new("Model")
    model.Name = petDef.name

    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = petDef.size
    body.Color = petDef.bodyColor
    body.Anchored = true
    body.CanCollide = false
    body.Shape = Enum.PartType.Block
    body.Parent = model

    -- Eyes
    for _, side in ipairs({-0.25, 0.25}) do
        local eye = Instance.new("Part")
        eye.Name = "Eye"
        eye.Size = Vector3.new(0.15, 0.15, 0.05)
        eye.Color = Color3.new(1, 1, 1)
        eye.Anchored = true
        eye.CanCollide = false
        eye.CFrame = body.CFrame * CFrame.new(side, petDef.size.Y * 0.2, -petDef.size.Z / 2)
        eye.Parent = model
    end

    model.PrimaryPart = body
    model:SetPrimaryPartCFrame(CFrame.new(position))
    model.Parent = workspace
    return model
end
```

## Egg Hatching System

```lua
local EGG_TIERS = {
    ["Common Egg"] = {
        cost = 500,  -- gold
        hatchTime = 30,  -- seconds
        pool = {
            {name = "Mining Mole", weight = 60},
            {name = "Baby Dragon", weight = 25},
            {name = "Lucky Cat", weight = 10},
            {name = "Loot Sprite", weight = 5},
        },
    },
    ["Premium Egg"] = {
        cost = 0,  -- Robux purchase (Developer Product)
        hatchTime = 10,
        pool = {
            {name = "Mining Mole", weight = 30},
            {name = "Baby Dragon", weight = 35},
            {name = "Lucky Cat", weight = 25},
            {name = "Loot Sprite", weight = 10},
        },
    },
}

local function rollEgg(eggTier)
    local pool = EGG_TIERS[eggTier].pool
    local totalWeight = 0
    for _, entry in ipairs(pool) do
        totalWeight = totalWeight + entry.weight
    end

    local roll = math.random() * totalWeight
    local cumulative = 0
    for _, entry in ipairs(pool) do
        cumulative = cumulative + entry.weight
        if roll <= cumulative then
            return entry.name
        end
    end
    return pool[1].name  -- fallback
end
```

## Pet Leveling

```lua
local function getPetLevelXP(level)
    return math.floor(50 * (level ^ 1.5))
end

local function addPetXP(player, petIndex, amount)
    local data = DataManager.GetData(player)
    if not data or not data.Pets then return end
    local pet = data.Pets.owned[petIndex]
    if not pet then return end

    local petDef = PetDatabase.GetPet(pet.name)
    if pet.level >= petDef.maxLevel then return end

    pet.xp = pet.xp + amount
    local needed = getPetLevelXP(pet.level)
    while pet.xp >= needed and pet.level < petDef.maxLevel do
        pet.xp = pet.xp - needed
        pet.level = pet.level + 1
        needed = getPetLevelXP(pet.level)
        -- Notify player of pet level up
    end
end

-- Pet ability scales with level:
-- effectiveAbility = baseAbility * (1 + (level - 1) * 0.05)
```

## Pet Abilities Applied

```lua
local function getPetBonus(player, bonusType)
    local data = DataManager.GetData(player)
    if not data or not data.Pets or not data.Pets.active then return 0 end
    local pet = data.Pets.owned[data.Pets.active]
    if not pet then return 0 end

    local petDef = PetDatabase.GetPet(pet.name)
    if petDef.baseAbility ~= bonusType then return 0 end

    return petDef.abilityValue * (1 + (pet.level - 1) * 0.05)
end

-- In combat: damage = baseDamage * (1 + getPetBonus(player, "combat_assist"))
-- In gathering: gatherTime = baseTime / (1 + getPetBonus(player, "gathering_boost"))
-- In XP: xpGain = baseXP * (1 + getPetBonus(player, "xp_bonus"))
```

## Summon/Dismiss

```lua
-- Server: remote handler
local function summonPet(player, petIndex)
    local data = DataManager.GetData(player)
    if not data or not data.Pets then return end
    if not data.Pets.owned[petIndex] then return end

    -- Dismiss current pet first
    dismissPet(player)

    data.Pets.active = petIndex
    -- Spawn pet model near player
    local char = player.Character
    if char and char.PrimaryPart then
        local petDef = PetDatabase.GetPet(data.Pets.owned[petIndex].name)
        local pos = char.PrimaryPart.Position + Vector3.new(3, 0, 0)
        local model = buildPetModel(petDef, pos)
        model:SetAttribute("Owner", player.UserId)
        -- Store reference for follow loop
    end
end

local function dismissPet(player)
    local data = DataManager.GetData(player)
    if data and data.Pets then data.Pets.active = nil end
    -- Destroy pet model in workspace
end
```

## Monetization Hooks

```lua
-- GamePass: Extra Pet Slots (3 → 6)
-- Developer Product: Premium Eggs
-- Cosmetic: Pet color/accessory changes (gold cost or Robux)
-- See roblox-monetization skill for implementation patterns
```

> See also: **roblox-monetization** for GamePass/DevProduct patterns, **roblox-data-persistence** for pet save schema, **roblox-combat-system** for applying pet combat bonuses, **roblox-particle-effects** for pet visual effects

## Common Pitfalls

1. **Pet follow teleport threshold** — If pet is >30 studs from owner (e.g., after teleport), snap-teleport it. Smooth follow at that range looks broken.
2. **SetPrimaryPartCFrame on anchored models** — Pet parts must be Anchored for server-side follow. But anchored parts don't replicate movement smoothly. Consider client-side follow for visual smoothness.
3. **Pet slot validation** — Always check `petIndex <= #data.Pets.owned` before accessing. Exploiters can send invalid indices.
4. **Dismiss on death/leave** — Clean up pet model on `Humanoid.Died` and `PlayerRemoving` or pet models orphan in workspace.
