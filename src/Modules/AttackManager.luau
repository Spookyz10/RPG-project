local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local CooldownSystem = require(script.Parent.CooldownSystem)
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local DamageHandler = require(script.Parent.DamageHandler)
local Hitbox = require(script.Parent.Hitbox)
local Skills = require(script.Parent.Skills)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local AttackManager = {}

function AttackManager:Swing(class: Types.Entity)
	local Player = Players:GetPlayerFromCharacter(class.Model)
	if not Player then
		print("what the hell!!!!!!!!")
		return
	end

	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	local Weapon = PlayerData.Equipment.Weapon()

	if Weapon == "" then
		print("Player has no weapon equipped.")
		return
	end

	if CooldownSystem:IsInCooldown(Player, "Swing") then
		return
	end

	local WeaponData = ItemsData[Weapon] :: Types.Equipment

	if not WeaponData then
		print("Invakid Weapon Id")
		return
	end

	if Functions:isEntityAlive(class) then
		CooldownSystem:StartCooldown(Player, "Swing", 0.6)
		local PrimaryPart = class.Model.PrimaryPart
		if PrimaryPart then
			Hitbox:Create({
				Size = Vector3.new(5, 5, 5),
				Part = PrimaryPart,
				Offset = CFrame.new(0, 0, -3),
				Time = 0.5,
				Drag = true,
				OnHit = function(_, HitEntity)
					DamageHandler:dealDamage(class, HitEntity)
					if WeaponData.Swing then
						WeaponData.Swing()
					end
				end,
			})
		end
	end
end

function AttackManager:UseSkill(class: Types.Entity, slot: string)
	local Player = Players:GetPlayerFromCharacter(class.Model)
	if not Player then
		print("what the hell!!!!!!!!")
		return
	end

	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	local EquippedSkills = PlayerData.Skills()

	local SkillInfo = Skills[EquippedSkills[slot]] :: Types.Skill
	if not SkillInfo then
		return
	end

	local key = slot .. SkillInfo.Name

	if CooldownSystem:IsInCooldown(Player, key) then
		return
	end

	CooldownSystem:StartCooldown(key, key, SkillInfo.Cooldown)

	SkillInfo:Activate(class)
end

return AttackManager
