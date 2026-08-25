local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server

local CooldownSystem = require(script.Parent.CooldownSystem)
local ComboManager = require(script.Parent.ComboManager)
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local DamageHandler = require(script.Parent.DamageHandler)
local Hitbox = require(script.Parent.Hitbox)
local Skills = require(script.Parent.Skills)
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

	CooldownSystem:StartCooldown(Player, "Swing", 0.6)

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

	local EquippedSkills = PlayerData.Skills()
	local SkillInfo = Skills[EquippedSkills[slot]] :: Types.Skill
	if not SkillInfo then
		return
	end

	local key = slot .. SkillInfo.Name

	if CooldownSystem:IsInCooldown(Player, key) then
		return
	end

	if not Functions:isEntityAlive(Character) then
		return
	end

	CooldownSystem:StartCooldown(Player, key, SkillInfo.Cooldown)

	RemoteManager.SendClientEvent("SkillCooldown", { Player = Player }, slot, SkillInfo.Cooldown)

	local Entity = { Model = Character } :: Types.Entity

	SkillInfo:Activate(Entity)

	ComboManager:RecordSkill(Player, Entity, SkillInfo.Name)
end

return AttackManager
