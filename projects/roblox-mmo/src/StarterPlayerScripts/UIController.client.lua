-- UIController.client.lua
-- Handles all client-side UI: inventory, skills, zone warnings, damage numbers

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- === MAIN SCREEN GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WildernessUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- === ZONE INDICATOR (top center) ===
local zoneFrame = Instance.new("Frame")
zoneFrame.Name = "ZoneIndicator"
zoneFrame.Size = UDim2.new(0, 300, 0, 50)
zoneFrame.Position = UDim2.new(0.5, -150, 0, 10)
zoneFrame.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
zoneFrame.BackgroundTransparency = 0.3
zoneFrame.BorderSizePixel = 0
zoneFrame.Parent = screenGui

local zoneCorner = Instance.new("UICorner")
zoneCorner.CornerRadius = UDim.new(0, 8)
zoneCorner.Parent = zoneFrame

local zoneLabel = Instance.new("TextLabel")
zoneLabel.Name = "ZoneText"
zoneLabel.Size = UDim2.new(1, 0, 1, 0)
zoneLabel.BackgroundTransparency = 1
zoneLabel.Text = "🛡️ SAFE ZONE"
zoneLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
zoneLabel.TextScaled = true
zoneLabel.Font = Enum.Font.GothamBold
zoneLabel.Parent = zoneFrame

-- === SKILLS PANEL (left side) ===
local skillsFrame = Instance.new("Frame")
skillsFrame.Name = "SkillsPanel"
skillsFrame.Size = UDim2.new(0, 200, 0, 250)
skillsFrame.Position = UDim2.new(0, 10, 0.5, -125)
skillsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
skillsFrame.BackgroundTransparency = 0.2
skillsFrame.BorderSizePixel = 0
skillsFrame.Parent = screenGui

local skillsCorner = Instance.new("UICorner")
skillsCorner.CornerRadius = UDim.new(0, 8)
skillsCorner.Parent = skillsFrame

local skillsTitle = Instance.new("TextLabel")
skillsTitle.Size = UDim2.new(1, 0, 0, 30)
skillsTitle.BackgroundTransparency = 1
skillsTitle.Text = "⚔️ SKILLS"
skillsTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
skillsTitle.TextScaled = true
skillsTitle.Font = Enum.Font.GothamBold
skillsTitle.Parent = skillsFrame

local skillsList = Instance.new("UIListLayout")
skillsList.Padding = UDim.new(0, 2)
skillsList.Parent = skillsFrame

-- Skill labels (will be updated by remotes)
local skillLabels = {}
local skillNames = {"Mining", "Woodcutting", "Fishing", "Smithing", "Cooking", "Combat"}
local skillEmojis = {Mining = "⛏️", Woodcutting = "🪓", Fishing = "🎣", Smithing = "🔨", Cooking = "🍳", Combat = "⚔️"}

for _, skillName in ipairs(skillNames) do
	local label = Instance.new("TextLabel")
	label.Name = skillName
	label.Size = UDim2.new(1, -10, 0, 30)
	label.Position = UDim2.new(0, 5, 0, 0)
	label.BackgroundTransparency = 0.7
	label.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	label.Text = "  " .. (skillEmojis[skillName] or "") .. " " .. skillName .. ": Lv 1 (0 XP)"
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.TextScaled = true
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = skillsFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = label

	skillLabels[skillName] = label
end

-- === INVENTORY PANEL (right side) ===
local invFrame = Instance.new("Frame")
invFrame.Name = "InventoryPanel"
invFrame.Size = UDim2.new(0, 220, 0, 400)
invFrame.Position = UDim2.new(1, -230, 0.5, -200)
invFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
invFrame.BackgroundTransparency = 0.2
invFrame.BorderSizePixel = 0
invFrame.Parent = screenGui

local invCorner = Instance.new("UICorner")
invCorner.CornerRadius = UDim.new(0, 8)
invCorner.Parent = invFrame

local invTitle = Instance.new("TextLabel")
invTitle.Size = UDim2.new(1, 0, 0, 30)
invTitle.BackgroundTransparency = 1
invTitle.Text = "🎒 INVENTORY (0/28)"
invTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
invTitle.TextScaled = true
invTitle.Font = Enum.Font.GothamBold
invTitle.Parent = invFrame

