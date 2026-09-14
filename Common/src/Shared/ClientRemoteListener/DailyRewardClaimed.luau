local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local Abbreviation = require(RS.Shared.Utils.Abbreviation)
local Toast = require(RS.Shared.UI.Toast)
local Remote = {}
local activeClose

function Remote:Activate(reward)
	if typeof(reward) ~= "table" then return end
	for _, key in {"Gold", "XP", "Streak"} do
		local value = reward[key]
		if typeof(value) ~= "number" or value ~= value or value < 0 or value == math.huge then return end
	end
	local gui = Players.LocalPlayer.PlayerGui:FindFirstChild("DailyRewards")
	local template = gui and gui:FindFirstChild("Card")
	if not template then
		Toast.Show("Daily reward claimed! +" .. Abbreviation:Number(reward.Gold) .. " Gold / +" .. Abbreviation:Number(reward.XP) .. " XP")
		warn("Generate tools/ui-generators/36_DailyRewards.luau in Edit mode.")
		return
	end
	if activeClose then activeClose() end
	local card = template:Clone()
	card.Name = "ClaimedReward"
	card.Gold.Amount.Text = "+" .. Abbreviation:Number(reward.Gold)
	card.XP.Amount.Text = "+" .. Abbreviation:Number(reward.XP)
	card.Streak.Text = tostring(reward.Streak) .. (reward.Streak == 1 and " DAY STREAK" or " DAYS STREAK")
	card.GroupTransparency = 1
	local targetScale = card.Pop.Scale
	card.Pop.Scale = targetScale * 0.85
	card.Visible = true
	card.Parent = gui
	local fade = TweenService:Create(card, TweenInfo.new(0.2), {GroupTransparency = 0})
	local pop = TweenService:Create(card.Pop, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = targetScale})
	local closed = false
	local timer
	local connection
	local close
	close = function(destroying)
		if closed then return end
		closed = true
		if timer then task.cancel(timer); timer = nil end
		if connection then connection:Disconnect() end
		fade:Cancel(); pop:Cancel()
		if not destroying then card:Destroy() end
		if activeClose == close then activeClose = nil end
	end
	activeClose = close
	connection = card.Close.Activated:Connect(function() close() end)
	card.Destroying:Once(function() close(true) end)
	timer = task.delay(8, function() timer = nil; close() end)
	fade:Play(); pop:Play()
end

return Remote
