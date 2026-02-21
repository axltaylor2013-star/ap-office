--[[
	GameUI.client.lua
	Clean, simple UI system for the game.
	Just inventory, stats, and hotbar - no complexity.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("[GameUI] Starting UI initialization...")

-- Brand colors
local DARK_BG = Color3.fromRGB(20, 20, 25)
local GOLD = Color3.fromRGB(218, 165, 32)
local WHITE = Color3.fromRGB(255, 255, 255)
local LIGHTER_BG = Color3.fromRGB(30, 30, 35)

-- Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 100
screenGui.Parent = playerGui

-- ===========================================
-- HOTBAR (Always visible)
-- ===========================================
local hotbar = Instance.new("Frame")
hotbar.Name = "Hotbar"
hotbar.Size = UDim2.new(0, 350, 0, 70)
hotbar.Position = UDim2.new(0.5, -175, 1, -90)
hotbar.BackgroundColor3 = DARK_BG
hotbar.BorderSizePixel = 0
hotbar.Parent = screenGui

-- Hotbar corner rounding
local hotbarCorner = Instance.new("UICorner")
hotbarCorner.CornerRadius = UDim.new(0, 8)
hotbarCorner.Parent = hotbar

-- Create 5 hotbar slots
for i = 1, 5 do
	local slot = Instance.new("Frame")
	slot.Name = "Slot" .. i
	slot.Size = UDim2.new(0, 60, 0, 60)
	slot.Position = UDim2.new(0, (i-1) * 65 + 10, 0, 5)
	slot.BackgroundColor3 = LIGHTER_BG
	slot.BorderSizePixel = 1
	slot.BorderColor3 = GOLD
	slot.Parent = hotbar
	
	local slotCorner = Instance.new("UICorner")
	slotCorner.CornerRadius = UDim.new(0, 4)
	slotCorner.Parent = slot
	
	-- Slot key indicator
	local keyLabel = Instance.new("TextLabel")
	keyLabel.Size = UDim2.new(1, 0, 0, 16)
	keyLabel.Position = UDim2.new(0, 0, 1, -16)
	keyLabel.BackgroundTransparency = 1
	keyLabel.Text = tostring(i)
	keyLabel.TextColor3 = GOLD
	keyLabel.TextSize = 12
	keyLabel.Font = Enum.Font.GothamBold
	keyLabel.Parent = slot
end

-- ===========================================
-- INVENTORY PANEL (Toggle with I)
-- ===========================================
local inventoryPanel = Instance.new("Frame")
inventoryPanel.Name = "InventoryPanel"
inventoryPanel.Size = UDim2.new(0, 350, 0, 450)
inventoryPanel.Position = UDim2.new(0, 20, 0.5, -225)
inventoryPanel.BackgroundColor3 = DARK_BG
inventoryPanel.BorderSizePixel = 0
inventoryPanel.Visible = false
inventoryPanel.Parent = screenGui

local invCorner = Instance.new("UICorner")
invCorner.CornerRadius = UDim.new(0, 8)
invCorner.Parent = inventoryPanel

-- Inventory title bar
local invTitleBar = Instance.new("Frame")
invTitleBar.Size = UDim2.new(1, 0, 0, 40)
invTitleBar.BackgroundColor3 = GOLD
invTitleBar.BorderSizePixel = 0
invTitleBar.Parent = inventoryPanel

local invTitleCorner = Instance.new("UICorner")
invTitleCorner.CornerRadius = UDim.new(0, 8)
invTitleCorner.Parent = invTitleBar

local invTitle = Instance.new("TextLabel")
invTitle.Size = UDim2.new(1, 0, 1, 0)
invTitle.BackgroundTransparency = 1
invTitle.Text = "INVENTORY"
invTitle.TextColor3 = DARK_BG
invTitle.TextSize = 18
invTitle.Font = Enum.Font.GothamBold
invTitle.Parent = invTitleBar

-- Inventory content area
local invContent = Instance.new("ScrollingFrame")
invContent.Size = UDim2.new(1, -20, 1, -60)
invContent.Position = UDim2.new(0, 10, 0, 50)
invContent.BackgroundColor3 = LIGHTER_BG
invContent.BorderSizePixel = 0
invContent.ScrollBarThickness = 6
invContent.CanvasSize = UDim2.new(0, 0, 0, 300)
invContent.Parent = inventoryPanel

local invContentCorner = Instance.new("UICorner")
invContentCorner.CornerRadius = UDim.new(0, 4)
invContentCorner.Parent = invContent

-- ===========================================
-- STATS PANEL (Toggle with K)  
-- ===========================================
local statsPanel = Instance.new("Frame")
statsPanel.Name = "StatsPanel"
statsPanel.Size = UDim2.new(0, 300, 0, 400)
statsPanel.Position = UDim2.new(1, -320, 0, 20)
statsPanel.BackgroundColor3 = DARK_BG
statsPanel.BorderSizePixel = 0
statsPanel.Visible = false
statsPanel.Parent = screenGui

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 8)
statsCorner.Parent = statsPanel

-- Stats title bar
local statsTitleBar = Instance.new("Frame")
statsTitleBar.Size = UDim2.new(1, 0, 0, 40)
statsTitleBar.BackgroundColor3 = GOLD
statsTitleBar.BorderSizePixel = 0
statsTitleBar.Parent = statsPanel

local statsTitleCorner = Instance.new("UICorner")
statsTitleCorner.CornerRadius = UDim.new(0, 8)
statsTitleCorner.Parent = statsTitleBar

local statsTitle = Instance.new("TextLabel")
statsTitle.Size = UDim2.new(1, 0, 1, 0)
statsTitle.BackgroundTransparency = 1
statsTitle.Text = "SKILLS"
statsTitle.TextColor3 = DARK_BG
statsTitle.TextSize = 18
statsTitle.Font = Enum.Font.GothamBold
statsTitle.Parent = statsTitleBar

-- Stats content area
local statsContent = Instance.new("ScrollingFrame")
statsContent.Size = UDim2.new(1, -20, 1, -60)
statsContent.Position = UDim2.new(0, 10, 0, 50)
statsContent.BackgroundColor3 = LIGHTER_BG
statsContent.BorderSizePixel = 0
statsContent.ScrollBarThickness = 6
statsContent.CanvasSize = UDim2.new(0, 0, 0, 300)
statsContent.Parent = statsPanel

local statsContentCorner = Instance.new("UICorner")
statsContentCorner.CornerRadius = UDim.new(0, 4)
statsContentCorner.Parent = statsContent

-- ===========================================
-- CONTROLS INSTRUCTIONS
-- ===========================================
local controls = Instance.new("TextLabel")
controls.Size = UDim2.new(0, 300, 0, 80)
controls.Position = UDim2.new(0, 20, 0, 20)
controls.BackgroundColor3 = DARK_BG
controls.BorderSizePixel = 0
controls.Text = "CONTROLS\nI - Toggle Inventory\nK - Toggle Skills\n1-5 - Hotbar Slots"
controls.TextColor3 = GOLD
controls.TextSize = 14
controls.Font = Enum.Font.Gotham
controls.Parent = screenGui

local controlsCorner = Instance.new("UICorner")
controlsCorner.CornerRadius = UDim.new(0, 8)
controlsCorner.Parent = controls

-- Auto-hide controls after 8 seconds
task.spawn(function()
	task.wait(8)
	controls.Visible = false
end)

-- ===========================================
-- TOGGLE FUNCTIONS
-- ===========================================
local function toggleInventory()
	inventoryPanel.Visible = not inventoryPanel.Visible
	print("[GameUI] Inventory", inventoryPanel.Visible and "opened" or "closed")
end

local function toggleStats()
	statsPanel.Visible = not statsPanel.Visible
	print("[GameUI] Stats", statsPanel.Visible and "opened" or "closed")
end

-- ===========================================
-- INPUT HANDLING
-- ===========================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.I then
		toggleInventory()
	elseif input.KeyCode == Enum.KeyCode.K then
		toggleStats()
	elseif input.KeyCode == Enum.KeyCode.One then
		print("[GameUI] Hotbar slot 1 pressed")
	elseif input.KeyCode == Enum.KeyCode.Two then
		print("[GameUI] Hotbar slot 2 pressed")
	elseif input.KeyCode == Enum.KeyCode.Three then
		print("[GameUI] Hotbar slot 3 pressed")
	elseif input.KeyCode == Enum.KeyCode.Four then
		print("[GameUI] Hotbar slot 4 pressed")
	elseif input.KeyCode == Enum.KeyCode.Five then
		print("[GameUI] Hotbar slot 5 pressed")
	end
end)

