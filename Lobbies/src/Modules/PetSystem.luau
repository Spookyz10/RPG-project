local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Talents = require(ReplicatedStorage.Shared.Talents)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Data = require(ReplicatedStorage.Shared.Data).server
local PetTalentManager = require(script.Parent.PetTalentManager)

local PetSystem = {}

local EXCLUDED_RARITIES = {
	Common = true,
}

local function RollTalent(): string
	local TotalWeight = 0
	for talentName, info in Talents do
		if EXCLUDED_RARITIES[info.Rarity] then
			continue
		end
		TotalWeight += info.Weight
	end

	local Roll = math.random() * TotalWeight
	local Current = 0

	for talentName, info in Talents do
		if EXCLUDED_RARITIES[info.Rarity] then
			continue
		end

		Current += info.Weight
		if Roll <= Current then
			return talentName
		end
	end

	return "No Talent"
end

function PetSystem.AddPet(Player: Player, PetName: string): string?
	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	if not PlayerData then
		return nil
	end

	local UUID = Functions:GenUUID()
	local PetData: Types.PetData = {
		Name = PetName,
		Level = 1,
		Talent = RollTalent(),
	}

	PlayerData.Pets[UUID](PetData)

	return UUID
end

function PetSystem:EquipPet(player: Player, UUID: string)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	local PetEntry = PlayerData.Pets[UUID]()
	if not PetEntry then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "You don't have that pet silly!")
		return
	end

	local Current = PlayerData.EquippedPet()
	if Current and Current ~= "" then
		PetTalentManager:Unequip(player)
	end

	PlayerData.EquippedPet(UUID)
	PetTalentManager:Equip(player, PetEntry)
end

function PetSystem:UnequipPet(player: Player)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	if PlayerData.EquippedPet() == "" then
		return
	end

	PetTalentManager:Unequip(player)
	PlayerData.EquippedPet("")
end

function PetSystem:VanityEquipPet(player: Player, UUID: string)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	local PetEntry = PlayerData.Pets[UUID]()
	if not PetEntry then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "You don't have that pet silly!")
		return
	end

	PlayerData.VanityPet(UUID)
end

function PetSystem:VanityUnequipPet(player: Player)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	PlayerData.VanityPet("")
end

return PetSystem
