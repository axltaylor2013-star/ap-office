---
name: roblox-item-system
description: Design and manage item databases, equipment systems, inventory management, and loot tables for Roblox games. Covers item definitions, rarity tiers, equipment slots, visual models, crafting recipes, and drop tables.
---

# Roblox Item System

Reference project: `workspace/projects/roblox-mmo/` (Roscape Runeblocks)
See also: `docs/team-lessons.md`, `docs/CODE-REVIEW-CHECKLIST.md`

## Critical Rules

- **Dot notation on modules**, no Luau type annotations, requires at TOP
- **DataManager fields are UPPERCASE**: Skills, Inventory, Equipment, Gold, Bank, Quests
- **Inventory items**: `{name = string, quantity = number}`
- **Equipment fields**: `{Head="", Body="", Legs="", Weapon="", Shield="", Tool=""}`
- **Skills are raw XP numbers**: `data.Skills.Mining = 150`
- **New items MUST be added to BOTH ItemDatabase AND ItemVisuals**

## ItemDatabase ModuleScript Pattern

```lua
-- src/ReplicatedStorage/Modules/ItemDatabase.lua
local ItemDatabase = {}

local items = {
    -- Weapons
    ["Bronze Sword"] = {
        name = "Bronze Sword", type = "weapon",
        damage = 4, equipSlot = "Weapon",
        value = 20, combatReq = 1,
    },
    ["Iron Sword"] = {
        name = "Iron Sword", type = "weapon",
        damage = 8, equipSlot = "Weapon",
        value = 100, combatReq = 10,
    },

    -- Armor
    ["Bronze Platebody"] = {
        name = "Bronze Platebody", type = "armor",
        defense = 5, equipSlot = "Body",
        value = 50, combatReq = 1,
    },

    -- Food
    ["Shrimp"] = {
        name = "Shrimp", type = "food",
        healAmount = 5, value = 5,
    },

    -- Materials
    ["Copper Ore"] = {
        name = "Copper Ore", type = "material",
        value = 8,
    },

    -- Tools
    ["Bronze Pickaxe"] = {
        name = "Bronze Pickaxe", type = "tool",
        equipSlot = "Tool", toolType = "pickaxe",
        toolSpeed = 1.0, value = 20, skillReq = {Mining = 1},
    },
}

-- Auto-assign rarity based on value
for _, item in pairs(items) do
    if not item.rarity then
        local v = item.value or 0
        if v >= 5000 then item.rarity = "legendary"
        elseif v >= 1000 then item.rarity = "epic"
        elseif v >= 200 then item.rarity = "rare"
        elseif v >= 50 then item.rarity = "uncommon"
        else item.rarity = "common" end
    end
end

function ItemDatabase.GetItem(name)
    return items[name]
end

function ItemDatabase.GetItemsByType(itemType)
    local result = {}
    for _, item in pairs(items) do
        if item.type == itemType then
            table.insert(result, item)
        end
    end
    return result
end

function ItemDatabase.GetAllItems()
    return items
end

return ItemDatabase
```

## Item Schema

| Field | Type | Used By | Notes |
|-------|------|---------|-------|
| name | string | All | Display name, also the key |
| type | string | All | weapon, armor, food, material, tool, quest |
| damage | number | Weapons | Base damage value |
| defense | number | Armor | Defense value |
| healAmount | number | Food | HP restored on eat |
| equipSlot | string | Equipment | Weapon, Head, Body, Legs, Shield, Tool |
| value | number | All | Gold value (buy/sell, also drives rarity) |
| rarity | string | All | Auto-set from value if not specified |
| combatReq | number | Weapons/Armor | Combat level required |
| skillReq | table | Tools | e.g. `{Mining = 10}` |
| toolType | string | Tools | pickaxe, axe, fishingrod |
| toolSpeed | number | Tools | Multiplier (lower = faster) |
| stackable | bool | Materials/Food | Can stack in inventory |

## Equipment Slots

```
Head     → Helmets (Bronze Helm, Iron Helm, ...)
Body     → Platebodies, Chainbodies, Leather
Legs     → Platelegs, Leather chaps
Weapon   → Swords, Bows, Staffs
Shield   → Wooden Shield, Iron Shield, ...
Tool     → Pickaxes, Axes, Fishing Rods
```

