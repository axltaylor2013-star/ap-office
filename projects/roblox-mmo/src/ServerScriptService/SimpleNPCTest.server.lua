--[[
	SimpleNPCTest.server.lua
	Minimal NPC spawner to test if NPC creation works at all.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Wait a bit for game to load
task.wait(5)

print("[SimpleNPCTest] Starting NPC test...")

-- Try to get Remotes (but don't crash if they don't exist)
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not Remotes then
	print("[SimpleNPCTest] Warning: No Remotes folder found")
else
	print("[SimpleNPCTest] Remotes folder found")
end

-- Simple NPC creation function
local function createSimpleNPC(name, position)
	print("[SimpleNPCTest] Creating NPC:", name, "at", position)
	
	-- Create a simple NPC model
	local npcModel = Instance.new("Model")
	npcModel.Name = name
	npcModel.Parent = Workspace
	
	-- Create basic body parts
	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(2, 2, 1)
	torso.Position = position
	torso.Material = Enum.Material.SmoothPlastic
	torso.Color = Color3.fromRGB(245, 205, 148) -- Skin color
	torso.Anchored = true
	torso.Parent = npcModel
	
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(2, 1, 1)
	head.Position = position + Vector3.new(0, 2, 0)
	head.Material = Enum.Material.SmoothPlastic
	head.Color = Color3.fromRGB(245, 205, 148) -- Skin color
	head.Anchored = true
	head.Parent = npcModel
	
	-- Add name tag
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 100, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.Parent = head
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 1, 0)
	nameLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.BackgroundTransparency = 0.5
	nameLabel.Text = name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = billboard
	
	-- Add click detector
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 25
	clickDetector.Parent = torso
	
	clickDetector.MouseClick:Connect(function(player)
		print("[SimpleNPCTest]", player.Name, "clicked", name)
		
		-- Try to send a message to the player
		local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
		if Remotes then
			local NPCInteractEvent = Remotes:FindFirstChild("NPCInteract")
			if NPCInteractEvent then
				NPCInteractEvent:FireClient(player, {
					npcName = name,
					dialog = "Welcome to the bank! (This is a test NPC)"
				})
			end
		end
	end)
	
	print("[SimpleNPCTest] Created NPC:", name)
	return npcModel
end

-- Try to create one test NPC
pcall(function()
	local testNPC = createSimpleNPC("Test Banker", Vector3.new(10, 15, 10))
	if testNPC then
		print("[SimpleNPCTest] SUCCESS: Test NPC created!")
	else
		print("[SimpleNPCTest] FAILED: Could not create test NPC")
	end
end)

print("[SimpleNPCTest] Test complete")