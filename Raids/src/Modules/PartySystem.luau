local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local PartySystem = {}

local MaxPartyMembers = 15
local MIN_PARTY_MEMBERS = 2
local XP_BOOST_PER_MEMBER = 0.025
local INVITE_EXPIRE_TIME = 30

export type Party = {
	Leader: Player,
	Members: { [Player]: boolean },
}

local ActiveParties: { [Player]: Party } = {}
local PlayerToLeader: { [Player]: Player } = {}
local PendingInvites: { [Player]: { [Player]: number } } = {}

local function GetMemberCount(party: Party): number
	local count = 0
	for _ in party.Members do
		count += 1
	end
	return count
end

function PartySystem:GetParty(Player: Player): Party?
	local Leader = PlayerToLeader[Player]
	if not Leader then
		return nil
	end
	return ActiveParties[Leader]
end

function PartySystem:IsInParty(Player: Player): boolean
	return PlayerToLeader[Player] ~= nil
end

local function BuildPartyPayload(party: Party): { [string]: boolean }
	local Payload = {}
	for member in party.Members do
		Payload[member.Name] = true
	end
	return Payload
end

local function BroadcastPartyUpdate(party: Party)
	for member in party.Members do
		RemoteManager.SendClientEvent(
			"PartyUpdate",
			{ Player = member },
			"PartyUpdate",
			BuildPartyPayload(party),
			party.Leader.Name
		)
	end
end

local function BroadcastPartyLeave(player: Player)
	RemoteManager.SendClientEvent("PartyUpdate", { Player = player }, "Leave")
end

function PartySystem:CreateParty(Leader: Player): Party
	local Existing = ActiveParties[Leader]
	if Existing then
		return Existing
	end

	local Party: Party = {
		Leader = Leader,
		Members = { [Leader] = true },
	}

	ActiveParties[Leader] = Party
	PlayerToLeader[Leader] = Leader

	return Party
end

local function AcceptsInvites(player: Player): boolean
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return false
	end

	local Settings = PlayerData.Settings()
	return Settings["Party Invites"] ~= false
end

local function ClearInvite(target: Player, inviter: Player)
	local TargetInvites = PendingInvites[target]
	if not TargetInvites then
		return
	end

	TargetInvites[inviter] = nil

	if next(TargetInvites) == nil then
		PendingInvites[target] = nil
	end
end

function PartySystem:InvitePlayer(inviter: Player, target: Player): (boolean, string)
	if not target or typeof(target) ~= "Instance" or not target:IsA("Player") or target == inviter then
		return false, "Invalid target"
	end

	if not AcceptsInvites(target) then
		return false, "This player is not accepting party invites"
	end

	if self:IsInParty(target) then
		return false, "Player is already in a party"
	end

	local ExistingParty = self:GetParty(inviter)
	if ExistingParty and ExistingParty.Leader ~= inviter then
		return false, "Only the party leader can invite"
	end

	if ExistingParty and GetMemberCount(ExistingParty) >= MaxPartyMembers then
		return false, "Party is full"
	end

	local TargetInvites = PendingInvites[target]
	if not TargetInvites then
		TargetInvites = {}
		PendingInvites[target] = TargetInvites
	end

	if TargetInvites[inviter] then
		return false, "Invite already sent"
	end

	local ExpireAt = os.clock() + INVITE_EXPIRE_TIME
	TargetInvites[inviter] = ExpireAt

	RemoteManager.SendClientEvent("PartyInvite", { Player = target }, inviter.Name, INVITE_EXPIRE_TIME)

	task.delay(INVITE_EXPIRE_TIME, function()
		local Invites = PendingInvites[target]
		if Invites and Invites[inviter] == ExpireAt then
			ClearInvite(target, inviter)
		end
	end)

	return true, "Invite sent"
end

function PartySystem:AcceptInvite(target: Player, inviterName: string): (boolean, string)
	local TargetInvites = PendingInvites[target]
	if not TargetInvites then
		return false, "No pending invite"
	end

	local Inviter: Player? = nil
	for player in TargetInvites do
		if player.Name == inviterName then
			Inviter = player
			break
		end
	end

	if not Inviter or not Inviter.Parent then
		return false, "Invite no longer valid"
	end

	ClearInvite(target, Inviter)

	if self:IsInParty(target) then
		return false, "Already in a party"
	end

	local Party = self:GetParty(Inviter)
	if not Party then
		Party = self:CreateParty(Inviter)
	end

	if GetMemberCount(Party) >= MaxPartyMembers then
		return false, "Party is full"
	end

	Party.Members[target] = true
	PlayerToLeader[target] = Party.Leader

	BroadcastPartyUpdate(Party)

	return true, "Joined party"
end

function PartySystem:DeclineInvite(target: Player, inviterName: string)
	local TargetInvites = PendingInvites[target]
	if not TargetInvites then
		return
	end

	for player in TargetInvites do
		if player.Name == inviterName then
			ClearInvite(target, player)
			break
		end
	end
end

function PartySystem:AddPlayer(Player: Player, Leader: Player)
	self:InvitePlayer(Leader, Player)
end

function PartySystem:PlayerLeaveParty(Player: Player)
	local Leader = PlayerToLeader[Player]
	if not Leader then
		return
	end

	local Party = ActiveParties[Leader]
	if not Party then
		PlayerToLeader[Player] = nil
		return
	end

	Party.Members[Player] = nil
	PlayerToLeader[Player] = nil
	BroadcastPartyLeave(Player)

	if Player ~= Leader then
		if GetMemberCount(Party) <= 1 then
			local LastMember = next(Party.Members)
			if LastMember then
				Party.Members[LastMember] = nil
				PlayerToLeader[LastMember] = nil
				BroadcastPartyLeave(LastMember)
			end
			ActiveParties[Leader] = nil
		else
			BroadcastPartyUpdate(Party)
		end
		return
	end

	local RemainingMembers = {}
	for Member in Party.Members do
		table.insert(RemainingMembers, Member)
	end

	ActiveParties[Leader] = nil

	if #RemainingMembers == 0 then
		return
	end

	local NewLeader = RemainingMembers[1]
	local NewParty: Party = {
		Leader = NewLeader,
		Members = {},
	}

	for _, Member in RemainingMembers do
		NewParty.Members[Member] = true
		PlayerToLeader[Member] = NewLeader
	end

	ActiveParties[NewLeader] = NewParty
	BroadcastPartyUpdate(NewParty)
end

function PartySystem:KickPlayer(Leader: Player, targetName: string)
	local Party = self:GetParty(Leader)
	if not Party or Party.Leader ~= Leader then
		return
	end

	local Target: Player? = nil
	for member in Party.Members do
		if member.Name == targetName then
			Target = member
			break
		end
	end

	if not Target or Target == Leader then
		return
	end

	self:PlayerLeaveParty(Target)
end

function PartySystem:GetMemberCount(Player: Player): number
	local Party = self:GetParty(Player)
	if not Party then
		return 0
	end
	return GetMemberCount(Party)
end

function PartySystem:GetXPBoost(Player: Player): number
	local MemberCount = self:GetMemberCount(Player)
	if MemberCount < MIN_PARTY_MEMBERS then
		return 0
	end
	return MemberCount * XP_BOOST_PER_MEMBER
end

function PartySystem:OnPlayerRemoved(Player: Player)
	self:PlayerLeaveParty(Player)
	PendingInvites[Player] = nil
end

return PartySystem
