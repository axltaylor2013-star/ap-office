---
name: roblox-economy-design
description: Design balanced in-game economies for Roblox. Covers gold sinks, item pricing, shop systems, trading, crafting costs, drop rate tuning, and inflation prevention.
---

# Roblox Economy Design

Reference project: `workspace/projects/roblox-mmo/` (Roscape Runeblocks)

## Critical Rules

- **Server-authoritative**: ALL gold/item transactions on server. Client only requests.
- **Validate everything**: Check player has enough gold, has the item, isn't duping
- **Dot notation on modules**, no Luau type annotations, requires at TOP

## Gold Sink Design

Every economy needs ways to REMOVE gold. Without sinks, inflation ruins the game.

| Sink | Cost Range | Notes |
|------|-----------|-------|
| Repair costs | 10-30% item value | Equipment degrades over use |
| Fast travel fees | 50-500g | Scales with distance |
| Cosmetic items | 500-50000g | Pure vanity, infinite sink |
| Bank slot unlock | 1000-10000g | Scaling cost per slot |
| Skill respec | 5000g | Occasional big sink |
| Crafting fees | 10-20% material value | NPC charges to craft |
| Shop tax | 5-10% on player trades | Removes gold from trades |
| Death penalty | 5% of carried gold | Caps at reasonable amount |

## Price Scaling Formula

```lua
-- Item value scales with level tier
local function calculateItemValue(baseValue, tier)
    -- tier 1 = bronze, 2 = iron, 3 = steel, etc.
    return math.floor(baseValue * (tier ^ 1.8))
end

-- NPC buy price = 40% of item value (gold sink)
local function getNPCSellPrice(itemValue)
    return math.floor(itemValue * 0.4)
end

-- NPC sell price = full value
local function getNPCBuyPrice(itemValue)
    return itemValue
end
```

## Shop System (NPC Buy/Sell)

```lua
-- Server: ShopManager.server.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(ReplicatedStorage.Modules.DataManager)
local ItemDatabase = require(ReplicatedStorage.Modules.ItemDatabase)

local buyRemote = Instance.new("RemoteFunction")
buyRemote.Name = "BuyItem"
buyRemote.Parent = ReplicatedStorage.Remotes

buyRemote.OnServerInvoke = function(player, itemName, quantity)
    quantity = math.clamp(math.floor(quantity or 1), 1, 99)
    local item = ItemDatabase.GetItem(itemName)
    if not item or not item.value then return false, "Invalid item" end

    local data = DataManager.GetData(player)
    if not data then return false, "No data" end

    local totalCost = item.value * quantity
    if data.Gold < totalCost then return false, "Not enough gold" end

    data.Gold = data.Gold - totalCost
    DataManager.AddItem(player, itemName, quantity)
    return true, "Purchased"
end
```

## Drop Rate Math

```lua
local RARITY_RATES = {
    common =    {min = 0.60, max = 1.00},   -- 60-100%
    uncommon =  {min = 0.15, max = 0.30},   -- 15-30%
    rare =      {min = 0.05, max = 0.15},   -- 5-15%
    epic =      {min = 0.01, max = 0.05},   -- 1-5%
    legendary = {min = 0.001, max = 0.01},  -- 0.1-1%
}

-- Drop table pattern
local function rollDropTable(dropTable)
    local drops = {}
    for _, entry in ipairs(dropTable) do
        -- entry = {name = "Iron Ore", chance = 0.8, min = 1, max = 3}
        if math.random() <= entry.chance then
            local qty = math.random(entry.min, entry.max)
            table.insert(drops, {name = entry.name, quantity = qty})
        end
    end
    return drops
end
```

## Trade System Architecture

```lua
-- Trade state on server
local activeTrades = {}  -- {[tradeId] = {player1, player2, offers1, offers2, confirmed1, confirmed2}}

-- Flow:
-- 1. Player A requests trade with Player B → server creates trade session
-- 2. Both players add/remove items via RemoteEvents
-- 3. Both must click "Confirm" → sets confirmed flag
-- 4. If either modifies after confirm → RESET both confirms (scam prevention)
-- 5. Server validates both have items, executes swap atomically
-- 6. CRITICAL: Remove items BEFORE adding to prevent duplication

local function executeTrade(tradeId)
    local trade = activeTrades[tradeId]
    -- Validate both players still have offered items
    -- Remove from player1, remove from player2
    -- Add to player1, add to player2
    -- If any step fails, rollback
    activeTrades[tradeId] = nil
end
```

## Crafting Cost Balancing

```lua
-- Crafting cost = material value + gold fee (10-20%)
local function getCraftingCost(recipe)
    local materialValue = 0
    for _, mat in ipairs(recipe.materials) do
        local item = ItemDatabase.GetItem(mat.name)
        materialValue = materialValue + (item.value * mat.quantity)
    end
    local goldFee = math.floor(materialValue * 0.15)  -- 15% fee
    return goldFee
end
```

## Economy Monitoring

```lua
-- Track total gold in circulation (run periodically)
local function getGoldInCirculation()
    local total = 0
    for _, player in ipairs(game.Players:GetPlayers()) do
        local data = DataManager.GetData(player)
        if data then total = total + data.Gold end
    end
    return total
end

-- Log to analytics or ordered datastore for tracking trends
-- Target: gold per player should stay within 2-5x of level-appropriate range
```

## Anti-Duplication Safeguards

1. **Remove before add**: When transferring items, remove from source FIRST
2. **Atomic operations**: Use UpdateAsync for critical transfers
3. **Server-only**: Never let client modify gold/inventory directly
4. **Validate quantities**: Check player actually has the item count they claim
5. **Rate limit trades**: Max 1 trade per 5 seconds per player
6. **Log suspicious activity**: Gold jumps > 10000 in one action = flag

## Premium Currency (Ethical)

```
Robux → Gems (Developer Product)
Gems → Cosmetics ONLY (skins, titles, effects, emotes)
NEVER: Gems → Gold, Gems → Weapons, Gems → Power

Acceptable GamePasses:
- XP Boost (1.5x, not 10x)
- Extra Bank Slots
- Cosmetic Pack
- Pet Slot Unlock

NOT acceptable:
- Best weapon in game
- Instant max level
- Exclusive power items
```

> See also: **roblox-item-system** for item value/rarity, **roblox-data-persistence** for save patterns, **roblox-monetization** for Robux pricing

## Common Pitfalls

1. **Remove before add in trades** — If you add items to buyer before removing from seller, a crash between steps duplicates items.
2. **NPC sell price ≠ buy price** — NPCs buy at 40-60% of value. Without this gold sink, players print money by buying and reselling.
3. **Validate quantity server-side** — `math.clamp(math.floor(quantity), 1, 99)` prevents negative/huge/fractional quantities.
4. **Gold overflow** — Use reasonable caps. A player with 2^53 gold breaks JSON serialization.
