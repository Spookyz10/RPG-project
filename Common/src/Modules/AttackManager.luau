local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local CombatConstants = require(ReplicatedStorage.Shared.Combat.Constants)
local AttackStyles = require(ReplicatedStorage.Shared.Combat.AttackStyles)

local CooldownSystem = require(script.Parent.CooldownSystem)
local ComboManager = require(script.Parent.ComboManager)
local StunManager = require(script.Parent.StunManager)
local DamageHandler = require(script.Parent.DamageHandler)
local Hitbox = require(script.Parent.Hitbox)
local SkillResolver = require(script.Parent.SkillResolver)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)

local Motion = require(script.Parent.MobAnimations)
local AttackManager = {}

local DEFAULT_SKILL_STUN_DURATION = 0.6
local DEFAULT_STYLE = "Solo"

local SwingComboIndex: { [Player]: number } = {}
local LastSwingTime: { [Player]: number } = {}

local function GetAttackStyle(WeaponData: Types.Equipment?)
	local WeaponType = WeaponData and WeaponData.WeaponType
	return (WeaponType and AttackStyles[WeaponType]) or AttackStyles[DEFAULT_STYLE]
end

function AttackManager:Swing(Player: Player)
	local Character = Player.Character
	if not Character then
		return
	end

	if StunManager:IsStunned(Player) then
		return
	end

	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	if not PlayerData or Player.Character ~= Character then
		return
	end

	local Weapon = PlayerData.Equipment.Weapon()
	if Weapon == "" then
		return
	end

	if CooldownSystem:IsInCooldown(Player, "Swing") then
		return
	end

	local WeaponEntry = PlayerData.Inventory[Weapon]()
	if not WeaponEntry then
		return
	end

	local WeaponData = Functions:GetItemInfo(WeaponEntry) :: Types.Equipment
	if not WeaponData then
		return
	end

	if not Functions:isEntityAlive(Character) then
		return
	end

	local PrimaryPart = Character.PrimaryPart
	if not PrimaryPart then
		return
	end

	local Style = GetAttackStyle(WeaponData)
	local Cooldown = Style.Cooldown or CombatConstants.SwingCooldown

	local Now = os.clock()
	local LastTime = LastSwingTime[Player] or 0
	if Now - LastTime > Cooldown * CombatConstants.ComboResetMultiplier then
		SwingComboIndex[Player] = 0
	end
	LastSwingTime[Player] = Now
	SwingComboIndex[Player] = ((SwingComboIndex[Player] or 0) % Style.MaxCombo) + 1

	CooldownSystem:StartCooldown(Player, "Swing", Cooldown)

	local comboIndex = SwingComboIndex[Player]
	Motion:Play(Character, Style.Prefix .. comboIndex)

	task.delay(0.2, function()
		if Player.Character ~= Character or not Functions:isEntityAlive(Character)
			or PlayerData.Equipment.Weapon() ~= Weapon or StunManager:IsStunned(Player) then
			return
		end
		RemoteManager.SendClientEvent("AttackSound", { All = true }, Character)
		RemoteManager.SendClientEvent("SkillVFX", { All = true }, "Basic", Character, comboIndex)

		Hitbox:Create({
			Size = Vector3.new(5, 5, 5),
			Part = PrimaryPart,
			Offset = CFrame.new(0, 0, -3),
			Time = 0.5,
			Caster = Character,
			Drag = true,
			OnHit = function(_, HitEntity)
				if Player.Character ~= Character or not Functions:isEntityAlive(Character) or PlayerData.Equipment.Weapon() ~= Weapon then return end
				DamageHandler:dealDamage(Character, HitEntity)
				if WeaponData.Swing then
					WeaponData.Swing()
				end
			end,
		})
	end)
end

function AttackManager:UseSkill(Player: Player, slot: string)
	if typeof(slot) ~= "string" or (slot ~= "Q" and slot ~= "E" and slot ~= "R") then return end
	local Character = Player.Character
	if not Character then
		return
	end

	if StunManager:IsStunned(Player) then
		return
	end

	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	if not PlayerData or Player.Character ~= Character then
		return
	end

	local Definition, Behavior = SkillResolver:GetEquippedSkill(PlayerData, slot)
	if not Definition or not Behavior then
		return
	end
	local slotLevel = ({ Q = 1, E = 5, R = 10 })[slot]
	if PlayerData.Level() < slotLevel or not Definition:Elligable(PlayerData()) then return end

	if CooldownSystem:IsInCooldown(Player, slot) then
		return
	end

	if not Functions:isEntityAlive(Character) then
		return
	end

	CooldownSystem:StartCooldown(Player, slot, Definition.Cooldown)

	RemoteManager.SendClientEvent("SkillCooldown", { Player = Player }, slot, Definition.Cooldown, Definition.Name)

	local duration = Motion:Play(Character, Definition.Name)
	StunManager:Stun(Player, math.max(duration, DEFAULT_SKILL_STUN_DURATION))
	task.delay(Definition.Name == "Cyclone" and 0.12 or 0.28, function()
		if Player.Character == Character and Functions:isEntityAlive(Character) and not StunManager:IsHardStunned(Player) then
			Behavior:Execute(Player, Definition)
		end
	end)

	ComboManager:RecordSkill(Player, Definition.Name)
end

function AttackManager.OnPlayerRemoved(Player: Player)
	SwingComboIndex[Player] = nil
	LastSwingTime[Player] = nil
end

return AttackManager
