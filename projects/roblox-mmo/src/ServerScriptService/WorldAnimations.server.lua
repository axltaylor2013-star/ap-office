--[[
	WorldAnimations.server.lua
	ServerScriptService

	Makes the world feel alive with ambient animations:
	- Torch flame flicker (size + brightness)
	- Water shimmer (transparency oscillation)
	- NPC idle breathing (torso scale pulse) + head turns
	- Tree canopy gentle sway
]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

task.wait(6) -- let MapSetup + NPCManager finish

print("[WorldAnimations] Starting ambient animations...")

--------------------------------------------------------------------------------
-- TORCH FLICKER
--------------------------------------------------------------------------------
local function animateTorchFlames()
	local flames = {}
	-- Find all TorchFlame parts in workspace (recursive)
	for _, obj in Workspace:GetDescendants() do
		if obj:IsA("BasePart") and obj.Name == "TorchFlame" then
			table.insert(flames, obj)
		end
	end

	print("[WorldAnimations] Found " .. #flames .. " torch flames")

	for _, flame in ipairs(flames) do
		task.spawn(function()
			local baseSize = flame.Size
			local baseTransparency = flame.Transparency
			local light = flame:FindFirstChildOfClass("PointLight")
			local baseBrightness = light and light.Brightness or 2
			local baseRange = light and light.Range or 20

			while flame and flame.Parent do
				-- Random flicker target
				local scaleFactor = 0.85 + math.random() * 0.3
				local transFactor = baseTransparency + (math.random() * 0.2 - 0.05)
				local duration = 0.1 + math.random() * 0.2

				local tween = TweenService:Create(flame, TweenInfo.new(duration, Enum.EasingStyle.Sine), {
					Size = Vector3.new(
						baseSize.X * scaleFactor,
						baseSize.Y * (0.8 + math.random() * 0.4),
						baseSize.Z * scaleFactor
					),
					Transparency = math.clamp(transFactor, 0.05, 0.5),
				})
				tween:Play()

				if light then
					local lightTween = TweenService:Create(light, TweenInfo.new(duration, Enum.EasingStyle.Sine), {
						Brightness = baseBrightness * (0.7 + math.random() * 0.6),
						Range = baseRange * (0.85 + math.random() * 0.3),
					})
					lightTween:Play()
				end

				task.wait(duration + 0.02)
			end
		end)
	end
end

--------------------------------------------------------------------------------
-- FORGE FIRE FLICKER (same idea but for ForgeFire)
--------------------------------------------------------------------------------
local function animateForges()
	for _, obj in Workspace:GetDescendants() do
		if obj:IsA("BasePart") and (obj.Name == "ForgeFire" or obj.Name == "CookingRange") then
			task.spawn(function()
				local baseTransparency = obj.Transparency
				while obj and obj.Parent do
					local t = 0.15 + math.random() * 0.2
					TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Sine), {
						Transparency = baseTransparency + math.random() * 0.15,
					}):Play()
					task.wait(t + 0.05)
				end
			end)
		end
	end
end

--------------------------------------------------------------------------------
-- WATER SHIMMER
--------------------------------------------------------------------------------
local function animateWater()
	local waterParts = {}
	local waterNames = {
		PondWater = true, LilyPond = true, FountainWater = true,
		FountainTopWater = true, LakeWater = true, DarkPondWater = true,
		SwampWater = true, WellWater = true, Waterfall = true,
	}

	for _, obj in Workspace:GetDescendants() do
		if obj:IsA("BasePart") and waterNames[obj.Name] then
			table.insert(waterParts, obj)
		end
	end

	print("[WorldAnimations] Found " .. #waterParts .. " water surfaces")

	for _, water in ipairs(waterParts) do
		task.spawn(function()
			local baseTransparency = water.Transparency
			local phase = math.random() * math.pi * 2

			while water and water.Parent do
				phase = phase + 0.03
				local newTrans = baseTransparency + math.sin(phase) * 0.08
				water.Transparency = math.clamp(newTrans, 0.1, 0.7)
				task.wait(0.05)
			end
		end)
	end
end

--------------------------------------------------------------------------------
-- LAVA PULSE
--------------------------------------------------------------------------------
local function animateLava()
	for _, obj in Workspace:GetDescendants() do
		if obj:IsA("BasePart") and (obj.Name == "LavaPit" or obj.Name:find("LavaRiver")) then
			task.spawn(function()
				local baseTransparency = obj.Transparency
				local phase = math.random() * math.pi * 2
				local light = obj:FindFirstChildOfClass("PointLight")

				while obj and obj.Parent do
					phase = phase + 0.04
					obj.Transparency = baseTransparency + math.sin(phase) * 0.1

					if light then
						light.Brightness = 4 + math.sin(phase * 1.3) * 1.5
					end
					task.wait(0.06)
				end
			end)
		end
	end
end

--------------------------------------------------------------------------------
-- NPC IDLE BREATHING + HEAD TURNS
--------------------------------------------------------------------------------
local function animateNPCs()
	local npcsFolder = Workspace:FindFirstChild("NPCs")
	if not npcsFolder then
		print("[WorldAnimations] No NPCs folder found, skipping NPC animations")
		return
	end

	for _, npc in npcsFolder:GetChildren() do
		if not npc:IsA("Model") then continue end

		local torso = npc:FindFirstChild("Torso")
		local head = npc:FindFirstChild("Head")

		if torso then
			-- Breathing: gentle Y-scale pulse on torso
			task.spawn(function()
				local basePos = torso.Position
				local breathPhase = math.random() * math.pi * 2

				while torso and torso.Parent do
					breathPhase = breathPhase + 0.06
					local breathOffset = math.sin(breathPhase) * 0.04
					torso.Position = Vector3.new(basePos.X, basePos.Y + breathOffset, basePos.Z)
					task.wait(0.05)
				end
			end)
		end

		if head then
			-- Occasional head turns
			task.spawn(function()
				local baseCF = head.CFrame

				while head and head.Parent do
					-- Wait 3-8 seconds between head turns
					task.wait(3 + math.random() * 5)

					if not head or not head.Parent then break end

					-- Turn head slightly left or right
					local turnAngle = (math.random() * 30 - 15)
					local targetCF = baseCF * CFrame.Angles(0, math.rad(turnAngle), 0)

					TweenService:Create(head, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
						CFrame = targetCF,
					}):Play()

					-- Hold for a moment, then return
					task.wait(1.5 + math.random() * 2)

					if head and head.Parent then
						TweenService:Create(head, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
							CFrame = baseCF,
						}):Play()
					end
				end
			end)
		end
	end
