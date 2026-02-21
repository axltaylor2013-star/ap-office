--[[
	AttackVisualHandler.server.lua
	ServerScriptService

	Bridges combat events between server and all clients.
	- Broadcasts player attack visuals to nearby clients
	- Broadcasts monster attack visuals when monsters attack
	- Sends hit effect events for damage numbers, blocks, etc.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--------------------------------------------------------------------------------
-- REMOTE EVENTS (create if missing)
--------------------------------------------------------------------------------
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)

local function getRemote(name)
	return Remotes:WaitForChild(name, 10)
end

local AttackVisualEvent = getRemote("AttackVisual")
local HitEffectEvent = getRemote("HitEffect")
local MonsterAttackVisualEvent = getRemote("MonsterAttackVisual")
local MonsterDamageEvent = getRemote("MonsterDamage")
local MonsterDeathEvent = getRemote("MonsterDeath")

--------------------------------------------------------------------------------
-- BROADCAST RADIUS
--------------------------------------------------------------------------------
local BROADCAST_RADIUS = 100

local function getNearbyPlayers(position, radius)
	local result = {}
	for _, p in Players:GetPlayers() do
		local char = p.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local dist = (hrp.Position - position).Magnitude
				if dist <= radius then
					table.insert(result, p)
				end
			end
		end
	end
	return result
end

--------------------------------------------------------------------------------
-- PLAYER ATTACK BROADCAST
-- When a player attacks, broadcast the visual to nearby clients
--------------------------------------------------------------------------------
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
if Remotes then
	local attack = Remotes:FindFirstChild("Attack")
	if attack then
		-- We listen to DamageDealt to broadcast visuals
		-- But attack visuals are better triggered client-side per-attacker
		-- This handler is for OTHER players to see the attack animation
	end
end

-- Expose a function for MonsterManager to call when monsters attack
shared.AttackVisualHandler = {
	-- Call this when a monster attacks a player
	BroadcastMonsterAttack = function(monsterModel, targetPlayer, monsterName)
		if not monsterModel or not monsterModel.PrimaryPart then return end
		local pos = monsterModel.PrimaryPart.Position
		local nearby = getNearbyPlayers(pos, BROADCAST_RADIUS)
		for _, p in nearby do
			MonsterAttackVisualEvent:FireClient(p, monsterModel, targetPlayer, monsterName)
		end
	end,

	-- Call this when a player takes damage (from monster or PvP)
	BroadcastHitEffect = function(position, damage, effectType, isCritical, targetPlayer)
		if targetPlayer then
			HitEffectEvent:FireClient(targetPlayer, position, damage, effectType, isCritical)
		end
	end,

	-- Broadcast a player's attack animation to other nearby players
	BroadcastPlayerAttack = function(attackerPlayer, targetModel, weaponType, isCritical)
		local char = attackerPlayer.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		local nearby = getNearbyPlayers(hrp.Position, BROADCAST_RADIUS)
		for _, p in nearby do
			if p ~= attackerPlayer then
				AttackVisualEvent:FireClient(p, attackerPlayer, targetModel, weaponType, isCritical)
			end
		end
	end,
}

print("[AttackVisualHandler] Visual handler loaded!")
