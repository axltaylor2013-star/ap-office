-- CombatManager.server.lua
-- Server-authoritative combat system for PvP

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Modules.Config)
local ItemDB = require(ReplicatedStorage.Modules.ItemDatabase)

local DataManager = require(ReplicatedStorage.Modules.DataManager)

-- Track attack cooldowns
local attackCooldowns = {}

-- Wilderness check
local WILDERNESS_Z = -100
local function isInWilderness(position)
	return position.Z < WILDERNESS_Z
end

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local attackRemote = Remotes:WaitForChild("Attack", 5)
local damageRemote = Remotes:WaitForChild("DamageDealt", 5)

-- Get player's equipped weapon damage
local function getPlayerDamage(player)
	local data = DataManager:GetData(player)
	if not data then return 5 end

	-- Find best weapon in inventory
	local bestDamage = 5 -- fist damage
	for _, slot in ipairs(data.Inventory) do
		local item = ItemDB.GetItem(slot.name)
		if item and item.type == "weapon" then
			local strLevel = DataManager.GetSkillLevel(player, "Strength")
			if strLevel >= (item.combatReq or 1) then
				if item.damage > bestDamage then
					bestDamage = item.damage
				end
			end
		end
	end

	-- Add strength level bonus
	local strLevel = DataManager.GetSkillLevel(player, "Strength")
	bestDamage = bestDamage + math.floor(strLevel * 0.5)

	return bestDamage
end

-- Get player's max health based on defense level
local function getPlayerMaxHealth(player)
	local defLevel = DataManager.GetSkillLevel(player, "Defense")
	return Config.BaseHealth + (defLevel * Config.HealthPerCombatLevel)
end

-- Set up player health on spawn
local function setupPlayerHealth(player, character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	local maxHP = getPlayerMaxHealth(player)
	humanoid.MaxHealth = maxHP
	humanoid.Health = maxHP
end

-- Handle attack request from client
attackRemote.OnServerEvent:Connect(function(attacker, targetPlayer)
	-- Validate target
	if not targetPlayer or not targetPlayer:IsA("Player") then return end
	if targetPlayer == attacker then return end

	-- Cooldown check
	local now = tick()
	if attackCooldowns[attacker.UserId] and (now - attackCooldowns[attacker.UserId]) < Config.AttackCooldown then
		return -- still on cooldown
	end
	attackCooldowns[attacker.UserId] = now

	-- Both players must have characters
	local attackerChar = attacker.Character
	local targetChar = targetPlayer.Character
	if not attackerChar or not targetChar then return end

	local attackerRoot = attackerChar:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
	if not attackerRoot or not targetRoot then return end

	-- Range check (must be within 14 studs)
	local distance = (attackerRoot.Position - targetRoot.Position).Magnitude
	if distance > 14 then return end

	-- PvP zone check — both must be in wilderness
	if not isInWilderness(attackerRoot.Position) or not isInWilderness(targetRoot.Position) then
		return -- can't PvP in safe zone
	end

	-- Calculate damage
	local damage = getPlayerDamage(attacker)

	-- Apply some randomness (80%-120%)
	local multiplier = 0.8 + (math.random() * 0.4)
	damage = math.floor(damage * multiplier)

	-- Apply damage
	local targetHumanoid = targetChar:FindFirstChild("Humanoid")
	if not targetHumanoid or targetHumanoid.Health <= 0 then return end

	-- Tag the kill (so WildernessManager knows who killed them)
	local tag = targetHumanoid:FindFirstChild("creator")
	if not tag then
		tag = Instance.new("ObjectValue")
		tag.Name = "creator"
		tag.Parent = targetHumanoid
	end
	tag.Value = attacker

	-- Clear tag after 5 seconds
	task.delay(5, function()
		if tag and tag.Parent then
			tag:Destroy()
		end
	end)

	targetHumanoid:TakeDamage(damage)

	-- Award XP: Strength for attacking, Defense for taking hits
	local xpGain = math.floor(damage * 1.5)
	DataManager.AddSkillXP(attacker, "Strength", xpGain)
	DataManager.AddSkillXP(targetPlayer, "Defense", math.floor(damage * 0.8))

	-- Notify both players
	damageRemote:FireClient(attacker, "dealt", damage, targetPlayer.Name)
	damageRemote:FireClient(targetPlayer, "received", damage, attacker.Name)

	print("[Combat] " .. attacker.Name .. " hit " .. targetPlayer.Name .. " for " .. damage .. " damage")
end)

-- === EAT FOOD (healing) ===
local eatRemote = Remotes:WaitForChild("EatFood", 5)

eatRemote.OnServerEvent:Connect(function(player, itemName)
	local item = ItemDB.GetItem(itemName)
	if not item or item.type ~= "food" then return end

	-- Must have the food
	if not DataManager.HasItem(player, itemName, 1) then return end

	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	-- Already full health?
	if humanoid.Health >= humanoid.MaxHealth then return end

	-- Eat it!
	DataManager.RemoveFromInventory(player, itemName, 1)
	humanoid.Health = math.min(humanoid.Health + item.healAmount, humanoid.MaxHealth)

	-- Update inventory
	local invRemote = ReplicatedStorage.Remotes:FindFirstChild("InventoryUpdate")
	if invRemote then
		local data = DataManager:GetData(player)
		invRemote:FireClient(player, data.Inventory)
	end

	print("[Combat] " .. player.Name .. " ate " .. itemName .. " and healed " .. item.healAmount .. " HP")
end)

-- === PLAYER SETUP ===
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		task.wait(0.5) -- wait for DataManager to load
		setupPlayerHealth(player, character)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	attackCooldowns[player.UserId] = nil
end)

print("[CombatManager] PvP combat system active!")
