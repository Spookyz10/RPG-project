local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Types = require(ReplicatedStorage.Shared.Utils.Types)
local UIFunctions = {}

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("Main") :: ScreenGui
local HoverGui = PlayerGui:WaitForChild("Hover") :: ScreenGui
local FloatingItem = HoverGui:WaitForChild("FloatingDisplay") :: Frame
local Mouse = Players.LocalPlayer:GetMouse()

local OpenUI: Frame = nil

local CurrentSession = 0
local ActiveConnections = {}
local MouseOffset = Vector2.new(20, 0)
local Container = FloatingItem.Parent :: GuiObject

local function GetHoverPosition(): UDim2
	local RelativeX = (Mouse.X - Container.AbsolutePosition.X) / Container.AbsoluteSize.X
	local RelativeY = (Mouse.Y - Container.AbsolutePosition.Y) / Container.AbsoluteSize.Y

	return UDim2.new(RelativeX, MouseOffset.X, RelativeY, MouseOffset.Y)
end

local function HideAll()
	for _, child in FloatingItem:GetChildren() do
		if child:IsA("GuiObject") then
			child.Visible = false
		end
	end
end

function UIFunctions:StopHover()
	CurrentSession += 1

	for _, Connection in ipairs(ActiveConnections) do
		Connection:Disconnect()
	end
	table.clear(ActiveConnections)

	if FloatingItem then
		FloatingItem.Visible = false
	end
end

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
			if Stats[label.Name] and Stats[label.Name] > 0 then
				label.Text = label.Name .. ": " .. Stats[label.Name]
				label.Visible = true
			else
				label.Visible = false
			end
		end
	end
end

function UIFunctions:Hover(Button: GuiObject, Populate: ((FloatingItem: Frame) -> ())?)
	if not FloatingItem then
		return
	end

	self:StopHover()
	CurrentSession += 1
	local Session = CurrentSession

	HideAll()

	FloatingItem.Visible = true
	FloatingItem.Position = GetHoverPosition()

	if Populate then
		Populate(FloatingItem)
	end

	local RenderConnection = RunService.RenderStepped:Connect(function()
		if Session ~= CurrentSession then
			return
		end
		FloatingItem.Position = GetHoverPosition()
	end)

	local LeaveConnection
	LeaveConnection = Button.MouseLeave:Connect(function()
		if Session ~= CurrentSession then
			return
		end
		self:StopHover()
	end)

	local DestroyingConnection
	DestroyingConnection = Button.Destroying:Connect(function()
		if Session ~= CurrentSession then
			return
		end
		self:StopHover()
	end)

	table.insert(ActiveConnections, RenderConnection)
	table.insert(ActiveConnections, LeaveConnection)
	table.insert(ActiveConnections, DestroyingConnection)
end

return UIFunctions
