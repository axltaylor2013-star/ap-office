--[[
	PlayerSpawner.server.lua
	Handles proper player spawning at the spawn platform.
	Simple, reliable spawning system.
]]

local Players = game:GetService("Players")

-- Spawn position (on top of spawn platform)
local SPAWN_POSITION = Vector3.new(0, 10, 0)

print("[PlayerSpawner] Spawn system ready - spawn position:", SPAWN_POSITION)

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
	print("[PlayerSpawner]", player.Name, "joined the game")
	
	-- Handle character spawning/respawning
	player.CharacterAdded:Connect(function(character)
		-- Wait for HumanoidRootPart to load
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
		
		if humanoidRootPart then
			-- Wait a moment for character to fully load
			task.wait(0.5)
			
			-- Set spawn position
			humanoidRootPart.CFrame = CFrame.new(SPAWN_POSITION)
			
			print("[PlayerSpawner] Spawned", player.Name, "at", SPAWN_POSITION)
		else
			warn("[PlayerSpawner] Failed to find HumanoidRootPart for", player.Name)
		end
	end)
end)

print("[PlayerSpawner] Ready - players will spawn at", SPAWN_POSITION)