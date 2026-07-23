local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local CooldownSystem = require(script.Parent.CooldownSystem)
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local DamageHandler = require(script.Parent.DamageHandler)
local Hitbox = require(script.Parent.Hitbox)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local AttackManager = {}

function AttackManager:Swing(class: Types.Entity)
	local Player = Players:GetPlayerFromCharacter(class.Model)
	if not Player then
		print("what the hell!!!!!!!!")
		return
	end

	local PlayerData = Data.Service:waitForData(Player)
	local Weapon = PlayerData.Equipment.Weapon()

	if not Weapon then
		print("Player has no weapon equipped.")
		return
	end

	local WeaponData = ItemsData[Weapon] :: Types.Equipment

	if Functions:isEntityAlive(class) then
		CooldownSystem:StartCooldown(Player, "Swing", 0.6)
		local PrimaryPart = class.Model.PrimaryPart
		if PrimaryPart then
			Hitbox:Create({
				Size = Vector3.new(5, 5, 5),
				Position = PrimaryPart.CFrame,
				Time = 0.5,
				Drag = true,
				OnHit = function(_, HitEntity)
					DamageHandler:dealDamage(WeaponData.Stats.Attack, HitEntity)
					if WeaponData.Swing then
						WeaponData.Swing()
					end
				end,
			})
		end
	end
end

return AttackManager
