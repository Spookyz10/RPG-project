local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local CombatConstants = require(ReplicatedStorage.Shared.Combat.Constants)

local CooldownSystem = require(script.Parent.CooldownSystem)
local ComboManager = require(script.Parent.ComboManager)
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local DamageHandler = require(script.Parent.DamageHandler)
local Hitbox = require(script.Parent.Hitbox)
local SkillResolver = require(script.Parent.SkillResolver)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)

local AttackManager = {}

function AttackManager:Swing(Player: Player)
	local Character = Player.Character
	if not Character then
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

	CooldownSystem:StartCooldown(Player, "Swing", CombatConstants.SwingCooldown - 0.2)

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

	Behavior:Execute(Player, Definition)

	ComboManager:RecordSkill(Player, Definition.Name)
end

return AttackManager
