local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local ModifierSystem = require(script.Parent.ModifierSystem)
local EventBus = require(script.Parent.EventBus)
local Passives = require(script.Parent.EquipmentPassives)

local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local DamageHandler = {}

local BASE_CRITICAL_MULTIPLIER = 2

function DamageHandler:BuildContext(caster: Model, victim: Model, multi: number?): Types.DamageContext
	local CasterPlayer = Players:GetPlayerFromCharacter(caster)
	local VictimPlayer = Players:GetPlayerFromCharacter(victim)

	local CasterData = CasterPlayer and Data.Service:waitForData(CasterPlayer)
	local VictimData = VictimPlayer and Data.Service:waitForData(VictimPlayer)

	local CasterStats = Functions:GetTotalStats(caster, CasterData and CasterData())
	local VictimStats = Functions:GetTotalStats(victim, VictimData and VictimData())

	local Context = {
		Caster = caster, Victim = victim,
		CasterPlayer = CasterPlayer, VictimPlayer = VictimPlayer,
		Attack = CasterStats.Attack,
		CriticalMultiplier = BASE_CRITICAL_MULTIPLIER + (CasterStats["Critical Power"] or 0) / 100,
		ForceCritical = false, TriggeredPassives = {},
		Multiplier = multi, Tags = {}, Cancelled = false,
		AttackerPassives = CasterData and Passives:Get(caster, CasterData()) or {},
		DefenderPassives = VictimData and Passives:Get(victim, VictimData()) or {},
	}
	EventBus:Fire("BeforeAttack", Context)
	local CasterAttack = Context.Attack
	local VictimDefense = VictimStats.Defense

	if multi then
		CasterAttack *= multi
	end

	VictimDefense = ModifierSystem:Aggregate(victim, "Defense", VictimDefense)
	CasterAttack = ModifierSystem:Aggregate(caster, "Damage", CasterAttack)

	local CritChance = ModifierSystem:Aggregate(caster, "Critical", CasterStats.Critical)
	local IsCrit = Context.ForceCritical or math.random() * 100 < CritChance
	if IsCrit then
		CasterAttack *= ModifierSystem:Aggregate(caster, "CriticalMultiplier", Context.CriticalMultiplier)
	end

	local FinalDamage = CasterAttack - VictimDefense
	FinalDamage = ModifierSystem:Aggregate(victim, "IncomingDamage", FinalDamage)
	Context.Damage = FinalDamage
	Context.IsCrit = IsCrit
	EventBus:Fire("BeforeIncomingDamage", Context)
	Context.Damage = math.max(0, Context.Damage)
	return Context
end

function DamageHandler:dealDamage(caster: Model, victim: Model, multi: number?): (number, boolean)
	if not Functions:isEntityAlive(caster) or not Functions:isEntityAlive(victim) then
		return 0, false
	end
	local Context = self:BuildContext(caster, victim, multi)

	EventBus:Fire("BeforeDamageCalculated", Context)

	if Context.Cancelled then
		return 0, false
	end

	local Damage = Context.Damage
	if Damage > 0 then
		EventBus:Fire("HitConfirmed", Context)
	end

	if Context.CasterPlayer then
		local HitList = victim:FindFirstChild("HitList")
		if HitList then
			local Entry = HitList:FindFirstChild(tostring(Context.CasterPlayer.UserId))
			if not Entry then
				Entry = Instance.new("NumberValue")
				Entry.Name = tostring(Context.CasterPlayer.UserId)
				Entry.Value = 0
				Entry.Parent = HitList
			end
			Entry.Value += Damage
		end
	end

	local VictimHumanoid = victim:FindFirstChildOfClass("Humanoid")
	VictimHumanoid.Health -= Damage
	if Damage > 0 then
		EventBus:Fire("HitApplied", Context)
	end

	EventBus:Fire("DamageDealt", Context)

	if Context.IsCrit then
		EventBus:Fire("CriticalHit", Context)
	end

	if VictimHumanoid.Health <= 0 then
		EventBus:Fire("LethalDamage", Context)
	end

	if Functions:isClassMob(victim) and Functions:isEntityAlive(victim) then
		local MobHandler = require(script.Parent.MobHandler)
		MobHandler:StartBehavior(victim)
	end

	RemoteManager.SendClientEvent("Damage", { All = true }, victim, Damage, {
		Type = Context.IsCrit and "Crit" or "Base",
		CasterUserId = Context.CasterPlayer and Context.CasterPlayer.UserId,
	})

	return Damage, Context.IsCrit
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

	EventBus:Fire("HealDealt", {
		Caster = caster,
		Victim = victim,
		Amount = HealAmount,
	})

	RemoteManager.SendClientEvent("Damage", { All = true }, victim, HealAmount, {
		Type = "Heal",
		CasterUserId = CasterPlayer and CasterPlayer.UserId,
	})
	return HealAmount
end

return DamageHandler