local invScroll = Instance.new("ScrollingFrame")
invScroll.Size = UDim2.new(1, -10, 1, -35)
invScroll.Position = UDim2.new(0, 5, 0, 32)
invScroll.BackgroundTransparency = 1
invScroll.ScrollBarThickness = 4
invScroll.Parent = invFrame

local invLayout = Instance.new("UIListLayout")
invLayout.Padding = UDim.new(0, 2)
invLayout.Parent = invScroll

-- === DAMAGE NUMBERS ===
local function showDamageNumber(text, color)
	local dmgLabel = Instance.new("TextLabel")
	dmgLabel.Size = UDim2.new(0, 200, 0, 40)
	dmgLabel.Position = UDim2.new(0.5, -100, 0.4, 0)
	dmgLabel.BackgroundTransparency = 1
	dmgLabel.Text = text
	dmgLabel.TextColor3 = color
	dmgLabel.TextScaled = true
	dmgLabel.Font = Enum.Font.GothamBold
	dmgLabel.TextStrokeTransparency = 0.5
	dmgLabel.Parent = screenGui

	-- Animate upward and fade
	local tween = TweenService:Create(dmgLabel, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -100, 0.3, 0),
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	})
	tween:Play()
	tween.Completed:Connect(function()
		dmgLabel:Destroy()
	end)
end

-- === LEVEL UP NOTIFICATION ===
local function showLevelUp(skillName, newLevel)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 350, 0, 60)
	frame.Position = UDim2.new(0.5, -175, 0.3, 0)
	frame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	frame.BackgroundTransparency = 0.1
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, 0, 1, 0)
	text.BackgroundTransparency = 1
	text.Text = "🎉 " .. skillName .. " LEVEL UP! Level " .. newLevel .. " 🎉"
	text.TextColor3 = Color3.fromRGB(20, 20, 20)
	text.TextScaled = true
	text.Font = Enum.Font.GothamBold
	text.Parent = frame

	-- Fade out after 3 seconds
	task.delay(2, function()
		local tween = TweenService:Create(frame, TweenInfo.new(1), {
			BackgroundTransparency = 1,
		})
		local textTween = TweenService:Create(text, TweenInfo.new(1), {
			TextTransparency = 1,
		})
		tween:Play()
		textTween:Play()
		textTween.Completed:Connect(function()
			frame:Destroy()
		end)
	end)
end

-- === WILDERNESS WARNING ===
local function showZoneWarning()
	local warning = Instance.new("Frame")
	warning.Size = UDim2.new(1, 0, 0, 80)
	warning.Position = UDim2.new(0, 0, 0.15, 0)
	warning.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
	warning.BackgroundTransparency = 0.3
	warning.BorderSizePixel = 0
	warning.Parent = screenGui

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, 0, 1, 0)
	text.BackgroundTransparency = 1
	text.Text = "☠️ WARNING: You are entering the WILDERNESS!\nPvP is ENABLED — You will LOSE ALL ITEMS on death! ☠️"
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
	text.TextScaled = true
	text.Font = Enum.Font.GothamBold
	text.Parent = warning

	-- Fade out after 5 seconds
	task.delay(4, function()
		local tween = TweenService:Create(warning, TweenInfo.new(1), { BackgroundTransparency = 1 })
		local textTween = TweenService:Create(text, TweenInfo.new(1), { TextTransparency = 1 })
		tween:Play()
		textTween:Play()
		textTween.Completed:Connect(function()
			warning:Destroy()
		end)
	end)
end

