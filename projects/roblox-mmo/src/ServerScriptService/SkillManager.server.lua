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

-- Get gather feedback remote
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local gatherRemote = Remotes:WaitForChild("GatherFeedback", 10)

-- Skill mapping
local skillMap = {
	Rock = "Mining",
	Tree = "Woodcutting",
	FishingSpot = "Fishing",
}

-- === RESOURCE NODE SETUP ===
local function createResourceNode(name, nodeType, position, parent, levelReq, itemDrop, xpReward, quantity)
	-- Use a Model to group all parts together
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent

	local mainPart -- the part that gets the ClickDetector

	if nodeType == "Rock" then
		-- Determine ore color based on item drop
		local oreColors = {
			["Copper Ore"] = {main = Color3.fromRGB(140, 90, 50), vein = Color3.fromRGB(184, 115, 51)},
			["Iron Ore"] = {main = Color3.fromRGB(80, 80, 85), vein = Color3.fromRGB(160, 160, 170)},
			["Gold Ore"] = {main = Color3.fromRGB(100, 95, 75), vein = Color3.fromRGB(218, 165, 32)},
			["Runite Ore"] = {main = Color3.fromRGB(50, 80, 80), vein = Color3.fromRGB(0, 170, 170)},
		}
		local colors = oreColors[itemDrop] or {main = Color3.fromRGB(90, 90, 90), vein = Color3.fromRGB(150, 150, 150)}

		mainPart = Instance.new("Part")
		mainPart.Name = "Rock"
		mainPart.Size = Vector3.new(3, 2.5, 3)
		mainPart.Position = position + Vector3.new(0, 1.25, 0)
		mainPart.Anchored = true
		mainPart.CanCollide = true
		mainPart.Color = colors.main
		mainPart.Material = Enum.Material.Slate
		mainPart.Parent = model

		-- Smaller rock next to it
		local rock2 = Instance.new("Part")
		rock2.Name = "RockSmall"
		rock2.Size = Vector3.new(1.8, 1.6, 1.8)
		rock2.Position = position + Vector3.new(2, 0.8, 0.8)
		rock2.Anchored = true
		rock2.CanCollide = true
		rock2.Color = colors.main
		rock2.Material = Enum.Material.Rock
		rock2.Parent = model

		-- Colored ore vein on surface
		local vein = Instance.new("Part")
		vein.Name = "OreVein"
		vein.Size = Vector3.new(1.2, 0.8, 0.2)
		vein.Position = position + Vector3.new(0, 1.5, 1.5)
		vein.Anchored = true
		vein.CanCollide = false
		vein.Color = colors.vein
		vein.Material = Enum.Material.SmoothPlastic
		vein.Parent = model

	elseif nodeType == "Tree" then
		-- Determine tree size based on item drop
		local treeSizes = {
			["Oak Log"] = {trunk = Vector3.new(1.5, 6, 1.5), canopy = Vector3.new(5, 4, 5), canopyY = 7, glow = false},
			["Willow Log"] = {trunk = Vector3.new(1.8, 7, 1.8), canopy = Vector3.new(6, 4.5, 6), canopyY = 8, glow = false},
			["Yew Log"] = {trunk = Vector3.new(2, 8, 2), canopy = Vector3.new(7, 5, 7), canopyY = 9, glow = false},
			["Magic Log"] = {trunk = Vector3.new(2.2, 10, 2.2), canopy = Vector3.new(8, 6, 8), canopyY = 11, glow = true},
		}
		local treeInfo = treeSizes[itemDrop] or treeSizes["Oak Log"]

		-- Trunk
		mainPart = Instance.new("Part")
		mainPart.Name = "Trunk"
		mainPart.Size = treeInfo.trunk
		mainPart.Position = position + Vector3.new(0, treeInfo.trunk.Y / 2, 0)
		mainPart.Anchored = true
		mainPart.CanCollide = true
		mainPart.Color = Color3.fromRGB(101, 67, 33)
		mainPart.Material = Enum.Material.Wood
		mainPart.Parent = model

		-- Canopy
		local leaves = Instance.new("Part")
		leaves.Name = "Leaves"
		leaves.Shape = Enum.PartType.Ball
		leaves.Size = treeInfo.canopy
		leaves.Position = position + Vector3.new(0, treeInfo.canopyY, 0)
		leaves.Anchored = true
		leaves.CanCollide = false
		leaves.Color = Color3.fromRGB(34, 100, 34)
		leaves.Material = Enum.Material.Grass
		leaves.Parent = model

		-- Magic trees get a subtle glow
		if treeInfo.glow then
			local glow = Instance.new("PointLight")
			glow.Color = Color3.fromRGB(100, 200, 255)
			glow.Brightness = 1.5
			glow.Range = 14
			glow.Parent = leaves
		end

		-- ClickDetector on leaves too (increased range)
		local leavesClick = Instance.new("ClickDetector")
		leavesClick.MaxActivationDistance = 25
		leavesClick.Parent = leaves
		leaves:SetAttribute("IsGatherNode", true)

	elseif nodeType == "FishingSpot" then
		-- Transparent blue ring on water surface
		mainPart = Instance.new("Part")
		mainPart.Name = "FishingSpot"
		mainPart.Shape = Enum.PartType.Cylinder
		mainPart.Size = Vector3.new(0.3, 6, 6)
		mainPart.CFrame = CFrame.new(position + Vector3.new(0, 0.15, 0)) * CFrame.Angles(0, 0, math.rad(90))
		mainPart.Anchored = true
		mainPart.CanCollide = false
		mainPart.Color = Color3.fromRGB(65, 130, 175)
		mainPart.Material = Enum.Material.Water
		mainPart.Transparency = 0.5
		mainPart.Parent = model

		-- Bobber (small bright sphere)
		local bobber = Instance.new("Part")
		bobber.Name = "Bobber"
		bobber.Shape = Enum.PartType.Ball
		bobber.Size = Vector3.new(0.8, 0.8, 0.8)
		bobber.Position = position + Vector3.new(0, 0.6, 0)
		bobber.Anchored = true
		bobber.CanCollide = false
		bobber.Color = Color3.fromRGB(255, 80, 20)
		bobber.Material = Enum.Material.SmoothPlastic
		bobber.Parent = model

		-- Splash particle effect
		local emitter = Instance.new("ParticleEmitter")
		emitter.Color = ColorSequence.new(Color3.fromRGB(200, 220, 255))
		emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 0)})
		emitter.Lifetime = NumberRange.new(0.3, 0.8)
		emitter.Rate = 5
		emitter.Speed = NumberRange.new(1, 3)
		emitter.SpreadAngle = Vector2.new(30, 30)
		emitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)})
		emitter.Parent = bobber
	end

	if not mainPart then
		warn("[SkillManager] Failed to create main part for " .. name)
		return
	end

	-- ClickDetector on main part (increased range for easier clicking)
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 25
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
	label.TextColor3 = Color3.fromRGB(255, 223, 120)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextStrokeTransparency = 0.5
	label.Parent = billboard

	-- Tool type required per node type
	local toolRequired = {Rock = "pickaxe", Tree = "axe", FishingSpot = "fishing_rod"}

	-- Track who is currently gathering this node
	local gatheringPlayers = {}

	-- Helper: find best tool for this node
	local function findTool(player, requiredToolType)
		local playerLevel = DataManager.GetSkillLevel(player, skillMap[nodeType])
		local data = DataManager:GetData(player)
		if not data then return false, 1.0 end

		-- Check equipped tool first
		local equippedTool = data.Equipment and data.Equipment.Tool or ""
		if equippedTool ~= "" then
			local toolInfo = ItemDB.GetItem(equippedTool)
			if toolInfo and toolInfo.toolType == requiredToolType and playerLevel >= (toolInfo.levelReq or 1) then
				return true, toolInfo.gatherSpeed or 1.0
			end
		end

		-- Check inventory for best tool
		if data.Inventory then
			local bestSpeed = 999
			local found = false
			for _, slot in ipairs(data.Inventory) do
				local itemInfo = ItemDB.GetItem(slot.name)
				if itemInfo and itemInfo.toolType == requiredToolType and playerLevel >= (itemInfo.levelReq or 1) then
					local spd = itemInfo.gatherSpeed or 1.0
					if spd < bestSpeed then
						bestSpeed = spd
						found = true
					end
				end
			end
			if found then return true, bestSpeed end
		end

		return false, 1.0
	end

	-- Helper: do one gather cycle, returns true if should continue
	local function doOneGather(player, toolSpeed)
		local skill = skillMap[nodeType]
		local playerLevel = DataManager.GetSkillLevel(player, skill)

		-- Calculate gather time
		local baseTime = 2 + (levelReq / 15)
		local gatherTime = baseTime * toolSpeed
		local levelBonus = math.min(0.3, (playerLevel - levelReq) * 0.005)
		gatherTime = gatherTime * (1 - levelBonus)
		gatherTime = math.max(1, gatherTime)

		-- Tell client gathering started
		gatherRemote:FireClient(player, "start", itemDrop, gatherTime)

		-- Wait for gather time, checking player stays near
		local startPos = model.PrimaryPart and model.PrimaryPart.Position or model:GetChildren()[1].Position
		local elapsed = 0
		while elapsed < gatherTime do
			task.wait(0.25)
			elapsed = elapsed + 0.25
			local char = player.Character
			if not char then return false end
			local root = char:FindFirstChild("HumanoidRootPart")
			if not root or (root.Position - startPos).Magnitude > 20 then return false end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if not hum or hum.Health <= 0 then return false end
		end

		-- Check inventory space
		local added = DataManager.AddToInventory(player, itemDrop, 1)
		if not added then
			gatherRemote:FireClient(player, "full", itemDrop, 0)
			return false
		end

		-- Award XP
		DataManager.AddSkillXP(player, skill, xpReward)

		-- Notify client
		gatherRemote:FireClient(player, "gather", itemDrop, xpReward)

		-- Update client inventory
		local invRemote = Remotes:FindFirstChild("InventoryUpdate")
		if invRemote then
			local data = DataManager:GetData(player)
			if data and data.Inventory then
				invRemote:FireClient(player, data.Inventory)
			end
		end

		return true -- keep going
	end

	-- Gather handler — click once, auto-repeats until full/walk away/die
	local function onGather(player)
		if gatheringPlayers[player.UserId] then return end -- already gathering here

		local skill = skillMap[nodeType]
		if not skill then return end

		-- Check level requirement
		local playerLevel = DataManager.GetSkillLevel(player, skill)
		if playerLevel < levelReq then
			gatherRemote:FireClient(player, "level", itemDrop, levelReq)
			return
		end

		-- Check for required tool
		local requiredToolType = toolRequired[nodeType]
		local hasTool, toolSpeed = findTool(player, requiredToolType)

		if not hasTool then
			local toolNames = {pickaxe = "pickaxe", axe = "axe", fishing_rod = "fishing rod"}
			gatherRemote:FireClient(player, "notool", toolNames[requiredToolType] or "tool", 0)
			return
		end

		-- Mark player as gathering
		gatheringPlayers[player.UserId] = true

		-- Auto-gather loop — keeps going until interrupted
		task.spawn(function()
			while gatheringPlayers[player.UserId] do
				-- Re-check tool each cycle (might break or get dropped)
				local stillHasTool, currentSpeed = findTool(player, requiredToolType)
				if not stillHasTool then
					local toolNames = {pickaxe = "pickaxe", axe = "axe", fishing_rod = "fishing rod"}
					gatherRemote:FireClient(player, "notool", toolNames[requiredToolType] or "tool", 0)
					break
				end

				local keepGoing = doOneGather(player, currentSpeed)
				if not keepGoing then break end

				-- Small pause between gathers
				task.wait(0.5)
			end
			gatheringPlayers[player.UserId] = nil
			gatherRemote:FireClient(player, "stop", itemDrop, 0)
		end)
	end

	-- Stop gathering if player clicks again (toggle off)
	local function onClickToggle(player)
		if gatheringPlayers[player.UserId] then
			-- Already gathering — stop
			gatheringPlayers[player.UserId] = nil
			return
		end
		-- Not gathering — start
		onGather(player)
	end

	-- Connect main click (toggle: click to start, click again to stop)
	clickDetector.MouseClick:Connect(onClickToggle)

	-- Connect leaf clicks for trees
	if nodeType == "Tree" then
		for _, child in ipairs(model:GetChildren()) do
			local childClick = child:FindFirstChild("ClickDetector")
			if childClick and child ~= mainPart then
				childClick.MouseClick:Connect(onClickToggle)
			end
		end
	end

	-- Stop gathering if player dies or leaves
	Players.PlayerRemoving:Connect(function(p)
		gatheringPlayers[p.UserId] = nil
	end)

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
createResourceNode("CopperRock1", "Rock", Vector3.new(-105, 0, 20), resourceFolder, 1, "Copper Ore", 20, 5)
createResourceNode("CopperRock2", "Rock", Vector3.new(-100, 0, 10), resourceFolder, 1, "Copper Ore", 20, 4)
createResourceNode("CopperRock3", "Rock", Vector3.new(-95, 0, 5), resourceFolder, 1, "Copper Ore", 20, 3)
createResourceNode("CopperRock4", "Rock", Vector3.new(-88, 0, 15), resourceFolder, 1, "Copper Ore", 20, 6)
createResourceNode("CopperRock5", "Rock", Vector3.new(-82, 0, 8), resourceFolder, 1, "Copper Ore", 20, 4)

