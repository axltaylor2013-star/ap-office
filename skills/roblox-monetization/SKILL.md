---
name: roblox-monetization
description: Implement ethical monetization for Roblox games. Covers GamePasses, Developer Products, premium currency, cosmetics, battle passes, and Roblox marketplace best practices.
---

# Roblox Monetization

Reference project: `workspace/projects/roblox-mmo/` (Roscape Runeblocks)

## Critical Rules

- **NEVER pay-to-win**: Purchasable items must NOT give combat/power advantages
- **Cosmetic-first**: Skins, titles, effects, emotes — not stats
- **Server-authoritative**: ALL purchases validated server-side via ProcessReceipt
- **Dot notation on modules**, no Luau type annotations, requires at TOP

## GamePass Patterns (Permanent Unlocks)

```lua
local MarketplaceService = game:GetService("MarketplaceService")

-- Define GamePass IDs (set in Roblox Creator Dashboard)
local GAME_PASSES = {
    ExtraBankSlots = 123456789,     -- 99 Robux
    DoublePetSlots = 123456790,     -- 149 Robux
    XPBoost = 123456791,            -- 199 Robux (1.5x, not 10x)
    CosmeticPack = 123456792,       -- 299 Robux
    VIPTitle = 123456793,           -- 49 Robux
}

-- Check if player owns a GamePass
local function hasGamePass(player, passName)
    local passId = GAME_PASSES[passName]
    if not passId then return false end
    local ok, owns = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
    end)
    return ok and owns
end

-- Apply GamePass effects
local function applyGamePassEffects(player)
    local data = DataManager.GetData(player)
    if not data then return end

    if hasGamePass(player, "ExtraBankSlots") then
        data.maxBankSlots = 48  -- default 28
    end
    if hasGamePass(player, "DoublePetSlots") then
        data.Pets.slots = 6  -- default 3
    end
    -- XP boost checked in XP gain functions
end
```

## Developer Products (Consumables)

```lua
local DEV_PRODUCTS = {
    GoldPack500 = 111111111,     -- 49 Robux → 500 gold
    GoldPack2500 = 111111112,    -- 199 Robux → 2500 gold
    GemPack100 = 111111113,      -- 99 Robux → 100 gems
    ReviveToken = 111111114,     -- 25 Robux
    NameChange = 111111115,      -- 49 Robux
}

-- Prompt purchase
local function promptPurchase(player, productName)
    local productId = DEV_PRODUCTS[productName]
    if not productId then return end
    pcall(function()
        MarketplaceService:PromptProductPurchase(player, productId)
    end)
end
```

## ProcessReceipt (CRITICAL)

```lua
-- This MUST return Enum.ProductPurchaseDecision.PurchaseGranted
-- or the purchase will retry. Handle ALL products here.

MarketplaceService.ProcessReceipt = function(receiptInfo)
    local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local data = DataManager.GetData(player)
    if not data then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local productId = receiptInfo.ProductId

    if productId == DEV_PRODUCTS.GoldPack500 then
        data.Gold = data.Gold + 500
    elseif productId == DEV_PRODUCTS.GoldPack2500 then
        data.Gold = data.Gold + 2500
    elseif productId == DEV_PRODUCTS.GemPack100 then
        data.Gems = (data.Gems or 0) + 100
    elseif productId == DEV_PRODUCTS.ReviveToken then
        data.ReviveTokens = (data.ReviveTokens or 0) + 1
    else
        warn("[Monetization] Unknown product: " .. productId)
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    -- Save immediately after purchase
    DataManager.SaveData(player)

    return Enum.ProductPurchaseDecision.PurchaseGranted
end
```

## Premium Currency Design

```
Flow: Robux → Gems → Cosmetics
- Gems are the intermediate currency
- Gems buy ONLY cosmetics: skins, titles, particle effects, emotes
- Gems NEVER buy gold, weapons, armor, or gameplay power
- Gold is earned through gameplay ONLY

Why intermediate currency:
- Psychological detachment from real money
- Flexible pricing without Robux constraints
- Can give gems as event/login rewards
```

## Battle Pass Structure

