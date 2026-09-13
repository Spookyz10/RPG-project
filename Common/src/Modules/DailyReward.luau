local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local RewardManager = require(script.Parent.RewardManager)
local Data = require(ReplicatedStorage.Shared.Data).server
local DailyReward = {}
local DAILY_COOLDOWN = 24 * 60 * 60
local STREAK_GRACE_PERIOD = 48 * 60 * 60
local FIRST_UNIX_TIMESTAMP = 1_000_000_000

local function getClaimElapsed(lastClaimed: number, now: number): number?
	if lastClaimed < FIRST_UNIX_TIMESTAMP then
		return nil
	end
	return math.max(0, now - lastClaimed)
end

function DailyReward.ClaimDaily(Player: Player)
	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData

	if not PlayerData then
		RemoteManager.SendClientEvent("Notification", { Player = Player }, "Invalid data? how.")
		return
	end

	local timeNow = os.time()
	local LastClaimed = PlayerData.LastDailyReward()
	local elapsed = getClaimElapsed(LastClaimed, timeNow)

	if elapsed and elapsed < DAILY_COOLDOWN then
		RemoteManager.SendClientEvent(
			"Notification",
			{ Player = Player },
			"You may claim again in " .. Functions.FormatTime(DAILY_COOLDOWN - elapsed)
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

	local elapsed = getClaimElapsed(PlayerData.LastDailyReward(), os.time())
	if elapsed and elapsed >= STREAK_GRACE_PERIOD then
		PlayerData.DailyStreak(0)
		RemoteManager.SendClientEvent(
			"Notification",
			{ Player = Player },
			"You lost your daily streak, you have been away for: "
				.. Functions.FormatTime(elapsed)
		)
	end
end

return DailyReward
