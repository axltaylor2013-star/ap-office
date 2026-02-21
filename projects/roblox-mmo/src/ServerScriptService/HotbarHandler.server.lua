--[[
	HotbarHandler.server.lua
	Server-side handler for hotbar item usage
	Handles food consumption, healing, and other consumable items
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[HotbarHandler] Starting...")

-- Modules
local Modules = ReplicatedStorage:WaitForChild("Modules", 5)
local DataManager = require(Modules:WaitForChild("DataManager", 5))
local ItemDatabase = require(Modules:WaitForChild("ItemDatabase", 5))

-- Get UseItem RemoteEvent
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local UseItemRemote = Remotes:WaitForChild("UseItem", 10)

-- Also get other remotes for notifications
local XPPopupEvent = Remotes:FindFirstChild("XPPopup")
local InventoryUpdateEvent = Remotes:FindFirstChild("InventoryUpdate")

-----------------------------------------------------------------------
-- ITEM USAGE HANDLERS
-----------------------------------------------------------------------

local function handleFoodConsumption(player, itemName)
	local itemDef = ItemDatabase.GetItem(itemName)
	if not itemDef then
		warn("[HotbarHandler] Unknown item:", itemName)
		return false
	end
	
	-- Verify it's actually food
	if itemDef.type ~= "food" then
		warn("[HotbarHandler] Item is not food:", itemName)
		return false
	end
	
	-- Check if player has the item
	local playerData = DataManager:GetData(player)
	if not playerData then
		warn("[HotbarHandler] No player data for:", player.Name)
		return false
	end
	
	-- Find item in inventory
	local foundSlot = nil
	for i, slot in ipairs(playerData.inventory) do
		if slot and slot.name == itemName and slot.count > 0 then
			foundSlot = i
			break
		end
	end
	
	if not foundSlot then
		warn("[HotbarHandler] Player doesn't have item:", itemName)
		return false
	end
	
	-- Get heal amount (with fallback based on tier)
	local healAmount = itemDef.healAmount
	if not healAmount then
		-- Default heal amounts based on item tier/value
		local value = itemDef.value or 0
		if value >= 200 then
			healAmount = 50 -- High tier food
		elseif value >= 50 then
			healAmount = 25 -- Mid tier food
		elseif value >= 10 then
			healAmount = 15 -- Low tier food
		else
			healAmount = 8 -- Basic food
		end
	end
	
	-- Get player's current health
	local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
	if not humanoid then
		warn("[HotbarHandler] Player has no humanoid")
		return false
	end
	
	local currentHealth = humanoid.Health
	local maxHealth = humanoid.MaxHealth
	
	-- Don't eat if already at full health
	if currentHealth >= maxHealth then
		print("[HotbarHandler] Player already at full health")
		return false
	end
	
	-- Consume the item
	local consumed = DataManager.RemoveItem(player, itemName, 1)
	if not consumed then
		warn("[HotbarHandler] Failed to remove item:", itemName)
		return false
	end
	
	-- Heal the player
	local newHealth = math.min(currentHealth + healAmount, maxHealth)
	humanoid.Health = newHealth
	
	print("[HotbarHandler] " .. player.Name .. " ate " .. itemName .. " and healed " .. healAmount .. " HP")
	
	-- Notify client of inventory update
	if InventoryUpdateEvent then
		local data = DataManager:GetData(player)
		if data and data.Inventory then
			InventoryUpdateEvent:FireClient(player, data.Inventory)
		end
	end
	
	-- Show heal effect (you could add a visual effect here)
	-- For now, just print to the player
	if XPPopupEvent then
		XPPopupEvent:FireClient(player, "+" .. healAmount .. " HP", Color3.fromRGB(0, 255, 0), player.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
	end
	
	return true
end

local function handlePotionConsumption(player, itemName)
	-- Future: Handle potions (stat boosts, temporary effects, etc.)
	print("[HotbarHandler] Potion consumption not yet implemented:", itemName)
	return false
end

local function handleOtherConsumables(player, itemName)
	-- Future: Handle other consumable items
	print("[HotbarHandler] Other consumable usage not yet implemented:", itemName)
	return false
end

-----------------------------------------------------------------------
-- MAIN HANDLER
-----------------------------------------------------------------------

UseItemRemote.OnServerEvent:Connect(function(player, itemName)
	if not player or not itemName then
		warn("[HotbarHandler] Invalid parameters")
		return
	end
	
	print("[HotbarHandler] " .. player.Name .. " attempting to use:", itemName)
	
	local itemDef = ItemDatabase.GetItem(itemName)
	if not itemDef then
		warn("[HotbarHandler] Unknown item:", itemName)
		return
	end
	
	-- Route to appropriate handler based on item type
	local success = false
	
	if itemDef.type == "food" then
		success = handleFoodConsumption(player, itemName)
	elseif itemDef.type == "potion" then
		success = handlePotionConsumption(player, itemName)
	else
		-- Try as other consumable
		success = handleOtherConsumables(player, itemName)
	end
	
	if not success then
		warn("[HotbarHandler] Failed to use item:", itemName)
	end
end)

print("[HotbarHandler] Ready!")