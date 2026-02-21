-- FriendManager.server.lua
-- Server-side friend system with error handling

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")

-- Wait for dependencies with timeouts
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local Modules = ReplicatedStorage:WaitForChild("Modules", 5)

-- Load ErrorHandler first for error handling
local ErrorHandler
local dataManagerSuccess, DataManager = pcall(function()
	return require(Modules:WaitForChild("DataManager", 5))
end)

-- Initialize ErrorHandler
local errorHandlerSuccess, errorHandlerResult = pcall(function()
	return require(Modules:WaitForChild("ErrorHandler", 5))
end)

if errorHandlerSuccess then
	ErrorHandler = errorHandlerResult
else
	-- Fallback ErrorHandler with self parameter
	ErrorHandler = {
		LogWarning = function(self, msg, data) warn("[FriendManager] " .. tostring(msg)) end,
		LogError = function(self, msg, data) error("[FriendManager] " .. tostring(msg)) end,
		ValidateNotNil = function(self, val, ctx, fallback) return val or fallback end,
		LogDebug = function(self, msg, data) print("[DEBUG] " .. tostring(msg)) end,
		LogInfo = function(self, msg, data) print("[INFO] " .. tostring(msg)) end,
		SafeDataStoreOperation = function(self, opName, callback, fallback)
			local s, r = pcall(callback)
			return s and r or fallback
		end
	}
end

-- Validate dependencies
if not dataManagerSuccess then
	ErrorHandler:LogError(ErrorHandler, "Failed to load DataManager", {error = DataManager})
	DataManager = {
		GetData = function(player) 
			return {friends = {}, friendRequests = {}}
		end,
		UpdateData = function() return true end,
		SaveData = function() return true end
	}
end

-- RemoteEvents with validation
local FriendRequestEvent = Remotes and Remotes:WaitForChild("FriendRequest", 5)
local FriendAcceptEvent = Remotes and Remotes:WaitForChild("FriendAccept", 5)
local FriendDeclineEvent = Remotes and Remotes:WaitForChild("FriendDecline", 5)
local FriendRemoveEvent = Remotes and Remotes:WaitForChild("FriendRemove", 5)
local FriendUpdateEvent = Remotes and Remotes:WaitForChild("FriendUpdate", 5)

-- Validate remotes
if not FriendRequestEvent then
	ErrorHandler:LogError(ErrorHandler, "FriendRequest remote not found")
	return
end

-- Friend system configuration
local FRIEND_CONFIG = {
	MAX_FRIENDS = 50,
	REQUEST_COOLDOWN = 30, -- seconds
	DATASTORE_KEY = "FriendData_v1"
}

-- DataStore for friend data (persistent across servers)
local FriendDataStore
local dataStoreAvailable = false

local function initializeDataStore()
	return ErrorHandler:SafeDataStoreOperation( "GetFriendDataStore", function()
		FriendDataStore = DataStoreService:GetDataStore(FRIEND_CONFIG.DATASTORE_KEY)
		dataStoreAvailable = true
		return true
	end, false)
end

-- Initialize DataStore
local initSuccess = initializeDataStore()
if not initSuccess then
	ErrorHandler:LogWarning(ErrorHandler, "Friend DataStore initialization failed, using memory only")
	dataStoreAvailable = false
end

-- In-memory cache for friend data
local friendDataCache = {}
local pendingRequests = {} -- Track pending friend requests

-- Helper: Get friend data for player
local function getFriendData(player)
	local userId = tostring(player.UserId)
	
	-- Check cache first
	if friendDataCache[userId] then
		return friendDataCache[userId]
	end
	
	-- Try DataStore if available
	local friendData = ErrorHandler:SafeDataStoreOperation("LoadFriendData", function()
		if dataStoreAvailable then
			return FriendDataStore:GetAsync(userId)
		end
		return nil
	end, nil)
	
	-- Initialize default friend data if none exists
	if not friendData then
		friendData = {
			friends = {}, -- {userId = {name = "PlayerName", online = false, lastSeen = os.time()}}
			friendRequests = {}, -- {fromUserId = timestamp}
			sentRequests = {}, -- {toUserId = timestamp}
			settings = {
				allowFriendRequests = true,
				showOnlineStatus = true
			}
		}
	end
	
	-- Cache the data
	friendDataCache[userId] = friendData
	
	return friendData
