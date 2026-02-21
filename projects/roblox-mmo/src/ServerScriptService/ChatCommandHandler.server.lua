-- ChatCommandHandler.server.lua
-- Server-side chat command handler with error handling

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")

-- Wait for dependencies with timeouts
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local Modules = ReplicatedStorage:WaitForChild("Modules", 5)

-- Load ErrorHandler first for error handling
local ErrorHandler
local errorHandlerSuccess, errorHandlerResult = pcall(function()
	return require(Modules:WaitForChild("ErrorHandler", 5))
end)

if errorHandlerSuccess then
	ErrorHandler = errorHandlerResult
else
	-- Fallback ErrorHandler with self parameter
	ErrorHandler = {
		LogWarning = function(self, msg, data) warn("[ChatCommandHandler] " .. tostring(msg)) end,
		LogError = function(self, msg, data) error("[ChatCommandHandler] " .. tostring(msg)) end,
		ValidateNotNil = function(self, val, ctx, fallback) return val or fallback end,
		LogDebug = function(self, msg, data) print("[DEBUG] " .. tostring(msg)) end,
		LogInfo = function(self, msg, data) print("[INFO] " .. tostring(msg)) end
	}
end

-- RemoteEvents with validation
local ChatCommandEvent = Remotes and Remotes:WaitForChild("ChatCommand", 5)
local WhisperMessageEvent = Remotes and Remotes:WaitForChild("WhisperMessage", 5)
local PartyMessageEvent = Remotes and Remotes:WaitForChild("PartyMessage", 5)

-- Validate remotes
if not ChatCommandEvent then
	ErrorHandler:LogError(ErrorHandler, "ChatCommand remote not found")
	return
end

-- Load other managers if available
local PartyManager
local TradeManager
local DataManager

local function loadManagers()
	-- Try to load PartyManager
	local partySuccess, partyResult = pcall(function()
		return require(Modules:WaitForChild("PartyManager", 5))
	end)
	
	if partySuccess then
		PartyManager = partyResult
	else
		PartyManager = nil
		ErrorHandler:LogWarning(ErrorHandler, "PartyManager not available", {error = partyResult})
	end
	
	-- Try to load TradeManager
	local tradeSuccess, tradeResult = pcall(function()
		return require(Modules:WaitForChild("TradeManager", 5))
	end)
	
	if tradeSuccess then
		TradeManager = tradeResult
	else
		TradeManager = nil
		ErrorHandler:LogWarning(ErrorHandler, "TradeManager not available", {error = tradeResult})
	end
	
	-- Try to load DataManager
	local dataSuccess, dataResult = pcall(function()
		return require(Modules:WaitForChild("DataManager", 5))
	end)
	
	if dataSuccess then
		DataManager = dataResult
	else
		DataManager = nil
		ErrorHandler:LogWarning(ErrorHandler, "DataManager not available", {error = dataResult})
	end
end

-- Initialize managers
loadManagers()

-- Command configuration
local COMMAND_CONFIG = {
	PREFIX = "/",
	COMMANDS = {
		["trade"] = {
			description = "Request a trade with another player",
			usage = "/trade <playerName>",
			minArgs = 1,
			handler = "handleTradeCommand"
		},
		["party"] = {
			description = "Party commands: invite, leave, kick, chat",
			usage = "/party <invite|leave|kick|chat> [args]",
			minArgs = 1,
			handler = "handlePartyCommand"
		},
		["whisper"] = {
			description = "Send a private message to another player",
			usage = "/whisper <playerName> <message>",
			minArgs = 2,
			handler = "handleWhisperCommand"
		},
		["help"] = {
			description = "Show available commands",
			usage = "/help [command]",
			minArgs = 0,
			handler = "handleHelpCommand"
		},
		["stats"] = {
			description = "Show your character statistics",
			usage = "/stats",
			minArgs = 0,
			handler = "handleStatsCommand"
		},
		["me"] = {
			description = "Roleplay action",
			usage = "/me <action>",
			minArgs = 1,
			handler = "handleMeCommand"
		},
		["roll"] = {
			description = "Roll a dice (1-100)",
			usage = "/roll [max]",
			minArgs = 0,
			handler = "handleRollCommand"
		},
		["time"] = {
			description = "Show server time",
			usage = "/time",
			minArgs = 0,
			handler = "handleTimeCommand"
		},
		["players"] = {
			description = "Show online players",
			usage = "/players",
			minArgs = 0,
			handler = "handlePlayersCommand"
		},
		["ignore"] = {
			description = "Ignore a player's messages",
			usage = "/ignore <playerName>",
			minArgs = 1,
			handler = "handleIgnoreCommand"
		},
		["unignore"] = {
			description = "Stop ignoring a player",
			usage = "/unignore <playerName>",
			minArgs = 1,
			handler = "handleUnignoreCommand"
		}
	}
}

