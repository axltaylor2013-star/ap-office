-- PartyManager.server.lua
-- Party/Group system for Wilderness MMO

print("[PartyManager] Starting...")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for dependencies with timeouts
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)

-- Load required modules
local DataManager = require(Modules:WaitForChild("DataManager", 10))

-- Get remotes
local PartyInvite = Remotes:WaitForChild("PartyInvite", 5)
local PartyAccept = Remotes:WaitForChild("PartyAccept", 5)
local PartyLeave = Remotes:WaitForChild("PartyLeave", 5)
local PartyKick = Remotes:WaitForChild("PartyKick", 5)
local PartyUpdate = Remotes:WaitForChild("PartyUpdate", 5)
local PartyChat = Remotes:WaitForChild("PartyChat", 5)

-- Validate remotes
if not PartyInvite or not PartyAccept or not PartyLeave or not PartyKick or not PartyUpdate or not PartyChat then
	warn("[PartyManager] Missing remotes!")
	return
end

-- Party data structure
local parties = {} -- partyId -> {leader = userId, members = {userId1, userId2, ...}}
local playerToParty = {} -- userId -> partyId
local partyInvites = {} -- {inviterUserId: {targetUserId: timestamp}}

-- Constants
local MAX_PARTY_SIZE = 4
local SHARED_XP_RANGE = 50 -- studs
local XP_BONUS_PER_MEMBER = 0.10 -- 10% per member

-- Helper function to get party by player
local function getPlayerParty(player)
	local partyId = playerToParty[player.UserId]
	if partyId then
		return parties[partyId]
	end
	return nil
end

-- Helper function to create new party
local function createParty(leader)
	local partyId = "party_" .. leader.UserId .. "_" .. os.time()
	
	parties[partyId] = {
		leader = leader.UserId,
		members = {leader.UserId},
		created = os.time()
	}
	
	playerToParty[leader.UserId] = partyId
	
	-- Notify leader
	PartyUpdate:FireClient(leader, {
		type = "created",
		partyId = partyId,
		leader = leader.UserId,
		members = {leader.UserId}
	})
	
	return partyId
end

-- Helper function to disband party
local function disbandParty(partyId)
	local party = parties[partyId]
	if not party then return end
	
	-- Notify all members
	for _, memberId in ipairs(party.members) do
		local member = Players:GetPlayerByUserId(memberId)
		if member then
			PartyUpdate:FireClient(member, {
				type = "disbanded",
				partyId = partyId
			})
			playerToParty[memberId] = nil
		end
	end
	
	-- Remove party
	parties[partyId] = nil
end

-- Helper function to add member to party
local function addMemberToParty(partyId, player)
	local party = parties[partyId]
	if not party then return false end
	
	-- Check if party is full
	if #party.members >= MAX_PARTY_SIZE then
		return false, "Party is full"
	end
	
	-- Add player
	table.insert(party.members, player.UserId)
	playerToParty[player.UserId] = partyId
	
	-- Notify all party members
	for _, memberId in ipairs(party.members) do
		local member = Players:GetPlayerByUserId(memberId)
		if member then
			PartyUpdate:FireClient(member, {
				type = "member_joined",
				partyId = partyId,
				member = player.UserId,
				members = party.members
			})
		end
	end
	
	return true
end

-- Helper function to remove member from party
local function removeMemberFromParty(partyId, userId, kickedBy)
	local party = parties[partyId]
	if not party then return end
	
	-- Find and remove member
	for i, memberId in ipairs(party.members) do
		if memberId == userId then
			table.remove(party.members, i)
			break
		end
	end
	
	playerToParty[userId] = nil
	
	-- Notify removed player
	local removedPlayer = Players:GetPlayerByUserId(userId)
	if removedPlayer then
		PartyUpdate:FireClient(removedPlayer, {
			type = kickedBy and "kicked" or "left",
			partyId = partyId,
			kickedBy = kickedBy
		})
	end
	
	-- Notify remaining members
	for _, memberId in ipairs(party.members) do
		local member = Players:GetPlayerByUserId(memberId)
		if member then
			PartyUpdate:FireClient(member, {
				type = "member_left",
				partyId = partyId,
				member = userId,
				members = party.members
			})
		end
	end
	
	-- Disband if empty or only leader left
	if #party.members <= 1 then
		disbandParty(partyId)
	end
end

-- Helper function to get nearby party members
local function getNearbyPartyMembers(player, range)
	local party = getPlayerParty(player)
	if not party then return {} end
	
	local playerPos = player.Character and player.Character:GetPivot().Position
	if not playerPos then return {} end
	
	local nearby = {}
	
	for _, memberId in ipairs(party.members) do
		if memberId ~= player.UserId then
			local member = Players:GetPlayerByUserId(memberId)
			if member and member.Character then
				local memberPos = member.Character:GetPivot().Position
				if (memberPos - playerPos).Magnitude <= range then
					table.insert(nearby, member)
				end
			end
		end
	end
	
	return nearby
end