end

-- Helper: Save friend data for player
local function saveFriendData(player, friendData)
	local userId = tostring(player.UserId)
	
	-- Update cache
	friendDataCache[userId] = friendData
	
	-- Save to DataStore if available
	return ErrorHandler:SafeDataStoreOperation( "SaveFriendData", function()
		if dataStoreAvailable then
			FriendDataStore:SetAsync(userId, friendData)
			return true
		end
		return false
	end, true)
end

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

-- Helper: Validate friend request
local function validateFriendRequest(sender, targetName)
	-- Check sender
	if not sender or not sender:IsA("Player") then
		return false, "Invalid sender"
	end
	
	-- Check if sender can send requests
	local senderData = getFriendData(sender)
	if #senderData.friends >= FRIEND_CONFIG.MAX_FRIENDS then
		return false, "Friend list full (max " .. tostring(FRIEND_CONFIG.MAX_FRIENDS) .. ")"
	end
	
	-- Check cooldown for sent requests
	local currentTime = os.time()
	for targetUserId, sentTime in pairs(senderData.sentRequests) do
		if currentTime - sentTime < FRIEND_CONFIG.REQUEST_COOLDOWN then
			return false, "Please wait before sending another request"
		end
	end
	
	-- Find target player
	local targetPlayer = getPlayerByName(targetName)
	if not targetPlayer then
		return false, "Player not found: " .. tostring(targetName)
	end
	
	-- Can't friend yourself
	if targetPlayer == sender then
		return false, "You cannot add yourself as a friend"
	end
	
	-- Check if already friends
	local targetUserId = tostring(targetPlayer.UserId)
	if senderData.friends[targetUserId] then
		return false, "Already friends with " .. tostring(targetPlayer.Name)
	end
	
	-- Check if request already pending
	if senderData.sentRequests[targetUserId] then
		return false, "Friend request already sent to " .. tostring(targetPlayer.Name)
	end
	
	-- Check target's settings
	local targetData = getFriendData(targetPlayer)
	if not targetData.settings.allowFriendRequests then
		return false, tostring(targetPlayer.Name) .. " is not accepting friend requests"
	end
	
	-- Check target's friend list capacity
	if #targetData.friends >= FRIEND_CONFIG.MAX_FRIENDS then
		return false, tostring(targetPlayer.Name) .. "'s friend list is full"
	end
	
	return true, "Valid", targetPlayer, targetUserId
end

-- Helper: Send friend request
local function sendFriendRequest(sender, targetPlayer, targetUserId)
	local senderData = getFriendData(sender)
	local targetData = getFriendData(targetPlayer)
	local currentTime = os.time()
	
	-- Add to sender's sent requests
	senderData.sentRequests[targetUserId] = currentTime
	
	-- Add to target's pending requests
	targetData.friendRequests[tostring(sender.UserId)] = {
		fromName = sender.Name,
		timestamp = currentTime
	}
	
	-- Save data
	saveFriendData(sender, senderData)
	saveFriendData(targetPlayer, targetData)
	
	-- Notify target player
	if FriendUpdateEvent then
		FriendUpdateEvent:FireClient(targetPlayer, "request", {
			fromUserId = tostring(sender.UserId),
			fromName = sender.Name,
			timestamp = currentTime
		})
	end
	
	-- Track pending request
	pendingRequests[tostring(sender.UserId) .. "_" .. targetUserId] = {
		sender = sender,
		target = targetPlayer,
		timestamp = currentTime
	}
	
	ErrorHandler:LogInfo(ErrorHandler, "Friend request sent", {
		from = sender.Name,
		to = targetPlayer.Name
	})
	
	return true
end