-- Helper: Get player by name (case-insensitive)
local function getPlayerByName(playerName)
	if not playerName or type(playerName) ~= "string" then
		return nil
	end
	
	playerName = playerName:lower()
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Name:lower() == playerName then
			return player
		end
	end
	
	return nil
end

-- Helper: Send message to player
local function sendMessageToPlayer(player, message, messageType)
	-- messageType: "system", "error", "success", "whisper", "party"
	local color = Color3.fromRGB(255, 255, 255)
	
	if messageType == "error" then
		color = Color3.fromRGB(255, 100, 100)
	elseif messageType == "success" then
		color = Color3.fromRGB(100, 255, 100)
	elseif messageType == "system" then
		color = Color3.fromRGB(100, 200, 255)
	elseif messageType == "whisper" then
		color = Color3.fromRGB(255, 200, 100)
	elseif messageType == "party" then
		color = Color3.fromRGB(200, 100, 255)
	end
	
	-- Use TextChatService if available
	if TextChatService then
		local textChannel = TextChatService:FindFirstChild("TextChannels"):FindFirstChild("RBXSystem")
		if textChannel then
			textChannel:DisplaySystemMessage(message, player)
		else
			-- Fallback to RemoteEvent
			if Remotes:FindFirstChild("SystemMessage") then
				Remotes.SystemMessage:FireClient(player, message, color)
			end
		end
	else
		-- Fallback to RemoteEvent
		if Remotes:FindFirstChild("SystemMessage") then
			Remotes.SystemMessage:FireClient(player, message, color)
		end
	end
end

-- Helper: Broadcast message to all players
local function broadcastMessage(message, messageType)
	for _, player in ipairs(Players:GetPlayers()) do
		sendMessageToPlayer(player, message, messageType)
	end
end

-- Helper: Parse command arguments
local function parseCommand(input)
	if not input or type(input) ~= "string" then
		return nil, nil
	end
	
	-- Remove leading/trailing whitespace
	input = input:gsub("^%s*(.-)%s*$", "%1")
	
	-- Check if it's a command
	if not input:sub(1, 1) == COMMAND_CONFIG.PREFIX then
		return nil, nil
	end
	
	-- Remove prefix
	input = input:sub(2)
	
	-- Split into command and arguments
	local parts = {}
	for part in input:gmatch("%S+") do
		table.insert(parts, part)
	end
	
	if #parts == 0 then
		return nil, nil
	end
	
	local command = parts[1]:lower()
	table.remove(parts, 1)
	
	return command, parts
end

-- Command handlers
local function handleTradeCommand(player, args)
	if not TradeManager then
		sendMessageToPlayer(player, "Trading system is currently unavailable.", "error")
		return
	end
	
	if #args < 1 then
		sendMessageToPlayer(player, "Usage: /trade <playerName>", "error")
		return
	end
	
	local targetName = args[1]
	local targetPlayer = getPlayerByName(targetName)
	
	if not targetPlayer then
		sendMessageToPlayer(player, "Player not found: " .. targetName, "error")
		return
	end
	
	if targetPlayer == player then
		sendMessageToPlayer(player, "You cannot trade with yourself.", "error")
		return
	end
	
	-- Check if target is ignoring player
	-- (This would require an ignore system to be implemented)
	
	-- Send trade request
	-- This would call TradeManager:RequestTrade(player, targetPlayer)
	sendMessageToPlayer(player, "Trade request sent to " .. targetPlayer.Name, "success")
	sendMessageToPlayer(targetPlayer, player.Name .. " wants to trade with you.", "system")
	
	ErrorHandler:LogInfo(ErrorHandler, "Trade command executed", {
		from = player.Name,
		to = targetPlayer.Name
	})
end

