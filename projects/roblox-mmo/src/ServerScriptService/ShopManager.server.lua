--[[
	ShopManager.server.lua
	Server-side shop system for NPCs with merchant role.
	Handles buying/selling items with gold, 60% sell-back value.
	Updated to use correct DataManager API.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataManager = require(ReplicatedStorage.Modules.DataManager)
local ItemDatabase = require(ReplicatedStorage.Modules.ItemDatabase)

print("[ShopManager] Loading...")

------------------------------------------------------------
-- Remote Events
------------------------------------------------------------
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local BuyItemEvent = Remotes:WaitForChild("BuyItem", 10)
local SellItemEvent = Remotes:WaitForChild("SellItem", 10)

------------------------------------------------------------
-- Shop Inventories by NPC Name (ONLY EXISTING ITEMS!)
------------------------------------------------------------
local ShopInventories = {
	["Mara the Merchant"] = {
		{item = "Cooked Shrimp", stock = 40, basePrice = 15},
		{item = "Cooked Trout", stock = 30, basePrice = 30},
		{item = "Cooked Chicken", stock = 30, basePrice = 12},
		{item = "Cooked Beef", stock = 25, basePrice = 20},
		{item = "Cooked Lobster", stock = 15, basePrice = 80},
		{item = "Wooden Shield", stock = 5, basePrice = 50},
		{item = "Bronze Helmet", stock = 5, basePrice = 60},
		{item = "Bones", stock = 20, basePrice = 10},
		{item = "Feather", stock = 50, basePrice = 5},
	},
	["Grimnir the Smith"] = {
		{item = "Copper Sword", stock = 10, basePrice = 50},
		{item = "Iron Sword", stock = 8, basePrice = 200},
		{item = "Gold Sword", stock = 5, basePrice = 800},
		{item = "Bronze Platebody", stock = 8, basePrice = 100},
		{item = "Iron Platebody", stock = 5, basePrice = 400},
		{item = "Gold Platebody", stock = 3, basePrice = 1500},
		{item = "Bronze Platelegs", stock = 8, basePrice = 80},
		{item = "Iron Platelegs", stock = 5, basePrice = 350},
		{item = "Iron Chainbody", stock = 5, basePrice = 300},
		{item = "Iron Shield", stock = 5, basePrice = 250},
		{item = "Gold Shield", stock = 3, basePrice = 900},
		{item = "Copper Bar", stock = 30, basePrice = 25},
		{item = "Iron Bar", stock = 20, basePrice = 60},
		{item = "Gold Bar", stock = 10, basePrice = 200},
	},
	["Old Bess the Cook"] = {
		{item = "Cooked Shrimp", stock = 40, basePrice = 15},
		{item = "Cooked Trout", stock = 30, basePrice = 30},
		{item = "Cooked Chicken", stock = 30, basePrice = 12},
		{item = "Cooked Beef", stock = 25, basePrice = 20},
		{item = "Cooked Lobster", stock = 15, basePrice = 80},
		{item = "Raw Chicken", stock = 20, basePrice = 5},
		{item = "Raw Beef", stock = 20, basePrice = 8},
	},
	["Fisher Tom"] = {
		{item = "Wooden Rod", stock = 10, basePrice = 50},
		{item = "Iron Rod", stock = 5, basePrice = 200},
		{item = "Gold Rod", stock = 3, basePrice = 600},
		{item = "Shrimp", stock = 30, basePrice = 8},
		{item = "Trout", stock = 20, basePrice = 20},
		{item = "Lobster", stock = 10, basePrice = 50},
	},
	["Woodsman Jake"] = {
		{item = "Bronze Axe", stock = 10, basePrice = 50},
		{item = "Iron Axe", stock = 5, basePrice = 200},
		{item = "Gold Axe", stock = 3, basePrice = 600},
		{item = "Oak Shortbow", stock = 8, basePrice = 100},
		{item = "Willow Shortbow", stock = 5, basePrice = 300},
		{item = "Bronze Arrows", stock = 99, basePrice = 5},
		{item = "Iron Arrows", stock = 50, basePrice = 15},
		{item = "Arrow Shafts", stock = 99, basePrice = 3},
		{item = "Bowstring", stock = 30, basePrice = 10},
		{item = "Feather", stock = 99, basePrice = 5},
	},
	["Captain Blackbeard"] = {
		{item = "Pirate Cutlass", stock = 3, basePrice = 500},
		{item = "Gold Crossbow", stock = 2, basePrice = 1200},
		{item = "Gold Arrows", stock = 30, basePrice = 40},
		{item = "Gold Bolts", stock = 20, basePrice = 50},
		{item = "Studded Body", stock = 3, basePrice = 600},
		{item = "Studded Chaps", stock = 3, basePrice = 500},
		{item = "Leather Body", stock = 5, basePrice = 200},
		{item = "Leather Chaps", stock = 5, basePrice = 150},
	},
	["Priestess Solara"] = {
		{item = "Bronze Pickaxe", stock = 10, basePrice = 50},
		{item = "Iron Pickaxe", stock = 5, basePrice = 200},
		{item = "Gold Pickaxe", stock = 3, basePrice = 600},
		{item = "Bones", stock = 20, basePrice = 10},
		{item = "Bone Dust", stock = 15, basePrice = 20},
	},
}

------------------------------------------------------------
-- Helper Functions (Updated to use correct DataManager API)
------------------------------------------------------------
local function getShopInventory(npcName)
	return ShopInventories[npcName] or {}
end

local function canAfford(player, price)
	local data = DataManager:GetData(player)
	return data and data.Gold >= price
end

local function countItemInInventory(player, itemName)
	local data = DataManager:GetData(player)
	if not data or not data.Inventory then return 0 end
	
	local count = 0
	for _, slot in ipairs(data.Inventory) do
		if slot.name == itemName then
			count = count + slot.quantity
		end
	end
	return count
end

local function fireInventoryUpdate(player)
	local invRemote = Remotes:FindFirstChild("InventoryUpdate")
	if invRemote then
		local data = DataManager:GetData(player)
		if data and data.Inventory then
			invRemote:FireClient(player, data.Inventory)
		end
	end
end

------------------------------------------------------------
-- Buy Item Handler
------------------------------------------------------------
local function onBuyItem(player, npcName, itemName, quantity)
	-- Validate inputs
	if not player or not npcName or not itemName or not quantity then return end
	if quantity <= 0 or quantity > 100 then return end -- Sanity check

	-- Check if item exists in ItemDatabase
	local itemData = ItemDatabase.GetItem(itemName)
	if not itemData then
		warn("[ShopManager] Item does not exist in ItemDatabase:", itemName)
		return
	end

	-- Get shop inventory
	local shopItems = getShopInventory(npcName)
	local shopItem = nil
	for _, item in ipairs(shopItems) do
		if item.item == itemName then
			shopItem = item
			break
		end
	end

	if not shopItem then
		warn("[ShopManager] Item not found in shop:", itemName, "for NPC:", npcName)
		return
	end

	-- Check stock
	if shopItem.stock < quantity then
		print("[ShopManager] Insufficient stock for", itemName, "in", npcName, "shop")
		return
	end

	-- Calculate total price
	local totalPrice = shopItem.basePrice * quantity

	-- Check if player can afford
	if not canAfford(player, totalPrice) then
		print("[ShopManager]", player.Name, "cannot afford", quantity, itemName, "for", totalPrice, "gold")
		return
	end

	-- Process purchase
	if DataManager.RemoveGold(player, totalPrice) then
		if DataManager.AddToInventory(player, itemName, quantity) then
			-- Reduce shop stock
			shopItem.stock = shopItem.stock - quantity
			
			-- Fire inventory update
			fireInventoryUpdate(player)
			
			print("[ShopManager]", player.Name, "bought", quantity, itemName, "for", totalPrice, "gold from", npcName)
		else
			-- Refund if inventory add failed
			DataManager.AddGold(player, totalPrice)
			print("[ShopManager] Failed to add item to inventory, refunding")
		end
	else
		warn("[ShopManager] Failed to remove gold from player")
	end
end

------------------------------------------------------------
-- Sell Item Handler
------------------------------------------------------------
local function onSellItem(player, npcName, itemName, quantity)
	-- Validate inputs
	if not player or not npcName or not itemName or not quantity then return end
	if quantity <= 0 or quantity > 100 then return end

	-- Check if item exists in ItemDatabase
	local itemData = ItemDatabase.GetItem(itemName)
	if not itemData then
		warn("[ShopManager] Item does not exist in ItemDatabase:", itemName)
		return
	end

	-- Check if player has enough of the item
	local playerHas = countItemInInventory(player, itemName)
	if playerHas < quantity then
		print("[ShopManager]", player.Name, "doesn't have enough", itemName, "to sell")
		return
	end

	-- Get item value and calculate sell price (60% of base value)
	local itemValue = itemData.value or 1
	local sellPrice = math.floor(itemValue * quantity * 0.6)

	-- Remove items from inventory
	if DataManager.RemoveFromInventory(player, itemName, quantity) then
		-- Give gold to player
		DataManager.AddGold(player, sellPrice)
		
		-- Fire inventory update
		fireInventoryUpdate(player)
		
		print("[ShopManager]", player.Name, "sold", quantity, itemName, "for", sellPrice, "gold to", npcName)
	else
		warn("[ShopManager] Failed to remove items from inventory")
	end
end

------------------------------------------------------------
-- Event Connections
------------------------------------------------------------
BuyItemEvent.OnServerEvent:Connect(onBuyItem)
SellItemEvent.OnServerEvent:Connect(onSellItem)

print("[ShopManager] Initialized with", #ShopInventories, "shop inventories")
