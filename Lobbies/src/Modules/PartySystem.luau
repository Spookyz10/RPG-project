local PartySystem = {}

local MaxPartyMembers = 15

local ActiveParties = {} :: { [Player]: { Members: { Player } } }

local function PlayerInParty(Player: Player)
	for _, Members in ActiveParties do
		if Members[Player] then
			return true
		end
	end

	return false
end

function PartySystem:CreateParty(Leader: Player)
	if ActiveParties[Leader] then
		return
	end

	ActiveParties[Leader] = { Members = { Leader } }
end

function PartySystem:AddPlayer(Player: Player, Leader: Player)
	if not ActiveParties[Leader] then
		return
	end

	if PlayerInParty(Player) then
		return
	end

	if #ActiveParties[Leader].Members >= MaxPartyMembers then
		return
	end

	table.insert(ActiveParties[Leader].Members, Player)
end

function PartySystem:PlayerLeaveParty(Player: Player)
	for leader, members in ActiveParties do
		if leader == Player then
			ActiveParties[Player] = nil
			return
		end

		if members[Player] then
			table.remove(members, Player)
			return
		end
	end
end

function PartySystem:OnPlayerRemoved(Player: Player)
	if not PlayerInParty(Player) then
		return
	end

	self:PlayerLeaveParty(Player)
end

return PartySystem