local function handlePartyCommand(player, args)
	if not PartyManager then
		sendMessageToPlayer(player, "Party system is currently unavailable.", "error")
		return
	end
	
	if #args < 1 then
		sendMessageToPlayer(player, "Usage: /party <invite|leave|kick|chat> [args]", "error")
		return
	end
	
	local subCommand = args[1]:lower()
	table.remove(args, 1)
	
	if subCommand == "invite" then
		if #args < 1 then
			sendMessageToPlayer(player, "Usage: /party invite <playerName>", "error")
			return
		end
		
		local targetName = args[1]
		local targetPlayer = getPlayerByName(targetName)
		
		if not targetPlayer then
			sendMessageToPlayer(player, "Player not found: " .. targetName, "error")
			return
		end
		
		if targetPlayer == player then
			sendMessageToPlayer(player, "You cannot invite yourself.", "error")
			return
		end
		
		-- Send party invite
		-- This would call PartyManager:InvitePlayer(player, targetPlayer)
		sendMessageToPlayer(player, "Party invite sent to " .. targetPlayer.Name, "success")
		sendMessageToPlayer(targetPlayer, player.Name .. " invited you to their party.", "system")
		
	elseif subCommand == "leave" then
		-- Leave party
		-- This would call PartyManager:LeaveParty(player)
		sendMessageToPlayer(player, "You left the party.", "success")
		
	elseif subCommand == "kick" then
		if #args < 1 then
			sendMessageToPlayer(player, "Usage: /party kick <playerName>", "error")
			return
		end
		
		local targetName = args[1]
		local targetPlayer = getPlayerByName(targetName)
		
		if not targetPlayer then
			sendMessageToPlayer(player, "Player not found: " .. targetName, "error")
			return
		end
		
		-- Kick player from party
		-- This would call PartyManager:KickPlayer(player, targetPlayer)
		sendMessageToPlayer(player, "Kicked " .. targetPlayer.Name .. " from the party.", "success")
		sendMessageToPlayer(targetPlayer, "You were kicked from the party.", "system")
		
	elseif subCommand == "chat" then
		if #args < 1 then
			sendMessageToPlayer(player, "Usage: /party chat <message>", "error")
			return
		end
		
		local message = table.concat(args, " ")
		
		-- Send party chat message
		if PartyMessageEvent then
			PartyMessageEvent:FireServer(player, message)
		end
		
		sendMessageToPlayer(player, "[Party] " .. player.Name .. ": " .. message, "party")
		
	else
		sendMessageToPlayer(player, "Unknown party command: " .. subCommand, "error")
		sendMessageToPlayer(player, "Available commands: invite, leave, kick, chat", "system")
	end
	
	ErrorHandler:LogInfo(ErrorHandler, "Party command executed", {
		player = player.Name,
		command = subCommand,
		args = args
	})
end

local function handleWhisperCommand(player, args)
	if #args < 2 then
		sendMessageToPlayer(player, "Usage: /whisper <playerName> <message>", "error")
		return
	end
	
	local targetName = args[1]
	local targetPlayer = getPlayerByName(targetName)
	
	if not targetPlayer then
		sendMessageToPlayer(player, "Player not found: " .. targetName, "error")
		return
	end
	
	if targetPlayer == player then
		sendMessageToPlayer(player, "You cannot whisper to yourself.", "error")
		return
	end
	
	-- Check if target is ignoring player
	-- (This would require an ignore system to be implemented)
	
	local message = table.concat(args, " ", 2)
	
	-- Send whisper message
	if WhisperMessageEvent then
		WhisperMessageEvent:FireServer(player, targetPlayer, message)
	end
	
	-- Notify sender
	sendMessageToPlayer(player, "[To " .. targetPlayer.Name .. "] " .. message, "whisper")
	
	-- Notify receiver
	sendMessageToPlayer(targetPlayer, "[From " .. player.Name .. "] " .. message, "whisper")
	
	ErrorHandler:LogInfo(ErrorHandler, "Whisper command executed", {
		from = player.Name,
		to = targetPlayer.Name,
		message = message
	})
end

