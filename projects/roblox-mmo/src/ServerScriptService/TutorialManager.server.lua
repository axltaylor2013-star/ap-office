-- TutorialManager.server.lua
-- Tutorial/onboarding system for Wilderness MMO

print("[TutorialManager] Starting...")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for dependencies with timeouts
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)

-- Load required modules
local DataManager = require(Modules:WaitForChild("DataManager", 10))

-- Get remotes
local TutorialStep = Remotes:WaitForChild("TutorialStep", 5)
local TutorialComplete = Remotes:WaitForChild("TutorialComplete", 5)
local TutorialSkip = Remotes:WaitForChild("TutorialSkip", 5)

-- Validate remotes
if not TutorialStep or not TutorialComplete or not TutorialSkip then
	warn("[TutorialManager] Missing remotes!")
	return
end

-- Tutorial steps
local TUTORIAL_STEPS = {
	{
		id = "welcome",
		title = "Welcome to Wilderness!",
		description = "Welcome to the world of Wilderness! Let's get you started on your adventure.",
		action = "none",
		uiElement = nil,
		duration = 5
	},
	{
		id = "movement",
		title = "Movement",
		description = "Use WASD keys to move around. Try walking to the marked area.",
		action = "move_to",
		targetPosition = Vector3.new(10, 0, 10),
		radius = 10,
		uiElement = nil,
		duration = 0
	},
	{
		id = "inventory",
		title = "Inventory",
		description = "Press I to open your inventory. This is where you store items.",
		action = "open_ui",
		uiElement = "Inventory",
		key = Enum.KeyCode.I,
		duration = 0
	},
	{
		id = "equip_weapon",
		title = "Equip Weapon",
		description = "Drag the Bronze Sword from your inventory to the equipment slot.",
		action = "equip_item",
		itemName = "Bronze Sword",
		uiElement = "Equipment",
		duration = 0
	},
	{
		id = "attack_monster",
		title = "Combat",
		description = "Left-click on a Goblin to attack. Defeat it to continue.",
		action = "kill_monster",
		monsterType = "Goblin",
		uiElement = nil,
		duration = 0
	},
	{
		id = "pickup_loot",
		title = "Loot",
		description = "Walk over the loot that dropped from the Goblin to pick it up.",
		action = "pickup_item",
		itemName = "Bones",
		uiElement = nil,
		duration = 0
	},
	{
		id = "skills_panel",
		title = "Skills",
		description = "Press K to open your skills panel. This shows your skill levels.",
		action = "open_ui",
		uiElement = "Skills",
		key = Enum.KeyCode.K,
		duration = 0
	},
	{
		id = "complete",
		title = "Tutorial Complete!",
		description = "Great job! You've learned the basics. Now go explore the world!",
		action = "none",
		uiElement = nil,
		duration = 5
	}
}

-- Player tutorial state
local playerTutorials = {}

-- Helper function to get player tutorial state
local function getPlayerTutorialState(player)
	if not player then return nil end
	
	if not playerTutorials[player.UserId] then
		-- Load from player data
		local data = DataManager:GetData(player)
		playerTutorials[player.UserId] = {
			completed = data.tutorialCompleted or false,
			currentStep = data.tutorialStep or 1,
			stepProgress = data.tutorialStepProgress or {}
		}
	end
	
	return playerTutorials[player.UserId]
end

-- Helper function to save player tutorial state
local function savePlayerTutorialState(player)
	if not player then return end
	
	local state = playerTutorials[player.UserId]
	if state then
		DataManager.UpdatePlayerData(player, {
			tutorialCompleted = state.completed,
			tutorialStep = state.currentStep,
			tutorialStepProgress = state.stepProgress
		})
	end
end

-- Function to start tutorial for player
local function startTutorial(player)
	local state = getPlayerTutorialState(player)
	if not state then return end
	
	if state.completed then
		-- Tutorial already completed
		return
	end
	
	-- Reset to step 1
	state.currentStep = 1
	state.stepProgress = {}
	
	-- Send first step
	sendTutorialStep(player, 1)
	
	print("[TutorialManager] Started tutorial for " .. player.Name)
end

-- Function to send tutorial step to player
local function sendTutorialStep(player, stepIndex)
	if not player or stepIndex < 1 or stepIndex > #TUTORIAL_STEPS then return end
	
	local step = TUTORIAL_STEPS[stepIndex]
	local state = getPlayerTutorialState(player)
	
	if not state then return end
	
	-- Update current step
	state.currentStep = stepIndex
	state.stepProgress[stepIndex] = state.stepProgress[stepIndex] or {
		started = os.time(),
		completed = false
	}
	
	-- Send step to client
	TutorialStep:FireClient(player, {
		step = stepIndex,
		totalSteps = #TUTORIAL_STEPS,
		title = step.title,
		description = step.description,
		action = step.action,
		targetPosition = step.targetPosition,
		radius = step.radius,
		uiElement = step.uiElement,
		key = step.key,
		itemName = step.itemName,
		monsterType = step.monsterType,
		duration = step.duration
	})
	
	-- Auto-complete duration-based steps
	if step.duration > 0 then
		task.delay(step.duration, function()
			if player and playerTutorials[player.UserId] and state.currentStep == stepIndex then
				completeTutorialStep(player, stepIndex)
			end
		end)
	end
	
	savePlayerTutorialState(player)
