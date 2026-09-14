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

local function formatRemaining(seconds: number): string
	seconds = math.max(0, math.ceil(seconds))
	local days = math.floor(seconds / 86400)
	seconds %= 86400
	local hours = math.floor(seconds / 3600)
	seconds %= 3600
	local minutes = math.floor(seconds / 60)
	seconds %= 60
	if days > 0 then return string.format("%dd %02dh %02dm %02ds", days, hours, minutes, seconds) end
	if hours > 0 then return string.format("%dh %02dm %02ds", hours, minutes, seconds) end
	return string.format("%dm %02ds", minutes, seconds)
end

local function getClaimElapsed(lastClaimed: number, now: number): number?
	if lastClaimed < FIRST_UNIX_TIMESTAMP then
		return nil
	end
	return math.max(0, now - lastClaimed)
end

local claiming = setmetatable({}, { __mode = "k" })

local function claim(Player: Player)
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
			"Daily reward available in " .. formatRemaining(DAILY_COOLDOWN - elapsed)
		)
		return
	end

	PlayerData.LastDailyReward(timeNow)
	PlayerData.TotalDailyRewards(function(current)
		return current + 1
	end)
	PlayerData.DailyStreak(function(current)
		return elapsed and elapsed >= STREAK_GRACE_PERIOD and 1 or current + 1
	end)

	local XPToGive = Functions:GetXPNeeded(PlayerData.Level()) * (0.1 + PlayerData.DailyStreak() * 0.05)
	local GoldToGive = (PlayerData.Level() * 100) * (0.1 + PlayerData.DailyStreak() * 0.05)
	local grantedXP = RewardManager:AddXP(Player, XPToGive)
	local grantedGold = RewardManager:AddCurrency(Player, "Gold", GoldToGive)
	if grantedXP == nil or grantedGold == nil then
		RemoteManager.SendClientEvent("Notification", { Player = Player }, "Daily reward could not be completed. Please rejoin and check your rewards.")
		return
	end

	RemoteManager.SendClientEvent(
		"DailyRewardClaimed",
		{ Player = Player },
		{ XP = grantedXP, Gold = grantedGold, Streak = PlayerData.DailyStreak() }
	)
end

function DailyReward.ClaimDaily(Player: Player)
	if claiming[Player] then return end
	claiming[Player] = true
	local ok, reason = pcall(claim, Player)
	claiming[Player] = nil
	if not ok then warn("Daily reward failed: " .. tostring(reason)) end
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