createResourceNode("IronRock1", "Rock", Vector3.new(-105, 0, 3), resourceFolder, 15, "Iron Ore", 35, 3)
createResourceNode("IronRock2", "Rock", Vector3.new(-85, 0, 2), resourceFolder, 15, "Iron Ore", 35, 4)
createResourceNode("IronRock3", "Rock", Vector3.new(-93, 0, 0), resourceFolder, 15, "Iron Ore", 35, 3)

-- A few rocks outside the mine too
createResourceNode("CopperRockOutside1", "Rock", Vector3.new(-80, 0, 40), resourceFolder, 1, "Copper Ore", 20, 3)
createResourceNode("IronRockOutside1", "Rock", Vector3.new(-75, 0, 50), resourceFolder, 15, "Iron Ore", 35, 2)

-- === HAVEN FOREST (oak + willow trees) ===
createResourceNode("OakTree1", "Tree", Vector3.new(100, 0, 25), resourceFolder, 1, "Oak Log", 18, 4)
createResourceNode("OakTree2", "Tree", Vector3.new(112, 0, 35), resourceFolder, 1, "Oak Log", 18, 5)
createResourceNode("OakTree3", "Tree", Vector3.new(125, 0, 20), resourceFolder, 1, "Oak Log", 18, 3)
createResourceNode("OakTree4", "Tree", Vector3.new(108, 0, 45), resourceFolder, 1, "Oak Log", 18, 6)
createResourceNode("OakTree5", "Tree", Vector3.new(135, 0, 50), resourceFolder, 1, "Oak Log", 18, 4)
createResourceNode("OakTree6", "Tree", Vector3.new(140, 0, 30), resourceFolder, 1, "Oak Log", 18, 5)

