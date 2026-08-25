local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)

local UI = {}

local EquipmentEntries = {}

function UI.Init()
	local Card = UIConstants.PlayerGui:WaitForChild("Overlap").PlayerCard

	Card.Close.MouseButton1Click:Connect(function()
		Card.Visible = false
	end)
end

function UI.Open(targetPlayer: Player)
	local Card = UIConstants.PlayerGui:WaitForChild("Overlap").PlayerCard
	local Data = RemoteManager.InvokeServerFunction("GetPlayerInfo", targetPlayer)

	if not Data then
		return
	end

	Card.PlayerName.Text = Data.Name .. "'s Player Card"
	Card.Player.Level.Text = "Level: " .. Data.Level
	Card.Player.Icon.Image =
		Players:GetUserThumbnailAsync(targetPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)

	local StatsInfo = Card.Stats.Info
	StatsInfo.Attack.Text = "Attack: " .. Data.Stats.Attack
	StatsInfo.Defense.Text = "Defense: " .. Data.Stats.Defense
	StatsInfo.Critical.Text = "Critical Chance: " .. Data.Stats.CriticalChance
	StatsInfo.Luck.Text = "Luck: " .. Data.Stats.Luck
	StatsInfo.Speed.Text = "Speed: " .. Data.Stats.Speed
	StatsInfo.Health.Text = "Health: " .. Data.Stats.Health

	local Misc = Card.Stats.Misc
	Misc.Gold.Text = "Gold: " .. Data.Gold
	Misc.Gems.Text = "Gems: " .. Data.Gems
	Misc.PlayTime.Text = "Play Time: " .. Functions.FormatTime(Data.PlayTime)
	Misc.Deaths.Text = "Deaths: " .. Data.Deaths
	Misc.Kills.Text = "Kills: " .. Data.Kills

	local EquipmentInfo = Card.Equipment.Info
	for _, entry in EquipmentEntries do
		entry:Destroy()
	end
	table.clear(EquipmentEntries)

	local EquipmentTemplate = ReplicatedStorage.Assets.UI.Templates.Equipment

	for _, itemInfo in Data.Equipment do
		local Clone = EquipmentTemplate:Clone()
		Clone.Icon.Image = itemInfo.Icon
		Clone.TypeLabel.Text = itemInfo.SubType
		UIFunctions:ApplyRarityGradient(Clone.Rarity, itemInfo.Rarity)
		Clone.Parent = EquipmentInfo
		table.insert(EquipmentEntries, Clone)
	end

	Card.Visible = true
end

return UI
