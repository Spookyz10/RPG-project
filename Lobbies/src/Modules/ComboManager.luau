local Players = game:GetService("Players")

local ComboManager = {}

local HistoryWindow = 4
local ComboTimeout = 2.5

export type ComboEffect = (player: Player) -> ()

export type ComboDefinition = {
	Sequence: { string },
	Effect: ComboEffect,
}

local PlayerHistory: { [Player]: { { Skill: string, Time: number } } } = {}
local Combos: { ComboDefinition } = {}

local function getHistory(player: Player)
	local History = PlayerHistory[player]
	if not History then
		History = {}
		PlayerHistory[player] = History
	end
	return History
end

local function trimHistory(History: { { Skill: string, Time: number } })
	local Now = os.clock()
	while #History > 0 and (Now - History[1].Time > ComboTimeout) do
		table.remove(History, 1)
	end

	while #History > HistoryWindow do
		table.remove(History, 1)
	end
end

local function matchesSequence(History: { { Skill: string, Time: number } }, Sequence: { string }): boolean
	if #History < #Sequence then
		return false
	end

	local Offset = #History - #Sequence
	for index, skillName in Sequence do
		if History[Offset + index].Skill ~= skillName then
			return false
		end
	end

	return true
end

function ComboManager:RegisterCombo(sequence: { string }, effect: ComboEffect)
	table.insert(Combos, { Sequence = sequence, Effect = effect })
end

function ComboManager:RecordSkill(player: Player, skillName: string)
	local History = getHistory(player)
	table.insert(History, { Skill = skillName, Time = os.clock() })
	trimHistory(History)

	for _, combo in Combos do
		if matchesSequence(History, combo.Sequence) then
			combo.Effect(player)
			table.clear(History)
			break
		end
	end
end

function ComboManager:ClearPlayer(player: Player)
	PlayerHistory[player] = nil
end

Players.PlayerRemoving:Connect(function(player: Player)
	ComboManager:ClearPlayer(player)
end)

return ComboManager
