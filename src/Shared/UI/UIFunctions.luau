local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local UIFunctions = {}

local Main = Players.LocalPlayer.PlayerGui:WaitForChild("Main") :: ScreenGui

local OpenUI: Frame = nil

function UIFunctions:ApplyRarityGradient(container: Instance, rarity: string)
	local CurrentGradient = container:FindFirstChildOfClass("UIGradient")
	if CurrentGradient then
		CurrentGradient:Destroy()
	end

	if not rarity then
		return
	end

	local RarityGradient = ReplicatedStorage.Assets.UI.Rarities:FindFirstChild(rarity) :: UIGradient?
	if not RarityGradient then
		return
	end

	RarityGradient:Clone().Parent = container
end

function UIFunctions:CloseUI()
	for _, frame in Main:GetChildren() do
		frame.Visible = false
	end

	OpenUI = nil
end

function UIFunctions:OpenUI(uiName: string)
	local Target = Main:FindFirstChild(uiName) :: Frame?

	if not Target then
		return
	end

	if OpenUI == Target then
		OpenUI.Visible = false
		OpenUI = nil
		return
	end

	if OpenUI then
		OpenUI.Visible = false
	end

	Target.Visible = true
	OpenUI = Target
end

function UIFunctions:UpdateStatsContainer(container: Frame, Stats: Types.Stats)
	for _, label: TextLabel in container:GetChildren() do
		if label:IsA("TextLabel") then
			label.Text = label.Name .. ": " .. Stats[label.Name]
		end
	end
end

return UIFunctions
