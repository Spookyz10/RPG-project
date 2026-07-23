local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)

local PlayerClass = {}

local PlayerData = {} :: { [Player]: Types.PlayerInfo }

local playerAdded = Instance.new("BindableEvent")
local playerRemoving = Instance.new("BindableEvent")
local died = Instance.new("BindableEvent")

PlayerClass.PlayerAdded = playerAdded.Event
PlayerClass.PlayerRemoved = playerRemoving.Event
PlayerClass.Died = died.Event

function PlayerClass.new(player: Player): Types.PlayerInfo
	return {
		Player = player,
		HP = 100,
		MaxHP = 100,
		isPlayer = true,
	}
end

function PlayerClass.getPlayerInfo(player: Player): Types.PlayerInfo | nil
	if not PlayerData[player] then
		return nil
	end

	return PlayerData[player]
end

function PlayerClass.getLoadedPlayers(): { [Player]: Types.PlayerInfo }
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
