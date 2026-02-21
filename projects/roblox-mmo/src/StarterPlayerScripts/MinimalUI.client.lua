--[[
	MinimalUI.client.lua
	Simple working UI - just inventory and stats.
	No complex features, just the basics that work.
]]

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Colors
local DARK_BG = Color3.fromRGB(20, 20, 25)
local GOLD = Color3.fromRGB(218, 165, 32)
local WHITE = Color3.fromRGB(255, 255, 255)

-- Create main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GameUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Create inventory panel (simple)
local inventoryFrame = Instance.new("Frame")
inventoryFrame.Name = "InventoryPanel"
inventoryFrame.Size = UDim2.new(0, 300, 0, 400)
inventoryFrame.Position = UDim2.new(0, 20, 0.5, -200)
inventoryFrame.BackgroundColor3 = DARK_BG
inventoryFrame.BorderSizePixel = 0
inventoryFrame.Visible = false
inventoryFrame.Parent = screenGui

-- Inventory title
local invTitle = Instance.new("TextLabel")
invTitle.Name = "Title"
invTitle.Size = UDim2.new(1, 0, 0, 40)
invTitle.Position = UDim2.new(0, 0, 0, 0)
invTitle.BackgroundColor3 = GOLD
invTitle.BorderSizePixel = 0
invTitle.Text = "INVENTORY"
invTitle.TextColor3 = DARK_BG
invTitle.TextScaled = true
invTitle.Font = Enum.Font.GothamBold
invTitle.Parent = inventoryFrame

-- Inventory content area
local invContent = Instance.new("ScrollingFrame")
invContent.Name = "Content"
invContent.Size = UDim2.new(1, -20, 1, -60)
invContent.Position = UDim2.new(0, 10, 0, 50)
invContent.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
invContent.BorderSizePixel = 0
invContent.ScrollBarThickness = 8
invContent.Parent = inventoryFrame

-- Create stats panel (simple)
local statsFrame = Instance.new("Frame")
statsFrame.Name = "StatsPanel"
statsFrame.Size = UDim2.new(0, 250, 0, 300)
statsFrame.Position = UDim2.new(1, -270, 0, 20)
statsFrame.BackgroundColor3 = DARK_BG
statsFrame.BorderSizePixel = 0
statsFrame.Visible = false
statsFrame.Parent = screenGui

-- Stats title
local statsTitle = Instance.new("TextLabel")
statsTitle.Name = "Title"
statsTitle.Size = UDim2.new(1, 0, 0, 40)
statsTitle.Position = UDim2.new(0, 0, 0, 0)
statsTitle.BackgroundColor3 = GOLD
statsTitle.BorderSizePixel = 0
statsTitle.Text = "SKILLS"
statsTitle.TextColor3 = DARK_BG
statsTitle.TextScaled = true
statsTitle.Font = Enum.Font.GothamBold
statsTitle.Parent = statsFrame

-- Stats content
local statsContent = Instance.new("ScrollingFrame")
statsContent.Name = "Content"
statsContent.Size = UDim2.new(1, -20, 1, -60)
statsContent.Position = UDim2.new(0, 10, 0, 50)
statsContent.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
statsContent.BorderSizePixel = 0
statsContent.ScrollBarThickness = 8
statsContent.Parent = statsFrame

-- Create hotbar (simple)
local hotbar = Instance.new("Frame")
hotbar.Name = "Hotbar"
hotbar.Size = UDim2.new(0, 400, 0, 60)
hotbar.Position = UDim2.new(0.5, -200, 1, -80)
hotbar.BackgroundColor3 = DARK_BG
hotbar.BorderSizePixel = 0
hotbar.Parent = screenGui

-- Hotbar slots (5 slots)
for i = 1, 5 do
	local slot = Instance.new("Frame")
	slot.Name = "Slot" .. i
	slot.Size = UDim2.new(0, 60, 0, 60)
	slot.Position = UDim2.new(0, (i-1) * 70 + 20, 0, 0)
	slot.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	slot.BorderSizePixel = 1
	slot.BorderColor3 = GOLD
	slot.Parent = hotbar
	
	-- Slot number
	local slotNum = Instance.new("TextLabel")
	slotNum.Size = UDim2.new(1, 0, 0, 20)
	slotNum.Position = UDim2.new(0, 0, 1, -20)
	slotNum.BackgroundTransparency = 1
	slotNum.Text = tostring(i)
	slotNum.TextColor3 = GOLD
	slotNum.TextScaled = true
	slotNum.Font = Enum.Font.Gotham
	slotNum.Parent = slot
end

-- Toggle functions
local function toggleInventory()
	inventoryFrame.Visible = not inventoryFrame.Visible
