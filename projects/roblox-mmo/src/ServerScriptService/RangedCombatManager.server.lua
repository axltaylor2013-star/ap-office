-- RangedCombatManager.server.lua
-- Server-side ranged combat system for bows and crossbows with error handling

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Wait for dependencies with timeouts
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)

-- Load ErrorHandler first for error handling
local ErrorHandler
local itemDatabaseSuccess, ItemDatabase = pcall(function()
	return require(Modules:WaitForChild("ItemDatabase", 5))
end)

local dataManagerSuccess, DataManager = pcall(function()
	return require(Modules:WaitForChild("DataManager", 5))
end)

-- Initialize ErrorHandler
local errorHandlerSuccess, errorHandlerResult = pcall(function()
	return require(Modules:WaitForChild("ErrorHandler", 5))
end)

if errorHandlerSuccess then
	ErrorHandler = errorHandlerResult
else
	-- Fallback ErrorHandler
	ErrorHandler = {
		LogWarning = function(self, msg, data) warn("[RangedCombat] " .. tostring(msg)) end,
		LogError = function(self, msg, data) warn("[RangedCombat] " .. tostring(msg)) end,
		ValidateNotNil = function(self, val, ctx, fallback) return val or fallback end
	}
end

-- Validate dependencies
if not itemDatabaseSuccess then
	ErrorHandler:LogError("Failed to load ItemDatabase", {error = ItemDatabase})
	ItemDatabase = {}
end

if not dataManagerSuccess then
	ErrorHandler:LogWarning("Failed to load DataManager, using fallback", {error = DataManager})
	DataManager = {
		GetData = function() return {skills = {ranged = 1}} end,
		SaveData = function() return true end
	}
end

-- RemoteEvents with validation
local RangedAttackEvent = Remotes and Remotes:WaitForChild("RangedAttack", 5)
local RangedHitEvent = Remotes and Remotes:WaitForChild("RangedHit", 5)
local RangedAmmoUpdateEvent = Remotes and Remotes:WaitForChild("RangedAmmoUpdate", 5)

-- Validate remotes
if not RangedAttackEvent then
	ErrorHandler:LogError("RangedAttack remote not found")
	return
end

-- Constants
local MAX_RANGE_BOW = 50
local MAX_RANGE_CROSSBOW = 70
local PROJECTILE_SPEED = 100 -- studs per second
local PROJECTILE_LIFETIME = 5 -- seconds

-- Weapon type definitions
local WEAPON_TYPES = {
	["Bow"] = {
		range = MAX_RANGE_BOW,
		speedMultiplier = 1.0,
		ammoType = "Arrow"
	},
	["Crossbow"] = {
		range = MAX_RANGE_CROSSBOW,
		speedMultiplier = 0.8, -- slower attack speed
		ammoType = "Bolt"
	}
}

-- Projectile tracking
local activeProjectiles = {}
local lastAttackTimes = {}

-- Helper: Get appropriate ammo for weapon
local function getAmmoForWeapon(weaponId)
	local weaponData = ItemDatabase[weaponId]
	if not weaponData then return nil end
	
	local weaponType = weaponData.subtype or "Bow"
	local ammoType = WEAPON_TYPES[weaponType] and WEAPON_TYPES[weaponType].ammoType or "Arrow"
	
	-- Find matching ammo in player's inventory
	-- This would be implemented with actual inventory lookup
	return ammoType
end

-- Helper: Calculate ranged damage
local function calculateRangedDamage(player, weaponId, ammoId, targetDistance)
	local playerData = DataManager:GetData(player)
	if not playerData then return 0 end
	
	local weaponData = ItemDatabase[weaponId]
	local ammoData = ammoId and ItemDatabase[ammoId]
	
	if not weaponData then return 0 end
	
	-- Base damage from weapon
	local baseDamage = weaponData.damage or 1
	
	-- Ammo bonus
	local ammoBonus = ammoData and ammoData.damage or 0
	
	-- Ranged skill bonus
	local rangedLevel = playerData.skills.ranged or 1
	local skillBonus = math.floor(rangedLevel / 10) + 1
	
	-- Distance penalty (reduced damage at max range)
	local maxRange = WEAPON_TYPES[weaponData.subtype or "Bow"] and WEAPON_TYPES[weaponData.subtype or "Bow"].range or MAX_RANGE_BOW
	local distancePenalty = 1 - (targetDistance / maxRange) * 0.3
	distancePenalty = math.max(0.7, distancePenalty)
	
	-- Calculate final damage
	local damage = (baseDamage + ammoBonus + skillBonus) * distancePenalty
	
	-- Random variation ±10%
	local variation = 0.9 + math.random() * 0.2
	damage = math.floor(damage * variation)
	
	return math.max(1, damage)