createResourceNode("WillowTree1", "Tree", Vector3.new(150, 0, 25), resourceFolder, 20, "Willow Log", 40, 3)
createResourceNode("WillowTree2", "Tree", Vector3.new(155, 0, 45), resourceFolder, 20, "Willow Log", 40, 4)
createResourceNode("WillowTree3", "Tree", Vector3.new(145, 0, 60), resourceFolder, 20, "Willow Log", 40, 3)

-- === HAVEN POND (shrimp + trout fishing) ===
createResourceNode("ShrimpSpot1", "FishingSpot", Vector3.new(75, 0, 82), resourceFolder, 1, "Shrimp", 15, 6)
createResourceNode("ShrimpSpot2", "FishingSpot", Vector3.new(85, 0, 78), resourceFolder, 1, "Shrimp", 15, 5)
createResourceNode("ShrimpSpot3", "FishingSpot", Vector3.new(80, 0, 88), resourceFolder, 1, "Shrimp", 15, 7)
createResourceNode("TroutSpot1", "FishingSpot", Vector3.new(72, 0, 75), resourceFolder, 20, "Trout", 35, 4)
createResourceNode("TroutSpot2", "FishingSpot", Vector3.new(88, 0, 85), resourceFolder, 20, "Trout", 35, 3)

-- Lily pond has trout too
createResourceNode("TroutSpot3", "FishingSpot", Vector3.new(108, 0, 58), resourceFolder, 20, "Trout", 35, 4)
createResourceNode("TroutSpot4", "FishingSpot", Vector3.new(114, 0, 62), resourceFolder, 20, "Trout", 35, 5)