## EquipmentManager Pattern

```lua
local EquipmentManager = {}

local DataManager = require(ReplicatedStorage.Modules.DataManager)
local ItemDatabase = require(ReplicatedStorage.Modules.ItemDatabase)

function EquipmentManager.Equip(player, itemName)
    local data = DataManager.GetData(player)
    if not data then return false, "No data" end

    local item = ItemDatabase.GetItem(itemName)
    if not item or not item.equipSlot then return false, "Not equippable" end

    -- Check requirements
    if item.combatReq then
        local combatXP = data.Skills.Combat or 0
        local level = Config.GetLevelFromXP(combatXP)
        if level < item.combatReq then return false, "Level too low" end
    end

    -- Check inventory has it
    if not EquipmentManager.HasItem(data.Inventory, itemName) then
        return false, "Not in inventory"
    end

    -- Unequip current item in that slot
    local slot = item.equipSlot
    local currentItem = data.Equipment[slot]
    if currentItem and currentItem ~= "" then
        EquipmentManager.AddToInventory(data.Inventory, currentItem, 1)
    end

    -- Equip new item
    EquipmentManager.RemoveFromInventory(data.Inventory, itemName, 1)
    data.Equipment[slot] = itemName

    return true
end

function EquipmentManager.Unequip(player, slot)
    local data = DataManager.GetData(player)
    if not data then return false end
    local itemName = data.Equipment[slot]
    if not itemName or itemName == "" then return false end
    if #data.Inventory >= 28 then return false, "Inventory full" end
    EquipmentManager.AddToInventory(data.Inventory, itemName, 1)
    data.Equipment[slot] = ""
    return true
end

return EquipmentManager
```

## VisualEquipment Pattern

```lua
local function createModelOnLimb(character, limbName, parts, tag)
    local limb = character:FindFirstChild(limbName)
        or character:FindFirstChild(R6_FALLBACKS[limbName])
    if not limb then return end

    -- Clear old visuals with same tag
    for _, child in pairs(limb:GetChildren()) do
        if child:GetAttribute("VisualTag") == tag then child:Destroy() end
    end

    for _, partDef in ipairs(parts) do
        local p = Instance.new("Part")
        p.Name = partDef.name
        p.Size = partDef.size
        p.Color = partDef.color
        p.Material = partDef.material or Enum.Material.SmoothPlastic
        p.CanCollide = false
        p.Massless = true
        p:SetAttribute("VisualTag", tag)

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = limb
        weld.Part1 = p
        weld.Parent = p

        -- Weapons need 180° Z flip so blade points down from hand
        -- Helmets and shields do NOT flip
        local flipCF = partDef.skipFlip and CFrame.new()
            or CFrame.Angles(0, 0, math.rad(180))
        p.CFrame = limb.CFrame * flipCF * (partDef.offset or CFrame.new())
        p.Parent = limb
    end
end

-- R15 → R6 fallback names
local R6_FALLBACKS = {
    RightHand = "Right Arm",
    LeftHand = "Left Arm",
    Head = "Head",
}
```

## ItemVisuals Module

```lua
-- src/ReplicatedStorage/Modules/ItemVisuals.lua
local ItemVisuals = {}

local visuals = {
    ["Bronze Sword"]   = {emoji = "⚔️", color = Color3.fromRGB(180, 120, 60), shape = "blade"},
    ["Copper Ore"]     = {emoji = "🪨", color = Color3.fromRGB(180, 100, 50), shape = "cube"},
    ["Shrimp"]         = {emoji = "🦐", color = Color3.fromRGB(255, 150, 120), shape = "flat"},
    ["Oak Log"]        = {emoji = "🪵", color = Color3.fromRGB(139, 90, 43), shape = "cylinder"},
}

function ItemVisuals.Get(itemName)
    return visuals[itemName] or {emoji = "❓", color = Color3.fromRGB(150, 150, 150), shape = "cube"}
end

return ItemVisuals
```

## Loot Table Design

