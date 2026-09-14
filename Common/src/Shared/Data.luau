local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DataService = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("DataServiceTyped"))
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local template: Types.PlayerData = {
	FirstTimeJoined = true,
	Level = 1,
	XP = 0,
	Kills = 0,
	Donations = 0,
	Deaths = 0,
	Honor = 0,
	PlayTime = 0,
	Inventory = {} :: { [string]: Types.ItemData },
	Storage = {} :: { [string]: Types.ItemData },
	Settings = {
		Music = true,
		["Potion Toggle"] = true,
		["Party Invites"] = true,
		["Trade Offers"] = true,
		["Damage Checker"] = false,
	},
	Equipment = {
		Weapon = "",
		Armor = "",
		Ring = "",
		Necklace = "",
		Aura = "",
		Rune = "",
	},
	MaxInventorySpace = 100,
	CurrentInventorySpace = 0,
	MaxStorageSpace = 100,
	CurrentStorageSpace = 0,
	Skills = {
		Q = "",
		E = "",
		R = "",
	},
	Currencies = {
		Gold = 0,
		["Rune Crystals"] = 0,
		["Raid Coins"] = 0,
		Tokens = 0,
	},
	Vanity = {
		Weapon = "",
		Aura = "",
	},
	ExtraStats = {
		Health = 0,
		Speed = 0,
		Attack = 0,
		Critical = 0,
		Defense = 0,
	},
	MobIndex = {},
	Quests = {},
	DailyQuests = {},
	CompletedQuests = {},
	LastDailyReward = 0,
	TotalDailyRewards = 0,
	DailyStreak = 0,
	RaidRuns = {},
	RaidRecords = {},
	RaidAutoDelete = {},
}

local Data = DataService({ template = template, profileStoreIndex = "PlayerData" })

if RunService:IsServer() then
	function Data.server.Service:onPlayerInit(_player: Player, data: Types.PlayerData)
		-- Equipment is authoritative; repair legacy per-item flags before initial replication.
		local EquippedItems: { [string]: boolean } = {}
		for _, UUID in data.Equipment do
			if UUID ~= "" then
				EquippedItems[UUID] = true
			end
		end

		for UUID, ItemEntry in data.Inventory do
			local IsEquipped = EquippedItems[UUID] == true
			if IsEquipped or ItemEntry.Equipped ~= nil then
				ItemEntry.Equipped = IsEquipped
			end
		end
	end
end

return Data
