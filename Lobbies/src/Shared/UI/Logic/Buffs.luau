local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local BuffsUI = {}

local BuffIcons = {
	Campfire = "rbxassetid://6145145342",
	DiscoBuff = "rbxassetid://7005099588",
	DodgeBuff = "rbxassetid://7005099563",
	GiftCrit = "rbxassetid://8309374261",
	GiftDamage = "rbxassetid://8309375217",
	Infertao = "rbxassetid://10460731273",
	InfertaoCD = "rbxassetid://11015492558",
	SOTD = "rbxassetid://15537336323",
	DepthsBuff = "rbxassetid://133940626292161",
	DepthsNoHeal = "rbxassetid://136407182068311",
	Safeguard = "rbxassetid://4863970462",
}

local Container: Instance = nil
local Template: GuiObject = nil
local ActiveEntries: { [string]: GuiObject } = {}

function BuffsUI.Init()
	local AttackGui = UIConstants.PlayerGui:WaitForChild("Attack")
	Container = AttackGui:WaitForChild("Buffs")
	Template = ReplicatedStorage.Resources.UI.Templates:WaitForChild("BuffTemplate") :: GuiObject
	Template.Visible = false
end

function BuffsUI:Start(effectId: string, duration: number)
	if not Container or not Template then
		return
	end

	local Existing = ActiveEntries[effectId]
	if Existing then
		Existing:Destroy()
		ActiveEntries[effectId] = nil
	end

	local Entry = Template:Clone()
	Entry.Name = effectId
	Entry.Visible = true

	local Icon = Entry :: any
	Icon.Image = BuffIcons[effectId] or ""

	Entry.Parent = Container
	ActiveEntries[effectId] = Entry

	local CDLabel = Entry:FindFirstChild("CD") :: TextLabel?

	task.spawn(function()
		local TimeLeft = duration

		while TimeLeft > 0 do
			if not Entry or not Entry.Parent then
				return
			end

			if CDLabel then
				CDLabel.Text = tostring(math.ceil(TimeLeft))
			end

			task.wait(1)
			TimeLeft -= 1
		end

		if Entry and Entry.Parent then
			Entry:Destroy()
		end

		if ActiveEntries[effectId] == Entry then
			ActiveEntries[effectId] = nil
		end
	end)
end

function BuffsUI:Stop(effectId: string)
	local Entry = ActiveEntries[effectId]
	if Entry then
		Entry:Destroy()
		ActiveEntries[effectId] = nil
	end
end

return BuffsUI
