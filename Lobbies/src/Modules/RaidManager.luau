local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Raids = require(ReplicatedStorage.Shared.Raids)
local Data = require(ReplicatedStorage.Shared.Data).server
local InventoryManager = require(script.Parent.InventoryManager)
local PartySystem = require(script.Parent.PartySystem)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local RaidManager = {}

type Session = {
	RaidName: string,
	Hardcore: boolean,
	Members: { Player },
	StartTime: number,
}

local ActiveRaids: { [Player]: Session } = {}

function RaidManager:IsInRaid(player: Player): boolean
	return ActiveRaids[player] ~= nil
end

function RaidManager:CanStart(player: Player, raidName: string): (boolean, string, Types.RaidInfo?)
	local RaidInfo = Raids[raidName] :: Types.RaidInfo
	if not RaidInfo then
		return false, "Raid not found", nil
	end

	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return false, "Invalid player data", nil
	end

	if PlayerData.Level() < RaidInfo.RequiredLevel then
		return false, "Level too low", nil
	end

	if self:IsInRaid(player) then
		return false, "Already in a raid", nil
	end

	local Party = PartySystem:GetParty(player)
	if Party and Party.Leader ~= player then
		return false, "Only the party leader can start a raid", nil
	end

	return true, "OK", RaidInfo
end

function RaidManager:StartRaid(player: Player, raidName: string, hardcore: boolean)
	local CanStart, Reason = self:CanStart(player, raidName)
	if not CanStart then
		RemoteManager.SendClientEvent("Notification", { Player = player }, Reason)
		return
	end

	local Members = { player }
	local Party = PartySystem:GetParty(player)
	if Party then
		for member in Party.Members do
			if member ~= player then
				table.insert(Members, member)
			end
		end
	end

	local Session: Session = {
		RaidName = raidName,
		Hardcore = hardcore,
		Members = Members,
		StartTime = os.clock(),
	}

	for _, member in Members do
		if self:IsInRaid(member) then
			RemoteManager.SendClientEvent("Notification", { Player = player }, member.Name .. " is already in a raid")
			return
		end
	end

	for _, member in Members do
		ActiveRaids[member] = Session
		RemoteManager.SendClientEvent("RaidStarted", { Player = member }, raidName, hardcore)
	end
end

function RaidManager:CompleteRaid(player: Player)
	local Session = ActiveRaids[player]
	if not Session then
		return
	end

	local RaidInfo = Raids[Session.RaidName] :: Types.RaidInfo
	local Drops = Session.Hardcore and RaidInfo.HCDrops or RaidInfo.Drops
	local ClearTime = os.clock() - Session.StartTime
	local Mode = Session.Hardcore and "Hardcore" or "Normal"

	for _, member in Session.Members do
		ActiveRaids[member] = nil

		if not member.Parent then
			continue
		end

		local PlayerData = Data.Service:waitForData(member) :: Types.PlayerData
		if not PlayerData then
			continue
		end

		for itemName, chance in Drops do
			if math.random() * 100 < chance then
				InventoryManager:AddItem(member, itemName, 1)
			end
		end

		local Runs = PlayerData.RaidRuns()
		PlayerData.RaidRuns[Session.RaidName]((Runs[Session.RaidName] or 0) + 1)

		local Records = PlayerData.RaidRecords()
		local ExistingRecord = Records[Session.RaidName]
		local BestTime = ExistingRecord and ExistingRecord[Mode]

		if not BestTime or ClearTime < BestTime then
			local NewRecord = ExistingRecord and table.clone(ExistingRecord) or {}
			NewRecord[Mode] = ClearTime
			PlayerData.RaidRecords[Session.RaidName](NewRecord)
		end

		RemoteManager.SendClientEvent("RaidCompleted", { Player = member }, Session.RaidName, ClearTime)
	end
end

function RaidManager:AbandonRaid(player: Player)
	local Session = ActiveRaids[player]
	if not Session then
		return
	end

	for _, member in Session.Members do
		ActiveRaids[member] = nil
	end
end

function RaidManager.OnPlayerRemoved(player: Player)
	RaidManager:AbandonRaid(player)
end

return RaidManager
