local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local BuffsUI = {}
local StatusDefinitions = require(ReplicatedStorage.Shared.StatusEffects)

local BuffIcons = {
	Poison = "rbxassetid://6145145342",
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
local DebuffContainer: Instance = nil
local Template: GuiObject = nil
local ActiveEntries: { [string]: GuiObject } = {}

function BuffsUI.Init()
	local AttackGui = UIConstants.PlayerGui:WaitForChild("Attack")
	Container = AttackGui:WaitForChild("Buffs")
	DebuffContainer = AttackGui:FindFirstChild("Debuffs")
	-- Older saved screens can still bind until the Combat generator is rerun.
	if not DebuffContainer then
		local frame = Container:Clone() :: GuiObject
		frame.Name = "Debuffs"
		for _, child in frame:GetChildren() do
			if child:IsA("GuiObject") then child:Destroy() end
		end
		frame.Position = frame.Position - UDim2.fromOffset(0, 44)
		frame.Parent = AttackGui
		DebuffContainer = frame
	end
	Template = require(ReplicatedStorage.Shared.UI.Bootstrap).GetTemplates():WaitForChild("BuffTemplate") :: GuiObject
	Template.Visible = false
	game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
		for effectId in ActiveEntries do BuffsUI:Stop(effectId) end
	end)
end

function BuffsUI:Start(effectId: string, duration: number?, stacks: number?)
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
	local definition = StatusDefinitions[effectId] or {}
	Icon.Image = definition.Icon or BuffIcons[effectId] or ""

	Entry.Parent = definition.Category == "Debuff" and DebuffContainer or Container
	ActiveEntries[effectId] = Entry

	local CDLabel = Entry:FindFirstChild("CD") :: TextLabel?
	if duration == nil then
		if CDLabel then CDLabel.Text = tostring(stacks or 1) .. "/" .. tostring(definition.MaxStacks or 1) end
		return
	end

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
