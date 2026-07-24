local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuffsManager = require(script.Parent.BuffsManager)
local MobClass = require(ReplicatedStorage.Shared.MobClass)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local DamageHandler = {}

local baseCriticalMultiplier = 2

function DamageHandler:calculateDamage(caster: Types.Entity, victim: Types.Entity, multi: number): (number, boolean)
	local CasterStats = Functions:GetStatsFromClass(caster)
	local VictimStats = Functions:GetStatsFromClass(victim)

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

	local isCrit = math.random() * 100 <= CasterStats.CriticalChance
	if isCrit then
		CasterAttack *= (baseCriticalMultiplier * (1 + CasterStats.CriticalPower / 100))
	end

	return CasterAttack - VictimDefense, isCrit
end

function DamageHandler:dealDamage(caster: Types.Entity, victim: Types.Entity, multi: number)
	local Damage, isCrit = self:calculateDamage(caster, victim, multi)
	victim.HP = victim.HP - Damage
	if victim.HP <= 0 and Functions:isClassMob(victim) then
		MobClass.FireDied(victim.HitList, victim.Model:FindFirstChild("UUID").Value)
	end
	return Damage, isCrit
end

return DamageHandler
