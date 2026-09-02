local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local CombatConstants = require(ReplicatedStorage.Shared.Combat.Constants)
local AttackStyles = require(ReplicatedStorage.Shared.Combat.AttackStyles)
local AnimationHandler = require(ReplicatedStorage.Shared.AnimationHandler)

local CooldownSystem = require(script.Parent.CooldownSystem)
local ComboManager = require(script.Parent.ComboManager)
local StunManager = require(script.Parent.StunManager)
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local DamageHandler = require(script.Parent.DamageHandler)
local Hitbox = require(script.Parent.Hitbox)
local SkillResolver = require(script.Parent.SkillResolver)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)

local AttackManager = {}

local DEFAULT_SKILL_STUN_DURATION = 0.6
local SKILL_STUN_RELEASE_BUFFER = 0.1
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
	if not PlayerData then
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

	local WeaponData = ItemsData[WeaponEntry.Name] :: Types.Equipment
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

	CooldownSystem:StartCooldown(Player, "Swing", Cooldown - 0.2)

	local Handler = AnimationHandler.GetOrCreate(Character)
	Handler:Play(Style.Prefix .. SwingComboIndex[Player], 0.1)

	RemoteManager.SendClientEvent("AttackSound", { All = true }, Character)

	Hitbox:Create({
		Size = Vector3.new(5, 5, 5),
		Part = PrimaryPart,
		Offset = CFrame.new(0, 0, -3),
		Time = 0.5,
		Caster = Character,
		Drag = true,
		OnHit = function(_, HitEntity)
			DamageHandler:dealDamage(Character, HitEntity)
			if WeaponData.Swing then
				WeaponData.Swing()
			end
		end,
	})
end

function AttackManager:UseSkill(Player: Player, slot: string)
	local Character = Player.Character
	if not Character then
		return
	end

	if StunManager:IsStunned(Player) then
		return
	end

	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	local Definition, Behavior = SkillResolver:GetEquippedSkill(PlayerData, slot)
	if not Definition or not Behavior then
		return
	end

	if CooldownSystem:IsInCooldown(Player, slot) then
		return
	end

	if not Functions:isEntityAlive(Character) then
		return
	end

	CooldownSystem:StartCooldown(Player, slot, Definition.Cooldown)

	RemoteManager.SendClientEvent("SkillCooldown", { Player = Player }, slot, Definition.Cooldown)

	local Track = Behavior:Execute(Player, Definition)

	StunManager:StunUntilAnimationEnds(Player, Track, SKILL_STUN_RELEASE_BUFFER, DEFAULT_SKILL_STUN_DURATION)

	ComboManager:RecordSkill(Player, Definition.Name)
end

function AttackManager.OnPlayerRemoved(Player: Player)
	SwingComboIndex[Player] = nil
	LastSwingTime[Player] = nil
end

return AttackManager
