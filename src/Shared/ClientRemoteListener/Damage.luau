local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Abbreviation = require(ReplicatedStorage.Shared.Utils.Abbreviation)

local Remote = {}

local POP_TIME = 0.15
local FLOAT_TIME = 0.8

function Remote:Activate(entityHurt: Model, amount: number, params: {})
	local PrimaryPart = entityHurt.PrimaryPart
	if not PrimaryPart then
		return
	end

	local DamageTemplate = ReplicatedStorage.Assets.UI.Templates.DamageUI:Clone() :: BillboardGui
	local DamageLabel = DamageTemplate.Damage :: TextLabel
	local Stroke = DamageLabel:FindFirstChildOfClass("UIStroke")

	if amount <= 0 then
		DamageLabel.Text = "Too weak"
	else
		DamageLabel.Text = (params.Heal and "+" or "") .. Abbreviation:Number(amount)
	end

	DamageTemplate.Parent = PrimaryPart

	for _, child in DamageLabel:GetChildren() do
		if child:IsA("UIGradient") then
			child.Enabled = false
		end
	end

	if params.Crit then
		DamageLabel:FindFirstChild("Critical").Enabled = true
	elseif params.Heal then
		DamageLabel:FindFirstChild("Heal").Enabled = true
	else
		DamageLabel:FindFirstChild("Damage").Enabled = true
	end

	DamageLabel.TextTransparency = 1
	local OriginalSize = DamageLabel.Size
	DamageLabel.Size = UDim2.fromScale(0, 0)

	local OriginalThickness = Stroke and Stroke.Thickness or 0
	if Stroke then
		Stroke.Transparency = 1
		Stroke.Thickness = params.Crit and OriginalThickness * 1.8 or OriginalThickness
	end

	local StartOffset = DamageTemplate.StudsOffset

	TweenService:Create(DamageLabel, TweenInfo.new(POP_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = OriginalSize,
		TextTransparency = 0,
	}):Play()

	if Stroke then
		TweenService:Create(Stroke, TweenInfo.new(POP_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Transparency = 0,
			Thickness = OriginalThickness,
		}):Play()
	end

	TweenService:Create(DamageTemplate, TweenInfo.new(FLOAT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		StudsOffset = StartOffset + Vector3.new(0, 3, 0),
	}):Play()

	task.delay(FLOAT_TIME * 0.5, function()
		if not DamageLabel or not DamageLabel.Parent then
			return
		end

		TweenService
			:Create(DamageLabel, TweenInfo.new(FLOAT_TIME * 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				TextTransparency = 1,
			})
			:Play()

		if Stroke then
			TweenService
				:Create(Stroke, TweenInfo.new(FLOAT_TIME * 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Transparency = 1,
				})
				:Play()
		end
	end)

	Debris:AddItem(DamageTemplate, FLOAT_TIME + 0.3)
end

return Remote
