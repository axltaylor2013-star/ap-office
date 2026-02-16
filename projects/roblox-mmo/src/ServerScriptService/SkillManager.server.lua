-- SkillManager.server.lua
-- Handles resource gathering (mining, woodcutting, fishing)

print("[SkillManager] Starting...")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules", 10)
print("[SkillManager] Modules folder found: " .. tostring(Modules ~= nil))

local ok1, Config = pcall(function() return require(Modules:WaitForChild("Config", 10)) end)
print("[SkillManager] Config loaded: " .. tostring(ok1))

local ok2, ItemDB = pcall(function() return require(Modules:WaitForChild("ItemDatabase", 10)) end)
print("[SkillManager] ItemDB loaded: " .. tostring(ok2))

local ok3, DataManager = pcall(function() return require(Modules:WaitForChild("DataManager", 10)) end)
print("[SkillManager] DataManager loaded: " .. tostring(ok3))

if not ok1 or not ok2 or not ok3 then
	warn("[SkillManager] FAILED to load modules! Config=" .. tostring(ok1) .. " ItemDB=" .. tostring(ok2) .. " DataManager=" .. tostring(ok3))
	return
end

-- Create a remote for gather feedback
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local gatherRemote = Instance.new("RemoteEvent")
gatherRemote.Name = "GatherFeedback"
gatherRemote.Parent = Remotes

-- Skill mapping
local skillMap = {
	Rock = "Mining",
	Tree = "Woodcutting",
	FishingSpot = "Fishing",
}

-- === RESOURCE NODE SETUP ===
local function createResourceNode(name, nodeType, position, parent, levelReq, itemDrop, xpReward)
	-- Use a Model to group all parts together
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent

	local mainPart -- the part that gets the ClickDetector

	if nodeType == "Rock" then
		mainPart = Instance.new("Part")
		mainPart.Name = "Rock"
		mainPart.Size = Vector3.new(4, 3, 4)
		mainPart.Position = position + Vector3.new(0, 1.5, 0)
		mainPart.Anchored = true
		mainPart.CanCollide = true
		mainPart.BrickColor = BrickColor.new("Dark stone grey")
		mainPart.Material = Enum.Material.Slate
		mainPart.Parent = model

		-- Add a smaller rock next to it for visual interest
		local rock2 = Instance.new("Part")
		rock2.Name = "RockSmall"
		rock2.Size = Vector3.new(2, 2, 2)
		rock2.Position = position + Vector3.new(2.5, 1, 1)
		rock2.Anchored = true
		rock2.CanCollide = true
		rock2.BrickColor = BrickColor.new("Medium stone grey")
		rock2.Material = Enum.Material.Slate
		rock2.Parent = model

	elseif nodeType == "Tree" then
		-- Trunk (upright block, NOT a rotated cylinder)
		mainPart = Instance.new("Part")
		mainPart.Name = "Trunk"
		mainPart.Size = Vector3.new(2, 8, 2)
		mainPart.Position = position + Vector3.new(0, 4, 0)
		mainPart.Anchored = true
		mainPart.CanCollide = true
		mainPart.BrickColor = BrickColor.new("Reddish brown")
		mainPart.Material = Enum.Material.Wood
		mainPart.Parent = model

		-- Leaves (big green ball on top)
		local leaves = Instance.new("Part")
		leaves.Name = "Leaves"
		leaves.Shape = Enum.PartType.Ball
		leaves.Size = Vector3.new(10, 10, 10)
		leaves.Position = position + Vector3.new(0, 10, 0)
		leaves.Anchored = true
		leaves.CanCollide = false
		leaves.BrickColor = BrickColor.new("Forest green")
		leaves.Material = Enum.Material.Grass
		leaves.Parent = model

		-- ALSO add ClickDetector to leaves so clicking the canopy works
		local leavesClick = Instance.new("ClickDetector")
		leavesClick.MaxActivationDistance = 16
		leavesClick.Parent = leaves

		-- Connect leaves click to same handler (set up below)
		leaves:SetAttribute("IsGatherNode", true)

	elseif nodeType == "FishingSpot" then
		-- Flat circle on the ground (easier to click than thin cylinder)
		mainPart = Instance.new("Part")
		mainPart.Name = "FishingSpot"
		mainPart.Size = Vector3.new(6, 0.5, 6)
		mainPart.Position = position + Vector3.new(0, 0.25, 0)
		mainPart.Anchored = true
		mainPart.CanCollide = false
		mainPart.BrickColor = BrickColor.new("Cyan")
		mainPart.Material = Enum.Material.Neon
		mainPart.Transparency = 0.3
		mainPart.Parent = model

		-- Bobbing effect marker
		local bobber = Instance.new("Part")
		bobber.Name = "Bobber"
		bobber.Shape = Enum.PartType.Ball
		bobber.Size = Vector3.new(1, 1, 1)
		bobber.Position = position + Vector3.new(0, 0.8, 0)
		bobber.Anchored = true
		bobber.CanCollide = false
		bobber.BrickColor = BrickColor.new("Bright red")
		bobber.Material = Enum.Material.SmoothPlastic
		bobber.Parent = model
	end

	if not mainPart then
		warn("[SkillManager] Failed to create main part for " .. name)
		return
	end

	-- ClickDetector on main part
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 16
	clickDetector.Parent = mainPart

	-- Floating label showing what it is
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(5, 0, 1, 0)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.Parent = mainPart

	local skillEmojis = {Rock = "⛏️", Tree = "🪓", FishingSpot = "🎣"}
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = (skillEmojis[nodeType] or "") .. " " .. itemDrop .. " (Lv " .. levelReq .. ")"
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextStrokeTransparency = 0.5
	label.Parent = billboard

	-- Node state
	local nodeData = { active = true }

	-- Gather handler
	local function onGather(player)
		if not nodeData.active then return end

		local skill = skillMap[nodeType]
		if not skill then return end

		-- Check level requirement
		local playerLevel = DataManager.GetSkillLevel(player, skill)
		if playerLevel < levelReq then
			gatherRemote:FireClient(player, "level", itemDrop, levelReq)
			return
		end

		-- Add to inventory
		local added = DataManager.AddToInventory(player, itemDrop, 1)
		if not added then
			gatherRemote:FireClient(player, "full", itemDrop, 0)
			return
		end

		-- Award XP
		DataManager.AddSkillXP(player, skill, xpReward)

		-- Notify client
		gatherRemote:FireClient(player, "gather", itemDrop, xpReward)

		-- Update client inventory
		local invRemote = Remotes:FindFirstChild("InventoryUpdate")
		if invRemote then
			local data = DataManager.GetData(player)
			invRemote:FireClient(player, data.Inventory)
		end

		-- Deplete resource
		nodeData.active = false
		for _, child in ipairs(model:GetChildren()) do
			if child:IsA("BasePart") then
				child.Transparency = 0.8
			end
		end
		-- Hide label
		label.TextTransparency = 1

		-- Respawn
		local respawnTime = Config.ResourceRespawnTime[nodeType] or 15
		task.delay(respawnTime, function()
			nodeData.active = true
			for _, child in ipairs(model:GetChildren()) do
				if child:IsA("BasePart") then
					if child.Name == "FishingSpot" then
						child.Transparency = 0.3
					elseif child.Name == "Leaves" then
						child.Transparency = 0
					else
						child.Transparency = 0
					end
				end
			end
			label.TextTransparency = 0
		end)
	end

	-- Connect main click
	clickDetector.MouseClick:Connect(onGather)

	-- Connect leaf clicks for trees
	if nodeType == "Tree" then
		for _, child in ipairs(model:GetChildren()) do
			local childClick = child:FindFirstChild("ClickDetector")
			if childClick and child ~= mainPart then
				childClick.MouseClick:Connect(onGather)
			end
		end
	end

	return model