-- === UPDATE INVENTORY UI ===
local function updateInventoryUI(inventory)
	-- Clear existing
	for _, child in ipairs(invScroll:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	invTitle.Text = "🎒 INVENTORY (" .. #inventory .. "/28)"

	for i, slot in ipairs(inventory) do
		local itemLabel = Instance.new("TextLabel")
		itemLabel.Size = UDim2.new(1, -5, 0, 25)
		itemLabel.BackgroundTransparency = 0.7
		itemLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		itemLabel.Text = "  " .. slot.name .. " x" .. slot.quantity
		itemLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
		itemLabel.TextScaled = true
		itemLabel.Font = Enum.Font.Gotham
		itemLabel.TextXAlignment = Enum.TextXAlignment.Left
		itemLabel.Parent = invScroll

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = itemLabel
	end

	-- Update canvas size for scrolling
	invScroll.CanvasSize = UDim2.new(0, 0, 0, #inventory * 27)
end

-- === CONNECT REMOTES ===

-- XP Update
Remotes:WaitForChild("XPUpdate").OnClientEvent:Connect(function(skillName, totalXP, level)
	local label = skillLabels[skillName]
	if label then
		local emoji = skillEmojis[skillName] or ""
		label.Text = "  " .. emoji .. " " .. skillName .. ": Lv " .. level .. " (" .. totalXP .. " XP)"
	end
end)

-- Level Up
Remotes:WaitForChild("LevelUp").OnClientEvent:Connect(function(skillName, newLevel)
	showLevelUp(skillName, newLevel)
end)

-- Inventory Update
Remotes:WaitForChild("InventoryUpdate").OnClientEvent:Connect(function(inventory)
	updateInventoryUI(inventory)
end)

-- Zone Changed
Remotes:WaitForChild("ZoneChanged").OnClientEvent:Connect(function(zone)
	if zone == "Wilderness" then
		zoneFrame.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
		zoneLabel.Text = "☠️ WILDERNESS — PVP ENABLED"
		showZoneWarning()
	else
		zoneFrame.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
		zoneLabel.Text = "🛡️ SAFE ZONE"
	end
end)

-- Damage
Remotes:WaitForChild("DamageDealt").OnClientEvent:Connect(function(direction, damage, otherName)
	if direction == "dealt" then
		showDamageNumber("💥 " .. damage .. " → " .. otherName, Color3.fromRGB(255, 100, 100))
	else
		showDamageNumber("💔 -" .. damage .. " from " .. otherName, Color3.fromRGB(255, 50, 50))
	end
end)

-- === ATTACK INPUT (click other players) ===
local mouse = player:GetMouse()
local attackRemote = Remotes:WaitForChild("Attack")

mouse.Button1Down:Connect(function()
	local target = mouse.Target
	if target then
		-- Check if clicked on a player character
		local character = target.Parent
		if character then
			local targetPlayer = Players:GetPlayerFromCharacter(character)
			if targetPlayer and targetPlayer ~= player then
				attackRemote:FireServer(targetPlayer)
			end
		end
	end
end)

-- === GATHER FEEDBACK ===
local gatherRemote = Remotes:FindFirstChild("GatherFeedback")
if gatherRemote then
	gatherRemote.OnClientEvent:Connect(function(action, itemName, xpOrLevel)
		if action == "gather" then
			showDamageNumber("+" .. itemName .. " (+" .. xpOrLevel .. " XP)", Color3.fromRGB(100, 255, 100))
		elseif action == "full" then
			showDamageNumber("❌ Inventory Full!", Color3.fromRGB(255, 100, 100))
		elseif action == "level" then
			showDamageNumber("🔒 Need Level " .. xpOrLevel .. "!", Color3.fromRGB(255, 200, 50))
		end
	end)
end

-- === CLIENT-SIDE ZONE CHECK (backup) ===
-- In case server remote doesn't fire, check locally too
local WILDERNESS_Z = -100
task.spawn(function()
	local lastZone = "safe"
	while true do
		task.wait(0.3)
		local character = player.Character
		if character then
			local root = character:FindFirstChild("HumanoidRootPart")
			if root then
				local currentZone = root.Position.Z < WILDERNESS_Z and "wild" or "safe"
				if currentZone ~= lastZone then
					lastZone = currentZone
					if currentZone == "wild" then
						zoneFrame.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
						zoneLabel.Text = "☠️ WILDERNESS — PVP ENABLED"
						showZoneWarning()
					else
						zoneFrame.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
						zoneLabel.Text = "🛡️ SAFE ZONE"
					end
				end
			end
		end
	end
end)

print("[UIController] Client UI loaded!")
