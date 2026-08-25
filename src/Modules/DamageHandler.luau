local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local BuffsManager = require(script.Parent.BuffsManager)

local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local DamageHandler = {}

local baseCriticalMultiplier = 2

function DamageHandler:calculateDamage(caster: Model, victim: Model, multi: number): (number, boolean)
	local CasterPlayer = Players:GetPlayerFromCharacter(caster)
	local VictimPlayer = Players:GetPlayerFromCharacter(victim)

	local CasterData = CasterPlayer and Data.Service:waitForData(CasterPlayer)
	local VictimData = VictimPlayer and Data.Service:waitForData(VictimPlayer)

	local CasterStats = Functions:GetTotalStats(caster, CasterData and CasterData())
	local VictimStats = Functions:GetTotalStats(victim, VictimData and VictimData())

	local CasterAttack = CasterStats.Attack
	local VictimDefense = VictimStats.Defense

	if multi then
		CasterAttack *= multi
	end

	local ExtraDefense = BuffsManager:GetBuffAmount(victim, "Defense")

	if ExtraDefense then
		VictimDefense += ExtraDefense
	end

	local DamageBuff = BuffsManager:GetBuffAmount(caster, "Damage")
	if DamageBuff then
		CasterAttack *= 1 + DamageBuff / 100
	end

	local isCrit = math.random() * 100
		<= CasterStats.CriticalChance + BuffsManager:GetBuffAmount(caster, "CriticalChance") + 5
	if isCrit then
		CasterAttack *= (baseCriticalMultiplier * (1 + CasterStats.CriticalPower / 100))
	end

	local FinalDamage = CasterAttack - VictimDefense

	if FinalDamage < 0 then
		FinalDamage = 0
	end

	return FinalDamage, isCrit
end

function DamageHandler:dealDamage(caster: Model, victim: Model, multi: number)
	local Damage, isCrit = self:calculateDamage(caster, victim, multi)

	local CasterPlayer = Players:GetPlayerFromCharacter(caster)
	if CasterPlayer then
		local HitList = victim:FindFirstChild("HitList")
		if HitList then
			local Entry = HitList:FindFirstChild(tostring(CasterPlayer.UserId))
			if not Entry then
				Entry = Instance.new("NumberValue")
				Entry.Name = tostring(CasterPlayer.UserId)
				Entry.Parent = HitList
			end
			Entry.Value = os.clock()
		end
	end

	local VictimHumanoid = victim:FindFirstChildOfClass("Humanoid")
	VictimHumanoid.Health -= Damage

	RemoteManager.SendClientEvent("Damage", { All = true }, victim, Damage, { Crit = isCrit })
	return Damage, isCrit
end

function DamageHandler:heal(_caster: Model, victim: Model, amount: number): number
	if amount <= 0 then
		return 0
	end

	if not Functions:isEntityAlive(victim) then
		return 0
	end

	local VictimHumanoid = victim:FindFirstChildOfClass("Humanoid")
	local HealAmount = math.min(amount, VictimHumanoid.MaxHealth - VictimHumanoid.Health)
	VictimHumanoid.Health += HealAmount

	RemoteManager.SendClientEvent("Damage", { All = true }, victim, HealAmount, { Heal = true })
	return HealAmount
end

return DamageHandler
