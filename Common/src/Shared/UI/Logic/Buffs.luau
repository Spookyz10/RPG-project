local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bootstrap = require(ReplicatedStorage.Shared.UI.Bootstrap)
local StatusDefinitions = require(ReplicatedStorage.Shared.StatusEffects)
local TooltipFollower = require(ReplicatedStorage.Shared.UI.TooltipFollower)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local BuffsUI = {}
local activeEntries: { [string]: GuiObject } = {}
local container: Instance
local debuffContainer: Instance
local template: GuiObject
local tooltip: GuiObject
local follower

local function bindTooltip(entry: GuiObject, effectId: string, definition)
	local function show()
		tooltip.Title.Text = effectId .. " - " .. (definition.Category or "Buff")
		tooltip.Description.Text = definition.Description or "This effect is currently active on your character."
		follower:Show(entry)
	end
	entry.MouseEnter:Connect(function()
		if not follower:IsTouch() then show() end
	end)
	entry.MouseLeave:Connect(function() follower:Hide(entry) end)
	entry.SelectionGained:Connect(show)
	entry.SelectionLost:Connect(function() follower:Hide(entry) end)
	if entry:IsA("GuiButton") then
		entry.Activated:Connect(function()
			if follower:IsShowing(entry) then follower:Hide(entry) else show() end
		end)
	end
	entry.Destroying:Connect(function() follower:Hide(entry) end)
end

local function startTimer(entry: GuiObject, effectId: string, duration: number, cooldown: TextLabel?)
	task.spawn(function()
		local expiresAt = os.clock() + duration
		while entry.Parent do
			local remaining = expiresAt - os.clock()
			if remaining <= 0 then break end
			if cooldown then cooldown.Text = tostring(math.ceil(remaining)) end
			task.wait(math.min(1, remaining))
		end
		if entry.Parent then entry:Destroy() end
		if activeEntries[effectId] == entry then activeEntries[effectId] = nil end
	end)
end

function BuffsUI.Init()
	local attack = UIConstants.PlayerGui:WaitForChild("Attack")
	tooltip = attack:WaitForChild("StatusTooltip")
	container = attack:WaitForChild("Buffs")
	debuffContainer = attack:WaitForChild("Debuffs")
	template = Bootstrap.GetTemplates():WaitForChild("BuffTemplate")
	follower = TooltipFollower.new(attack, tooltip)
	follower:Hide()
	Players.LocalPlayer.CharacterRemoving:Connect(function()
		for effectId in activeEntries do BuffsUI:Stop(effectId) end
	end)
	attack.Destroying:Connect(function() follower:Destroy() end)
end

function BuffsUI:Start(effectId: string, duration: number?, stacks: number?)
	local existing = activeEntries[effectId]
	if existing then existing:Destroy() end
	local definition = StatusDefinitions[effectId] or {}
	local entry = template:Clone()
	entry.Name = effectId
	local imageEntry = entry :: any
	imageEntry.Image = definition.Icon or ""
	entry.Visible = true
	entry.Parent = definition.Category == "Debuff" and debuffContainer or container
	activeEntries[effectId] = entry
	bindTooltip(entry, effectId, definition)
	local cooldown = entry:FindFirstChild("CD") :: TextLabel?
	if duration then
		startTimer(entry, effectId, duration, cooldown)
	elseif cooldown then
		cooldown.Text = tostring(stacks or 1) .. "/" .. tostring(definition.MaxStacks or 1)
	end
end

function BuffsUI:Stop(effectId: string)
	local entry = activeEntries[effectId]
	if entry then entry:Destroy() end
	activeEntries[effectId] = nil
end

return BuffsUI