end

-- Helper: Consume ammo from inventory
local function consumeAmmo(player, ammoId)
	-- This would interface with the inventory system
	-- For now, just return true
	return true
end

-- Helper: Award ranged XP
local function awardRangedXP(player, damageDealt)
	local playerData = DataManager:GetData(player)
	if not playerData then return end
	
	-- XP based on damage dealt
	local xpGained = math.floor(damageDealt * 0.5)
	
	-- Update player's ranged skill
	playerData.skills.ranged = (playerData.skills.ranged or 1) + xpGained
	DataManager:SaveData(player, playerData)
	
	-- Notify client of XP gain
	-- This would use an existing XP notification system
end

-- Main ranged attack handler with error handling
RangedAttackEvent.OnServerEvent:Connect(function(player, weaponId, targetPosition)
	-- Validate input parameters
	if not player or not player:IsA("Player") then
		ErrorHandler:LogWarning("Invalid player in ranged attack", {player = player})
		return
	end
	
	if not weaponId or type(weaponId) ~= "string" then
		ErrorHandler:LogWarning("Invalid weaponId", {player = player.Name, weaponId = weaponId})
		return
	end
	
	if not targetPosition or not targetPosition:IsA("Vector3") then
		ErrorHandler:LogWarning("Invalid target position", {player = player.Name})
		return
	end
	
	-- Validate player character
	local character = player.Character
	if not character then
		ErrorHandler:LogWarning("Player has no character", {player = player.Name})
		return
	end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		ErrorHandler:LogWarning("Player has no HumanoidRootPart", {player = player.Name})
		return
	end
	
	-- Get weapon data with validation
	local weaponData = ItemDatabase[weaponId]
	if not weaponData then
		ErrorHandler:LogWarning("Weapon not found in database", {player = player.Name, weaponId = weaponId})
		return
	end
	
	if weaponData.type ~= "Weapon" then
		ErrorHandler:LogWarning("Item is not a weapon", {player = player.Name, weaponId = weaponId, type = weaponData.type})
		return
	end
	
	-- Check weapon type
	local weaponType = weaponData.subtype or "Bow"
	if not WEAPON_TYPES[weaponType] then
		ErrorHandler:LogWarning("Invalid weapon type", {player = player.Name, weaponType = weaponType})
		return
	end
	
	-- Get appropriate ammo
	local ammoType = WEAPON_TYPES[weaponType].ammoType
	
	-- Calculate distance with validation
	local distance
	local success, err = pcall(function()
		distance = (targetPosition - humanoidRootPart.Position).Magnitude
	end)
	
	if not success then
		ErrorHandler:LogError("Distance calculation failed", {player = player.Name, error = err})
		return
	end
	
	local maxRange = WEAPON_TYPES[weaponType].range
	
	if distance > maxRange then
		ErrorHandler:LogDebug("Target out of range", {player = player.Name, distance = distance, maxRange = maxRange})
		return
	end
	
	-- Check attack cooldown (would use existing cooldown system)
	-- For now, we'll implement a simple cooldown
	local currentTime = tick()
	local lastAttackTime = lastAttackTimes[player.UserId] or 0
	local attackCooldown = 1.0 -- 1 second cooldown
	
	if currentTime - lastAttackTime < attackCooldown then
		ErrorHandler:LogDebug("Attack on cooldown", {player = player.Name})
		return
	end
	
	lastAttackTimes[player.UserId] = currentTime
	
	-- Consume ammo
	local ammoConsumed = consumeAmmo(player, ammoType)
	if not ammoConsumed then
		ErrorHandler:LogWarning("No ammo available", {player = player.Name, ammoType = ammoType})
		return
	end
	
	-- Calculate damage
	local damage = calculateRangedDamage(player, weaponId, ammoType, distance)
	
	-- Create projectile on server with error handling
	local projectile
	local success, err = pcall(function()
		projectile = Instance.new("Part")
		projectile.Name = "RangedProjectile"
		projectile.Size = Vector3.new(0.2, 0.2, 0.2)
		projectile.Color = Color3.fromRGB(255, 255, 255)
		projectile.Material = Enum.Material.Neon
		projectile.CanCollide = false
		projectile.Anchored = true
		projectile.Position = humanoidRootPart.Position + Vector3.new(0, 1.5, 0)
		projectile.Parent = workspace
	end)
	
	if not success or not projectile then
		ErrorHandler:LogError("Failed to create projectile", {player = player.Name, error = err})
		return
	end
	
	-- Store projectile data
	local projectileId = #activeProjectiles + 1
	activeProjectiles[projectileId] = {
		part = projectile,
		player = player,
		weaponId = weaponId,
		damage = damage,
		startPosition = projectile.Position,
		targetPosition = targetPosition,
		startTime = tick(),
		speed = PROJECTILE_SPEED
	}
	
	-- Notify clients to create visual projectile
	if RangedHitEvent then
		local fireSuccess, fireErr = pcall(function()
			RangedHitEvent:FireAllClients(player, projectile.Position, targetPosition, weaponType)
		end)
		
		if not fireSuccess then
			ErrorHandler:LogWarning("Failed to fire RangedHitEvent", {player = player.Name, error = fireErr})
		end
	end
	
	-- Schedule projectile cleanup
	game:GetService("Debris"):AddItem(projectile, PROJECTILE_LIFETIME)
	
	ErrorHandler:LogDebug("Ranged attack executed", {
		player = player.Name,
		weapon = weaponId,
		damage = damage,
		distance = distance
	})
end)

