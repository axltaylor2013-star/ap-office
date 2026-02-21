-- MonetizationManager.server.lua
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(ReplicatedStorage.Modules.DataManager)
local ItemDatabase = require(ReplicatedStorage.Modules.ItemDatabase)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)

-- Product IDs (LIVE ROBLOX PRODUCT IDS)
local PRODUCT_IDS = {
    -- Double XP (1 hour) = Developer Product
    DOUBLE_XP_1HR = 3539561334,
    -- Starweave Set (individual pieces) - 50 Robux each
    STARWEAVE_SWORD = 3539559450,
    STARWEAVE_HELM = 3539559585,
    STARWEAVE_PLATEBODY = 3539559706,
    STARWEAVE_PLATELEGS = 3539559963,
    STARWEAVE_SHIELD = 3539560087,
    -- Emberfrost Set - 100 Robux each
    EMBERFROST_BLADE = 3539560175,
    EMBERFROST_CROWN = 3539560288,
    EMBERFROST_PLATEBODY = 3539560378,
    EMBERFROST_PLATELEGS = 3539560601,
    EMBERFROST_BULWARK = 3539560715,
    -- Voidborn Set - 500 Robux each
    VOIDBORN_GREATSWORD = 3539560841,
    VOIDBORN_VISAGE = 3539560916,
    VOIDBORN_PLATEBODY = 3539561044,
    VOIDBORN_PLATELEGS = 3539561143,
    VOIDBORN_AEGIS = 3539561215,
}

-- Reverse lookup: productId -> item name
local PRODUCT_TO_ITEM = {
    [3539559450] = "Starweave Sword",
    [3539559585] = "Starweave Helm",
    [3539559706] = "Starweave Platebody",
    [3539559963] = "Starweave Platelegs",
    [3539560087] = "Starweave Shield",
    [3539560175] = "Emberfrost Blade",
    [3539560288] = "Emberfrost Crown",
    [3539560378] = "Emberfrost Platebody",
    [3539560601] = "Emberfrost Platelegs",
    [3539560715] = "Emberfrost Bulwark",
    [3539560841] = "Voidborn Greatsword",
    [3539560916] = "Voidborn Visage",
    [3539561044] = "Voidborn Platebody",
    [3539561143] = "Voidborn Platelegs",
    [3539561215] = "Voidborn Aegis",
}

-- GamePass IDs
local GAMEPASS_IDS = {
    DOUBLE_XP_PERMANENT = 0, -- Permanent 2x XP gamepass
}

-- Double XP tracking (in-memory, per session)
local doubleXPPlayers = {} -- [userId] = expireTime (os.time)

-- Check if player has double XP active
local function hasDoubleXP(player)
    -- Check permanent gamepass first
    local hasPass = false
    pcall(function()
        hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, GAMEPASS_IDS.DOUBLE_XP_PERMANENT)
    end)
    if hasPass then return true end
    -- Check timed boost
    local expire = doubleXPPlayers[player.UserId]
    if expire and os.time() < expire then return true end
    return false
end

-- Grant item to player
local function grantItem(player, itemName)
    local item = ItemDatabase.GetItem(itemName)
    if not item then return false end
    local data = DataManager:GetData(player)
    if not data then return false end
    -- Check if already owns it
    for _, inv in ipairs(data.Inventory) do
        if inv.name == itemName then
            -- Already owns, don't duplicate
            return false
        end
    end
    table.insert(data.Inventory, {name = itemName, quantity = 1})
    Remotes.InventoryUpdate:FireClient(player, data.Inventory)
    return true
end

-- Process receipts
MarketplaceService.ProcessReceipt = function(receiptInfo)
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
    
    local productId = receiptInfo.ProductId
    
    -- Double XP 1hr
    if productId == PRODUCT_IDS.DOUBLE_XP_1HR then
        doubleXPPlayers[player.UserId] = os.time() + 3600
        Remotes.DoubleXPStatus:FireClient(player, true)
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end
    
    -- Item purchase
    local itemName = PRODUCT_TO_ITEM[productId]
    if itemName then
        local success = grantItem(player, itemName)
        if success then
            return Enum.ProductPurchaseDecision.PurchaseGranted
        end
    end
    
    return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- Handle premium item purchase requests
Remotes.PurchasePremiumItem.OnServerEvent:Connect(function(player, itemName)
    local item = ItemDatabase.GetItem(itemName)
    if not item or not item.premium or not item.robuxPrice then
        return
    end
    
    -- Find the product ID for this item
    local productId = nil
    for id, name in pairs(PRODUCT_TO_ITEM) do
        if name == itemName then
            productId = id
            break
        end
    end
    
    if productId and productId > 0 then
        MarketplaceService:PromptProductPurchase(player, productId)
    else
        warn("[MonetizationManager] No product ID set for item: " .. itemName)
    end
end)

-- Send double XP status to client on join
Players.PlayerAdded:Connect(function(player)
    task.wait(1) -- Wait for data to load
    local isActive = hasDoubleXP(player)
    Remotes.DoubleXPStatus:FireClient(player, isActive)
end)

-- Expose hasDoubleXP for other scripts
_G.HasDoubleXP = hasDoubleXP

-- Cleanup on leave
Players.PlayerRemoving:Connect(function(player)
    doubleXPPlayers[player.UserId] = nil
end)

print("[MonetizationManager] Loaded - Product IDs need to be set after publishing")
