local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local UI = {}

local SlotButtons = { Q = "Slot1", E = "Slot2", R = "Slot3" }

local ActiveSessions: { [string]: number } = {}

local ICON_POP_SIZE = UDim2.fromScale(1.4, 1.4)
local ICON_BASE_SIZE = UDim2.fromScale(1, 1)
local ICON_POP_DURATION = 0.4

local function getButton(slot: string): Instance?
	local buttonName = SlotButtons[slot]
	if not buttonName then
		return nil
	end

	local AttackGui = UIConstants.PlayerGui:FindFirstChild("Attack")
	if not AttackGui then
		return nil
	end

	local Slots = AttackGui:FindFirstChild("Slots")
	if not Slots then
		return nil
	end

	return Slots:FindFirstChild(buttonName)
end

local function PlayIconPop(Icon: ImageLabel, slot: string, session: number)
	Icon.Size = ICON_POP_SIZE

	task.delay(ICON_POP_DURATION, function()
		if ActiveSessions[slot] ~= session then
			return
		end

		Icon.Size = ICON_BASE_SIZE
	end)
end

local function PlayCountdown(CooldownLabel: TextLabel, duration: number, slot: string, session: number)
	CooldownLabel.Visible = duration > 0
	local StartTime = os.clock()

	task.spawn(function()
		while ActiveSessions[slot] == session do
			local TimeLeft = duration - (os.clock() - StartTime)

			if TimeLeft <= 0 then
				CooldownLabel.Text = ""
				CooldownLabel.Visible = false
				break
			end

			CooldownLabel.Text = string.format("%.1f", TimeLeft)
			task.wait(0.1)
		end
	end)
end

function UI.StartCooldown(slot: string, duration: number)
	local Button = getButton(slot)
	if not Button then
		return
	end

	ActiveSessions[slot] = (ActiveSessions[slot] or 0) + 1
	local Session = ActiveSessions[slot]

	local Icon = Button:FindFirstChild("Icon") :: ImageLabel?
	if Icon then
		PlayIconPop(Icon, slot, Session)
	end

	local CooldownLabel = Button:FindFirstChild("Cooldown") :: TextLabel?
	if CooldownLabel then
		PlayCountdown(CooldownLabel, duration, slot, Session)
	end
end

return UI