local function handleHelpCommand(player, args)
	if #args == 0 then
		-- Show all commands
		local helpText = "Available commands:\n"
		
		for cmdName, cmdInfo in pairs(COMMAND_CONFIG.COMMANDS) do
			helpText = helpText .. string.format("  %s%s - %s\n", 
				COMMAND_CONFIG.PREFIX, cmdName, cmdInfo.description)
		end
		
		helpText = helpText .. "\nUse /help <command> for more information."
		sendMessageToPlayer(player, helpText, "system")
		
	else
		-- Show specific command help
		local cmdName = args[1]:lower()
		local cmdInfo = COMMAND_CONFIG.COMMANDS[cmdName]
		
		if cmdInfo then
			local helpText = string.format("Command: %s%s\n", COMMAND_CONFIG.PREFIX, cmdName)
			helpText = helpText .. "Description: " .. cmdInfo.description .. "\n"
			helpText = helpText .. "Usage: " .. cmdInfo.usage .. "\n"
			helpText = helpText .. "Minimum arguments: " .. tostring(cmdInfo.minArgs)
			
			sendMessageToPlayer(player, helpText, "system")
		else
			sendMessageToPlayer(player, "Unknown command: " .. cmdName, "error")
		end
	end
	
	ErrorHandler:LogDebug(ErrorHandler, "Help command executed", {
		player = player.Name,
		args = args
	})
end

local function handleStatsCommand(player, args)
	if not DataManager then
		sendMessageToPlayer(player, "Stats system is currently unavailable.", "error")
		return
	end
	
	-- Get player data
	local playerData = DataManager:GetData(player)
	
	if not playerData then
		sendMessageToPlayer(player, "Could not load your data.", "error")
		return
	end
	
	-- Format stats
	local statsText = "=== Your Statistics ===\n"
	
	-- Combat stats
	if playerData.combat then
		statsText = statsText .. string.format("Combat Level: %d\n", playerData.combat.level or 1)
		statsText = statsText .. string.format("Hitpoints: %d/%d\n", 
			playerData.combat.currentHP or 10, playerData.combat.maxHP or 10)
		statsText = statsText .. string.format("Prayer: %d/%d\n",
			playerData.combat.currentPrayer or 10, playerData.combat.maxPrayer or 10)
	end
	
	-- Skills
	if playerData.skills then
		statsText = statsText .. "\n=== Skills ===\n"
		
		local skillNames = {"attack", "strength", "defense", "ranged", "magic", "prayer", 
			"mining", "woodcutting", "fishing", "cooking", "crafting", "smithing", "fletching"}
		
		for _, skillName in ipairs(skillNames) do
			local skill = playerData.skills[skillName]
			if skill then
				statsText = statsText .. string.format("%s: Level %d (XP: %d)\n",
					skillName:gsub("^%l", string.upper), skill.level or 1, skill.xp or 0)
			end
		end
	end
	
	-- Equipment
	if playerData.equipment then
		statsText = statsText .. "\n=== Equipment ===\n"
		
		local slotNames = {"head", "cape", "neck", "ammo", "weapon", "body", "shield", "legs", "hands", "feet", "ring"}
		
		for _, slotName in ipairs(slotNames) do
			local item = playerData.equipment[slotName]
			if item and item.id then
				statsText = statsText .. string.format("%s: %s\n",
					slotName:gsub("^%l", string.upper), item.name or "Unknown")
			else
				statsText = statsText .. string.format("%s: Empty\n",
					slotName:gsub("^%l", string.upper))
			end
		end
	end
	
	-- Inventory
	if playerData.inventory then
		local itemCount = 0
		for _, item in pairs(playerData.inventory) do
			if item and item.id then
				itemCount = itemCount + 1
			end
		end
		
		statsText = statsText .. string.format("\n=== Inventory ===\nItems: %d/28\n", itemCount)
	end
	
	-- Bank
	if playerData.bank then
		local bankCount = 0
		for _, item in pairs(playerData.bank) do
			if item and item.id then
				bankCount = bankCount + 1
			end
		end
		
		statsText = statsText .. string.format("Bank items: %d\n", bankCount)
	end
	
	-- Gold
	statsText = statsText .. string.format("\n=== Wealth ===\nGold: %d\n", playerData.gold or 0)
	
	-- Quests
	if playerData.quests then
		local completed = 0
		local total = 0
		
		for _, quest in pairs(playerData.quests) do
			total = total + 1
			if quest.completed then
				completed = completed + 1
			end
		end
		
		statsText = statsText .. string.format("Quests: %d/%d completed\n", completed, total)
	end
	
	-- Playtime
	if playerData.playtime then
		local hours = math.floor(playerData.playtime / 3600)
		local minutes = math.floor((playerData.playtime % 3600) / 60)
		
		statsText = statsText .. string.format("Playtime: %d hours, %d minutes\n", hours, minutes)
	end
	
	sendMessageToPlayer(player, statsText, "system")
	
	ErrorHandler:LogDebug(ErrorHandler, "Stats command executed", {
		player = player.Name
	})
