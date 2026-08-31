local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Talents = require(ReplicatedStorage.Shared.Talents)
local PetsData = require(ReplicatedStorage.Shared.PetsData)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Data = require(ReplicatedStorage.Shared.Data).server
local PetTalentManager = require(script.Parent.PetTalentManager)
local ModifierSystem = require(script.Parent.ModifierSystem)
local HealthManager = require(script.Parent.HealthManager)

local PetSystem = {}

local EXCLUDED_RARITIES = {
	Common = true,
}

local DAMAGE_MODIFIER_ID = "PetDamage"
local HEALTH_MODIFIER_ID = "PetHealth"

local CLEARABLE_RARITIES = {
	Common = true,
	Uncommon = true,
}

local ListenedPlayers: { [Player]: boolean } = {}

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

local function GetXPNeeded(level: number): number
	return (150 * (level + 2) * (level + 2) - 150 * (level + 2)) * 0.25
end

local function GetLevelBonuses(level: number): (number, number)
	local Capped = math.min(level, PetsData.MaxLevel)
	local DamagePercent = Capped / 2.857142857142857 / 100
	local HealthPercent = Capped / 2 / 100
	return DamagePercent, HealthPercent
end

local function ApplyXP(PetEntry: Types.PetData, amount: number): number
	local LevelsGained = 0

	while amount > 0 do
		if PetEntry.Level >= PetsData.MaxLevel then
			return LevelsGained
		end

		local Needed = GetXPNeeded(PetEntry.Level)

		if Needed <= PetEntry.XP + amount then
			amount -= (Needed - PetEntry.XP)
			PetEntry.XP = 0
			PetEntry.Level += 1
			LevelsGained += 1
		else
			PetEntry.XP += amount
			amount = 0
		end
	end

	return LevelsGained
end

local function RefreshPetModifiers(player: Player)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	local Character = player.Character
	if not Character then
		return
	end

	local EquippedUUID = PlayerData.EquippedPet()

	if not EquippedUUID or EquippedUUID == "" then
		ModifierSystem:RemoveModifier(Character, "Damage", DAMAGE_MODIFIER_ID)
		ModifierSystem:RemoveModifier(Character, "MaxHealth", HEALTH_MODIFIER_ID)
		HealthManager:Refresh(player)
		return
	end

	local PetEntry = PlayerData.Pets[EquippedUUID]()
	if not PetEntry then
		return
	end

	local DamagePercent, HealthPercent = GetLevelBonuses(PetEntry.Level)

	ModifierSystem:AddModifier(Character, "Damage", DAMAGE_MODIFIER_ID, "Multiply", 1 + DamagePercent, 0, "Pet")
	ModifierSystem:AddModifier(Character, "MaxHealth", HEALTH_MODIFIER_ID, "Multiply", 1 + HealthPercent, 0, "Pet")

	HealthManager:Refresh(player)
end

function PetSystem:GetPetLimit(): number
	return PetsData.PetLimit
end

function PetSystem:AddPet(player: Player, petName: string, rarity: string): string?
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return nil
	end

	local UUID = Functions:GenUUID()
	local PetEntry: Types.PetData = {
		Name = petName,
		Rarity = rarity,
		Level = 1,
		XP = 0,
		Talent = RollTalent(),
		Locked = false,
	}

	PlayerData.Pets[UUID](PetEntry)

	return UUID
end

function PetSystem:BuyBox(player: Player, boxRarity: string, amount: number): (boolean, string, { string })
	local Cost = PetsData.BoxCost[boxRarity]
	if not Cost then
		return false, "Invalid box", {}
	end

	if typeof(amount) ~= "number" or amount ~= math.floor(amount) or amount <= 0 or amount > 10 then
		return false, "Invalid amount", {}
	end

	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return false, "Invalid player data", {}
	end

	local TotalCost = Cost * amount
	local Currencies = PlayerData.Currencies()

	if (Currencies.Gold or 0) < TotalCost then
		return false, "Not enough Gold", {}
	end

	local CurrentCount = 0
	for _ in PlayerData.Pets() do
		CurrentCount += 1
	end

	if CurrentCount + amount > PetsData.PetLimit then
		return false, "Not enough pet space", {}
	end

	PlayerData.Currencies.Gold(function(current)
		return current - TotalCost
	end)

	local Results = {}

	for _ = 1, amount do
		local PetName, RolledRarity = PetsData:RollPet(boxRarity)
		if PetName and RolledRarity then
			local UUID = self:AddPet(player, PetName, RolledRarity)
			if UUID then
				table.insert(Results, UUID)
			end
		end
	end

	return true, "Successfully purchased", Results
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
	RefreshPetModifiers(player)
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
	RefreshPetModifiers(player)
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

function PetSystem:LockPet(player: Player, UUID: string)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	local PetEntry = PlayerData.Pets[UUID]()
	if not PetEntry then
		return
	end

	PlayerData.Pets[UUID].Locked(not PetEntry.Locked)
