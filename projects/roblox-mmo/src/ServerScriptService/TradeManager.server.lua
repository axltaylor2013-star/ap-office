--[[
	TradeManager.server.lua
	Server-side trading system for a RuneScape-inspired full-loot PvP MMO.
	Handles trade requests, validation, item swapping, and timeouts.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Get Remotes folder and remote events
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local remotes = {
	TradeRequest = Remotes:WaitForChild("TradeRequest", 10),
	TradeUpdate = Remotes:WaitForChild("TradeUpdate", 10),
	TradeAccept = Remotes:WaitForChild("TradeAccept", 10),
	TradeCancel = Remotes:WaitForChild("TradeCancel", 10)
}

-- DataManager module for inventory operations
local DataManager = require(ReplicatedStorage:WaitForChild("Modules", 5):WaitForChild("DataManager", 5))

--------------------------------------------------------------------------------
-- Types & State
--------------------------------------------------------------------------------

-- TradeSession structure: {
--   player1, player2,
--   items1, items2,
--   confirmed1, confirmed2,
--   lastActivity
-- }

-- Active trades keyed by a canonical trade ID (sorted UserId pair)
local activeTrades = {}

-- Map each player to their current trade ID (one trade at a time)
local playerTrade = {}

-- Pending trade requests: requester -> target UserId
local pendingRequests = {}

local TRADE_TIMEOUT = 60  -- seconds of inactivity before auto-cancel
local WILDERNESS_Z_THRESHOLD = -100

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

--- Build a deterministic trade ID from two players.
local function tradeId(p1, p2)
	local a, b = math.min(p1.UserId, p2.UserId), math.max(p1.UserId, p2.UserId)
	return `{a}_{b}`
end

--- Check if a player is in the wilderness (Z < -100).
local function isInWilderness(player)
	local char = player.Character
	if not char then return true end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return true end
	return root.Position.Z < WILDERNESS_Z_THRESHOLD
end

--- Validate that a player actually owns all offered items.
local function validateItems(player, items)
	local data = DataManager:GetData(player)
	if not data then return false end
	local inventory = data.Inventory or data.inventory or {}
	for itemName, qty in items do
		if qty <= 0 then return false end
		local owned = inventory[itemName] or 0
		if owned < qty then return false end
	end
	return true
end

--- Send a trade state snapshot to both players.
local function broadcastTradeState(session)
	local payload = {
		items1 = session.items1,
		items2 = session.items2,
		confirmed1 = session.confirmed1,
		confirmed2 = session.confirmed2,
		partner1 = session.player1.Name,
		partner2 = session.player2.Name,
	}
	remotes.TradeUpdate:FireClient(session.player1, payload)
	remotes.TradeUpdate:FireClient(session.player2, payload)
end

--- Cancel and clean up a trade session.
local function cancelTrade(id, reason)
	local session = activeTrades[id]
	if not session then return end

	activeTrades[id] = nil
	playerTrade[session.player1.UserId] = nil
	playerTrade[session.player2.UserId] = nil

	local msg = reason or "Trade cancelled."
	pcall(function() remotes.TradeCancel:FireClient(session.player1, msg) end)
	pcall(function() remotes.TradeCancel:FireClient(session.player2, msg) end)
end

--- Execute a confirmed trade: swap items between players.
local function executeTrade(id)
	local session = activeTrades[id]
	if not session then return end

	local p1, p2 = session.player1, session.player2

	-- Final validation
	if isInWilderness(p1) or isInWilderness(p2) then
		cancelTrade(id, "Cannot trade in the Wilderness!")
		return
	end
	if not validateItems(p1, session.items1) then
		cancelTrade(id, `{p1.Name} no longer has the offered items.`)
		return
	end
	if not validateItems(p2, session.items2) then
		cancelTrade(id, `{p2.Name} no longer has the offered items.`)
		return
	end

	-- Remove items from both players
	for itemName, qty in session.items1 do
		DataManager.RemoveFromInventory(p1, itemName, qty)
	end
	for itemName, qty in session.items2 do
		DataManager.RemoveFromInventory(p2, itemName, qty)
	end

	-- Add swapped items
	for itemName, qty in session.items1 do
		DataManager.AddToInventory(p2, itemName, qty)
	end
	for itemName, qty in session.items2 do
		DataManager.AddToInventory(p1, itemName, qty)
	end

	-- Clean up and notify
	activeTrades[id] = nil
	playerTrade[p1.UserId] = nil
	playerTrade[p2.UserId] = nil

	local summary = { items1 = session.items1, items2 = session.items2 }
	pcall(function() remotes.TradeComplete:FireClient(p1, summary) end)
	pcall(function() remotes.TradeComplete:FireClient(p2, summary) end)

	print(`[TradeManager] Trade completed: {p1.Name} <-> {p2.Name}`)
end

--------------------------------------------------------------------------------
-- Remote Event Handlers
--------------------------------------------------------------------------------

-- TradeRequest: player requests to trade with targetPlayer (by UserId)
remotes.TradeRequest.OnServerEvent:Connect(function(player, targetUserId)
	-- Validate inputs
	if typeof(targetUserId) ~= "number" then return end
	local target = Players:GetPlayerByUserId(targetUserId)
	if not target or target == player then return end

	-- Can't trade if either player is already in a trade
	if playerTrade[player.UserId] then
		remotes.TradeCancel:FireClient(player, "You are already in a trade.")
		return
	end
	if playerTrade[target.UserId] then
		remotes.TradeCancel:FireClient(player, `{target.Name} is already trading.`)
		return
	end

	-- Wilderness check
	if isInWilderness(player) or isInWilderness(target) then
		remotes.TradeCancel:FireClient(player, "Cannot trade in the Wilderness!")
		return
	end

	-- Store pending request and notify target
	pendingRequests[player.UserId] = target.UserId
	remotes.TradeRequest:FireClient(target, player.UserId, player.Name)
	print(`[TradeManager] {player.Name} sent trade request to {target.Name}`)
end)

-- TradeResponse: target accepts or declines a pending request
-- NOTE: Using TradeAccept as TradeResponse since it handles acceptance logic
remotes.TradeAccept.OnServerEvent:Connect(function(player, requesterUserId, accepted)
	if typeof(requesterUserId) ~= "number" or typeof(accepted) ~= "boolean" then return end

	local requester = Players:GetPlayerByUserId(requesterUserId)
	if not requester then return end

	-- Verify the pending request exists and matches
	if pendingRequests[requesterUserId] ~= player.UserId then return end
	pendingRequests[requesterUserId] = nil

	if not accepted then
		remotes.TradeCancel:FireClient(requester, `{player.Name} declined your trade request.`)
		return
	end

	-- Re-check availability
	if playerTrade[player.UserId] or playerTrade[requester.UserId] then
		remotes.TradeCancel:FireClient(requester, "Trade no longer available.")
		remotes.TradeCancel:FireClient(player, "Trade no longer available.")
		return
	end

	-- Create the trade session
	local id = tradeId(requester, player)
	local session = {
		player1 = requester,
		player2 = player,
		items1 = {},
		items2 = {},
		confirmed1 = false,
		confirmed2 = false,
		lastActivity = os.clock(),
	}
	activeTrades[id] = session
	playerTrade[requester.UserId] = id
	playerTrade[player.UserId] = id

	broadcastTradeState(session)
	print(`[TradeManager] Trade started: {requester.Name} <-> {player.Name}`)
end)

-- TradeUpdate: player adds or removes an item from their offer
-- payload: { action = "add" | "remove", item = string, quantity = number }
remotes.TradeUpdate.OnServerEvent:Connect(function(player, payload)
	if typeof(payload) ~= "table" then return end

	local id = playerTrade[player.UserId]
	if not id then return end
	local session = activeTrades[id]
	if not session then return end

	local action = payload.action
	local itemName = payload.item
	local qty = payload.quantity

	if typeof(action) ~= "string" or typeof(itemName) ~= "string" or typeof(qty) ~= "number" then return end
	qty = math.floor(qty)
	if qty <= 0 then return end

	-- Determine which side this player is on
	local items = if player == session.player1 then session.items1 else session.items2

	if action == "add" then
		items[itemName] = (items[itemName] or 0) + qty
		-- Validate the total offered doesn't exceed owned
		if not validateItems(player, if player == session.player1 then session.items1 else session.items2) then
			items[itemName] = items[itemName] - qty
			if items[itemName] <= 0 then items[itemName] = nil end
			return
		end
	elseif action == "remove" then
		if not items[itemName] then return end
		items[itemName] = math.max(0, items[itemName] - qty)
		if items[itemName] <= 0 then items[itemName] = nil end
	else
		return
	end

	-- Any item change resets both confirmations
	session.confirmed1 = false
	session.confirmed2 = false
	session.lastActivity = os.clock()

	broadcastTradeState(session)
end)

-- TradeConfirm: player confirms their side of the trade
remotes.TradeAccept.OnServerEvent:Connect(function(player)
	local id = playerTrade[player.UserId]
	if not id then return end
	local session = activeTrades[id]
	if not session then return end

	if player == session.player1 then
		session.confirmed1 = true
	else
		session.confirmed2 = true
	end
	session.lastActivity = os.clock()

	broadcastTradeState(session)

	-- If both confirmed, execute
	if session.confirmed1 and session.confirmed2 then
		executeTrade(id)
	end
end)

-- TradeCancel: player cancels the trade
remotes.TradeCancel.OnServerEvent:Connect(function(player)
	local id = playerTrade[player.UserId]
	if not id then return end
	cancelTrade(id, `{player.Name} cancelled the trade.`)
end)

--------------------------------------------------------------------------------
-- Timeout Loop
--------------------------------------------------------------------------------

RunService.Heartbeat:Connect(function()
	local now = os.clock()
	for id, session in activeTrades do
		if now - session.lastActivity >= TRADE_TIMEOUT then
			cancelTrade(id, "Trade timed out due to inactivity.")
		end
	end
end)

--------------------------------------------------------------------------------
-- Player cleanup on disconnect
--------------------------------------------------------------------------------

Players.PlayerRemoving:Connect(function(player)
	-- Cancel active trade
	local id = playerTrade[player.UserId]
	if id then
		cancelTrade(id, `{player.Name} disconnected.`)
	end
	-- Clear pending requests
	pendingRequests[player.UserId] = nil
end)

print("[TradeManager] Trade system active!")
