local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local BuffsManager = require(script.Parent.BuffsManager)

local MobClass = require(ReplicatedStorage.Shared.MobClass)

local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local DamageHandler = {}

local baseCriticalMultiplier = 2

function DamageHandler:calculateDamage(caster: Types.Entity, victim: Types.Entity, multi: number): (number, boolean)
	local CasterPlayer = Players:GetPlayerFromCharacter(caster.Model)
	local VictimPlayer = Players:GetPlayerFromCharacter(victim.Model)

	local CasterData = CasterPlayer and Data.Service:waitForData(CasterPlayer)
	local VictimData = VictimPlayer and Data.Service:waitForData(VictimPlayer)

	local CasterStats = Functions:GetTotalStats(caster.Model, CasterData and CasterData())
	local VictimStats = Functions:GetTotalStats(victim.Model, VictimData and VictimData())

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

function DamageHandler:dealDamage(caster: Types.Entity, victim: Types.Entity, multi: number)
	local Damage, isCrit = self:calculateDamage(caster, victim, multi)
	victim.HP = victim.HP - Damage

	if Functions:isClassMob(victim) then
		local CasterPlayer = Players:GetPlayerFromCharacter(caster.Model)
		MobClass.FireDamaged(victim, CasterPlayer, Damage)

		if victim.HP <= 0 then
			MobClass.FireDied(victim.HitList, victim.Model:FindFirstChild("UUID").Value)
		end
	end

	RemoteManager.SendClientEvent("Damage", { All = true }, victim.Model, Damage, { Crit = isCrit })
	return Damage, isCrit
end

function DamageHandler:heal(caster: Types.Entity, victim: Types.Entity, amount: number): number
	if amount <= 0 then
		return 0
	end

	if not Functions:isEntityAlive(victim) then
		return 0
	end

	local HealAmount = math.min(amount, victim.MaxHP - victim.HP)
	victim.HP += HealAmount

	RemoteManager.SendClientEvent("Damage", { All = true }, victim.Model, HealAmount, { Heal = true })
	return HealAmount
end

return DamageHandler
