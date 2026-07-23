local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MobClass = require(ReplicatedStorage.Shared.MobClass)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local DamageHandler = {}

local baseCriticalMultiplier = 2

function DamageHandler:calculateDamage(amount: number, class: Types.Entity): (number, boolean)
	local Stats = Functions:GetStatsFromClass(class)
	local Defense = Stats.Defense
	local criticalChance = Stats.CriticalChance
	local criticalPower = Stats.CriticalPower

	local isCrit = math.random() * 100 < criticalChance
	local Damage = isCrit and (amount - Defense) * (baseCriticalMultiplier * criticalPower / 100) or (amount - Defense)

	return Damage, isCrit
end

function DamageHandler:dealDamage(amount: number, entity: Types.Entity)
	local Damage, isCrit = self:calculateDamage(amount, entity)
	entity.HP = math.clamp(entity.HP - Damage, 0, entity.MaxHP)
	if entity.HP <= 0 and Functions:isClassMob(entity) then
		MobClass.FireDied(entity.HitList, entity.Model:FindFirstChild("UUID").Value)
	end
	return Damage, isCrit
end

return DamageHandler
