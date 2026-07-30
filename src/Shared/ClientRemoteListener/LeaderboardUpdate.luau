local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Abbreviation = require(ReplicatedStorage.Shared.Utils.Abbreviation)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Remote = {}

local BoardFolders: { [Types.LeaderboardBoard]: string } = {
	Gold = "Gold",
	Kills = "Kills",
	PlayTime = "Play Time",
}

local RankStyles = { "Top1", "Top2", "Top3" }

local function FormatPlayTime(seconds: number): string
	if seconds < 60 then
		return math.floor(seconds) .. "s"
	elseif seconds < 3600 then
		return (string.format("%.1f", seconds / 60):gsub("%.0$", "")) .. "m"
	elseif seconds < 86400 then
		return (string.format("%.1f", seconds / 3600):gsub("%.0$", "")) .. "h"
	else
		return (string.format("%.1f", seconds / 86400):gsub("%.0$", "")) .. "d"
	end
end

local Formatters: { [Types.LeaderboardBoard]: (number) -> string } = {
	Gold = function(value: number)
		return Abbreviation:Number(value)
	end,
	Kills = function(value: number)
		return tostring(math.floor(value))
	end,
	PlayTime = FormatPlayTime,
}

local ActiveEntries: { [Types.LeaderboardBoard]: { Frame } } = {
	Gold = {},
	Kills = {},
	PlayTime = {},
}

local function ApplyRank(Entry: Frame, rank: number)
	Entry.Basic.Visible = rank > 3
	for index, styleName in RankStyles do
		Entry[styleName].Visible = rank == index
	end
end

local function CreateEntry(
	board: Types.LeaderboardBoard,
	rank: number,
	data: Types.LeaderboardEntry,
	Container: Instance
)
	local Template = ReplicatedStorage.Assets.UI.Templates.Leaderboard
	local Entry = Template:Clone() :: Frame

	ApplyRank(Entry, rank)

	Entry.PlayerName.Text = data.Name
	Entry.Stat.Text = Formatters[board](data.Value)

	local success, thumbnail = pcall(
		Players.GetUserThumbnailAsync,
		Players,
		data.UserId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size100x100
	)

	if success then
		Entry.Player.Image = thumbnail
	end

	Entry.LayoutOrder = rank
	Entry.Parent = Container

	table.insert(ActiveEntries[board], Entry)
end

function Remote:Activate(board: Types.LeaderboardBoard, entries: { Types.LeaderboardEntry })
	local FolderName = BoardFolders[board]
	if not FolderName then
		return
	end

	local Leaderboards = UIConstants.PlayerGui:WaitForChild("Leaderboards")
	local BoardFrame = Leaderboards:FindFirstChild(FolderName)
	if not BoardFrame then
		return
	end

	local Container = BoardFrame:FindFirstChild("Container")
	if not Container then
		return
	end

	for _, Entry in ActiveEntries[board] do
		Entry:Destroy()
	end
	table.clear(ActiveEntries[board])

	for rank, data in entries do
		CreateEntry(board, rank, data, Container)
	end
end

return Remote