```lua
local BATTLE_PASS = {
    season = 1,
    durationDays = 30,
    premiumCost = 499,  -- Robux

    tiers = {
        -- tier = {freeReward, premiumReward}
        [1] = {free = {gold = 100}, premium = {gems = 10}},
        [5] = {free = {item = "Wooden Shield"}, premium = {title = "Adventurer"}},
        [10] = {free = {gold = 500}, premium = {skin = "Golden Armor"}},
        [15] = {free = {item = "Iron Sword"}, premium = {emote = "Victory Dance"}},
        [20] = {free = {gold = 1000}, premium = {effect = "Fire Trail"}},
        [25] = {free = nil, premium = {skin = "Shadow Knight"}},
        [30] = {free = {gold = 2000}, premium = {title = "Season 1 Champion", effect = "Crown Glow"}},
    },

    -- XP per tier: 1000 base, +100 per tier
    xpPerTier = function(tier) return 1000 + (tier - 1) * 100 end,
}

-- Track in player data:
-- data.BattlePass = {season = 1, tier = 7, xp = 450, premium = true}
```

## Daily Login Rewards

```lua
local LOGIN_REWARDS = {
    [1] = {gold = 50},
    [2] = {gold = 75},
    [3] = {gold = 100},
    [4] = {gold = 150, item = "Shrimp"},
    [5] = {gold = 200},
    [6] = {gold = 250},
    [7] = {gold = 500, gems = 10},  -- weekly bonus
}

local function claimDailyReward(player)
    local data = DataManager.GetData(player)
    local today = os.date("%Y-%m-%d")
    if data.LastLogin == today then return false end  -- already claimed

    local streak = data.LoginStreak or 0
    local yesterday = os.date("%Y-%m-%d", os.time() - 86400)
    if data.LastLogin == yesterday then
        streak = streak + 1
    else
        streak = 1  -- reset streak
    end

    local day = ((streak - 1) % 7) + 1  -- cycle 1-7
    local reward = LOGIN_REWARDS[day]

    if reward.gold then data.Gold = data.Gold + reward.gold end
    if reward.gems then data.Gems = (data.Gems or 0) + reward.gems end
    if reward.item then DataManager.AddItem(player, reward.item, 1) end

    data.LoginStreak = streak
    data.LastLogin = today
    return true, reward, day
end
```

## Roblox Revenue Split

```
Player pays 100 Robux
→ Roblox takes ~30% platform fee
→ Developer gets ~70% in Robux
→ DevEx rate: ~$0.0035 per Robux (varies)
→ 100 Robux ≈ $0.35 to developer

Pricing guidelines:
- Small cosmetic: 49-99 Robux ($0.17-$0.35)
- GamePass: 99-499 Robux ($0.35-$1.75)
- Battle Pass: 399-699 Robux ($1.40-$2.45)
- Premium bundle: 799-1699 Robux ($2.80-$5.95)
```

## Pricing Psychology

```
1. Anchor pricing: Show "premium" option first to make standard look cheap
2. Bundles: "3 for price of 2" — higher perceived value
3. First-purchase bonus: 2x gems on first buy (one-time)
4. Limited time: "Season exclusive" creates urgency
5. Round numbers: Price at 99/199/499 Robux (just under thresholds)
6. Show savings: "Save 20%!" on bulk purchases
```

## Anti-Pay-to-Win Principles

1. **No stat items for Robux** — no swords, armor, potions behind paywall
2. **XP boost caps at 1.5x** — not 10x, still requires playing
3. **Cosmetics only** — skins don't change stats
4. **Free players can earn everything gameplay-related**
5. **Premium currency (gems) buys only vanity**
6. **No lootboxes with gameplay items** — egg hatching = pets only (cosmetic + minor passive)

## Analytics Tracking

```lua
-- Track these metrics (log to external or OrderedDataStore):
-- 1. Conversion rate: % of players who make any purchase
-- 2. ARPU: Average Revenue Per User
-- 3. Retention: Day 1, Day 7, Day 30 return rates
-- 4. Purchase frequency: how often buyers buy again
-- 5. Most popular items: what sells best
-- 6. Battle pass completion rate: how many reach max tier
```

> See also: **roblox-economy-design** for gold sink design, **roblox-data-persistence** for saving purchase state, **roblox-pet-system** for egg/pet monetization

## Common Pitfalls

1. **ProcessReceipt MUST return PurchaseGranted** — If it returns NotProcessedYet, Roblox retries on next join. If your code errors before returning, the purchase loops forever.
2. **Save immediately after purchase** — Call `DataManager.SaveData(player)` right after granting items. If server crashes before auto-save, player loses purchase.
3. **GamePass check is async** — `UserOwnsGamePassAsync` can fail. Always pcall it and default to `false`.
4. **Don't sell power** — Even "small" stat boosts (2x XP) feel pay-to-win. Cap at 1.5x and make it time-limited.
