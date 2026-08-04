local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local BuffsManager = {}

local Buffed: { [Model]: { [string]: number } } = {}

function BuffsManager:AddBuff(Entity: Model, Stat: string, Duration: number, Amount: number, CustomName: string?)
	Buffed[Entity] = Buffed[Entity] or {}
	Buffed[Entity][Stat] = Amount

	if CustomName then
		RemoteManager.SendClientEvent("BuffVFX", { All = true }, CustomName, Entity, "Start")
	end

	task.delay(Duration, function()
		local EntityBuffs = Buffed[Entity]
		if not EntityBuffs then
			return
		end

		EntityBuffs[Stat] = nil

		if next(EntityBuffs) == nil then
			Buffed[Entity] = nil
		end

		if CustomName then
			RemoteManager.SendClientEvent("BuffVFX", { All = true }, CustomName, Entity, "End")
		end
	end)
end

function BuffsManager:RemoveBuff(Entity: Model, Stat: string)
	local EntityBuffs = Buffed[Entity]
	if EntityBuffs and EntityBuffs[Stat] then
		EntityBuffs[Stat] = nil

		if next(EntityBuffs) == nil then
			Buffed[Entity] = nil
		end
	end
end

function BuffsManager:GetBuffAmount(Entity: Model, Stat: string): number
	local EntityBuffs = Buffed[Entity]
	return (EntityBuffs and EntityBuffs[Stat]) or 0
end

function BuffsManager:ClearEntity(Entity: Model)
	Buffed[Entity] = nil
end

return BuffsManager