-- ============================================================
-- WILDERNESS RESOURCES — better loot, more risk
-- ============================================================

-- Gold Rocks (scattered in mid-wilderness)
createResourceNode("GoldRock1", "Rock", Vector3.new(30, 0, -130), resourceFolder, 40, "Gold Ore", 65, 3)
createResourceNode("GoldRock2", "Rock", Vector3.new(45, 0, -145), resourceFolder, 40, "Gold Ore", 65, 2)
createResourceNode("GoldRock3", "Rock", Vector3.new(-20, 0, -135), resourceFolder, 40, "Gold Ore", 65, 4)

-- Runite Rocks (deep wilderness — high risk, high reward)
createResourceNode("RuniteRock1", "Rock", Vector3.new(55, 0, -200), resourceFolder, 70, "Runite Ore", 125, 2)
createResourceNode("RuniteRock2", "Rock", Vector3.new(-40, 0, -230), resourceFolder, 70, "Runite Ore", 125, 2)
createResourceNode("RuniteRock3", "Rock", Vector3.new(10, 0, -270), resourceFolder, 70, "Runite Ore", 125, 3)

-- Yew Trees (mid wilderness)
createResourceNode("YewTree1", "Tree", Vector3.new(-30, 0, -130), resourceFolder, 50, "Yew Log", 80, 3)
createResourceNode("YewTree2", "Tree", Vector3.new(-45, 0, -155), resourceFolder, 50, "Yew Log", 80, 4)
createResourceNode("YewTree3", "Tree", Vector3.new(40, 0, -140), resourceFolder, 50, "Yew Log", 80, 3)