end

local function toggleStats()
	statsFrame.Visible = not statsFrame.Visible
end

-- Key bindings
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.I then
		toggleInventory()
	elseif input.KeyCode == Enum.KeyCode.K then
		toggleStats()
	end
end)

-- Sample data for testing
local function addSampleInventoryItems()
	for i = 1, 10 do
		local item = Instance.new("TextLabel")
		item.Size = UDim2.new(1, -10, 0, 30)
		item.Position = UDim2.new(0, 5, 0, (i-1) * 35 + 5)
		item.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
		item.BorderSizePixel = 0
		item.Text = "Item " .. i .. " x" .. math.random(1, 10)
		item.TextColor3 = WHITE
		item.TextScaled = true
		item.Font = Enum.Font.Gotham
		item.Parent = invContent
	end
	invContent.CanvasSize = UDim2.new(0, 0, 0, 10 * 35 + 10)
end

local function addSampleSkills()
	local skills = {"Attack", "Defense", "Mining", "Fishing", "Cooking", "Woodcutting"}
	for i, skillName in ipairs(skills) do
		local skill = Instance.new("TextLabel")
		skill.Size = UDim2.new(1, -10, 0, 35)
		skill.Position = UDim2.new(0, 5, 0, (i-1) * 40 + 5)
		skill.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
		skill.BorderSizePixel = 0
		skill.Text = skillName .. " - Level " .. math.random(1, 20)
		skill.TextColor3 = WHITE
		skill.TextScaled = true
		skill.Font = Enum.Font.Gotham
		skill.Parent = statsContent
	end
	statsContent.CanvasSize = UDim2.new(0, 0, 0, #skills * 40 + 10)
end

-- Initialize with sample data
task.wait(1)
addSampleInventoryItems()
addSampleSkills()

-- Instructions
local instructions = Instance.new("TextLabel")
instructions.Size = UDim2.new(0, 300, 0, 60)
instructions.Position = UDim2.new(0, 20, 0, 20)
instructions.BackgroundColor3 = DARK_BG
instructions.BorderSizePixel = 0
instructions.Text = "Press I for Inventory\nPress K for Skills"
instructions.TextColor3 = GOLD
instructions.TextScaled = true
instructions.Font = Enum.Font.Gotham
instructions.Parent = screenGui

-- Simple NPC Dialog System
local npcDialog = Instance.new("Frame")
npcDialog.Name = "NPCDialog"
npcDialog.Size = UDim2.new(0, 400, 0, 300)
npcDialog.Position = UDim2.new(0.5, -200, 0.5, -150)
npcDialog.BackgroundColor3 = DARK_BG
npcDialog.BorderSizePixel = 2
npcDialog.BorderColor3 = GOLD
npcDialog.Visible = false
npcDialog.Parent = screenGui

-- Dialog title
local dialogTitle = Instance.new("TextLabel")
dialogTitle.Size = UDim2.new(1, 0, 0, 40)
dialogTitle.BackgroundColor3 = GOLD
dialogTitle.Text = "NPC"
dialogTitle.TextColor3 = DARK_BG
dialogTitle.TextScaled = true
dialogTitle.Font = Enum.Font.GothamBold
dialogTitle.Parent = npcDialog

-- Dialog text
local dialogText = Instance.new("TextLabel")
dialogText.Size = UDim2.new(1, -20, 1, -80)
dialogText.Position = UDim2.new(0, 10, 0, 50)
dialogText.BackgroundTransparency = 1
dialogText.Text = "Hello there!"
dialogText.TextColor3 = WHITE
dialogText.TextScaled = true
dialogText.Font = Enum.Font.Gotham
dialogText.Parent = npcDialog

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 100, 0, 30)
closeButton.Position = UDim2.new(0.5, -50, 1, -40)
closeButton.BackgroundColor3 = GOLD
closeButton.Text = "Close"
closeButton.TextColor3 = DARK_BG
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = npcDialog

closeButton.MouseButton1Click:Connect(function()
	npcDialog.Visible = false
end)

-- NPC Interaction Handler
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
if Remotes then
	local NPCInteractEvent = Remotes:WaitForChild("NPCInteract", 5)
	if NPCInteractEvent then
		NPCInteractEvent.OnClientEvent:Connect(function(data)
			if data and data.npcName and data.dialog then
				dialogTitle.Text = data.npcName
				dialogText.Text = data.dialog
				npcDialog.Visible = true
			end
		end)
	end
end

-- Hide instructions after 5 seconds
task.wait(5)
instructions.Visible = false

print("[MinimalUI] Basic UI loaded - Press I for inventory, K for skills, click NPCs to interact")