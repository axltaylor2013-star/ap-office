--[[
	DropHandler.server.lua
	Handles dropping items from inventory onto the ground.
	Shift+click in inventory fires DropItem remote.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

task.wait(3)

local DataManager = require(ReplicatedStorage.Modules.DataManager)
local ItemDatabase = require(ReplicatedStorage.Modules.ItemDatabase)

local RARITY_COLORS = {
	common = Color3.fromRGB(157, 157, 157),
	uncommon = Color3.fromRGB(30, 255, 0),
	rare = Color3.fromRGB(0, 112, 221),
	epic = Color3.fromRGB(163, 53, 238),
	legendary = Color3.fromRGB(255, 128, 0),
}

local DESPAWN_TIME = 120 -- seconds before dropped items vanish

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local DropItemRemote = Remotes:WaitForChild("DropItem", 5)
local UseItemRemote = Remotes:WaitForChild("UseItem", 5)

DropItemRemote.OnServerEvent:Connect(function(player, itemName, qty)
	if type(itemName) ~= "string" or type(qty) ~= "number" then return end
	qty = math.max(1, math.floor(qty))

	-- Validate player has the item
	local data = DataManager:GetData(player)
	if not data or not data.Inventory then return end

	-- Find item in inventory
	local found = false
	for i, slot in ipairs(data.Inventory) do
		if slot.name == itemName then
			if slot.quantity and slot.quantity > 1 then
				slot.quantity = slot.quantity - qty
				if slot.quantity <= 0 then
					table.remove(data.Inventory, i)
				end
			else
				table.remove(data.Inventory, i)
			end
			found = true
			break
		end
	end

	if not found then return end

	-- Notify client of inventory update
	local invRemote = Remotes:FindFirstChild("InventoryUpdate")
	if invRemote then
		local data = DataManager:GetData(player)
		if data and data.Inventory then
			invRemote:FireClient(player, data.Inventory)
		end
	end

	-- Spawn the item on the ground near the player
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Drop position: in front of player, on the ground
	local dropPos = hrp.Position + hrp.CFrame.LookVector * 3
	dropPos = Vector3.new(dropPos.X, 0.6, dropPos.Z)

	local itemDef = ItemDatabase.Items and ItemDatabase.Items[itemName]
	local rarity = (itemDef and itemDef.rarity) or "common"

	local itemPart = Instance.new("Part")
	itemPart.Name = "DroppedItem_" .. itemName
	itemPart.Size = Vector3.new(1.2, 1.2, 1.2)
	itemPart.Shape = Enum.PartType.Block
	itemPart.Anchored = true
	itemPart.CanCollide = false
	itemPart.Position = dropPos
	itemPart.Material = Enum.Material.Neon
	itemPart.Color = RARITY_COLORS[rarity] or RARITY_COLORS.common
	itemPart.Parent = workspace

	-- Label
	local bbg = Instance.new("BillboardGui")
	bbg.Size = UDim2.new(5, 0, 1, 0)
	bbg.StudsOffset = Vector3.new(0, 1.5, 0)
	bbg.AlwaysOnTop = true
	bbg.Adornee = itemPart
	bbg.Parent = itemPart

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	local displayText = itemName
	if qty > 1 then displayText = displayText .. " x" .. qty end
	label.Text = displayText
	label.TextColor3 = RARITY_COLORS[rarity] or RARITY_COLORS.common
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.TextStrokeTransparency = 0
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = bbg

	-- Click to pick up (anyone can pick up dropped items)
	local click = Instance.new("ClickDetector")
	click.MaxActivationDistance = 14
	click.Parent = itemPart

	local picked = false
	click.MouseClick:Connect(function(picker)
		if picked then return end
		picked = true
		pcall(function()
			DataManager.AddToInventory(picker, itemName, qty)
		end)
		-- Notify client of inventory update
		local invRemote = Remotes:FindFirstChild("InventoryUpdate")
		if invRemote then
			invRemote:FireClient(picker)
		end
		TweenService:Create(itemPart, TweenInfo.new(0.3), {
			Size = Vector3.new(0.1, 0.1, 0.1),
			Transparency = 1,
		}):Play()
		task.delay(0.35, function()
			if itemPart and itemPart.Parent then itemPart:Destroy() end
		end)
	end)

	-- Bobbing (with race condition protection)
	task.spawn(function()
		if not itemPart or not itemPart.Parent then return end
		local startY = itemPart.Position.Y
		local t = math.random() * math.pi * 2
		while true do
			-- Double-check every iteration to prevent race condition
			if not itemPart or not itemPart.Parent then break end
			t = t + 0.05
			
			-- Protect the Position assignment
			local success, err = pcall(function()
				if itemPart and itemPart.Parent then
					itemPart.Position = Vector3.new(itemPart.Position.X, startY + math.sin(t) * 0.3, itemPart.Position.Z)
				end
			end)
			if not success then break end -- Exit loop if casting error occurs
			
			task.wait(0.03)
		end
	end)

	-- Auto-despawn
	task.delay(DESPAWN_TIME, function()
		if itemPart and itemPart.Parent then itemPart:Destroy() end
	end)

	print("[DropHandler] " .. player.Name .. " dropped " .. itemName .. " x" .. qty)
end)

print("[DropHandler] Ready!")
