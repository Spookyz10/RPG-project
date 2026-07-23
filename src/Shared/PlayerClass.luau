local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)

local PlayerClass = {}

local PlayerData = {} :: { [Player]: Types.Entity }

local playerAdded = Instance.new("BindableEvent")
local playerRemoving = Instance.new("BindableEvent")
local died = Instance.new("BindableEvent")

PlayerClass.PlayerAdded = playerAdded.Event
PlayerClass.PlayerRemoved = playerRemoving.Event
PlayerClass.Died = died.Event

function PlayerClass.new(player: Player): Types.Entity
	return {
		HP = 100,
		MaxHP = 100,
		Model = player.Character :: Model,
		HitList = {},
		Buffs = {},
	}
end

function PlayerClass.getPlayerInfo(player: Player): Types.Entity?
	if not PlayerData[player] then
		return nil
	end

	return PlayerData[player]
end

function PlayerClass.getLoadedPlayers(): { [Player]: Types.Entity }
	return PlayerData
end

function PlayerClass.addPlayer(player: Player)
	local playerInfo = PlayerClass.new(player)
	PlayerData[player] = playerInfo
	playerAdded:Fire(player)
end

function PlayerClass.removePlayer(player: Player)
	local data = PlayerData[player]
	if data then
		playerRemoving:Fire(player)
		PlayerData[player] = nil
	end
end

return PlayerClass
