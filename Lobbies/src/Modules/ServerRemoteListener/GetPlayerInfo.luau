local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Remote = {}

function Remote:Invoke(_Player: Player, TargetPlayer: Player)
	if not TargetPlayer then
		return nil
	end

	local PlayerData = Data.Service:waitForData(TargetPlayer) :: Types.PlayerData
	if not PlayerData then
		return nil
	end

	local Stats = Functions:GetTotalStats(TargetPlayer.Character, PlayerData())

	local Equipment = {}
	for Slot, UUID in PlayerData.Equipment() do
		if UUID == "" then
			continue
		end

		local ItemEntry = PlayerData.Inventory[UUID]()
		if not ItemEntry then
			continue
		end

		local ItemInfo = ItemsData[ItemEntry.ID]
		if not ItemInfo then
			continue
		end

		Equipment[Slot] = {
			Icon = ItemInfo.Data.Icon,
			SubType = ItemInfo.Data.SubType,
			Rarity = ItemInfo.Data.Rarity,
		}
	end

	return {
		Name = TargetPlayer.Name,
		Level = PlayerData.Level(),
		Stats = Stats,
		Gold = PlayerData.Currencies().Gold or 0,
		Honor = PlayerData.Honor(),
		Kills = PlayerData.Kills(),
		Deaths = PlayerData.Deaths(),
		PlayTime = PlayerData.PlayTime(),
		Equipment = Equipment,
	}
end

return Remote
