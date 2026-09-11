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
local descriptions = {
 Poison = "Poison damage is applied every second.",
 Safeguard = "Incoming damage is reduced by 70%.",
 ["Lure Jab"] = "Defense is reduced by 50%.",
 Venom = "Venom mark: interacts with poison and venom equipment effects.",
 Fury = "Your next confirmed hit is a guaranteed critical with bonus critical damage. One charge every 15s, up to 2.",
}
local tooltip
local hovered
local function hideTip(entry)
 if hovered == entry and tooltip then tooltip.Visible = false; hovered = nil end
end
local ActiveEntries: { [string]: GuiObject } = {}

function BuffsUI.Init()
	local AttackGui = UIConstants.PlayerGui:WaitForChild("Attack")
	tooltip = AttackGui:FindFirstChild("StatusTooltip")
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
	local function show()
		if not tooltip then return end
		hovered = Entry
		tooltip.Title.Text = effectId .. " - " .. (definition.Category or "Buff")
		tooltip.Description.Text = definition.Description or descriptions[effectId] or "This effect is currently active on your character."
		tooltip.Visible = true
	end
	Entry.MouseEnter:Connect(show)
	Entry.MouseLeave:Connect(function() hideTip(Entry) end)
	Entry.SelectionGained:Connect(show)
	Entry.SelectionLost:Connect(function() hideTip(Entry) end)
	if Entry:IsA("GuiButton") then Entry.Activated:Connect(function() if hovered == Entry then hideTip(Entry) else show() end end) end
	Entry.Destroying:Connect(function() hideTip(Entry) end)

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