-- ===========================================
-- SAMPLE DATA (for testing)
-- ===========================================
task.spawn(function()
	task.wait(2)
	
	-- Add sample inventory items
	for i = 1, 8 do
		local item = Instance.new("Frame")
		item.Size = UDim2.new(1, -10, 0, 40)
		item.Position = UDim2.new(0, 5, 0, (i-1) * 45 + 5)
		item.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
		item.BorderSizePixel = 0
		item.Parent = invContent
		
		local itemCorner = Instance.new("UICorner")
		itemCorner.CornerRadius = UDim.new(0, 4)
		itemCorner.Parent = item
		
		local itemText = Instance.new("TextLabel")
		itemText.Size = UDim2.new(1, -10, 1, 0)
		itemText.Position = UDim2.new(0, 5, 0, 0)
		itemText.BackgroundTransparency = 1
		itemText.Text = "Test Item " .. i .. " (x" .. math.random(1, 10) .. ")"
		itemText.TextColor3 = WHITE
		itemText.TextSize = 14
		itemText.Font = Enum.Font.Gotham
		itemText.TextXAlignment = Enum.TextXAlignment.Left
		itemText.Parent = item
	end
	
	-- Update canvas size
	invContent.CanvasSize = UDim2.new(0, 0, 0, 8 * 45 + 10)
	
	-- Add sample skills
	local skills = {"Attack", "Defense", "Mining", "Fishing", "Cooking", "Woodcutting"}
	for i, skill in ipairs(skills) do
		local skillFrame = Instance.new("Frame")
		skillFrame.Size = UDim2.new(1, -10, 0, 45)
		skillFrame.Position = UDim2.new(0, 5, 0, (i-1) * 50 + 5)
		skillFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
		skillFrame.BorderSizePixel = 0
		skillFrame.Parent = statsContent
		
		local skillCorner = Instance.new("UICorner")
		skillCorner.CornerRadius = UDim.new(0, 4)
		skillCorner.Parent = skillFrame
		
		local skillName = Instance.new("TextLabel")
		skillName.Size = UDim2.new(0.6, 0, 1, 0)
		skillName.Position = UDim2.new(0, 10, 0, 0)
		skillName.BackgroundTransparency = 1
		skillName.Text = skill
		skillName.TextColor3 = WHITE
		skillName.TextSize = 16
		skillName.Font = Enum.Font.GothamBold
		skillName.TextXAlignment = Enum.TextXAlignment.Left
		skillName.Parent = skillFrame
		
		local skillLevel = Instance.new("TextLabel")
		skillLevel.Size = UDim2.new(0.4, -10, 1, 0)
		skillLevel.Position = UDim2.new(0.6, 0, 0, 0)
		skillLevel.BackgroundTransparency = 1
		skillLevel.Text = "Level " .. math.random(1, 25)
		skillLevel.TextColor3 = GOLD
		skillLevel.TextSize = 14
		skillLevel.Font = Enum.Font.Gotham
		skillLevel.TextXAlignment = Enum.TextXAlignment.Right
		skillLevel.Parent = skillFrame
	end
	
	-- Update canvas size
	statsContent.CanvasSize = UDim2.new(0, 0, 0, #skills * 50 + 10)
end)

print("[GameUI] UI system loaded successfully")
print("[GameUI] Controls: I = Inventory, K = Skills, 1-5 = Hotbar")