-- Magic Trees (deep wilderness — rarest resource)
createResourceNode("MagicTree1", "Tree", Vector3.new(-55, 0, -205), resourceFolder, 75, "Magic Log", 150, 2)
createResourceNode("MagicTree2", "Tree", Vector3.new(70, 0, -240), resourceFolder, 75, "Magic Log", 150, 2)

-- Lobster Spots (mid wilderness)
createResourceNode("LobsterSpot1", "FishingSpot", Vector3.new(20, 0, -140), resourceFolder, 40, "Lobster", 60, 4)
createResourceNode("LobsterSpot2", "FishingSpot", Vector3.new(-15, 0, -150), resourceFolder, 40, "Lobster", 60, 3)

-- Dark Crab (deep wilderness dark pond)
createResourceNode("DarkCrabSpot1", "FishingSpot", Vector3.new(-55, 0, -208), resourceFolder, 70, "Dark Crab", 130, 2)
createResourceNode("DarkCrabSpot2", "FishingSpot", Vector3.new(-65, 0, -214), resourceFolder, 70, "Dark Crab", 130, 3)

-- ============================================================
-- NEW AREA RESOURCES
-- ============================================================

-- === HAVEN LAKE (fishing) ===
createResourceNode("LakeShrimpSpot1", "FishingSpot", Vector3.new(-140, 0, 155), resourceFolder, 1, "Shrimp", 15, 8)
createResourceNode("LakeShrimpSpot2", "FishingSpot", Vector3.new(-160, 0, 160), resourceFolder, 1, "Shrimp", 15, 6)
createResourceNode("LakeTroutSpot1", "FishingSpot", Vector3.new(-145, 0, 145), resourceFolder, 20, "Trout", 35, 4)
createResourceNode("LakeTroutSpot2", "FishingSpot", Vector3.new(-130, 0, 150), resourceFolder, 20, "Trout", 35, 5)
createResourceNode("LakeTroutSpot3", "FishingSpot", Vector3.new(-165, 0, 148), resourceFolder, 20, "Trout", 35, 3)

