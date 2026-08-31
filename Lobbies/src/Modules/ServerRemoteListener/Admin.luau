local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server

local ALLOWED_USER_ID = 531376199

local Remote = {}

local Methods = {}

function Methods.ResetData(_caller: Player, target: Player)
	if typeof(target) ~= "Instance" or not target:IsA("Player") then
		return
	end

	Data.Service:resetData(target)
end

function Methods.UpdateLevel(_caller: Player, target: Player, level: number)
	if typeof(target) ~= "Instance" or not target:IsA("Player") then
		return
	end

	Data.Service:waitForData(target).Level(level)
end

function Methods.GiveGold(_caller: Player, target: Player, amount: number)
	if typeof(target) ~= "Instance" or not target:IsA("Player") then
		return
	end

	if typeof(amount) ~= "number" then
		return
	end

	local PlayerData = Data.Service:waitForData(target)
	if not PlayerData then
		return
	end

	PlayerData.Currencies.Gold(function(current)
		return current + amount
	end)
end

function Remote:Activate(player: Player, method: string, ...: any)
	if player.UserId ~= ALLOWED_USER_ID then
		return
	end

	if typeof(method) ~= "string" then
		return
	end

	local Handler = Methods[method]
	if not Handler then
		return
	end

	Handler(player, ...)
end

return Remote
