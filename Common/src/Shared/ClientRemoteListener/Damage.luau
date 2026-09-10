local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

local Abbreviation = require(ReplicatedStorage.Shared.Utils.Abbreviation)
local SoundManager = require(ReplicatedStorage.Shared.SoundManager)
local DamageStyles = require(ReplicatedStorage.Shared.DamageStyles)

local Remote = {}

local LocalPlayer = Players.LocalPlayer

local MAX_VISIBLE_DISTANCE = 100

local POP_TWEEN = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
local SETTLE_TWEEN = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local FLOAT_TWEEN = TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local FADE_TWEEN = TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local POP_WAIT = 0.5
local FLOAT_HEIGHT = 6
local FADE_WAIT = 0.5
local CLEANUP_TIME = 0.75

local DamageTemplate = require(ReplicatedStorage.Shared.UI.Bootstrap).GetTemplates().Damage :: BillboardGui

local function PlayHitSound(params: {})
	if not params.CasterUserId then
		return
	end

	local CasterPlayer = Players:GetPlayerByUserId(params.CasterUserId)
	if not CasterPlayer then
		return
	end

	local Character = CasterPlayer.Character
	if not Character then
		return
	end

	SoundManager:PlayHitSound(Character.PrimaryPart)
end

function Remote:Activate(entityHurt: Model, amount: number, params: {})
	local mobs = Workspace:FindFirstChild("Mobs")
	if not entityHurt or not mobs or not entityHurt:IsDescendantOf(mobs) or Players:GetPlayerFromCharacter(entityHurt) then
		return
	end
	local style, damageType = DamageStyles.Resolve(params.Type)

	local RootPart = entityHurt:FindFirstChild("Head") or entityHurt.PrimaryPart
	if not RootPart then
		return
	end

	local Camera = Workspace.CurrentCamera
	if Camera and (Camera.Focus.Position - RootPart.Position).Magnitude > MAX_VISIBLE_DISTANCE then
		return
	end

	if damageType == "Normal" or damageType == "Critical" then
		PlayHitSound(params)
	end

	local Billboard = DamageTemplate:Clone()

	local TargetFrame = Billboard:FindFirstChild(style.Template) :: GuiObject?
	if not TargetFrame then
		Billboard:Destroy()
		return
	end

	for _, frame in Billboard:GetChildren() do
		if frame:IsA("GuiObject") then
			frame.Visible = frame == TargetFrame
		end
	end

	local Label = TargetFrame:FindFirstChildWhichIsA("TextLabel", true) :: TextLabel?
	if not Label then
		Billboard:Destroy()
		return
	end

	Label.TextColor3 = style.Color
	if amount <= 0 and damageType ~= "Heal" then
		Label.Text = "Too weak"
	else
		Label.Text = (damageType == "Heal" and "+" or "") .. Abbreviation:Number(amount)
	end

	local Stroke = Label:FindFirstChildOfClass("UIStroke")
	if Stroke then Stroke.Color = style.Stroke end

	local Part = Instance.new("Part")
	Part.Size = Vector3.new(1, 1, 1)
	Part.Anchored = true
	Part.CanCollide = false
	Part.CanTouch = false
	Part.CanQuery = false
	Part.Transparency = 1
	Part.CastShadow = false

	local OffsetX = math.random(-10, 10) / 10
	local OffsetY = math.random(-10, 10) / 10
	local OffsetZ = math.random(-10, 10) / 10
	Part.Position = RootPart.Position + Vector3.new(OffsetX, OffsetY + 2, OffsetZ)
	Part.Parent = Workspace.Debris

	local WasCausedByMe = not params.CasterUserId or params.CasterUserId == LocalPlayer.UserId
	local BaseTextTransparency = WasCausedByMe and 0 or 0.8
	local BaseStrokeTransparency = WasCausedByMe and 0 or 0.65

	Billboard.Adornee = Part
	Billboard.Parent = Part

	local OriginalLabelSize = Label.Size
	local PopSize = UDim2.new(
		OriginalLabelSize.X.Scale * 1.2,
		OriginalLabelSize.X.Offset,
		OriginalLabelSize.Y.Scale * 1.2,
		OriginalLabelSize.Y.Offset
	)

	Label.Size = UDim2.fromScale(0, 0)
	Label.TextTransparency = BaseTextTransparency

	local OriginalThickness = Stroke and Stroke.Thickness or 0
	if Stroke then
		Stroke.Transparency = BaseStrokeTransparency
		Stroke.Thickness = damageType == "Critical" and OriginalThickness * 1.8 or OriginalThickness
	end

	TweenService:Create(Label, POP_TWEEN, { Size = PopSize }):Play()

	task.delay(POP_WAIT, function()
		if not Label or not Label.Parent then
			return
		end

		TweenService:Create(Label, SETTLE_TWEEN, { Size = OriginalLabelSize }):Play()
	end)

	TweenService:Create(Part, FLOAT_TWEEN, {
		Position = Part.Position + Vector3.new(math.random(-5, 5) / 10, FLOAT_HEIGHT / 10, 0),
	}):Play()

	task.delay(POP_WAIT, function()
		if not Label or not Label.Parent then
			return
		end

		TweenService:Create(Label, FADE_TWEEN, { TextTransparency = 1 }):Play()

		if Stroke then
			TweenService:Create(Stroke, FADE_TWEEN, { Transparency = 1 }):Play()
		end
	end)

	Debris:AddItem(Part, POP_WAIT + FADE_WAIT + CLEANUP_TIME)
end

return Remote
