-- Quick fix for stuck Fletching UI
-- Run this in Roblox Studio Command Bar or as a LocalScript

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Method 1: Try to find and hide the FletchingUI
local function hideFletchingUI()
	-- Check if player has PlayerGui
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then
		print("No PlayerGui found")
		return false
	end
	
	-- Look for FletchingUI ScreenGui
	local fletchingUI = playerGui:FindFirstChild("FletchingUI")
	if fletchingUI then
		local mainFrame = fletchingUI:FindFirstChild("MainFrame")
		if mainFrame then
			mainFrame.Visible = false
			print("✓ FletchingUI hidden successfully")
			return true
		end
	end
	
	print("FletchingUI not found in PlayerGui")
	return false
end

-- Method 2: Destroy the entire UI
local function destroyFletchingUI()
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then return false end
	
	local fletchingUI = playerGui:FindFirstChild("FletchingUI")
	if fletchingUI then
		fletchingUI:Destroy()
		print("✓ FletchingUI destroyed")
		return true
	end
	
	return false
end

-- Method 3: Try to call the toggleUI function if it exists
local function callToggleUIFunction()
	-- This would work if the FletchingUI module is accessible
	local success, result = pcall(function()
		-- Try to get the FletchingUI module from ReplicatedStorage
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local Modules = ReplicatedStorage:FindFirstChild("Modules")
		if Modules then
			local FletchingUI = require(Modules:FindFirstChild("FletchingUI"))
			if FletchingUI and FletchingUI.CloseUI then
				FletchingUI.CloseUI()
				print("✓ Called FletchingUI.CloseUI()")
				return true
			end
		end
		return false
	end)
	
	if not success then
		print("Could not call toggleUI function: " .. tostring(result))
	end
	
	return success
end

-- Try all methods
print("Attempting to fix stuck Fletching UI...")

if hideFletchingUI() then
	print("UI hidden using Method 1")
elseif callToggleUIFunction() then
	print("UI closed using Method 2")
elseif destroyFletchingUI() then
	print("UI destroyed using Method 3")
else
	print("Could not fix UI automatically. Try:")
	print("1. Rejoining the game")
	print("2. Opening and closing the UI with the X button")
	print("3. Checking if there's a crafting in progress")
end

-- Also check if there's a crafting in progress that might be stuck
local isCrafting = false
local craftingCheck = playerGui and playerGui:FindFirstChild("FletchingUI")
if craftingCheck then
	local mainFrame = craftingCheck:FindFirstChild("MainFrame")
	if mainFrame then
		local craftButton = mainFrame:FindFirstChild("CraftButton")
		if craftButton and craftButton.Text == "CRAFTING..." then
			isCrafting = true
			print("⚠️ Crafting appears to be in progress. This might prevent UI from closing.")
		end
	end
end

if isCrafting then
	print("Try waiting for crafting to complete, or force close with:")
	print("destroyFletchingUI()")
end