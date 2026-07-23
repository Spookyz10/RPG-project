local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local MobClass = {}

local LoadedMobs = {} :: { [string]: Types.Entity }

local mobAdded = Instance.new("BindableEvent")
local died = Instance.new("BindableEvent")

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

function MobClass.FireDied(hitlist: { [Player]: number }, ID: string)
	local mobInstance = LoadedMobs[ID]
	if mobInstance then
		died:Fire(mobInstance, hitlist)
	end
end

return MobClass