end

local function handleMeCommand(player, args)
	if #args < 1 then
		sendMessageToPlayer(player, "Usage: /me <action>", "error")
		return
	end
	
	local action = table.concat(args, " ")
	
	-- Broadcast roleplay action
	broadcastMessage("* " .. player.Name .. " " .. action, "system")
	
	ErrorHandler:LogDebug(ErrorHandler, "Me command executed", {
		player = player.Name,
		action = action
	})
end

local function handleRollCommand(player, args)
	local max = 100
	
	if #args >= 1 then
		local arg = args[1]
		if tonumber(arg) then
			max = math.floor(tonumber(arg))
			if max < 2 then max = 2 end
			if max > 1000 then max = 1000 end
		end
	end
	
	local roll = math.random(1, max)
	
	-- Broadcast roll result
	broadcastMessage(player.Name .. " rolled " .. roll .. " (1-" .. max .. ")", "system")
	
	ErrorHandler:LogDebug(ErrorHandler, "Roll command executed", {
		player = player.Name,
		roll = roll,
		max = max
	})
end

local function handleTimeCommand(player, args)
	local currentTime = os.time()
	local timeString = os.date("%I:%M %p", currentTime)
	local dateString = os.date("%B %d, %Y", currentTime)
	
	sendMessageToPlayer(player, "Server time: " .. timeString .. "\nDate: " .. dateString, "system")
	
	ErrorHandler:LogDebug(ErrorHandler, "Time command executed", {
		player = player.Name
	})
end

local function handlePlayersCommand(player, args)
	local playerCount = #Players:GetPlayers()
	local playerNames = {}
	
	for _, p in ipairs(Players:GetPlayers()) do
		table.insert(playerNames, p.Name)
	end
	
	table.sort(playerNames)
	
	local playersText = "=== Online Players ===\n"
	playersText = playersText .. "Total: " .. playerCount .. "\n\n"
	
	for i, name in ipairs(playerNames) do
		playersText = playersText .. name .. "\n"
	end
	
	sendMessageToPlayer(player, playersText, "system")
	
	ErrorHandler:LogDebug(ErrorHandler, "Players command executed", {
		player = player.Name,
		count = playerCount
	})
end

local function handleIgnoreCommand(player, args)
	if #args < 1 then
		sendMessageToPlayer(player, "Usage: /ignore <playerName>", "error")
		return
	end
	
	local targetName = args[1]
	local targetPlayer = getPlayerByName(targetName)
	
	if not targetPlayer then
		sendMessageToPlayer(player, "Player not found: " .. targetName, "error")
		return
	end
	
	if targetPlayer == player then
		sendMessageToPlayer(player, "You cannot ignore yourself.", "error")
		return
	end
	
	-- Add to ignore list
	-- This would require an ignore system to be implemented
	sendMessageToPlayer(player, "Now ignoring " .. targetPlayer.Name, "success")
	
	ErrorHandler:LogInfo(ErrorHandler, "Ignore command executed", {
		player = player.Name,
		target = targetPlayer.Name
	})
end

local function handleUnignoreCommand(player, args)
	if #args < 1 then
		sendMessageToPlayer(player, "Usage: /unignore <playerName>", "error")
		return
	end
	
	local targetName = args[1]
	local targetPlayer = getPlayerByName(targetName)
	
	if not targetPlayer then
		sendMessageToPlayer(player, "Player not found: " .. targetName, "error")
		return
	end
	
	-- Remove from ignore list
	-- This would require an ignore system to be implemented
	sendMessageToPlayer(player, "No longer ignoring " .. targetPlayer.Name, "success")
	
	ErrorHandler:LogInfo(ErrorHandler, "Unignore command executed", {
		player = player.Name,
		target = targetPlayer.Name
	})
end

