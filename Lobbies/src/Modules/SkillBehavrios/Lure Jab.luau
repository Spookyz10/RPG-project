local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local BuffsManager = require(ServerStorage.Modules.BuffsManager)
local EventBus = require(ServerStorage.Modules.EventBus)
local DamageHandler = require(ServerStorage.Modules.DamageHandler)
local Hitbox = require(ServerStorage.Modules.Hitbox)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Behavior = {} :: Types.SkillBehavior

local BUFF_ID = "LureJab"

EventBus:Subscribe("BuffRemoved", function(target, buffId)
	if buffId == BUFF_ID then
		RemoteManager.SendClientEvent("BuffVFX", { All = true }, "Lure Jab", target, "End")
	end
end)

function Behavior:Execute(caster: Player, definition: Types.SkillDefinition)
	local Character = caster.Character
	if not Character then
		return
	end

	if Functions:isEntityAlive(Character) then
		Hitbox:Create({
			Size = Vector3.new(10, 10, 10),
			Part = Character.PrimaryPart,
			Drag = true,
			Offset = nil,
			Time = 0.3,
			Caster = Character,
			OnHit = function(Model, HitEntity)
				DamageHandler:dealDamage(Character, HitEntity, definition.Multiplier)
				local Player = Players:GetPlayerFromCharacter(Model)
				local Amount = Functions:GetTotalStats(HitEntity, Player and Data.Service:waitForData(Player)).Defense
					* 0.1

				BuffsManager:Apply(HitEntity, BUFF_ID, {
					Property = "Defense",
					Operation = "Add",
					Value = Amount,
					Duration = 5,
					Source = "Lure Jab",
				})

				RemoteManager.SendClientEvent("BuffVFX", { All = true }, "Lure Jab", HitEntity, "Start")
			end,
		})
	end
end

return Behavior