end

function PetSystem:RemovePet(player: Player, UUID: string)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	local PetEntry = PlayerData.Pets[UUID]()
	if not PetEntry then
		return
	end

	if PetEntry.Locked then
		return
	end

	if PlayerData.EquippedPet() == UUID then
		return
	end

	if PlayerData.VanityPet() == UUID then
		return
	end

	PlayerData.Pets[UUID](nil)
end

function PetSystem:ClearPets(player: Player)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	local EquippedUUID = PlayerData.EquippedPet()
	local VanityUUID = PlayerData.VanityPet()

	for UUID, PetEntry in PlayerData.Pets() do
		if PetEntry.Locked then
			continue
		end

		if UUID == EquippedUUID or UUID == VanityUUID then
			continue
		end

		if not CLEARABLE_RARITIES[PetEntry.Rarity] then
			continue
		end

		PlayerData.Pets[UUID](nil)
	end
end

function PetSystem:FusePet(player: Player, targetUUID: string, catalystUUID: string?): (boolean, string)
	if not catalystUUID or catalystUUID == "" then
		return false, "No catalyst selected"
	end

	if targetUUID == catalystUUID then
		return false, "Cannot fuse a pet with itself"
	end

	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return false, "Invalid player data"
	end

	local TargetEntry = PlayerData.Pets[targetUUID]()
	if not TargetEntry then
		return false, "Target pet not found"
	end

	if PlayerData.EquippedPet() ~= targetUUID then
		return false, "Target pet must be equipped"
	end

	if TargetEntry.Level >= PetsData.MaxLevel then
		return false, "Pet is already max level"
	end

	local CatalystEntry = PlayerData.Pets[catalystUUID]()
	if not CatalystEntry then
		return false, "Catalyst pet not found"
	end

	if CatalystEntry.Locked then
		return false, "Catalyst pet is locked"
	end

	if PlayerData.VanityPet() == catalystUUID then
		return false, "Catalyst pet is in use as vanity"
	end

	local FusionInfo = PetsData.FusionInfo[CatalystEntry.Rarity]
	if not FusionInfo then
		return false, "Invalid catalyst rarity"
	end

	local GoldCost = CatalystEntry.Level * FusionInfo.Cost + FusionInfo.Cost
	local Currencies = PlayerData.Currencies()

	if (Currencies.Gold or 0) < GoldCost then
		return false, "Not enough Gold"
	end

	PlayerData.Currencies.Gold(function(current)
		return current - GoldCost
	end)

	local XPGiven = FusionInfo.Boost + FusionInfo.Boost * CatalystEntry.Level

	local UpdatedTarget = table.clone(TargetEntry)
	ApplyXP(UpdatedTarget, XPGiven)

	PlayerData.Pets[targetUUID].Level(UpdatedTarget.Level)
	PlayerData.Pets[targetUUID].XP(UpdatedTarget.XP)

	PlayerData.Pets[catalystUUID](nil)

	RefreshPetModifiers(player)

	return true, "Successfully fused pets"
end

function PetSystem:FuseAll(player: Player, targetUUID: string): (boolean, string)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return false, "Invalid player data"
	end

	if PlayerData.EquippedPet() ~= targetUUID then
		return false, "Target pet must be equipped"
	end

	local VanityUUID = PlayerData.VanityPet()
	local FusedAny = false

	local UUIDs = {}
	for UUID in PlayerData.Pets() do
		table.insert(UUIDs, UUID)
	end

	for _, UUID in UUIDs do
		if UUID == targetUUID then
			continue
		end

		local PetEntry = PlayerData.Pets[UUID]()
		if not PetEntry or PetEntry.Locked or UUID == VanityUUID then
			continue
		end

		local TargetEntry = PlayerData.Pets[targetUUID]()
		if not TargetEntry or TargetEntry.Level >= PetsData.MaxLevel then
			break
		end

		local Success = self:FusePet(player, targetUUID, UUID)
		if Success then
			FusedAny = true
		end
	end

	if not FusedAny then
		return false, "No pets were fused"
	end

	return true, "Successfully fused pets"
end

function PetSystem:Listen(player: Player)
	if ListenedPlayers[player] then
		return
	end
	ListenedPlayers[player] = true

	player.CharacterAdded:Connect(function()
		RefreshPetModifiers(player)
	end)
end

function PetSystem:LoadFromData(player: Player)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	local EquippedUUID = PlayerData.EquippedPet()
	if not EquippedUUID or EquippedUUID == "" then
		return
	end

	local PetEntry = PlayerData.Pets[EquippedUUID]()
	if not PetEntry then
		return
	end

	PetTalentManager:Equip(player, PetEntry)
	RefreshPetModifiers(player)
end

function PetSystem.OnPlayerRemoved(Player: Player)
	ListenedPlayers[Player] = nil
end

return PetSystem
