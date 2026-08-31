local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Talents = require(ReplicatedStorage.Shared.Talents)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Data = require(ReplicatedStorage.Shared.Data).server

local PetSystem = {}

local TalentChances = {
	Rare = 90,
	Legendary = 10,
}

local function GetTalentRarity()
	local RandomNumber = math.random(1, 100)
	if RandomNumber <= TalentChances.Rare then
		return "Rare"
	else
		return "Legendary"
	end
end

local function GetTalentByRarity(Rarity: string)
	local TalentPool = {}
	for TalentName, TalentData in pairs(Talents) do
		if TalentData.Rarity == Rarity then
			table.insert(TalentPool, TalentName)
		end
	end

	if #TalentPool == 0 then
		return nil
	end

	local RandomIndex = math.random(1, #TalentPool)
	return TalentPool[RandomIndex]
end

function PetSystem.AddPet(Player: Player, PetName: string)
	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	local UUID = Functions:GenUUID()
	local PetData = {
		Name = PetName,
		Level = 1,
		Talent = GetTalentByRarity(GetTalentRarity()),
	} :: Types.PetData

	PlayerData.Pets[UUID](PetData)
end

return PetSystem
