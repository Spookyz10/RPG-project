local ServerStorage = game:GetService("ServerStorage")
local DailyReward = require(ServerStorage.Modules.DailyReward)

local Remote = {}
local lastRequest = setmetatable({}, { __mode = "k" })

function Remote:Activate(player: Player)
	local now = os.clock()
	if lastRequest[player] and now - lastRequest[player] < 1.5 then return end
	lastRequest[player] = now
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local touchies = workspace:FindFirstChild("Touchies")
	local daily = touchies and touchies:FindFirstChild("Daily")
	if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then return end
	if not daily or not daily:IsA("BasePart") then return end
	-- TouchManager enters at 10 studs; small allowance for replication latency.
	if not ((root.Position - daily.Position).Magnitude <= 14) then return end
	DailyReward.ClaimDaily(player)
end

return Remote