end

-- === SPAWN RESOURCE NODES ===
local WS = game:GetService("Workspace")

-- Wait for MapSetup to run
task.wait(2)
local resourceFolder = WS:FindFirstChild("ResourceNodes")
if not resourceFolder then
	resourceFolder = Instance.new("Folder")
	resourceFolder.Name = "ResourceNodes"
	resourceFolder.Parent = WS
end
print("[SkillManager] ResourceNodes folder ready, spawning nodes...")

-- ============================================================
-- SAFE ZONE RESOURCES
-- ============================================================

-- === HAVEN MINE (copper + iron rocks inside cave) ===
createResourceNode("CopperRock1", "Rock", Vector3.new(-105, 0, 20), resourceFolder, 1, "Copper Ore", 20)
createResourceNode("CopperRock2", "Rock", Vector3.new(-100, 0, 10), resourceFolder, 1, "Copper Ore", 20)
createResourceNode("CopperRock3", "Rock", Vector3.new(-95, 0, 5), resourceFolder, 1, "Copper Ore", 20)
createResourceNode("CopperRock4", "Rock", Vector3.new(-88, 0, 15), resourceFolder, 1, "Copper Ore", 20)
createResourceNode("CopperRock5", "Rock", Vector3.new(-82, 0, 8), resourceFolder, 1, "Copper Ore", 20)

createResourceNode("IronRock1", "Rock", Vector3.new(-105, 0, 3), resourceFolder, 15, "Iron Ore", 35)
createResourceNode("IronRock2", "Rock", Vector3.new(-85, 0, 2), resourceFolder, 15, "Iron Ore", 35)
createResourceNode("IronRock3", "Rock", Vector3.new(-93, 0, 0), resourceFolder, 15, "Iron Ore", 35)

-- A few rocks outside the mine too
createResourceNode("CopperRockOutside1", "Rock", Vector3.new(-80, 0, 40), resourceFolder, 1, "Copper Ore", 20)
createResourceNode("IronRockOutside1", "Rock", Vector3.new(-75, 0, 50), resourceFolder, 15, "Iron Ore", 35)

