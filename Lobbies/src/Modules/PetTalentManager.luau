local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Talents = require(ReplicatedStorage.Shared.Talents)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Data = require(ReplicatedStorage.Shared.Data).server
local ModifierSystem = require(script.Parent.ModifierSystem)
local EventBus = require(script.Parent.EventBus)
local DamageHandler = require(script.Parent.DamageHandler)

local PetTalentManager = {}

local MODIFIER_ID = "PetTalent"

local SPECIAL_STATS = {
	Gold = true,
	XP = true,
	ExecuteDamage = true,
	Lifesteal = true,
}

local GOLD_CAP_PER_LEVEL = 1250000
local GILDED_MAX_DAMAGE_BONUS = 0.625
local MYSTIC_EXECUTE_THRESHOLD = 0.25
local MEDIC_HEAL_PERCENT = 0.05
local MEDIC_INTERVAL = 15
local VAMPIRIC_LIFESTEAL_PERCENT = 1 / 100

local ActiveTalent: { [Player]: string } = {}
local ActiveLoops: { [Player]: boolean } = {}
local ListenedPlayers: { [Player]: boolean } = {}

local function ConvertPercentageValue(value: number): number
	return 1 + value / 100
end

local function ApplyStatEffects(Character: Model, talentName: string, effects: { Types.TalentEffect })
	for _, effect in effects do
		if SPECIAL_STATS[effect.Stat] then
			continue
		end

		local ModifierKey = MODIFIER_ID .. ":" .. talentName .. ":" .. effect.Stat

		if effect.Type == "Percentage" then
			ModifierSystem:AddModifier(
				Character,
				effect.Stat,
				ModifierKey,
				"Multiply",
				ConvertPercentageValue(effect.Value),
				0,
				"Pet"
			)
		else
			ModifierSystem:AddModifier(Character, effect.Stat, ModifierKey, "Add", effect.Value, 0, "Pet")
		end
	end
end

local function RemoveStatEffects(Character: Model, talentName: string, effects: { Types.TalentEffect })
	for _, effect in effects do
		if SPECIAL_STATS[effect.Stat] then
			continue
		end

		ModifierSystem:RemoveModifier(Character, effect.Stat, MODIFIER_ID .. ":" .. talentName .. ":" .. effect.Stat)
	end
end

local function StartHealLoop(Player: Player)
	if ActiveLoops[Player] then
		return
	end
	ActiveLoops[Player] = true

	task.spawn(function()
		while ActiveLoops[Player] and Player.Parent do
			task.wait(MEDIC_INTERVAL)

			if not ActiveLoops[Player] or not Player.Parent then
				break
			end

			local Character = Player.Character
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
			if not Humanoid or Humanoid.Health <= 0 then
				continue
			end

			DamageHandler:heal(Character, Character, Humanoid.MaxHealth * MEDIC_HEAL_PERCENT)
		end
	end)
end

local function StopHealLoop(Player: Player)
	ActiveLoops[Player] = nil
end

function PetTalentManager:Equip(Player: Player, PetEntry: Types.PetData)
	local TalentName = PetEntry.Talent
	local TalentInfo = Talents[TalentName]
	if not TalentInfo then
		return
	end

	ActiveTalent[Player] = TalentName

	local Character = Player.Character
	if Character then
		ApplyStatEffects(Character, TalentName, TalentInfo.Effects)
	end

	if TalentInfo.HealsOverTime then
		StartHealLoop(Player)
	end
end

function PetTalentManager:Unequip(Player: Player)
	local TalentName = ActiveTalent[Player]
	if not TalentName then
		return
	end

	local TalentInfo = Talents[TalentName]
	local Character = Player.Character

	if TalentInfo and Character then
		RemoveStatEffects(Character, TalentName, TalentInfo.Effects)
	end

	if TalentInfo and TalentInfo.HealsOverTime then
		StopHealLoop(Player)
	end

	ActiveTalent[Player] = nil
end