-- === ANCIENT GROVE (willow trees among the ancient ones) ===
createResourceNode("GroveWillow1", "Tree", Vector3.new(-190, 0, 20), resourceFolder, 20, "Willow Log", 40, 4)
createResourceNode("GroveWillow2", "Tree", Vector3.new(-170, 0, 40), resourceFolder, 20, "Willow Log", 40, 3)
createResourceNode("GroveWillow3", "Tree", Vector3.new(-150, 0, 10), resourceFolder, 20, "Willow Log", 40, 5)
createResourceNode("GroveOak1", "Tree", Vector3.new(-200, 0, -10), resourceFolder, 1, "Oak Log", 18, 5)
createResourceNode("GroveOak2", "Tree", Vector3.new(-230, 0, 30), resourceFolder, 1, "Oak Log", 18, 4)

-- === FARMLANDS (a few rocks in the fields) ===
createResourceNode("FarmCopper1", "Rock", Vector3.new(220, 0, 160), resourceFolder, 1, "Copper Ore", 20, 4)
createResourceNode("FarmCopper2", "Rock", Vector3.new(200, 0, 190), resourceFolder, 1, "Copper Ore", 20, 5)

-- === DRAGON'S SPINE (deep wilderness mining — gold + runite) ===
createResourceNode("MtnGold1", "Rock", Vector3.new(-140, 2, -290), resourceFolder, 40, "Gold Ore", 65, 3)
createResourceNode("MtnGold2", "Rock", Vector3.new(-110, 2, -310), resourceFolder, 40, "Gold Ore", 65, 4)
createResourceNode("MtnRunite1", "Rock", Vector3.new(-130, 2, -340), resourceFolder, 70, "Runite Ore", 125, 2)
createResourceNode("MtnRunite2", "Rock", Vector3.new(-100, 2, -350), resourceFolder, 70, "Runite Ore", 125, 3)

-- === CURSED SWAMP (dark crabs + lobsters) ===
createResourceNode("SwampLobster1", "FishingSpot", Vector3.new(100, 0, -310), resourceFolder, 40, "Lobster", 60, 4)
createResourceNode("SwampLobster2", "FishingSpot", Vector3.new(130, 0, -330), resourceFolder, 40, "Lobster", 60, 3)
createResourceNode("SwampDarkCrab1", "FishingSpot", Vector3.new(150, 0, -350), resourceFolder, 70, "Dark Crab", 130, 2)

