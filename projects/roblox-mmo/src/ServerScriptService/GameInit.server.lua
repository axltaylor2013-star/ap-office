-- GameInit.server.lua
-- Bootstrap script: handles player join/leave, data loading, auto-save

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataManager = require(ReplicatedStorage.Modules.DataManager)

Players.PlayerAdded:Connect(function(player)
	DataManager.LoadData(player)
	
	-- Send initial inventory to client
	player.CharacterAdded:Connect(function()
		task.wait(1)
		local data = DataManager.GetData(player)
		if data then
			local invRemote = ReplicatedStorage.Remotes:FindFirstChild("InventoryUpdate")
			if invRemote then
				invRemote:FireClient(player, data.Inventory)
			end
			-- Send initial skill levels
			local xpRemote = ReplicatedStorage.Remotes:FindFirstChild("XPUpdate")
			if xpRemote then
				local Config = require(ReplicatedStorage.Modules.Config)
				for skillName, xp in pairs(data.Skills) do
					local level = Config.GetLevelFromXP(xp)
					xpRemote:FireClient(player, skillName, xp, level)
				end
			end
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	DataManager.SaveData(player)
	DataManager.PlayerData[player.UserId] = nil
end)

-- Auto-save every 5 minutes
task.spawn(function()
	while true do
		task.wait(300)
		for _, player in ipairs(Players:GetPlayers()) do
			DataManager.SaveData(player)
		end
		print("[GameInit] Auto-save complete")
	end
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		DataManager.SaveData(player)
	end
end)

print("[GameInit] Server initialized!")
