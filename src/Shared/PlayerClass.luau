local Types = require(game:GetService("ReplicatedStorage").Shared.Utils.Types)

local PlayerClass = {}

local PlayerData = {} :: { [Player]: Types.Entity }

local playerAdded = Instance.new("BindableEvent")
local playerRemoving = Instance.new("BindableEvent")
local died = Instance.new("BindableEvent")

PlayerClass.PlayerAdded = playerAdded.Event
PlayerClass.PlayerRemoved = playerRemoving.Event
PlayerClass.Died = died.Event

function PlayerClass.new(player: Player, HP: number): Types.Entity
	local hpChanged = Instance.new("BindableEvent")
	local maxHpChanged = Instance.new("BindableEvent")

	print("adding class player")

	return {
		HP = HP,
		MaxHP = HP,
		Model = player.Character or player.CharacterAdded:Wait() :: Model,
		HitList = {},
		_HPChangedEvent = hpChanged,
		_MaxHPChangedEvent = maxHpChanged,
		OnHPChanged = hpChanged.Event,
		OnMaxHPChanged = maxHpChanged.Event,
	}
end

function PlayerClass.getPlayerInfo(player: Player): Types.Entity?
	local MaxWait = 3
	local StartTime = os.clock()

	while not PlayerData[player] do
		print(PlayerData[player], PlayerData)
		if os.clock() - StartTime >= MaxWait then
			return nil
		end
		task.wait()
	end

	return PlayerData[player]
end

function PlayerClass.getLoadedPlayers(): { [Player]: Types.Entity }
	return PlayerData
end

function PlayerClass.addPlayer(player: Player, health: number)
	local playerInfo = PlayerClass.new(player, health)
	PlayerData[player] = playerInfo
	print(PlayerData, PlayerData[player])
	playerAdded:Fire(player)
end

function PlayerClass.removePlayer(player: Player)
	local data = PlayerData[player]
	if data then
		playerRemoving:Fire(player)
		data._HPChangedEvent:Destroy()
		data._MaxHPChangedEvent:Destroy()
		PlayerData[player] = nil
	end
end

function PlayerClass.setHP(player: Player, newHP: number)
	local data = PlayerData[player]
	if not data then
		return
	end

	local oldHP = data.HP
	data.HP = newHP

	if newHP ~= oldHP then
		data._HPChangedEvent:Fire(newHP, oldHP)
	end

	if newHP <= 0 and oldHP > 0 then
		died:Fire(player)
	end
end

function PlayerClass.setMaxHP(player: Player, newMaxHP: number)
	local data = PlayerData[player]
	if not data then
		return
	end

	local oldMaxHP = data.MaxHP
	data.MaxHP = newMaxHP

	if newMaxHP ~= oldMaxHP then
		data._MaxHPChangedEvent:Fire(newMaxHP, oldMaxHP)
	end
end

return PlayerClass