-- Calculate XP bonus for party
local function calculatePartyXPBonus(player, baseXP)
	local party = getPlayerParty(player)
	if not party then return baseXP end
	
	local nearbyMembers = getNearbyPartyMembers(player, SHARED_XP_RANGE)
	local bonusMultiplier = 1.0 + (#nearbyMembers * XP_BONUS_PER_MEMBER)
	
	return math.floor(baseXP * bonusMultiplier)
end

-- Handle party invites
PartyInvite.OnServerEvent:Connect(function(inviter, targetPlayer)
	if not inviter or not targetPlayer then return end
	
	-- Check if inviter is in a party
	local inviterParty = getPlayerParty(inviter)
	if not inviterParty then
		-- Create new party for inviter
		createParty(inviter)
		inviterParty = getPlayerParty(inviter)
	end
	
	-- Check if inviter is party leader
	if inviterParty.leader ~= inviter.UserId then
		PartyUpdate:FireClient(inviter, {
			type = "error",
			message = "Only party leader can invite players"
		})
		return
	end
	
	-- Check if target is already in a party
	if getPlayerParty(targetPlayer) then
		PartyUpdate:FireClient(inviter, {
			type = "error",
			message = targetPlayer.Name .. " is already in a party"
		})
		return
	end
	
	-- Check if party is full
	if #inviterParty.members >= MAX_PARTY_SIZE then
		PartyUpdate:FireClient(inviter, {
			type = "error",
			message = "Party is full"
		})
		return
	end
	
	-- Create invite
	partyInvites[inviter.UserId] = partyInvites[inviter.UserId] or {}
	partyInvites[inviter.UserId][targetPlayer.UserId] = os.time()
	
	-- Send invite to target
	PartyUpdate:FireClient(targetPlayer, {
		type = "invite",
		partyId = playerToParty[inviter.UserId],
		inviter = inviter.UserId,
		inviterName = inviter.Name
	})
	
	-- Notify inviter
	PartyUpdate:FireClient(inviter, {
		type = "invite_sent",
		target = targetPlayer.UserId,
		targetName = targetPlayer.Name
	})
end)

-- Handle party accept
PartyAccept.OnServerEvent:Connect(function(player, partyId, inviterId)
	if not player then return end
	
	-- Check if invite exists and is recent (within 60 seconds)
	local inviteTime = partyInvites[inviterId] and partyInvites[inviterId][player.UserId]
	if not inviteTime or os.time() - inviteTime > 60 then
		PartyUpdate:FireClient(player, {
			type = "error",
			message = "Invite expired"
		})
		return
	end
	
	-- Check if player is already in a party
	if getPlayerParty(player) then
		PartyUpdate:FireClient(player, {
			type = "error",
			message = "You are already in a party"
		})
		return
	end
	
	-- Add to party
	local success, message = addMemberToParty(partyId, player)
	if not success then
		PartyUpdate:FireClient(player, {
			type = "error",
			message = message
		})
		return
	end
	
	-- Clean up invite
	if partyInvites[inviterId] then
		partyInvites[inviterId][player.UserId] = nil
	end
end)

-- Handle party leave
PartyLeave.OnServerEvent:Connect(function(player)
	if not player then return end
	
	local party = getPlayerParty(player)
	if not party then
		PartyUpdate:FireClient(player, {
			type = "error",
			message = "You are not in a party"
		})
		return
	end
	
	removeMemberFromParty(playerToParty[player.UserId], player.UserId)
end)

-- Handle party kick
PartyKick.OnServerEvent:Connect(function(kicker, targetUserId)
	if not kicker then return end
	
	local party = getPlayerParty(kicker)
	if not party or party.leader ~= kicker.UserId then
		PartyUpdate:FireClient(kicker, {
			type = "error",
			message = "Only party leader can kick members"
		})
		return
	end
	
	-- Can't kick yourself
	if targetUserId == kicker.UserId then return end
	
	removeMemberFromParty(playerToParty[kicker.UserId], targetUserId, kicker.UserId)
end)

-- Handle party chat
PartyChat.OnServerEvent:Connect(function(player, message)
	if not player or not message or message == "" then return end
	
	local party = getPlayerParty(player)
	if not party then return end
	
	-- Broadcast to all party members
	for _, memberId in ipairs(party.members) do
		local member = Players:GetPlayerByUserId(memberId)
		if member then
			PartyUpdate:FireClient(member, {
				type = "chat",
				sender = player.UserId,
				senderName = player.Name,
				message = message
			})
		end
	end
end)

-- Clean up on player leave
Players.PlayerRemoving:Connect(function(player)
	local party = getPlayerParty(player)
	if party then
		removeMemberFromParty(playerToParty[player.UserId], player.UserId)
	end
	
	-- Clean up invites
	for inviterId, invites in pairs(partyInvites) do
		invites[player.UserId] = nil
	end
end)

-- Function to award XP with party bonus (to be called by other systems)
local function awardPartyXP(player, skill, baseXP)
	local party = getPlayerParty(player)
	if not party then return baseXP end
	
	local finalXP = calculatePartyXPBonus(player, baseXP)
	
	-- Award XP to player
	DataManager.AddSkillXP(player, skill, finalXP)
	
	-- Share XP with nearby party members
	local nearbyMembers = getNearbyPartyMembers(player, SHARED_XP_RANGE)
	for _, member in ipairs(nearbyMembers) do
		DataManager.AddSkillXP(member, skill, baseXP) -- Base XP only, not bonus
	end
	
	return finalXP
end

-- Functions are local to this script - no need to export since this is a server script

print("[PartyManager] Ready!")