function PetTalentManager:GetActiveTalent(Player: Player): (string?, Types.TalentInfo?)
	local TalentName = ActiveTalent[Player]
	if not TalentName then
		return nil, nil
	end
	return TalentName, Talents[TalentName]
end

function PetTalentManager:GetGoldMultiplier(Player: Player): number
	local TalentName, TalentInfo = self:GetActiveTalent(Player)
	if not TalentName or not TalentInfo or TalentInfo.Unique ~= "Midas" then
		return 1
	end

	for _, effect in TalentInfo.Effects do
		if effect.Stat == "Gold" then
			return ConvertPercentageValue(effect.Value)
		end
	end

	return 1
end

function PetTalentManager:GetXPMultiplier(Player: Player): number
	local TalentName, TalentInfo = self:GetActiveTalent(Player)
	if not TalentName or not TalentInfo or TalentInfo.Unique ~= "Smarty" then
		return 1
	end

	for _, effect in TalentInfo.Effects do
		if effect.Stat == "XP" then
			return ConvertPercentageValue(effect.Value)
		end
	end

	return 1
end

function PetTalentManager:Listen(Player: Player)
	if ListenedPlayers[Player] then
		return
	end
	ListenedPlayers[Player] = true

	Player.CharacterAdded:Connect(function(Character)
		local TalentName = ActiveTalent[Player]
		if not TalentName then
			return
		end

		local TalentInfo = Talents[TalentName]
		if TalentInfo then
			ApplyStatEffects(Character, TalentName, TalentInfo.Effects)
		end
	end)
end

function PetTalentManager:LoadFromData(Player: Player)
	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
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

	self:Equip(Player, PetEntry)
end

function PetTalentManager.OnPlayerRemoved(Player: Player)
	PetTalentManager:Unequip(Player)
	ActiveTalent[Player] = nil
	ActiveLoops[Player] = nil
	ListenedPlayers[Player] = nil
end

EventBus:Subscribe("BeforeDamageCalculated", function(Context: Types.DamageContext)
	if not Context.CasterPlayer then
		return
	end

	local TalentName, TalentInfo = PetTalentManager:GetActiveTalent(Context.CasterPlayer)
	if not TalentName or not TalentInfo then
		return
	end

	if TalentInfo.Unique == "Mystic" then
		local VictimHumanoid = Context.Victim:FindFirstChildOfClass("Humanoid")
		if VictimHumanoid and VictimHumanoid.MaxHealth > 0 then
			local HealthPercent = VictimHumanoid.Health / VictimHumanoid.MaxHealth
			if HealthPercent <= MYSTIC_EXECUTE_THRESHOLD then
				for _, effect in TalentInfo.Effects do
					if effect.Stat == "ExecuteDamage" then
						Context.Damage *= ConvertPercentageValue(effect.Value)
					end
				end
			end
		end
	elseif TalentInfo.Unique == "Gilded" then
		local PlayerData = Data.Service:waitForData(Context.CasterPlayer) :: Types.PlayerData
		if PlayerData then
			local Gold = PlayerData.Currencies().Gold or 0
			local FakeCap = math.max(1, PlayerData.Level() * GOLD_CAP_PER_LEVEL)
			local Proximity = math.clamp(Gold / FakeCap, 0, 1)
			Context.Damage *= 1 + Proximity * GILDED_MAX_DAMAGE_BONUS
		end
	end
end)

EventBus:Subscribe("DamageDealt", function(Context: Types.DamageContext)
	if not Context.CasterPlayer or Context.Damage <= 0 then
		return
	end

	local TalentName, TalentInfo = PetTalentManager:GetActiveTalent(Context.CasterPlayer)
	if not TalentName or not TalentInfo or TalentInfo.Unique ~= "Vampiric" then
		return
	end

	local Character = Context.CasterPlayer.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then
		return
	end

	DamageHandler:heal(Character, Character, Humanoid.MaxHealth * VAMPIRIC_LIFESTEAL_PERCENT)
end)

return PetTalentManager
