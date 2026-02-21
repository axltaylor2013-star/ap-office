--[[
	QuestManager.server.lua
	Server-side quest system for the RuneScape-inspired MMO.
	Tracks player quest progress, listens for game events, awards rewards.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataManager = require(ReplicatedStorage.Modules.DataManager)
local QuestDatabase = require(ReplicatedStorage.Modules.QuestDatabase)

------------------------------------------------------------
-- Remote Events Setup
------------------------------------------------------------
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local QuestAcceptEvent = Remotes:WaitForChild("QuestAccept", 10)
local QuestProgressEvent = Remotes:WaitForChild("QuestProgress", 10)
local QuestCompleteEvent = Remotes:WaitForChild("QuestComplete", 10)
local QuestListEvent = Remotes:WaitForChild("QuestList", 10)

-- Bindable events for other server scripts to fire into the quest system
local function getOrCreateBindable(name)
	local existing = ReplicatedStorage:FindFirstChild(name)
	if existing then return existing end
	local b = Instance.new("BindableEvent")
	b.Name = name
	b.Parent = ReplicatedStorage
	return b
end

local GatherEvent = getOrCreateBindable("QuestGatherEvent")
local CraftEvent = getOrCreateBindable("QuestCraftEvent")
local KillEvent = getOrCreateBindable("QuestKillEvent")
local ZoneEvent = getOrCreateBindable("QuestZoneEvent")
local TalkEvent = getOrCreateBindable("QuestTalkEvent")

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

-- Initialise the Quests field on player data if missing
local function ensureQuestData(player)
	local data = DataManager:GetData(player)
	if not data then return end
	if not data.Quests then
		data.Quests = {
			active = {},    -- { [questId] = { objectives = { [index] = currentProgress } } }
			completed = {}, -- { [questId] = true }
		}
	end
	return data
end

-- Check if a player meets quest requirements
local function meetsRequirements(player, quest)
	local data = DataManager:GetData(player)
	if not data then return false end

	-- Level requirements
	for _, req in quest.requirements.level do
		local skills = data.Skills or {}
		local skillData = skills[req.skill] or {}
		local playerLevel = skillData.Level or 1
		if playerLevel < req.level then
			return false
		end
	end

	-- Prerequisite quests
	local questData = data.Quests or {}
	for _, requiredQuestId in quest.requirements.quests do
		if not (questData.completed and questData.completed[requiredQuestId]) then
			return false
		end
	end

	return true
end

-- Send current quest state to a player
local function sendQuestList(player)
	local data = ensureQuestData(player)
	if not data then return end

	-- Find the first active quest for the client's simple structure
	local activeQuestId = nil
	for questId in data.Quests.active do
		activeQuestId = questId
		break -- Take first one as primary active quest
	end

	-- Build progress data for all active quests
	local questProgressData = {}
	for questId, progress in data.Quests.active do
		questProgressData[questId] = {}
		for i, current in progress.objectives do
			questProgressData[questId][i] = {
				current = current,
				done = false -- Will be set below
			}
		end
		
		-- Check if objectives are complete
		local quest = QuestDatabase.ById[questId]
		if quest then
			for i, obj in quest.objectives do
				local current = progress.objectives[i] or 0
				if current >= (obj.amount or 1) then
					questProgressData[questId][i].done = true
				end
			end
		end
	end

	local payload = {
		activeQuest = activeQuestId,
		completedQuests = {},
		questProgress = questProgressData,
	}

	-- Completed quests as array
	for questId in data.Quests.completed do
		table.insert(payload.completedQuests, questId)
	end

	QuestProgressEvent:FireClient(player, payload)
end

------------------------------------------------------------
-- Quest Accept
------------------------------------------------------------
QuestAcceptEvent.OnServerEvent:Connect(function(player, questId)
	local data = ensureQuestData(player)
	if not data then return end

	-- Validate quest exists
	local quest = QuestDatabase.ById[questId]
	if not quest then return end

	-- Already active or completed?
	if data.Quests.active[questId] or data.Quests.completed[questId] then return end

	-- Check requirements
	if not meetsRequirements(player, quest) then return end

	-- Accept the quest
	local objectives = {}
	for i in quest.objectives do
		objectives[i] = 0
	end
	data.Quests.active[questId] = { objectives = objectives }

	print(`[QuestManager] {player.Name} accepted quest: {quest.name}`)
	sendQuestList(player)
end)

------------------------------------------------------------
-- Quest List Request (client asks for current state)
------------------------------------------------------------
QuestListEvent.OnServerEvent:Connect(function(player)
	sendQuestList(player)
end)

------------------------------------------------------------
-- Progress Tracking
------------------------------------------------------------

-- Try to complete a quest if all objectives are met
local function tryComplete(player, questId)
	local data = DataManager:GetData(player)
	if not data or not data.Quests then return end

	local progress = data.Quests.active[questId]
	if not progress then return end

	local quest = QuestDatabase.ById[questId]
	if not quest then return end

	-- Check all objectives
	for i, obj in quest.objectives do
		if (progress.objectives[i] or 0) < obj.amount then
			return -- not done yet
		end
	end

	-- Complete! Remove from active, add to completed
	data.Quests.active[questId] = nil
	data.Quests.completed[questId] = true

	-- Award gold
	data.Gold = (data.Gold or 0) + quest.rewards.gold

	-- Award XP
	for _, xpReward in quest.rewards.xp do
		local skills = data.Skills or {}
		if not skills[xpReward.skill] then
			skills[xpReward.skill] = { Level = 1, XP = 0 }
		end
		skills[xpReward.skill].XP += xpReward.amount
		data.Skills = skills
	end

	-- Award items
	local inventory = data.Inventory or {}
	for _, itemName in quest.rewards.items do
		table.insert(inventory, { name = itemName, amount = 1 })
	end
	data.Inventory = inventory

	print(`[QuestManager] {player.Name} completed quest: {quest.name}`)
	QuestCompleteEvent:FireClient(player, questId, quest.rewards)
	sendQuestList(player)
end

-- Update progress for a specific objective type and target
local function updateProgress(player, objectiveType, target, amount)
	local data = DataManager:GetData(player)
	if not data or not data.Quests then return end

	local changed = false

	for questId, progress in data.Quests.active do
		local quest = QuestDatabase.ById[questId]
		if quest then
			for i, obj in quest.objectives do
				if obj.type == objectiveType and obj.target == target then
					local prev = progress.objectives[i] or 0
					if prev < obj.amount then
						progress.objectives[i] = math.min(prev + amount, obj.amount)
						changed = true
					end
				end
			end
		end
	end

	if changed then
		-- Notify client of progress update
		QuestProgressEvent:FireClient(player, {})
		sendQuestList(player)

		-- Check completions
		for questId in data.Quests.active do
			tryComplete(player, questId)
		end
	end
end

------------------------------------------------------------
-- Event Listeners (from other server scripts)
------------------------------------------------------------

-- Gather event: fired when player gathers a resource
-- Args: player, itemName, amount
GatherEvent.Event:Connect(function(player, itemName, amount)
	updateProgress(player, "gather", itemName, amount or 1)
end)

-- Craft event: fired when player crafts an item
-- Args: player, itemName, amount
CraftEvent.Event:Connect(function(player, itemName, amount)
	updateProgress(player, "craft", itemName, amount or 1)
end)

-- Kill event: fired when player defeats a target
-- Args: player, targetType, amount
KillEvent.Event:Connect(function(player, targetType, amount)
	updateProgress(player, "kill", targetType, amount or 1)
end)

-- Zone event: fired when player enters/exits a zone
-- Args: player, zoneName
ZoneEvent.Event:Connect(function(player, zoneName)
	updateProgress(player, "visit", zoneName, 1)
end)

-- Talk event: fired when player talks to an NPC
-- Args: player, npcName
TalkEvent.Event:Connect(function(player, npcName)
	updateProgress(player, "talk", npcName, 1)
end)

------------------------------------------------------------
-- Player Setup
------------------------------------------------------------
Players.PlayerAdded:Connect(function(player)
	-- Wait for DataManager to load player data
	task.wait(1)
	ensureQuestData(player)
	sendQuestList(player)
end)

print("[QuestManager] Quest system active!")
