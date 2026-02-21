--[[
	StatsPanelHandler.server.lua
	Handles GetStatsPanel RemoteFunction + GetSkillData RemoteFunction
	Returns player skills, inventory, equipment, and combat level
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(ReplicatedStorage.Modules.DataManager)
local Config = require(ReplicatedStorage.Modules.Config)
local ItemDatabase = require(ReplicatedStorage.Modules.ItemDatabase)

-- Wait for remotes (no delay — register handlers ASAP)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local GetStatsPanel = Remotes:WaitForChild("GetStatsPanel", 10)
local GetSkillData = Remotes:WaitForChild("GetSkillData", 10)

--------------------------------------------------------------------------------
-- SKILL NAMES
--------------------------------------------------------------------------------
local SKILL_NAMES = {"Mining", "Woodcutting", "Fishing", "Smithing", "Cooking", "Strength", "Defense", "Ranged", "Fletching", "Prayer"}

--------------------------------------------------------------------------------
-- GetStatsPanel → returns full panel data
--------------------------------------------------------------------------------
if GetStatsPanel then
	GetStatsPanel.OnServerInvoke = function(player)
		local data = DataManager:GetData(player)
		if not data then return nil end

		-- Skills (return flat level numbers — client expects numbers not tables)
		local skills = {}
		for _, skillName in SKILL_NAMES do
			local level = 1
			if data.Skills and data.Skills[skillName] ~= nil then
				level = Config.GetLevelFromXP(data.Skills[skillName])
			end
			skills[skillName] = level
		end

		-- Inventory (format for client: {name, count, rarity})
		-- DataManager stores Inventory as array of {name=, quantity=}
		local inventory = {}
		local inv = data.Inventory or {}
		for _, slot in ipairs(inv) do
			if slot.name and slot.quantity and slot.quantity > 0 then
				local itemDef = ItemDatabase.Items[slot.name]
				local rarity = "common"
				local itemType = "resource"
				if itemDef then
					rarity = itemDef.rarity or "common"
					itemType = itemDef.type or "resource"
				end
				table.insert(inventory, {
					name = slot.name,
					count = slot.quantity,
					rarity = rarity,
					itemType = itemType,
				})
			end
		end

		-- Equipment (placeholder — expand when equip system is built)
		local equipment = data.Equipment or {
			Head = "",
			Body = "",
			Legs = "",
			Weapon = "",
			Shield = "",
		}

		-- Combat level (simple: average of all skill levels, or dedicated combat level)
		local combatLevel = data.CombatLevel or 1
		if not data.CombatLevel then
			local total = 0
			local count = 0
			for _, lvl in pairs(skills) do
				total = total + lvl
				count = count + 1
			end
			combatLevel = math.floor(total / math.max(count, 1))
		end

		-- Gold
		local gold = data.Gold or 0

		-- Sanitize hotbar (only strings/numbers allowed through remotes)
		local hotbar = {}
		if data.Hotbar then
			for i, v in pairs(data.Hotbar) do
				if type(v) == "string" or type(v) == "number" then
					hotbar[i] = v
				end
			end
		end

		return {
			skills = skills,
			inventory = inventory,
			equipment = equipment,
			combatLevel = combatLevel,
			gold = gold,
			hotbar = hotbar,
		}
	end
	print("[StatsPanelHandler] GetStatsPanel ready")
end

--------------------------------------------------------------------------------
-- GetSkillData → returns skill tree data (for SkillTreeUI)
--------------------------------------------------------------------------------
if GetSkillData then
	GetSkillData.OnServerInvoke = function(player)
		local data = DataManager:GetData(player)
		if not data then return nil end

		local skills = {}
		for _, skillName in SKILL_NAMES do
			local level = 1
			local xp = 0
			if data.Skills and data.Skills[skillName] ~= nil then
				xp = data.Skills[skillName]
				level = Config.GetLevelFromXP(xp)
			end
			skills[skillName] = {
				level = level,
				xp = xp,
			}
		end
		return skills
	end
	print("[StatsPanelHandler] GetSkillData ready")
end