-- === DARK FOREST (yew + magic trees) ===
createResourceNode("DFYew1", "Tree", Vector3.new(100, 0, -160), resourceFolder, 50, "Yew Log", 80, 3)
createResourceNode("DFYew2", "Tree", Vector3.new(150, 0, -180), resourceFolder, 50, "Yew Log", 80, 4)
createResourceNode("DFMagic1", "Tree", Vector3.new(130, 0, -200), resourceFolder, 75, "Magic Log", 150, 2)

-- === THE ABYSS (runite rocks — highest risk/reward) ===
createResourceNode("AbyssRunite1", "Rock", Vector3.new(-30, 0, -460), resourceFolder, 70, "Runite Ore", 125, 3)
createResourceNode("AbyssRunite2", "Rock", Vector3.new(30, 0, -480), resourceFolder, 70, "Runite Ore", 125, 2)
createResourceNode("AbyssRunite3", "Rock", Vector3.new(0, 0, -500), resourceFolder, 70, "Runite Ore", 125, 4)

-- === NEW THEMED AREAS (MapSetup4) ===
-- ============================================================

-- === WHISPERING WOODS (X: 200-350, Z: 50-200) - Woodcutting ===
createResourceNode("WWOak1", "Tree", Vector3.new(220, 0, 70), resourceFolder, 1, "Oak Log", 18, 5)
createResourceNode("WWOak2", "Tree", Vector3.new(250, 0, 90), resourceFolder, 1, "Oak Log", 18, 4)
createResourceNode("WWOak3", "Tree", Vector3.new(280, 0, 120), resourceFolder, 1, "Oak Log", 18, 6)
createResourceNode("WWOak4", "Tree", Vector3.new(310, 0, 150), resourceFolder, 1, "Oak Log", 18, 5)
createResourceNode("WWWillow1", "Tree", Vector3.new(230, 0, 110), resourceFolder, 20, "Willow Log", 40, 4)
createResourceNode("WWWillow2", "Tree", Vector3.new(270, 0, 160), resourceFolder, 20, "Willow Log", 40, 3)
createResourceNode("WWWillow3", "Tree", Vector3.new(320, 0, 180), resourceFolder, 20, "Willow Log", 40, 4)

-- === DEEP MINE (X: -300 to -200, Z: -50 to 50) - Mining ===
createResourceNode("DMCopper1", "Rock", Vector3.new(-280, 0, -30), resourceFolder, 1, "Copper Ore", 20, 6)
createResourceNode("DMCopper2", "Rock", Vector3.new(-260, 0, -10), resourceFolder, 1, "Copper Ore", 20, 5)
createResourceNode("DMCopper3", "Rock", Vector3.new(-240, 0, 20), resourceFolder, 1, "Copper Ore", 20, 4)
createResourceNode("DMIron1", "Rock", Vector3.new(-290, 0, 10), resourceFolder, 15, "Iron Ore", 35, 4)
createResourceNode("DMIron2", "Rock", Vector3.new(-270, 0, 30), resourceFolder, 15, "Iron Ore", 35, 3)
createResourceNode("DMIron3", "Rock", Vector3.new(-220, 0, -20), resourceFolder, 15, "Iron Ore", 35, 4)
createResourceNode("DMGold1", "Rock", Vector3.new(-285, 0, 0), resourceFolder, 40, "Gold Ore", 65, 3)
createResourceNode("DMGold2", "Rock", Vector3.new(-250, 0, 40), resourceFolder, 40, "Gold Ore", 65, 2)

-- === CRYSTAL CAVERN (X: -350 to -250, Z: -150 to -80) - Mining ===
createResourceNode("CCGold1", "Rock", Vector3.new(-330, 0, -120), resourceFolder, 40, "Gold Ore", 65, 3)
createResourceNode("CCGold2", "Rock", Vector3.new(-300, 0, -100), resourceFolder, 40, "Gold Ore", 65, 4)
createResourceNode("CCRunite1", "Rock", Vector3.new(-320, 0, -140), resourceFolder, 70, "Runite Ore", 125, 2)
createResourceNode("CCRunite2", "Rock", Vector3.new(-280, 0, -120), resourceFolder, 70, "Runite Ore", 125, 3)

