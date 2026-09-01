local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local Raids = require(ReplicatedStorage.Shared.Raids)
local Data = require(ReplicatedStorage.Shared.Data).server
local PartySystem = require(script.Parent.PartySystem)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local RaidManager = {}

local RAID_PLACE_ID = 1239012932

function RaidManager:CanStart(player: Player, raidName: string, difficulty: string): (boolean, string, Types.RaidInfo?)
	local RaidInfo = Raids[raidName] :: Types.RaidInfo
	if not RaidInfo then
		return false, "Raid not found", nil
	end

	if not table.find(RaidInfo.Difficulties, difficulty) then
		return false, "Invalid difficulty", nil
	end

	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return false, "Invalid player data", nil
	end

	if PlayerData.Level() < RaidInfo.RequiredLevel then
		return false, "Level too low", nil
	end

	local Party = PartySystem:GetParty(player)
	if Party and Party.Leader ~= player then
		return false, "Only the party leader can start a raid", nil
	end

	return true, "OK", RaidInfo
end

function RaidManager:StartRaid(player: Player, raidName: string, difficulty: string)
	local CanStart, Reason = self:CanStart(player, raidName, difficulty)
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

	local TeleportOptions = Instance.new("TeleportOptions")
	TeleportOptions:SetTeleportData({
		RaidName = raidName,
		Difficulty = difficulty,
	})

	local ok, err = pcall(function()
		TeleportService:TeleportAsync(RAID_PLACE_ID, Members, TeleportOptions)
	end)

	if not ok then
		warn("[RaidManager] Falha ao teleportar para a raid: " .. tostring(err))
		for _, member in Members do
			RemoteManager.SendClientEvent("Notification", { Player = member }, "Failed to start raid, try again")
		end
	end
end

function RaidManager:ToggleAutoDelete(player: Player, itemName: string)
	if typeof(itemName) ~= "string" then
		return
	end

	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	local Current = PlayerData.RaidAutoDelete()
	local NewValue = not Current[itemName]

	PlayerData.RaidAutoDelete[itemName](NewValue or nil)
end

return RaidManager
