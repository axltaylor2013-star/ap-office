-- EquipmentManager.server.lua
-- Handles equipping/unequipping items for players

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataManager = require(ReplicatedStorage:WaitForChild("Modules", 5):WaitForChild("DataManager", 5))
local ItemDatabase = require(ReplicatedStorage:WaitForChild("Modules", 5):WaitForChild("ItemDatabase", 5))

-- Valid equipment slots
local VALID_SLOTS = {Head = true, Body = true, Legs = true, Weapon = true, Shield = true, Tool = true, Cape = true}

-- Get remotes from Remotes folder (created by Rojo project.json)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local EquipItemRemote = Remotes:WaitForChild("EquipItem", 5)
local UnequipItemRemote = Remotes:WaitForChild("UnequipItem", 5)
local EquipmentUpdateRemote = Remotes:WaitForChild("EquipmentUpdate", 5)
local EquipmentInfoRemote = Remotes:WaitForChild("EquipmentInfo", 5)

local function getWeaponTypeFromName(weaponName)
	if not weaponName or weaponName == "" then return "fist" end
	local lower = weaponName:lower()
	if lower:find("crossbow") then return "crossbow"
	elseif lower:find("bow") then return "bow"
	elseif lower:find("axe") or lower:find("battleaxe") or lower:find("halberd") then return "sword" -- client sub-classifies by name
	elseif lower:find("dagger") or lower:find("knife") or lower:find("shiv") then return "sword" -- client sub-classifies by name
	elseif lower:find("sword") or lower:find("scimitar") then return "sword"
	else return "sword" end
end

local function sendEquipmentUpdate(player)
	local data = DataManager:GetData(player)
	if data then
		EquipmentUpdateRemote:FireClient(player, data.Equipment)

		-- Send weapon type info to client for animation system
		local weaponName = (data.Equipment and data.Equipment.Weapon) or ""
		local weaponType = getWeaponTypeFromName(weaponName)
		EquipmentInfoRemote:FireClient(player, {
			weaponType = weaponType,
			weaponName = weaponName,
			hasShield = (data.Equipment.Shield ~= nil and data.Equipment.Shield ~= ""),
		})
	end
	-- Fire BindableEvent so VisualEquipment updates character appearance
	local equipChanged = ReplicatedStorage:FindFirstChild("EquipmentChanged")
	if equipChanged then
		equipChanged:Fire(player)
	end
end

EquipItemRemote.OnServerEvent:Connect(function(player, slotName, itemName)
	if type(slotName) ~= "string" or type(itemName) ~= "string" then return end
	if not VALID_SLOTS[slotName] then return end

	local data = DataManager:GetData(player)
	if not data then return end

	-- Validate item exists in database and fits the slot
	local itemInfo = ItemDatabase.GetItem(itemName)
	if not itemInfo then return end
	if itemInfo.equipSlot ~= slotName then return end

	-- Validate player has the item
	if not DataManager.HasItem(player, itemName, 1) then return end

	-- Unequip current item in that slot (put back in inventory)
	local currentEquip = data.Equipment[slotName]
	if currentEquip and currentEquip ~= "" then
		DataManager.AddToInventory(player, currentEquip, 1)
	end

	-- Remove new item from inventory and equip it
	DataManager.RemoveFromInventory(player, itemName, 1)
	data.Equipment[slotName] = itemName

	sendEquipmentUpdate(player)
	-- Also notify inventory changed (item moved from inventory to equipment)
	local invRemote = Remotes:FindFirstChild("InventoryUpdate")
	if invRemote then invRemote:FireClient(player) end
	print("[Equipment] " .. player.Name .. " equipped " .. itemName .. " in " .. slotName)
end)

UnequipItemRemote.OnServerEvent:Connect(function(player, slotName)
	if type(slotName) ~= "string" then return end
	if not VALID_SLOTS[slotName] then return end

	local data = DataManager:GetData(player)
	if not data then return end

	local currentEquip = data.Equipment[slotName]
	if not currentEquip or currentEquip == "" then return end

	-- Move back to inventory
	local added = DataManager.AddToInventory(player, currentEquip, 1)
	if not added then return end -- inventory full

	data.Equipment[slotName] = ""
	sendEquipmentUpdate(player)
	-- Also notify inventory changed (item moved from equipment to inventory)
	local invRemote = Remotes:FindFirstChild("InventoryUpdate")
	if invRemote then invRemote:FireClient(player) end
	print("[Equipment] " .. player.Name .. " unequipped " .. currentEquip .. " from " .. slotName)
end)

-- Send equipment state when player joins
Players.PlayerAdded:Connect(function(player)
	-- Wait for data to load
	task.defer(function()
		task.wait(2)
		sendEquipmentUpdate(player)
	end)
end)

print("[EquipmentManager] Loaded!")