-- === MOONLIT POND (X: 250-320, Z: -50 to 20) - Fishing ===
createResourceNode("MPShrimp1", "FishingSpot", Vector3.new(270, 0, -30), resourceFolder, 1, "Shrimp", 15, 7)
createResourceNode("MPShrimp2", "FishingSpot", Vector3.new(290, 0, -10), resourceFolder, 1, "Shrimp", 15, 6)
createResourceNode("MPTrout1", "FishingSpot", Vector3.new(280, 0, 0), resourceFolder, 20, "Trout", 35, 5)
createResourceNode("MPTrout2", "FishingSpot", Vector3.new(300, 0, -20), resourceFolder, 20, "Trout", 35, 4)
createResourceNode("MPLobster1", "FishingSpot", Vector3.new(285, 0, -15), resourceFolder, 40, "Lobster", 60, 3)

-- === THORNWOOD THICKET (X: -200 to -100, Z: 200-350) - Woodcutting ===
createResourceNode("TTOak1", "Tree", Vector3.new(-180, 0, 220), resourceFolder, 1, "Oak Log", 18, 4)
createResourceNode("TTOak2", "Tree", Vector3.new(-150, 0, 250), resourceFolder, 1, "Oak Log", 18, 5)
createResourceNode("TTWillow1", "Tree", Vector3.new(-170, 0, 280), resourceFolder, 20, "Willow Log", 40, 3)
createResourceNode("TTWillow2", "Tree", Vector3.new(-130, 0, 310), resourceFolder, 20, "Willow Log", 40, 4)
createResourceNode("TTYew1", "Tree", Vector3.new(-160, 0, 330), resourceFolder, 50, "Yew Log", 80, 3)

-- === SUNFLOWER FIELDS (X: 100-250, Z: 250-380) - Low level nodes ===
createResourceNode("SFCopper1", "Rock", Vector3.new(130, 0, 280), resourceFolder, 1, "Copper Ore", 20, 4)
createResourceNode("SFCopper2", "Rock", Vector3.new(180, 0, 320), resourceFolder, 1, "Copper Ore", 20, 3)
createResourceNode("SFOak1", "Tree", Vector3.new(150, 0, 360), resourceFolder, 1, "Oak Log", 18, 5)
createResourceNode("SFOak2", "Tree", Vector3.new(200, 0, 340), resourceFolder, 1, "Oak Log", 18, 4)

-- === ABANDONED QUARRY (X: -150 to -50, Z: -250 to -150) - Mining ===
createResourceNode("AQIron1", "Rock", Vector3.new(-130, 0, -220), resourceFolder, 15, "Iron Ore", 35, 4)
createResourceNode("AQIron2", "Rock", Vector3.new(-100, 0, -200), resourceFolder, 15, "Iron Ore", 35, 3)
createResourceNode("AQIron3", "Rock", Vector3.new(-80, 0, -230), resourceFolder, 15, "Iron Ore", 35, 5)
createResourceNode("AQGold1", "Rock", Vector3.new(-120, 0, -180), resourceFolder, 40, "Gold Ore", 65, 3)
createResourceNode("AQGold2", "Rock", Vector3.new(-90, 0, -210), resourceFolder, 40, "Gold Ore", 65, 2)

local totalNodes = 0
for _, _ in ipairs(resourceFolder:GetChildren()) do totalNodes = totalNodes + 1 end
print("[SkillManager] Resource nodes spawned - " .. totalNodes .. " nodes total")
print("🔧 [FORCE RELOAD] SkillManager v2.0 LOADED - CASTING ERROR FIXED! - " .. tick())
