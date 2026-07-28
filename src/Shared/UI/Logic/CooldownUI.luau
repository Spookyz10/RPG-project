local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local UI = {}

local Cooldowns = {} :: { [string]: { Tween: Tween, Connection: RBXScriptConnection } }

function UI.Init() end

function UI.StartCooldown(chosenSlot: string, time: number)
	local Slots = UIConstants.PlayerGui:FindFirstChild("HUD").SkillSlots :: Frame
	local Slot = Slots:FindFirstChild(chosenSlot) :: ImageButton

	local Instance = Cooldowns[Slot.Name]

	if Instance then
		if Instance["Connection"] then
			Instance["Connection"]:Disconnect()
		end

		if Instance["Tween"] then
			Instance["Tween"]:Cancel()
		end

		Cooldowns[Slot.Name] = nil
	end

	local EndTime = os.clock() + time
	local conn

	conn = RunService.RenderStepped:Connect(function()
		Cooldowns[Slot.Name]["Connection"] = conn
		local TimeLeft = EndTime - os.clock()
		Slot:FindFirstChild("Cooldown").Text = TimeLeft
		if TimeLeft <= 0 and Cooldowns[Slot.Name] and Cooldowns[Slot.Name]["Connection"] then
			Cooldowns[Slot.Name]["Connection"]:Disconnect()
		end
	end)

	local TweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	local Tween = TweenService:Create(Slot.Fade, TweenInfo, { Size = UDim2.fromScale(1, 0) }):Play() :: Tween
	Cooldowns[Slot.Name]["Tween"] = Tween
	Tween.Completed:Wait()
	if Cooldowns[Slot.Name] and Cooldowns[Slot.Name]["Tween"] then
		Cooldowns[Slot.Name]["Tween"] = nil
	end

	if Cooldowns[Slot.Name] then
		if Cooldowns[Slot.Name]["Connection"] then
			Cooldowns[Slot.Name]["Connection"]:Disconnect()
			Cooldowns[Slot.Name]["Connection"] = nil
		end

		if Cooldowns[Slot.Name]["Tween"] then
			Cooldowns[Slot.Name]["Tween"] = nil
		end

		Cooldowns[Slot.Name] = nil
	end
end

function UI.EndCooldown(chosenSlot: string)
	local Slots = UIConstants.PlayerGui:FindFirstChild("HUD").SkillSlots :: Frame
	local Slot = Slots:FindFirstChild(chosenSlot) :: ImageButton

	if Cooldowns[Slot.Name] then
		if Cooldowns[Slot.Name]["Connection"] then
			Cooldowns[Slot.Name]["Connection"]:Disconnect()
			Cooldowns[Slot.Name]["Connection"] = nil
		end

		if Cooldowns[Slot.Name]["Tween"] then
			Cooldowns[Slot.Name]["Tween"] = nil
		end

		Cooldowns[Slot.Name] = nil
	end
end

return UI
