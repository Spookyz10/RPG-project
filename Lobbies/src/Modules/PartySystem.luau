local PartySystem = {}

local MaxPartyMembers = 15
local MIN_PARTY_MEMBERS = 2
local XP_BOOST_PER_MEMBER = 0.025

export type Party = {
	Leader: Player,
	Members: { [Player]: boolean },
}

local ActiveParties: { [Player]: Party } = {}
local PlayerToLeader: { [Player]: Player } = {}

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

function PartySystem:CreateParty(Leader: Player)
	if self:IsInParty(Leader) then
		return
	end

	local Party: Party = {
		Leader = Leader,
		Members = { [Leader] = true },
	}

	ActiveParties[Leader] = Party
	PlayerToLeader[Leader] = Leader
end

function PartySystem:AddPlayer(Player: Player, Leader: Player)
	if Player == Leader then
		return
	end

	local Party = ActiveParties[Leader]
	if not Party or Party.Leader ~= Leader then
		return
	end

	if self:IsInParty(Player) then
		return
	end

	if GetMemberCount(Party) >= MaxPartyMembers then
		return
	end

	Party.Members[Player] = true
	PlayerToLeader[Player] = Leader
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

	if Player ~= Leader then
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
end

return PartySystem
