local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local TooltipFollower = {}
TooltipFollower.__index = TooltipFollower

function TooltipFollower.new(screen: ScreenGui, tooltip: GuiObject)
	local self = setmetatable({}, TooltipFollower)
	self.Screen = screen
	self.Tooltip = tooltip
	self.Target = nil
	self.FollowConnection = nil
	self.LastInputWasTouch = UserInputService:GetLastInputType() == Enum.UserInputType.Touch
	self.InputConnection = UserInputService.LastInputTypeChanged:Connect(function(inputType)
		self.LastInputWasTouch = inputType == Enum.UserInputType.Touch
	end)
	return self
end

function TooltipFollower:_place()
	local target = self.Target
	local tooltip = self.Tooltip
	local screen = self.Screen
	if not target or not target.Parent or not target.Visible or not tooltip.Parent or not screen.Enabled then
		self:Hide()
		return
	end
	local ancestor = target.Parent
	while ancestor and ancestor ~= screen do
		if ancestor:IsA("GuiObject") and not ancestor.Visible then
			self:Hide()
			return
		end
		ancestor = ancestor.Parent
	end
	local inset = screen.IgnoreGuiInset and Vector2.zero or GuiService:GetGuiInset()
	local raw = UserInputService:GetMouseLocation()
	local mouse = Vector2.new(raw.X - inset.X, raw.Y - inset.Y)
	local parent = tooltip.Parent :: any
	local origin = parent.AbsolutePosition
	local bounds = parent.AbsoluteSize
	local size = tooltip.AbsoluteSize
	local x = mouse.X + 14
	local y = mouse.Y + 14
	if x + size.X > origin.X + bounds.X - 8 then x = mouse.X - size.X - 14 end
	if y + size.Y > origin.Y + bounds.Y - 8 then y = mouse.Y - size.Y - 14 end
	x = math.clamp(x, origin.X + 8, math.max(origin.X + 8, origin.X + bounds.X - size.X - 8))
	y = math.clamp(y, origin.Y + 8, math.max(origin.Y + 8, origin.Y + bounds.Y - size.Y - 8))
	local parentSize = parent.AbsoluteSize
	tooltip.Position = UDim2.fromScale(
		tooltip.Position.X.Scale + (tooltip.Position.X.Offset + x - tooltip.AbsolutePosition.X) / math.max(1, parentSize.X),
		tooltip.Position.Y.Scale + (tooltip.Position.Y.Offset + y - tooltip.AbsolutePosition.Y) / math.max(1, parentSize.Y)
	)
end

function TooltipFollower:Show(target: GuiObject)
	self.Target = target
	self.Tooltip.Visible = true
	if not self.FollowConnection then
		self.FollowConnection = RunService.RenderStepped:Connect(function() self:_place() end)
	end
	self:_place()
end

function TooltipFollower:Hide(target: GuiObject?)
	if target and self.Target ~= target then return end
	self.Target = nil
	self.Tooltip.Visible = false
	if self.FollowConnection then
		self.FollowConnection:Disconnect()
		self.FollowConnection = nil
	end
end

function TooltipFollower:IsShowing(target: GuiObject): boolean
	return self.Target == target and self.Tooltip.Visible
end

function TooltipFollower:IsTouch(): boolean
	return self.LastInputWasTouch
end

function TooltipFollower:Destroy()
	self:Hide()
	self.InputConnection:Disconnect()
end

return TooltipFollower