```lua
local LOOT_TABLES = {
    ["Goblin"] = {
        {item = "Bones",         chance = 1.0, qtyMin = 1, qtyMax = 1},  -- always
        {item = "Bronze Sword",  chance = 0.15, qtyMin = 1, qtyMax = 1},
        {item = "Copper Ore",    chance = 0.25, qtyMin = 1, qtyMax = 3},
        {item = "Gold Coins",    chance = 0.5,  qtyMin = 5, qtyMax = 25},
    },
}

local function rollLootTable(tableName)
    local table = LOOT_TABLES[tableName]
    if not table then return {} end
    local drops = {}
    for _, entry in ipairs(table) do
        if math.random() <= entry.chance then
            local qty = math.random(entry.qtyMin, entry.qtyMax)
            drops[#drops + 1] = {name = entry.item, quantity = qty}
        end
    end
    return drops
end
```

## Crafting Recipe Structure

```lua
local RECIPES = {
    ["Bronze Bar"] = {
        ingredients = {{"Copper Ore", 1}, {"Tin Ore", 1}},
        skill = "Smithing", level = 1, xp = 10,
        result = {name = "Bronze Bar", quantity = 1},
    },
    ["Bronze Sword"] = {
        ingredients = {{"Bronze Bar", 2}},
        skill = "Smithing", level = 5, xp = 25,
        result = {name = "Bronze Sword", quantity = 1},
    },
}
```

## Inventory Management (28 Slots)

```lua
function EquipmentManager.AddToInventory(inventory, itemName, quantity)
    -- Try to stack with existing
    local itemDef = ItemDatabase.GetItem(itemName)
    if itemDef and itemDef.stackable then
        for _, slot in ipairs(inventory) do
            if slot.name == itemName then
                slot.quantity = slot.quantity + quantity
                return true
            end
        end
    end
    -- New slot
    if #inventory >= 28 then return false end
    inventory[#inventory + 1] = {name = itemName, quantity = quantity}
    return true
end

function EquipmentManager.RemoveFromInventory(inventory, itemName, quantity)
    for i, slot in ipairs(inventory) do
        if slot.name == itemName then
            slot.quantity = slot.quantity - quantity
            if slot.quantity <= 0 then
                table.remove(inventory, i)
            end
            return true
        end
    end
    return false
end

function EquipmentManager.HasItem(inventory, itemName, quantity)
    quantity = quantity or 1
    for _, slot in ipairs(inventory) do
        if slot.name == itemName and slot.quantity >= quantity then
            return true
        end
    end
    return false
end

function EquipmentManager.CountItem(inventory, itemName)
    for _, slot in ipairs(inventory) do
        if slot.name == itemName then return slot.quantity end
    end
    return 0
end
```

## Armor Tier Coverage

Every material tier needs ALL slot types:

| Material | Weapon | Head | Body | Legs | Shield |
|----------|--------|------|------|------|--------|
| Bronze | ✅ | ✅ | ✅ | ✅ | — |
| Iron | ✅ | ✅ | ✅ | ✅ | ✅ |
| Gold | ✅ | ✅ | ✅ | ✅ | ✅ |
| Runite | ✅ | ✅ | ✅ | ✅ | ✅ |
| Dragon | ✅ | ✅ | ✅ | ✅ | ✅ |

Plus: Leather/Studded/Dragonhide for ranger, Robes for mage.

> See also: **roblox-economy-design** for pricing/drop rates, **roblox-combat-system** for damage calculation using item stats, **roblox-data-persistence** for save schema

## Common Pitfalls

1. **New items must go in BOTH ItemDatabase AND ItemVisuals** — Missing ItemVisuals entry = missing emoji/color in UI and drops.
2. **Weapon type detection** — EquipmentManager infers weapon type from name string matching (`bow`, `crossbow`, `sword`). Name weapons consistently.
3. **BindableEvent on equip change** — Fire `EquipmentChanged` BindableEvent so VisualEquipment updates character model. Without this, equipping shows in data but not on character.
4. **Stackable flag matters** — Materials and food should have `stackable = true`. Weapons/armor should NOT. Missing flag = new inventory slot per pickup.
