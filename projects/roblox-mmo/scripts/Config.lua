-- Config.lua (ModuleScript in ReplicatedStorage/Modules)
-- Game-wide constants and settings

local Config = {}

-- === SKILLS ===
Config.Skills = {
	Mining = { maxLevel = 99, baseXP = 50 },
	Woodcutting = { maxLevel = 99, baseXP = 45 },
	Fishing = { maxLevel = 99, baseXP = 40 },
	Smithing = { maxLevel = 99, baseXP = 60 },
	Cooking = { maxLevel = 99, baseXP = 55 },
	Combat = { maxLevel = 99, baseXP = 70 },
}

-- XP formula: XP needed for level N = floor(N^2 * 100)
function Config.GetXPForLevel(level)
	return math.floor(level * level * 100)
end

-- Get level from total XP
function Config.GetLevelFromXP(totalXP)
	local level = 1
	while Config.GetXPForLevel(level + 1) <= totalXP and level < 99 do
		level = level + 1
	end
	return level
end

-- === INVENTORY ===
Config.MaxInventorySlots = 28 -- just like RuneScape
Config.MaxBankSlots = 100

-- === WILDERNESS ===
Config.WildernessEnabled = true
Config.SafeZoneOnDeath = true -- respawn in safe zone
Config.LootDropDuration = 60 -- seconds before loot despawns

-- === COMBAT ===
Config.BaseHealth = 100
Config.HealthPerCombatLevel = 5
Config.RespawnTime = 5 -- seconds
Config.AttackCooldown = 1.5 -- seconds between attacks

-- === RESOURCE RESPAWN ===
Config.ResourceRespawnTime = {
	Tree = 15,
	Rock = 20,
	FishingSpot = 10,
}

-- === ZONES ===
Config.Zones = {
	SafeZone = "SafeZone",
	Wilderness = "Wilderness",
}

return Config