-- Projectile update loop with error handling
RunService.Heartbeat:Connect(function(deltaTime)
	for id, projectileData in pairs(activeProjectiles) do
		local success, err = pcall(function()
			local projectile = projectileData.part
			if not projectile or not projectile.Parent then
				activeProjectiles[id] = nil
				return
			end
			
			-- Calculate progress
			local elapsed = tick() - projectileData.startTime
			local travelDistance = projectileData.speed * elapsed
			local totalDistance = (projectileData.targetPosition - projectileData.startPosition).Magnitude
			
			if travelDistance >= totalDistance then
				-- Projectile reached target
				projectile.Position = projectileData.targetPosition
				
				-- Check for hits with error handling
				local hitSuccess, hitErr = pcall(function()
					local hitCharacters = workspace:GetPartsInSphere(projectile.Position, 3)
					for _, part in pairs(hitCharacters) do
						local character = part.Parent
						if character and character:IsA("Model") then
							-- Check if it's a monster
							local monsterTag = character:FindFirstChild("Monster")
							if monsterTag then
								-- Apply damage to monster via Humanoid
								local humanoid = character:FindFirstChild("Humanoid")
								if humanoid and humanoid.Health > 0 then
									humanoid:TakeDamage(projectileData.damage)
									-- Fire damage event for UI feedback
									if Remotes then
										local monsterDamageEvent = Remotes:FindFirstChild("MonsterDamage")
										if monsterDamageEvent and projectileData.player then
											monsterDamageEvent:FireClient(projectileData.player, character, projectileData.damage)
										end
									end
								end
								
								-- Award XP to player
								awardRangedXP(projectileData.player, projectileData.damage)
								
								ErrorHandler:LogDebug("Projectile hit monster", {
									player = projectileData.player and projectileData.player.Name or "Unknown",
									damage = projectileData.damage
								})
								break
							end
						end
					end
				end)
				
				if not hitSuccess then
					ErrorHandler:LogWarning("Hit detection failed", {error = hitErr})
				end
				
				-- Remove projectile
				projectile:Destroy()
				activeProjectiles[id] = nil
			else
				-- Update projectile position
				local progress = travelDistance / totalDistance
				projectile.Position = projectileData.startPosition:Lerp(projectileData.targetPosition, progress)
			end
		end)
		
		if not success then
			ErrorHandler:LogWarning("Projectile update failed", {error = err, projectileId = id})
			-- Clean up failed projectile
			if projectileData and projectileData.part then
				pcall(function() projectileData.part:Destroy() end)
			end
			activeProjectiles[id] = nil
		end
	end
end)

-- Cleanup when player leaves
Players.PlayerRemoving:Connect(function(player)
	for id, projectileData in pairs(activeProjectiles) do
		if projectileData.player == player then
			if projectileData.part then
				projectileData.part:Destroy()
			end
			activeProjectiles[id] = nil
		end
	end
end)

print("[RangedCombatManager] Loaded!")