-- === HAVEN FOREST (oak + willow trees) ===
createResourceNode("OakTree1", "Tree", Vector3.new(100, 0, 25), resourceFolder, 1, "Oak Log", 18)
createResourceNode("OakTree2", "Tree", Vector3.new(112, 0, 35), resourceFolder, 1, "Oak Log", 18)
createResourceNode("OakTree3", "Tree", Vector3.new(125, 0, 20), resourceFolder, 1, "Oak Log", 18)
createResourceNode("OakTree4", "Tree", Vector3.new(108, 0, 45), resourceFolder, 1, "Oak Log", 18)
createResourceNode("OakTree5", "Tree", Vector3.new(135, 0, 50), resourceFolder, 1, "Oak Log", 18)
createResourceNode("OakTree6", "Tree", Vector3.new(140, 0, 30), resourceFolder, 1, "Oak Log", 18)

createResourceNode("WillowTree1", "Tree", Vector3.new(150, 0, 25), resourceFolder, 20, "Willow Log", 40)
createResourceNode("WillowTree2", "Tree", Vector3.new(155, 0, 45), resourceFolder, 20, "Willow Log", 40)
createResourceNode("WillowTree3", "Tree", Vector3.new(145, 0, 60), resourceFolder, 20, "Willow Log", 40)

-- === HAVEN POND (shrimp + trout fishing) ===
createResourceNode("ShrimpSpot1", "FishingSpot", Vector3.new(75, 0, 82), resourceFolder, 1, "Shrimp", 15)
createResourceNode("ShrimpSpot2", "FishingSpot", Vector3.new(85, 0, 78), resourceFolder, 1, "Shrimp", 15)
createResourceNode("ShrimpSpot3", "FishingSpot", Vector3.new(80, 0, 88), resourceFolder, 1, "Shrimp", 15)
createResourceNode("TroutSpot1", "FishingSpot", Vector3.new(72, 0, 75), resourceFolder, 20, "Trout", 35)
createResourceNode("TroutSpot2", "FishingSpot", Vector3.new(88, 0, 85), resourceFolder, 20, "Trout", 35)

-- Lily pond has trout too
createResourceNode("TroutSpot3", "FishingSpot", Vector3.new(108, 0, 58), resourceFolder, 20, "Trout", 35)
createResourceNode("TroutSpot4", "FishingSpot", Vector3.new(114, 0, 62), resourceFolder, 20, "Trout", 35)

-- ============================================================
-- WILDERNESS RESOURCES — better loot, more risk
-- ============================================================

-- Gold Rocks (scattered in mid-wilderness)
createResourceNode("GoldRock1", "Rock", Vector3.new(30, 0, -130), resourceFolder, 40, "Gold Ore", 65)
createResourceNode("GoldRock2", "Rock", Vector3.new(45, 0, -145), resourceFolder, 40, "Gold Ore", 65)
createResourceNode("GoldRock3", "Rock", Vector3.new(-20, 0, -135), resourceFolder, 40, "Gold Ore", 65)

-- Runite Rocks (deep wilderness — high risk, high reward)
createResourceNode("RuniteRock1", "Rock", Vector3.new(55, 0, -200), resourceFolder, 70, "Runite Ore", 125)
createResourceNode("RuniteRock2", "Rock", Vector3.new(-40, 0, -230), resourceFolder, 70, "Runite Ore", 125)
createResourceNode("RuniteRock3", "Rock", Vector3.new(10, 0, -270), resourceFolder, 70, "Runite Ore", 125)

-- Yew Trees (mid wilderness)
createResourceNode("YewTree1", "Tree", Vector3.new(-30, 0, -130), resourceFolder, 50, "Yew Log", 80)
createResourceNode("YewTree2", "Tree", Vector3.new(-45, 0, -155), resourceFolder, 50, "Yew Log", 80)
createResourceNode("YewTree3", "Tree", Vector3.new(40, 0, -140), resourceFolder, 50, "Yew Log", 80)

-- Magic Trees (deep wilderness — rarest resource)
createResourceNode("MagicTree1", "Tree", Vector3.new(-55, 0, -205), resourceFolder, 75, "Magic Log", 150)
createResourceNode("MagicTree2", "Tree", Vector3.new(70, 0, -240), resourceFolder, 75, "Magic Log", 150)

-- Lobster Spots (mid wilderness)
createResourceNode("LobsterSpot1", "FishingSpot", Vector3.new(20, 0, -140), resourceFolder, 40, "Lobster", 60)
createResourceNode("LobsterSpot2", "FishingSpot", Vector3.new(-15, 0, -150), resourceFolder, 40, "Lobster", 60)

-- Dark Crab (deep wilderness dark pond)
createResourceNode("DarkCrabSpot1", "FishingSpot", Vector3.new(-55, 0, -208), resourceFolder, 70, "Dark Crab", 130)
createResourceNode("DarkCrabSpot2", "FishingSpot", Vector3.new(-65, 0, -214), resourceFolder, 70, "Dark Crab", 130)

local totalNodes = 0
for _, _ in ipairs(resourceFolder:GetChildren()) do totalNodes = totalNodes + 1 end
print("[SkillManager] Resource nodes spawned - " .. totalNodes .. " nodes total")
