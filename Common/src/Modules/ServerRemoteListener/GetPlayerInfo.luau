local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Remote = {}

local function itemSummary(PlayerData: Types.PlayerData, UUID: string?)
	if not UUID or UUID == "" then return nil end
	local ItemCell = PlayerData.Inventory[UUID]
	local ItemEntry = ItemCell and (ItemCell :: any)()
	if not ItemEntry then return nil end
	local ItemInfo = ItemsData[ItemEntry.ID]
	if not ItemInfo then return nil end
	return {
		Name = ItemEntry.Name,
		Icon = ItemInfo.Data.Icon,
		SubType = ItemInfo.Data.SubType,
		Rarity = ItemInfo.Data.Rarity,
		WeaponType = ItemInfo.WeaponType,
	}
end

function Remote:Invoke(_Player: Player, TargetPlayer: Player)
	if typeof(TargetPlayer) ~= "Instance" or not TargetPlayer:IsA("Player") or TargetPlayer.Parent ~= game:GetService("Players") then
		return nil
	end

	local PlayerData = Data.Service:waitForData(TargetPlayer) :: Types.PlayerData
	if not PlayerData then
		return nil
	end

	local Character = TargetPlayer.Character
	local Stats = Character and Functions:GetTotalStats(Character, PlayerData()) or {
		Attack = 0,
		Defense = 0,
		Critical = 0,
		["Critical Power"] = 0,
		Speed = 0,
		Health = 0,
	}

	local Equipment = {}
	for Slot, UUID in PlayerData.Equipment() do
		Equipment[Slot] = itemSummary(PlayerData, UUID)
	end
	local Weapon = Equipment.Weapon
	local VanityWeapon = itemSummary(PlayerData, PlayerData.Vanity.Weapon())

	return {
		Name = TargetPlayer.Name,
		Level = PlayerData.Level(),
		Stats = Stats,
		ExtraStats = PlayerData.ExtraStats(),
		Gold = PlayerData.Currencies().Gold or 0,
		Honor = PlayerData.Honor(),
		Kills = PlayerData.Kills(),
		Deaths = PlayerData.Deaths(),
		PlayTime = PlayerData.PlayTime(),
		SessionTime = math.max(0, workspace:GetServerTimeNow() - (TargetPlayer:GetAttribute("SessionStartedAt") or workspace:GetServerTimeNow())),
		Equipment = Equipment,
		PreviewWeapon = Weapon and {
			Name = VanityWeapon and VanityWeapon.Name or Weapon.Name,
			WeaponType = Weapon.WeaponType,
		} or nil,
	}
end

return Remote
