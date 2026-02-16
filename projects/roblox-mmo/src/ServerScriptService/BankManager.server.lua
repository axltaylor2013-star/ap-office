-- BankManager.server.lua
-- Bank NPC + deposit/withdraw system

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local DataManager = require(ReplicatedStorage.Modules.DataManager)
local Config = require(ReplicatedStorage.Modules.Config)

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)

-- Create bank remotes
local bankOpenRemote = Instance.new("RemoteEvent")
bankOpenRemote.Name = "BankOpen"
bankOpenRemote.Parent = Remotes

local bankActionRemote = Instance.new("RemoteEvent")
bankActionRemote.Name = "BankAction"
bankActionRemote.Parent = Remotes

local bankUpdateRemote = Instance.new("RemoteEvent")
bankUpdateRemote.Name = "BankUpdate"
bankUpdateRemote.Parent = Remotes

-- === CREATE BANK NPC ===
task.wait(3) -- wait for MapSetup

local function createBankNPC()
	local safeZone = Workspace:FindFirstChild("SafeZone")
	if not safeZone then
		safeZone = Instance.new("Folder")
		safeZone.Name = "SafeZone"
		safeZone.Parent = Workspace
	end

	-- NPC body (positioned inside bank building at x=20, z=20)
	local npcModel = Instance.new("Model")
	npcModel.Name = "BankNPC"
	npcModel.Parent = safeZone

	-- Torso (main body)
	local torso = Instance.new("Part")
	torso.Name = "HumanoidRootPart"
	torso.Size = Vector3.new(2, 2, 1)
	torso.Position = Vector3.new(35, 1.5, 50)
	torso.Anchored = true
	torso.CanCollide = true
	torso.BrickColor = BrickColor.new("Bright blue")
	torso.Material = Enum.Material.SmoothPlastic
	torso.Parent = npcModel

	-- Head
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(1.5, 1.5, 1.5)
	head.Position = Vector3.new(35, 3, 50)
	head.Anchored = true
	head.CanCollide = false
	head.BrickColor = BrickColor.new("Light orange")
	head.Material = Enum.Material.SmoothPlastic
	head.Parent = npcModel

	-- Hat (banker hat)
	local hat = Instance.new("Part")
	hat.Name = "Hat"
	hat.Size = Vector3.new(2, 0.5, 2)
	hat.Position = Vector3.new(35, 3.8, 50)
	hat.Anchored = true
	hat.CanCollide = false
	hat.BrickColor = BrickColor.new("Dark stone grey")
	hat.Material = Enum.Material.SmoothPlastic
	hat.Parent = npcModel

	-- Legs
	local leftLeg = Instance.new("Part")
	leftLeg.Name = "LeftLeg"
	leftLeg.Size = Vector3.new(0.8, 1, 0.8)
	leftLeg.Position = Vector3.new(19.5, 0.25, 20)
	leftLeg.Anchored = true
	leftLeg.CanCollide = false
	leftLeg.BrickColor = BrickColor.new("Dark stone grey")
	leftLeg.Material = Enum.Material.SmoothPlastic
	leftLeg.Parent = npcModel

	local rightLeg = Instance.new("Part")
	rightLeg.Name = "RightLeg"
	rightLeg.Size = Vector3.new(0.8, 1, 0.8)
	rightLeg.Position = Vector3.new(20.5, 0.25, 20)
	rightLeg.Anchored = true
	rightLeg.CanCollide = false
	rightLeg.BrickColor = BrickColor.new("Dark stone grey")
	rightLeg.Material = Enum.Material.SmoothPlastic
	rightLeg.Parent = npcModel

	-- Arms
	local leftArm = Instance.new("Part")
	leftArm.Name = "LeftArm"
	leftArm.Size = Vector3.new(0.6, 1.8, 0.6)
	leftArm.Position = Vector3.new(18.7, 1.5, 20)
	leftArm.Anchored = true
	leftArm.CanCollide = false
	leftArm.BrickColor = BrickColor.new("Bright blue")
	leftArm.Material = Enum.Material.SmoothPlastic
	leftArm.Parent = npcModel

	local rightArm = Instance.new("Part")
	rightArm.Name = "RightArm"
	rightArm.Size = Vector3.new(0.6, 1.8, 0.6)
	rightArm.Position = Vector3.new(21.3, 1.5, 20)
	rightArm.Anchored = true
	rightArm.CanCollide = false
	rightArm.BrickColor = BrickColor.new("Bright blue")
	rightArm.Material = Enum.Material.SmoothPlastic
	rightArm.Parent = npcModel

	-- Bank booth (counter)
	local counter = Instance.new("Part")
	counter.Name = "BankCounter"
	counter.Size = Vector3.new(6, 3, 2)
	counter.Position = Vector3.new(35, 1.5, 48)
	counter.Anchored = true
	counter.CanCollide = true
	counter.BrickColor = BrickColor.new("Reddish brown")
	counter.Material = Enum.Material.Wood
	counter.Parent = safeZone

	-- Counter top
	local counterTop = Instance.new("Part")
	counterTop.Name = "CounterTop"
	counterTop.Size = Vector3.new(6.5, 0.3, 2.5)
	counterTop.Position = Vector3.new(35, 3.15, 48)
	counterTop.Anchored = true
	counterTop.CanCollide = true
	counterTop.BrickColor = BrickColor.new("Dark stone grey")
	counterTop.Material = Enum.Material.Marble
	counterTop.Parent = safeZone

	-- Gold bars on counter (decoration)
	local goldStack = Instance.new("Part")
	goldStack.Name = "GoldBars"
	goldStack.Size = Vector3.new(1, 0.5, 0.5)
	goldStack.Position = Vector3.new(36.5, 3.55, 48)
	goldStack.Anchored = true
	goldStack.CanCollide = false
	goldStack.BrickColor = BrickColor.new("Bright yellow")
	goldStack.Material = Enum.Material.Neon
	goldStack.Transparency = 0.1
	goldStack.Parent = safeZone

	-- NPC Name billboard
	local nameBillboard = Instance.new("BillboardGui")
	nameBillboard.Size = UDim2.new(6, 0, 1.5, 0)
	nameBillboard.StudsOffset = Vector3.new(0, 3, 0)
	nameBillboard.Parent = head

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = "ðŸ¦ Banker"
	nameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextStrokeTransparency = 0.5
	nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.Parent = nameBillboard

	local subLabel = Instance.new("TextLabel")
	subLabel.Size = UDim2.new(1, 0, 0.4, 0)
	subLabel.Position = UDim2.new(0, 0, 0.55, 0)
	subLabel.BackgroundTransparency = 1
	subLabel.Text = "Click to open bank"
	subLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	subLabel.TextScaled = true
	subLabel.Font = Enum.Font.Gotham
	subLabel.TextStrokeTransparency = 0.7
	subLabel.Parent = nameBillboard

	-- Click detector on torso
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 12
	clickDetector.Parent = torso

	-- Also add click detector to head for easier clicking
	local headClick = Instance.new("ClickDetector")
	headClick.MaxActivationDistance = 12
	headClick.Parent = head

	local function onBankClick(player)
		-- Only allow in safe zone
		local character = player.Character
		if character then
			local root = character:FindFirstChild("HumanoidRootPart")
			if root and root.Position.Z < -100 then
				-- In wilderness, can't use bank
				return
			end
		end

		local data = DataManager.GetData(player)
		if not data then return end

		-- Send bank data to client
		bankOpenRemote:FireClient(player, data.Bank, data.Inventory)
		print("[Bank] " .. player.Name .. " opened the bank")
	end

	clickDetector.MouseClick:Connect(onBankClick)
	headClick.MouseClick:Connect(onBankClick)

	print("[BankManager] Bank NPC created at safe zone")
	return npcModel