-- Helper: Accept friend request
local function acceptFriendRequest(player, fromUserId)
	local playerData = getFriendData(player)
	
	-- Check if request exists
	local request = playerData.friendRequests[fromUserId]
	if not request then
		return false, "Friend request not found"
	end
	
	-- Find sender player
	local senderPlayer = Players:GetPlayerByUserId(tonumber(fromUserId))
	local senderName = request.fromName
	
	-- Get sender data (even if offline)
	local senderData
	if senderPlayer then
		senderData = getFriendData(senderPlayer)
	else
		-- Load sender data from DataStore for offline acceptance
		senderData = ErrorHandler:SafeDataStoreOperation( "LoadOfflineFriendData", function()
			if dataStoreAvailable then
				return FriendDataStore:GetAsync(fromUserId)
			end
			return nil
		end, nil)
		
		if not senderData then
			return false, "Could not load sender data"
		end
	end
	
	-- Check if still within friend limits
	if #playerData.friends >= FRIEND_CONFIG.MAX_FRIENDS then
		return false, "Your friend list is full"
	end
	
	if #senderData.friends >= FRIEND_CONFIG.MAX_FRIENDS then
		return false, senderName .. "'s friend list is full"
	end
	
	-- Add to each other's friend lists
	local playerUserId = tostring(player.UserId)
	
	playerData.friends[fromUserId] = {
		name = senderName,
		online = senderPlayer ~= nil,
		lastSeen = os.time()
	}
	
	senderData.friends[playerUserId] = {
		name = player.Name,
		online = true,
		lastSeen = os.time()
	}
	
	-- Remove from pending requests
	playerData.friendRequests[fromUserId] = nil
	
	-- Remove from sender's sent requests
	senderData.sentRequests[playerUserId] = nil
	
	-- Save data
	saveFriendData(player, playerData)
	
	if senderPlayer then
		saveFriendData(senderPlayer, senderData)
		
		-- Notify sender
		if FriendUpdateEvent then
			FriendUpdateEvent:FireClient(senderPlayer, "accepted", {
				userId = playerUserId,
				name = player.Name
			})
		end
	else
		-- Save offline sender data
		ErrorHandler:SafeDataStoreOperation( "SaveOfflineFriendData", function()
			if dataStoreAvailable then
				FriendDataStore:SetAsync(fromUserId, senderData)
			end
			return true
		end, true)
	end
	
	-- Clean up pending request
	pendingRequests[fromUserId .. "_" .. playerUserId] = nil
	
	ErrorHandler:LogInfo(ErrorHandler, "Friend request accepted", {
		player = player.Name,
		friend = senderName
	})
	
	return true, senderName
end

-- Helper: Decline friend request
local function declineFriendRequest(player, fromUserId)
	local playerData = getFriendData(player)
	
	-- Check if request exists
	local request = playerData.friendRequests[fromUserId]
	if not request then
		return false, "Friend request not found"
	end
	
	-- Remove from pending requests
	playerData.friendRequests[fromUserId] = nil
	
	-- Remove from sender's sent requests if online
	local senderPlayer = Players:GetPlayerByUserId(tonumber(fromUserId))
	if senderPlayer then
		local senderData = getFriendData(senderPlayer)
		senderData.sentRequests[tostring(player.UserId)] = nil
		saveFriendData(senderPlayer, senderData)
		
		-- Notify sender
		if FriendUpdateEvent then
			FriendUpdateEvent:FireClient(senderPlayer, "declined", {
				userId = tostring(player.UserId),
				name = player.Name
			})
		end
	end
	
	-- Save player data
	saveFriendData(player, playerData)
	
	-- Clean up pending request
	pendingRequests[fromUserId .. "_" .. tostring(player.UserId)] = nil
	
	ErrorHandler:LogInfo(ErrorHandler, "Friend request declined", {
		player = player.Name,
		from = request.fromName
	})
	
	return true, request.fromName
end

-- Helper: Remove friend
local function removeFriend(player, friendUserId)
	local playerData = getFriendData(player)
	
	-- Check if friend exists
	local friendInfo = playerData.friends[friendUserId]
	if not friendInfo then
		return false, "Friend not found"
	end
	
	-- Remove from player's friend list
	playerData.friends[friendUserId] = nil
	
	-- Remove from friend's friend list if online
	local friendPlayer = Players:GetPlayerByUserId(tonumber(friendUserId))
	if friendPlayer then
		local friendData = getFriendData(friendPlayer)
		friendData.friends[tostring(player.UserId)] = nil
		saveFriendData(friendPlayer, friendData)
		
		-- Notify friend
		if FriendUpdateEvent then
			FriendUpdateEvent:FireClient(friendPlayer, "removed", {
				userId = tostring(player.UserId),
				name = player.Name
			})
		end
	else
		-- Update offline friend data
		ErrorHandler:SafeDataStoreOperation( "UpdateOfflineFriendData", function()
			if dataStoreAvailable then
				local offlineFriendData = FriendDataStore:GetAsync(friendUserId)
				if offlineFriendData then
					offlineFriendData.friends[tostring(player.UserId)] = nil
					FriendDataStore:SetAsync(friendUserId, offlineFriendData)
				end
			end
			return true
		end, true)
	end
	
	-- Save player data
	saveFriendData(player, playerData)
	
	ErrorHandler:LogInfo(ErrorHandler, "Friend removed", {
		player = player.Name,
		friend = friendInfo.name
	})
	
	return true, friendInfo.name
