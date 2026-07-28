local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local MobClass = {}

local LoadedMobs = {} :: { [string]: Types.Entity }

local mobAdded = Instance.new("BindableEvent")
local died = Instance.new("BindableEvent")
local damaged = Instance.new("BindableEvent")

MobClass.Damaged = damaged.Event
MobClass.MobAdded = mobAdded.Event
MobClass.Died = died.Event

function MobClass.addMob(mobData: Types.Entity)
	local GenertaedID = Functions:GenUUID()
	LoadedMobs[GenertaedID] = mobData
	local Value = Instance.new("StringValue")
	Value.Parent = mobData.Model
	Value.Name = "UUID"
	Value.Value = GenertaedID
	mobAdded:Fire(mobData)
	return GenertaedID
end

function MobClass.removeMob(ID: string)
	if LoadedMobs[ID] then
		LoadedMobs[ID] = nil
	end
end

function MobClass.getMob(ID: string): Types.Entity?
	if not LoadedMobs[ID] then
		return nil
	end

	return LoadedMobs[ID]
end

function MobClass.FireDied(ID: string)
	local mobInstance = LoadedMobs[ID]
	if mobInstance then
		died:Fire(mobInstance, mobInstance.HitList)
	end
end

function MobClass.FireDamaged(mobInstance: Types.Entity, casterPlayer: Player?, amount: number)
	damaged:Fire(mobInstance, casterPlayer, amount)
end

function MobClass.setHP(ID: string, newHP: number)
	local data = LoadedMobs[ID]
	if not data then
		return
	end

	local oldHP = data.HP
	data.HP = newHP

	if newHP ~= oldHP then
		data._HPChangedEvent:Fire(newHP, oldHP)
	end

	if newHP <= 0 and oldHP > 0 then
		died:Fire(data, data.HitList)
	end
end

function MobClass.setMaxHP(ID: string, newMaxHP: number)
	local data = LoadedMobs[ID]
	if not data then
		return
	end

	local oldMaxHP = data.MaxHP
	data.MaxHP = newMaxHP

	if newMaxHP ~= oldMaxHP then
		data._MaxHPChangedEvent:Fire(newMaxHP, oldMaxHP)
	end
end

return MobClass