end

--------------------------------------------------------------------------------
-- TREE CANOPY GENTLE SWAY
--------------------------------------------------------------------------------
local function animateTreeCanopies()
	local canopyParts = {}

	-- Find leaf/canopy parts in Forest and Grove areas
	for _, obj in Workspace:GetDescendants() do
		if obj:IsA("BasePart") and (obj.Name == "SLeaf" or obj.Name == "Leaves" or obj.Name:find("AncientCanopy")) then
			table.insert(canopyParts, obj)
		end
	end

	print("[WorldAnimations] Found " .. #canopyParts .. " tree canopies to sway")

	-- Only animate a subset to keep performance reasonable
	local maxAnimated = 30
	local count = 0

	for _, leaf in ipairs(canopyParts) do
		if count >= maxAnimated then break end
		count = count + 1

		task.spawn(function()
			local basePos = leaf.Position
			local phase = math.random() * math.pi * 2
			local swayAmount = 0.15 + math.random() * 0.1
			local speed = 0.02 + math.random() * 0.01

			while leaf and leaf.Parent do
				phase = phase + speed
				local offsetX = math.sin(phase) * swayAmount
				local offsetZ = math.cos(phase * 0.7) * swayAmount * 0.6
				leaf.Position = Vector3.new(basePos.X + offsetX, basePos.Y, basePos.Z + offsetZ)
				task.wait(0.08)
			end
		end)
	end
end

--------------------------------------------------------------------------------
-- GLOWING MUSHROOM PULSE
--------------------------------------------------------------------------------
local function animateMushrooms()
	for _, obj in Workspace:GetDescendants() do
		if obj:IsA("BasePart") and (obj.Name:find("Mushroom") or obj.Name:find("BlueMushroom")) then
			task.spawn(function()
				local baseTransparency = obj.Transparency
				local light = obj:FindFirstChildOfClass("PointLight")
				local baseBrightness = light and light.Brightness or 1
				local phase = math.random() * math.pi * 2

				while obj and obj.Parent do
					phase = phase + 0.04
					obj.Transparency = baseTransparency + math.sin(phase) * 0.12

					if light then
						light.Brightness = baseBrightness + math.sin(phase) * 0.4
					end
					task.wait(0.06)
				end
			end)
		end
	end
end

--------------------------------------------------------------------------------
-- CRYSTAL FLOAT (Abyss crystals bob up and down)
--------------------------------------------------------------------------------
local function animateCrystals()
	for _, obj in Workspace:GetDescendants() do
		if obj:IsA("BasePart") and obj.Name:find("Crystal") and obj.Parent and obj.Parent.Name == "TheAbyss" then
			task.spawn(function()
				local basePos = obj.Position
				local phase = math.random() * math.pi * 2
				local bobAmount = 0.3 + math.random() * 0.4

				while obj and obj.Parent do
					phase = phase + 0.025
					obj.Position = Vector3.new(basePos.X, basePos.Y + math.sin(phase) * bobAmount, basePos.Z)
					task.wait(0.06)
				end
			end)
		end
	end
end

--------------------------------------------------------------------------------
-- CAULDRON BUBBLE (Thessaly's brew)
--------------------------------------------------------------------------------
local function animateCauldrons()
	for _, obj in Workspace:GetDescendants() do
		if obj:IsA("BasePart") and obj.Name == "Brew" then
			task.spawn(function()
				local baseTransparency = obj.Transparency
				local phase = 0

				while obj and obj.Parent do
					phase = phase + 0.08
					obj.Transparency = baseTransparency + math.sin(phase) * 0.1
					task.wait(0.05)
				end
			end)
		end
	end
end

--------------------------------------------------------------------------------
-- STAINED GLASS SHIMMER (Chapel windows)
--------------------------------------------------------------------------------
local function animateStainedGlass()
	for _, obj in Workspace:GetDescendants() do
		if obj:IsA("BasePart") and obj.Name:find("StainedGlass") then
			task.spawn(function()
				local baseTransparency = obj.Transparency
				local phase = math.random() * math.pi * 2

				while obj and obj.Parent do
					phase = phase + 0.02
					obj.Transparency = baseTransparency + math.sin(phase) * 0.08
					task.wait(0.1)
				end
			end)
		end
	end
end

--------------------------------------------------------------------------------
-- LAUNCH ALL ANIMATIONS
--------------------------------------------------------------------------------
task.spawn(animateTorchFlames)
task.spawn(animateForges)
task.spawn(animateWater)
task.spawn(animateLava)
task.spawn(animateNPCs)
task.spawn(animateTreeCanopies)
task.spawn(animateMushrooms)
task.spawn(animateCrystals)
task.spawn(animateCauldrons)
task.spawn(animateStainedGlass)

print("[WorldAnimations] All ambient animations started!")
