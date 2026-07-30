local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local BuffsManager = require(ServerStorage.Modules.BuffsManager)
local DamageHandler = require(ServerStorage.Modules.DamageHandler)
local Hitbox = require(ServerStorage.Modules.Hitbox)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local SharedSkills = require(ReplicatedStorage.Shared.Skills)

local Skill = SharedSkills["Vital Jab"] :: Types.Skill

function Skill:Activate(class: Types.Entity)
	local Character = class.Model
	RemoteManager.SendClientEvent("SkillVFX", { All = true }, "Vital Jab", Character)
	if Character and Functions:isEntityAlive(class) then
		Hitbox:Create({
			Size = Vector3.new(10, 10, 10),
			Part = Character.PrimaryPart,
			Drag = true,
			Offset = nil,
			Time = 0.3,
			Caster = Character,
			OnHit = function(Model, HitEntity)
				DamageHandler:dealDamage(class, HitEntity, self.Multiplier)
				local Player = Players:GetPlayerFromCharacter(Model)
				BuffsManager:AddBuff(
					HitEntity,
					"Defense",
					5,
					Functions:GetTotalStats(HitEntity, Player and Data.Service:waitForData(Player)).Defense * 0.1
				)
			end,
		})
	end
end

return Skill
