local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local RewardManager = require(script.Parent.RewardManager)
local Data = require(ReplicatedStorage.Shared.Data).server
local DailyReward = {}

function DailyReward.ClaimDaily(Player: Player)
	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData

	if not PlayerData then
		RemoteManager.SendClientEvent("Notification", { Player = Player }, "Invalid data? how.")
		return
	end

	local timeNow = os.clock()
	local LastClaimed = PlayerData.LastDailyReward()

	if timeNow - LastClaimed < 86400 then
		RemoteManager.SendClientEvent(
			"Notification",
			{ Player = Player },
			"You may claim in " .. Functions.FormatTime(timeNow - LastClaimed)
		)
		return
	end

	PlayerData.LastDailyReward(timeNow)
	PlayerData.TotalDailyRewards(function(current)
		return current + 1
	end)
	PlayerData.DailyStreak(function(current)
		return current + 1
	end)

	local XPToGive = Functions:GetXPNeeded(PlayerData.Level()) * (0.1 + PlayerData.DailyStreak() * 0.05)
	local GoldToGive = (PlayerData.Level() * 100) * (0.1 + PlayerData.DailyStreak() * 0.05)
	RewardManager:AddXP(Player, XPToGive)
	RewardManager:AddCurrency(Player, "Gold", GoldToGive)

	RemoteManager.SendClientEvent(
		"Notification",
		{ Player = Player },
		"Successfully claimed daily reward! You got: " .. XPToGive .. " XP and " .. GoldToGive .. " Gold!"
	)
end

function DailyReward.ResetDailyStreak(Player: Player)
	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	if os.clock() - PlayerData.LastDailyReward() < 172800 then
		PlayerData.DailyStreak(0)
		RemoteManager.SendClientEvent(
			"Notification",
			{ Player = Player },
			"You lost your daily streak, you have been away for: "
				.. Functions.FormatTime(os.clock() - PlayerData.LastDailyReward())
		)
	end
end

return DailyReward
