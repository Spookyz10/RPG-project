local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local UI = {}

local Cooldowns: { [string]: { Tweens: { Tween }, Connection: RBXScriptConnection? } } = {}

local function formatTime(time: number): string
	if time <= 0 then
		return "0"
	end
	if time % 1 == 0 then
		return tostring(math.floor(time))
	end
	return string.format("%.2f", time)
end

local function getSlots(chosenSlot: string): { ImageButton }
	local HUD = UIConstants.PlayerGui:FindFirstChild("HUD")
	local slots = {}

	local PCSlots = HUD and HUD:FindFirstChild("PCSlots")
	local MobileSlots = HUD and HUD:FindFirstChild("MobileSlots")

	if PCSlots then
		local slot = PCSlots:FindFirstChild(chosenSlot)
		if slot then
			table.insert(slots, slot)
		end
	end

	if MobileSlots then
		local slot = MobileSlots:FindFirstChild(chosenSlot)
		if slot then
			table.insert(slots, slot)
		end
	end

	return slots
end

function UI.Init() end

function UI.StartCooldown(chosenSlot: string, time: number)
	local Slots = getSlots(chosenSlot)
	if #Slots == 0 then
		return
	end

	local Existing = Cooldowns[chosenSlot]
	if Existing then
		if Existing.Connection then
			Existing.Connection:Disconnect()
		end
		for _, tween in Existing.Tweens do
			tween:Cancel()
		end
		Cooldowns[chosenSlot] = nil
	end

	local Data: { Tweens: { Tween }, Connection: RBXScriptConnection? } = { Tweens = {}, Connection = nil }
	Cooldowns[chosenSlot] = Data

	local EndTime = os.clock() + time

	Data.Connection = RunService.RenderStepped:Connect(function()
		local TimeLeft = EndTime - os.clock()

		if TimeLeft <= 0 then
			if Data.Connection then
				Data.Connection:Disconnect()
				Data.Connection = nil
			end
			for _, slot in Slots do
				local label = slot:FindFirstChild("Cooldown")
				if label then
					label.Text = ""
				end
			end
			return
		end

		local text = formatTime(TimeLeft)
		for _, slot in Slots do
			local label = slot:FindFirstChild("Cooldown")
			if label then
				label.Text = text
			end
		end
	end)

	local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear, Enum.EasingDirection.In)

	for _, slot in Slots do
		local fade = slot:FindFirstChild("Fade")
		if fade then
			local tween = TweenService:Create(fade, tweenInfo, { Size = UDim2.fromScale(1, 0) })
			table.insert(Data.Tweens, tween)
			tween:Play()
		end
	end

	if Data.Tweens[1] then
		Data.Tweens[1].Completed:Wait()
	else
		task.wait(time)
	end

	if Cooldowns[chosenSlot] == Data then
		if Data.Connection then
			Data.Connection:Disconnect()
		end
		Cooldowns[chosenSlot] = nil
	end
end

function UI.EndCooldown(chosenSlot: string)
	local Existing = Cooldowns[chosenSlot]
	if Existing then
		if Existing.Connection then
			Existing.Connection:Disconnect()
		end
		for _, tween in Existing.Tweens do
			tween:Cancel()
		end
		Cooldowns[chosenSlot] = nil
	end

	local Slots = getSlots(chosenSlot)
	for _, slot in Slots do
		local label = slot:FindFirstChild("Cooldown")
		if label then
			label.Text = ""
		end
		local fade = slot:FindFirstChild("Fade")
		if fade then
			fade.Size = UDim2.fromScale(1, 0)
		end
	end
end

return UI
