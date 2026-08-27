local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local ModifierSystem = require(script.Parent.ModifierSystem)

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

	VictimDefense = ModifierSystem:Aggregate(victim, "Defense", VictimDefense)
	CasterAttack = ModifierSystem:Aggregate(caster, "Damage", CasterAttack)

	local CritChance = ModifierSystem:Aggregate(caster, "Critical", CasterStats.Critical) + 5
	local isCrit = math.random() * 100 <= CritChance
	if isCrit then
		CasterAttack *= baseCriticalMultiplier
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
				Entry.Value = 0
				Entry.Parent = HitList
			end
			Entry.Value += Damage
		end
	end

	local VictimHumanoid = victim:FindFirstChildOfClass("Humanoid")
	VictimHumanoid.Health -= Damage

	if Functions:isClassMob(victim) and Functions:isEntityAlive(victim) then
		local MobHandler = require(script.Parent.MobHandler)
		MobHandler:StartBehavior(victim)
	end

	RemoteManager.SendClientEvent("Damage", { All = true }, victim, Damage, {
		Type = isCrit and "Crit" or "Base",
		CasterUserId = CasterPlayer and CasterPlayer.UserId,
	})
	return Damage, isCrit
end

function DamageHandler:heal(caster: Model, victim: Model, amount: number): number
	if amount <= 0 then
		return 0
	end

	if not Functions:isEntityAlive(victim) then
		return 0
	end

	local VictimHumanoid = victim:FindFirstChildOfClass("Humanoid")
	local HealAmount = math.min(amount, VictimHumanoid.MaxHealth - VictimHumanoid.Health)
	VictimHumanoid.Health += HealAmount

	local CasterPlayer = caster and Players:GetPlayerFromCharacter(caster)

	RemoteManager.SendClientEvent("Damage", { All = true }, victim, HealAmount, {
		Type = "Heal",
		CasterUserId = CasterPlayer and CasterPlayer.UserId,
	})
	return HealAmount
end

return DamageHandler
