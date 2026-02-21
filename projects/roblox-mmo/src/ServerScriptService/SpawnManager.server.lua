--[[
	SpawnManager.server.lua
	Simple player spawning system - just handles spawn position.
	No inventory, no data, no complexity. Just spawn at Haven.
]]

local Players = game:GetService("Players")

-- Haven spawn position (safe zone)
local SPAWN_POSITION = Vector3.new(0, 15, 0)

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
	-- Handle character spawning
	player.CharacterAdded:Connect(function(character)
		-- Wait for HumanoidRootPart
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
		
		if humanoidRootPart then
			-- Small delay to ensure character is fully loaded
			task.wait(0.2)
			
			-- Set spawn position at Haven
			humanoidRootPart.CFrame = CFrame.new(SPAWN_POSITION)
			
			print("[SpawnManager] Spawned " .. player.Name .. " at Haven (" .. tostring(SPAWN_POSITION) .. ")")
		else
			warn("[SpawnManager] Failed to find HumanoidRootPart for " .. player.Name)
		end
	end)
	
	print("[SpawnManager] " .. player.Name .. " connected")
end)

print("[SpawnManager] Ready - players will spawn at", SPAWN_POSITION)