end

-- Function to complete tutorial step
local function completeTutorialStep(player, stepIndex)
	if not player or stepIndex < 1 or stepIndex > #TUTORIAL_STEPS then return end
	
	local state = getPlayerTutorialState(player)
	if not state then return end
	
	-- Mark step as completed
	state.stepProgress[stepIndex] = state.stepProgress[stepIndex] or {}
	state.stepProgress[stepIndex].completed = true
	state.stepProgress[stepIndex].completedTime = os.time()
	
	-- Move to next step or complete tutorial
	if stepIndex < #TUTORIAL_STEPS then
		sendTutorialStep(player, stepIndex + 1)
	else
		completeTutorial(player)
	end
	
	savePlayerTutorialState(player)
end

-- Function to complete entire tutorial
local function completeTutorial(player)
	local state = getPlayerTutorialState(player)
	if not state then return end
	
	state.completed = true
	state.currentStep = #TUTORIAL_STEPS
	
	-- Send completion
	TutorialComplete:FireClient(player, {
		completedSteps = #TUTORIAL_STEPS,
		totalSteps = #TUTORIAL_STEPS
	})
	
	-- Give tutorial reward
	DataManager.AddItem(player, "Bronze Sword", 1)
	DataManager.AddItem(player, "Bronze Pickaxe", 1)
	DataManager.AddItem(player, "Bronze Axe", 1)
	DataManager.AddGold(player, 100)
	
	savePlayerTutorialState(player)
	print("[TutorialManager] Tutorial completed for " .. player.Name)
end

-- Function to skip tutorial
local function skipTutorial(player)
	local state = getPlayerTutorialState(player)
	if not state then return end
	
	state.completed = true
	state.currentStep = #TUTORIAL_STEPS
	
	-- Send skip confirmation
	TutorialComplete:FireClient(player, {
		skipped = true,
		completedSteps = 0,
		totalSteps = #TUTORIAL_STEPS
	})
	
	-- Give tutorial reward (even when skipped)
	DataManager.AddItem(player, "Bronze Sword", 1)
	DataManager.AddItem(player, "Bronze Pickaxe", 1)
	DataManager.AddItem(player, "Bronze Axe", 1)
	DataManager.AddGold(player, 100)
	
	savePlayerTutorialState(player)
	print("[TutorialManager] Tutorial skipped for " .. player.Name)
end

-- Handle tutorial step completion from client
TutorialStep.OnServerEvent:Connect(function(player, stepIndex, success, data)
	if not player then return end
	
	local state = getPlayerTutorialState(player)
	if not state or state.completed or state.currentStep ~= stepIndex then return end
	
	if success then
		completeTutorialStep(player, stepIndex)
	else
		-- Step failed, retry or provide feedback
		print("[TutorialManager] Step " .. tostring(stepIndex) .. " failed for " .. player.Name)
	end
end)

-- Handle tutorial skip
TutorialSkip.OnServerEvent:Connect(function(player)
	if not player then return end
	
	skipTutorial(player)
end)

-- Handle player joined
Players.PlayerAdded:Connect(function(player)
	-- Wait for player data to load
	task.wait(2)
	
	local state = getPlayerTutorialState(player)
	if not state then return end
	
	if not state.completed then
		-- Start tutorial or resume from saved step
		if state.currentStep > 0 and state.currentStep <= #TUTORIAL_STEPS then
			-- Resume from saved step
			sendTutorialStep(player, state.currentStep)
		else
			-- Start new tutorial
			startTutorial(player)
		end
	end
end)

-- Clean up on player leave
Players.PlayerRemoving:Connect(function(player)
	playerTutorials[player.UserId] = nil
end)

-- Public API for other systems to check tutorial progress
local TutorialManager = {
	IsTutorialCompleted = function(player)
		local state = getPlayerTutorialState(player)
		return state and state.completed
	end,
	
	GetCurrentStep = function(player)
		local state = getPlayerTutorialState(player)
		return state and state.currentStep or 0
	end,
	
	CompleteStep = function(player, stepId)
		-- Find step by ID
		for i, step in ipairs(TUTORIAL_STEPS) do
			if step.id == stepId then
				completeTutorialStep(player, i)
				return true
			end
		end
		return false
	end
}

-- Initialize
print("[TutorialManager] Ready with " .. tostring(#TUTORIAL_STEPS) .. " steps!")

return TutorialManager