end

-- Helper: Update online status for all friends
local function updateOnlineStatus(player, isOnline)
	local playerData = getFriendData(player)
	local playerUserId = tostring(player.UserId)
	
	-- Update player's online status in all friends' lists
	for friendUserId, friendInfo in pairs(playerData.friends) do
		local friendPlayer = Players:GetPlayerByUserId(tonumber(friendUserId))
		if friendPlayer then
			local friendData = getFriendData(friendPlayer)
			if friendData.friends[playerUserId] then
				friendData.friends[playerUserId].online = isOnline
				friendData.friends[playerUserId].lastSeen = os.time()
				saveFriendData(friendPlayer, friendData)
				
				-- Notify friend of status change
				if FriendUpdateEvent then
					FriendUpdateEvent:FireClient(friendPlayer, "status", {
						userId = playerUserId,
						name = player.Name,
						online = isOnline
					})
				end
			end
		end
	end
	
	ErrorHandler:LogDebug(ErrorHandler, "Online status updated", {
		player = player.Name,
		online = isOnline
	})
end

-- Helper: Get friend list for player
local function getFriendList(player)
	local playerData = getFriendData(player)
	local friendList = {}
	
	for friendUserId, friendInfo in pairs(playerData.friends) do
		table.insert(friendList, {
			userId = friendUserId,
			name = friendInfo.name,
			online = friendInfo.online,
			lastSeen = friendInfo.lastSeen
		})
	end
	
	-- Sort by online status (online first), then by name
	table.sort(friendList, function(a, b)
		if a.online ~= b.online then
			return a.online
		end
		return a.name:lower() < b.name:lower()
	end)
	
	return friendList
end

-- Helper: Get pending requests for player
local function getPendingRequests(player)
	local playerData = getFriendData(player)
	local requests = {}
	
	for fromUserId, requestData in pairs(playerData.friendRequests) do
		table.insert(requests, {
			fromUserId = fromUserId,
			fromName = requestData.fromName,
			timestamp = requestData.timestamp
		})
	end
	
	-- Sort by timestamp (newest first)
	table.sort(requests, function(a, b)
		return a.timestamp > b.timestamp
	end)
	
	return requests
end

-- Remote event handlers
FriendRequestEvent.OnServerEvent:Connect(function(player, targetName)
	-- Validate and send friend request
	local isValid, errorMessage, targetPlayer, targetUserId = validateFriendRequest(player, targetName)
	
	if not isValid then
		ErrorHandler:LogDebug(ErrorHandler, "Friend request validation failed", {
			player = player.Name,
			target = targetName,
			error = errorMessage
		})
		
		-- Notify player of failure
		if FriendUpdateEvent then
			FriendUpdateEvent:FireClient(player, "error", errorMessage)
		end
		return
	end
	
	-- Send friend request
	local success = sendFriendRequest(player, targetPlayer, targetUserId)
	
	if success then
		-- Notify player of success
		if FriendUpdateEvent then
			FriendUpdateEvent:FireClient(player, "sent", {
				toName = targetPlayer.Name
			})
		end
	else
		-- Notify player of failure
		if FriendUpdateEvent then
			FriendUpdateEvent:FireClient(player, "error", "Failed to send friend request")
		end
	end
end)