end

-- === HANDLE BANK ACTIONS ===
bankActionRemote.OnServerEvent:Connect(function(player, action, itemName, quantity)
	if not player or not action or not itemName then return end
	quantity = tonumber(quantity) or 1
	if quantity < 1 then return end

	local data = DataManager.GetData(player)
	if not data then return end

	local success = false

	if action == "deposit" then
		success = DataManager.DepositToBank(player, itemName, quantity)
		if success then
			print("[Bank] " .. player.Name .. " deposited " .. quantity .. "x " .. itemName)
		end
	elseif action == "withdraw" then
		success = DataManager.WithdrawFromBank(player, itemName, quantity)
		if success then
			print("[Bank] " .. player.Name .. " withdrew " .. quantity .. "x " .. itemName)
		end
	elseif action == "deposit_all" then
		-- Deposit entire inventory
		local deposited = 0
		-- Make a copy of inventory since we're modifying it
		local invCopy = {}
		for _, slot in ipairs(data.Inventory) do
			table.insert(invCopy, { name = slot.name, quantity = slot.quantity })
		end
		for _, slot in ipairs(invCopy) do
			if DataManager.DepositToBank(player, slot.name, slot.quantity) then
				deposited = deposited + slot.quantity
			end
		end
		success = deposited > 0
		if success then
			print("[Bank] " .. player.Name .. " deposited all (" .. deposited .. " items)")
		end
	end

	-- Send updated bank + inventory data back
	local updatedData = DataManager.GetData(player)
	bankUpdateRemote:FireClient(player, updatedData.Bank, updatedData.Inventory, success, action)

	-- Also update inventory UI
	local invRemote = Remotes:FindFirstChild("InventoryUpdate")
	if invRemote then
		invRemote:FireClient(player, updatedData.Inventory)
	end
end)

-- Create the NPC
createBankNPC()

print("[BankManager] Bank system active!")




