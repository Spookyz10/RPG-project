local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Bootstrap = require(script.Parent.Bootstrap)
local UIConstants = require(script.Parent.UIConstants)

local Feedback = {}
local activeBanners: { CanvasGroup } = {}
local passiveTimes: { [string]: number } = {}
local MAX_BANNERS = 4
local PASSIVE_INTERVAL = 0.4

local function displayName(id: string): string
	return string.upper((id:gsub("(%l)(%u)", "%1 %2")))
end

local function templates(): Folder?
	return Bootstrap.GetTemplates():FindFirstChild("FeedbackTemplates") :: Folder?
end

local function animateSkill(effect: CanvasGroup)
	local pulse = effect:WaitForChild("Pulse") :: Frame
	local border = pulse:FindFirstChildOfClass("UIStroke")
	local pulseGoal = {
		Size = pulse:GetAttribute("EndSize") or pulse.Size,
		Position = pulse:GetAttribute("EndPosition") or pulse.Position,
		BackgroundTransparency = 1,
	}
	TweenService:Create(pulse, TweenInfo.new(0.48, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), pulseGoal):Play()
	if border then
		TweenService:Create(border, TweenInfo.new(0.48), { Transparency = 1 }):Play()
	end
	local echo = effect:WaitForChild("Echo") :: ImageLabel
	TweenService:Create(echo, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = echo:GetAttribute("EndPosition") or echo.Position,
		Size = echo:GetAttribute("EndSize") or echo.Size,
		ImageTransparency = 1,
	}):Play()
	for _, particle in effect:GetChildren() do
		if particle.Name:match("^Particle%d+$") then
			TweenService:Create(particle, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Position = particle:GetAttribute("EndPosition") or particle.Position,
				Size = particle:GetAttribute("EndSize") or particle.Size,
				BackgroundTransparency = 1,
				Rotation = particle.Rotation + 90,
			}):Play()
		end
	end
	local title = effect:WaitForChild("Title") :: TextLabel
	TweenService:Create(title, TweenInfo.new(0.62, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = title:GetAttribute("EndPosition") or title.Position,
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	}):Play()
end

function Feedback.Skill(button: GuiObject, skillName: string?)
	local library = templates()
	local source = library and library:FindFirstChild("Skill")
	if not source or not source:IsA("CanvasGroup") then return end
	local effect = source:Clone()
	local title = effect:WaitForChild("Title") :: TextLabel
	local echo = effect:WaitForChild("Echo") :: ImageLabel
	effect.Name = "SkillFeedback"
	title.Text = skillName and skillName ~= "" and string.upper(skillName) or "SKILL READY"
	local icon = button:FindFirstChild("Icon")
	if icon and icon:IsA("ImageLabel") then
		echo.Image = icon.Image
		echo.ImageColor3 = icon.ImageColor3
		echo.ImageRectOffset = icon.ImageRectOffset
		echo.ImageRectSize = icon.ImageRectSize
	else
		echo.Visible = false
	end
	effect.Visible = true
	effect.Parent = button
	Debris:AddItem(effect, 0.8)
	animateSkill(effect)
end

local function compactBanners()
	for index = #activeBanners, 1, -1 do
		if not activeBanners[index].Parent then table.remove(activeBanners, index) end
	end
end

local function targetPosition(card: CanvasGroup, index: number): UDim2
	local spacing = card:GetAttribute("StackSpacing") or 0.095
	local origin = card:GetAttribute("BasePosition") or card.Position
	return UDim2.new(origin.X.Scale, origin.X.Offset, origin.Y.Scale - (index - 1) * spacing, origin.Y.Offset)
end

local function banner(templateName: string, title: string, detail: string)
	local library = templates()
	local source = library and library:FindFirstChild(templateName)
	local attack = UIConstants.PlayerGui:FindFirstChild("Attack")
	if not source or not source:IsA("CanvasGroup") or not attack then return end
	compactBanners()
	if #activeBanners >= MAX_BANNERS then
		activeBanners[1]:Destroy()
		table.remove(activeBanners, 1)
	end
	local card = source:Clone()
	local titleLabel = card:WaitForChild("Title") :: TextLabel
	local detailLabel = card:WaitForChild("Detail") :: TextLabel
	local pop = card:WaitForChild("Pop") :: UIScale
	local slot = #activeBanners + 1
	local target = targetPosition(card, slot)
	card.Name = templateName .. "Feedback"
	titleLabel.Text = title
	detailLabel.Text = detail
	card.GroupTransparency = 0
	local targetScale = pop.Scale
	pop.Scale = pop:GetAttribute("StartScale") or targetScale
	card.Position = target + (card:GetAttribute("EntryOffset") or UDim2.new())
	card.Visible = true
	card.Parent = attack
	table.insert(activeBanners, card)
	Debris:AddItem(card, 1.8)
	TweenService:Create(pop, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = targetScale }):Play()
	TweenService:Create(card, TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = target }):Play()
	task.delay(1.15, function()
		if not card.Parent then return end
		local exit = card:GetAttribute("ExitOffset") or UDim2.new()
		TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Position = target + exit,
			GroupTransparency = 1,
		}):Play()
		local border = card:FindFirstChildOfClass("UIStroke")
		if border then TweenService:Create(border, TweenInfo.new(0.3), { Transparency = 1 }):Play() end
		local index = table.find(activeBanners, card)
		if index then table.remove(activeBanners, index) end
		for nextIndex, other in activeBanners do
			if other.Parent then
				TweenService:Create(other, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					Position = targetPosition(other, nextIndex),
				}):Play()
			end
		end
	end)
end

function Feedback.Status(effectId: string, category: string?)
	local negative = category == "Debuff"
	banner(negative and "Debuff" or "Buff", displayName(effectId), negative and "NEGATIVE EFFECT APPLIED" or "BUFF ACTIVE")
end

function Feedback.Passive(passiveId: string)
	local now = os.clock()
	if now - (passiveTimes[passiveId] or -math.huge) < PASSIVE_INTERVAL then
		return
	end
	passiveTimes[passiveId] = now
	banner("Passive", displayName(passiveId), passiveId == "Fury" and "CHARGE CONSUMED" or "PASSIVE TRIGGERED")
end

return Feedback