FriendAcceptEvent.OnServerEvent:Connect(function(player, fromUserId)
	-- Accept friend request
	local success, resultMessage = acceptFriendRequest(player, fromUserId)
	
	if success then
		-- Send updated friend list to player
		local friendList = getFriendList(player)
		local pendingRequests = getPendingRequests(player)
		
		if FriendUpdateEvent then
			FriendUpdateEvent:FireClient(player, "list", {
				friends = friendList,
				requests = pendingRequests
			})
		end
		
		ErrorHandler:LogInfo(ErrorHandler, "Friend request accepted", {
			player = player.Name,
			friend = resultMessage
		})
	else
		-- Notify player of failure
		if FriendUpdateEvent then
			FriendUpdateEvent:FireClient(player, "error", resultMessage or "Failed to accept friend request")
		end
	end
end)

FriendDeclineEvent.OnServerEvent:Connect(function(player, fromUserId)
	-- Decline friend request
	local success, resultMessage = declineFriendRequest(player, fromUserId)
	
	if success then
		-- Send updated pending requests to player
		local pendingRequests = getPendingRequests(player)
		
		if FriendUpdateEvent then
			FriendUpdateEvent:FireClient(player, "requests", pendingRequests)
		end
		
		ErrorHandler:LogInfo(ErrorHandler, "Friend request declined", {
			player = player.Name,
			from = resultMessage
		})
	else
		-- Notify player of failure
		if FriendUpdateEvent then
			FriendUpdateEvent:FireClient(player, "error", resultMessage or "Failed to decline friend request")
		end
	end
end)

FriendRemoveEvent.OnServerEvent:Connect(function(player, friendUserId)
	-- Remove friend
	local success, resultMessage = removeFriend(player, friendUserId)
	
	if success then
		-- Send updated friend list to player
		local friendList = getFriendList(player)
		
		if FriendUpdateEvent then
			FriendUpdateEvent:FireClient(player, "list", {
				friends = friendList,
				requests = getPendingRequests(player)
			})
		end
		
		ErrorHandler:LogInfo(ErrorHandler, "Friend removed", {
			player = player.Name,
			friend = resultMessage
		})
	else
		-- Notify player of failure
		if FriendUpdateEvent then
			FriendUpdateEvent:FireClient(player, "error", resultMessage or "Failed to remove friend")
		end
	end
end)

-- Player join/leave handlers
Players.PlayerAdded:Connect(function(player)
	-- Load friend data
	getFriendData(player)
	
	-- Update online status for all friends
	updateOnlineStatus(player, true)
	
	-- Send initial friend data to player
	local friendList = getFriendList(player)
	local pendingRequests = getPendingRequests(player)
	
	if FriendUpdateEvent then
		FriendUpdateEvent:FireClient(player, "init", {
			friends = friendList,
			requests = pendingRequests,
			maxFriends = FRIEND_CONFIG.MAX_FRIENDS
		})
	end
	
	ErrorHandler:LogInfo(ErrorHandler, "Player joined - friend system initialized", {
		player = player.Name,
		friendCount = #friendList,
		requestCount = #pendingRequests
	})
end)

Players.PlayerRemoving:Connect(function(player)
	-- Update online status for all friends
	updateOnlineStatus(player, false)
	
	-- Save friend data
	local playerData = getFriendData(player)
	saveFriendData(player, playerData)
	
	-- Clean up cache
	friendDataCache[tostring(player.UserId)] = nil
	
	ErrorHandler:LogInfo(ErrorHandler, "Player left - friend system cleaned up", {
		player = player.Name
	})
end)

-- Clean up old pending requests periodically
local function cleanupOldRequests()
	local currentTime = os.time()
	local removedCount = 0
	
	for requestKey, requestData in pairs(pendingRequests) do
		if currentTime - requestData.timestamp > FRIEND_CONFIG.REQUEST_COOLDOWN * 2 then
			-- Request is too old, clean it up
			pendingRequests[requestKey] = nil
			removedCount = removedCount + 1
		end
	end
	
	if removedCount > 0 then
		ErrorHandler:LogDebug(ErrorHandler, "Cleaned up old pending requests", {
			count = removedCount
		})
	end
end

-- Periodic cleanup
RunService.Heartbeat:Connect(function(deltaTime)
	cleanupOldRequests()
end)

-- Initialize
ErrorHandler:LogInfo(ErrorHandler, "FriendManager loaded successfully", {
	maxFriends = FRIEND_CONFIG.MAX_FRIENDS,
	requestCooldown = FRIEND_CONFIG.REQUEST_COOLDOWN,
	dataStoreAvailable = dataStoreAvailable
})