-- Main command handler
local function handleCommand(player, input)
	-- Parse command
	local command, args = parseCommand(input)
	
	if not command then
		-- Not a command, could be regular chat
		return false
	end
	
	-- Get command info
	local cmdInfo = COMMAND_CONFIG.COMMANDS[command]
	
	if not cmdInfo then
		sendMessageToPlayer(player, "Unknown command: " .. command, "error")
		sendMessageToPlayer(player, "Type /help for available commands.", "system")
		return true
	end
	
	-- Check minimum arguments
	if #args < cmdInfo.minArgs then
		sendMessageToPlayer(player, "Usage: " .. cmdInfo.usage, "error")
		return true
	end
	
	-- Call command handler
	local handler = _G[cmdInfo.handler]
	if not handler then
		handler = _G["handle" .. command:gsub("^%l", string.upper) .. "Command"]
	end
	
	if handler then
		local success, result = pcall(handler, player, args)
		
		if not success then
			ErrorHandler:LogError(ErrorHandler, "Command handler error", {
				player = player.Name,
				command = command,
				error = result
			})
			
			sendMessageToPlayer(player, "An error occurred while processing the command.", "error")
		end
	else
		sendMessageToPlayer(player, "Command not implemented: " .. command, "error")
	end
	
	return true
end

-- Remote event handlers
ChatCommandEvent.OnServerEvent:Connect(function(player, message)
	-- Validate player
	if not player or not player:IsA("Player") then
		ErrorHandler:LogWarning(ErrorHandler, "Invalid player for chat command")
		return
	end
	
	-- Validate message
	if not message or type(message) ~= "string" then
		ErrorHandler:LogWarning(ErrorHandler, "Invalid message for chat command", {
			player = player.Name
		})
		return
	end
	
	-- Trim message
	message = message:gsub("^%s*(.-)%s*$", "%1")
	
	if message == "" then
		return
	end
	
	-- Handle command
	local isCommand = handleCommand(player, message)
	
	if not isCommand then
		-- Regular chat message (could be processed here if needed)
		ErrorHandler:LogDebug(ErrorHandler, "Regular chat message", {
			player = player.Name,
			message = message
		})
	end
end)

WhisperMessageEvent.OnServerEvent:Connect(function(sender, target, message)
	-- Validate players
	if not sender or not sender:IsA("Player") then
		ErrorHandler:LogWarning(ErrorHandler, "Invalid sender for whisper")
		return
	end
	
	if not target or not target:IsA("Player") then
		sendMessageToPlayer(sender, "Player not found or offline.", "error")
		return
	end
	
	-- Validate message
	if not message or type(message) ~= "string" then
		ErrorHandler:LogWarning(ErrorHandler, "Invalid message for whisper", {
			sender = sender.Name,
			target = target.Name
		})
		return
	end
	
	-- Trim message
	message = message:gsub("^%s*(.-)%s*$", "%1")
	
	if message == "" then
		return
	end
	
	-- Check if target is ignoring sender
	-- (This would require an ignore system to be implemented)
	
	-- Send whisper
	sendMessageToPlayer(sender, "[To " .. target.Name .. "] " .. message, "whisper")
	sendMessageToPlayer(target, "[From " .. sender.Name .. "] " .. message, "whisper")
	
	ErrorHandler:LogInfo(ErrorHandler, "Whisper sent", {
		from = sender.Name,
		to = target.Name,
		message = message
	})
end)

PartyMessageEvent.OnServerEvent:Connect(function(player, message)
	-- Validate player
	if not player or not player:IsA("Player") then
		ErrorHandler:LogWarning(ErrorHandler, "Invalid player for party message")
		return
	end
	
	-- Validate message
	if not message or type(message) ~= "string" then
		ErrorHandler:LogWarning(ErrorHandler, "Invalid message for party chat", {
			player = player.Name
		})
		return
	end
	
	-- Trim message
	message = message:gsub("^%s*(.-)%s*$", "%1")
	
	if message == "" then
		return
	end
	
	-- Check if player is in a party
	-- This would require PartyManager integration
	
	-- For now, just echo back to player
	sendMessageToPlayer(player, "[Party] " .. player.Name .. ": " .. message, "party")
	
	ErrorHandler:LogDebug(ErrorHandler, "Party message", {
		player = player.Name,
		message = message
	})
end)

-- Player join handler
Players.PlayerAdded:Connect(function(player)
	-- Send welcome message with command info
	task.wait(2) -- Wait a bit for player to load
	
	sendMessageToPlayer(player, "Welcome to Roscape Runeblocks!", "system")
	sendMessageToPlayer(player, "Type /help for available commands.", "system")
	
	ErrorHandler:LogInfo(ErrorHandler, "Player joined - command system initialized", {
		player = player.Name
	})
end)

-- Initialize
ErrorHandler:LogInfo(ErrorHandler, "ChatCommandHandler loaded successfully", {
	commandCount = #COMMAND_CONFIG.COMMANDS,
	prefix = COMMAND_CONFIG.PREFIX
})