local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Bootstrap = require(script.Parent.Bootstrap)
local UIConstants = require(script.Parent.UIConstants)

local Feedback = {}
local activeBanners: { CanvasGroup } = {}
local bannersByKey: { [string]: CanvasGroup } = {}
local MAX_BANNERS = 4

Feedback.Messages = {
	Buff = "BUFF ACTIVE",
	Debuff = "NEGATIVE EFFECT APPLIED",
	Passive = "PASSIVE TRIGGERED",
	Fury = "CHARGE CONSUMED",
	FuryChargeGained = "CHARGE GAINED",
}

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

local function removeBanner(card: CanvasGroup, key: string)
	local index = table.find(activeBanners, card)
	if index then table.remove(activeBanners, index) end
	if bannersByKey[key] == card then bannersByKey[key] = nil end
end

local function scheduleBannerExit(card: CanvasGroup, key: string, token: number)
	task.delay(1.15, function()
		if not card.Parent or card:GetAttribute("LifetimeToken") ~= token then return end
		TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			GroupTransparency = 1,
		}):Play()
		local border = card:FindFirstChildOfClass("UIStroke")
		if border then TweenService:Create(border, TweenInfo.new(0.3), { Transparency = 1 }):Play() end
		removeBanner(card, key)
		task.delay(0.32, function()
			if card.Parent and card:GetAttribute("LifetimeToken") == token then card:Destroy() end
		end)
	end)
end

local function banner(templateName: string, title: string, detail: string)
	local library = templates()
	local source = library and library:FindFirstChild(templateName)
	local attack = UIConstants.PlayerGui:FindFirstChild("Attack")
	local feedback = attack and attack:FindFirstChild("Feedback")
	if not source or not source:IsA("CanvasGroup") or not feedback then return end
	local key = templateName .. "\0" .. title .. "\0" .. detail
	local existing = bannersByKey[key]
	if existing and existing.Parent then
		local count = (existing:GetAttribute("FeedbackCount") or 1) + 1
		existing:SetAttribute("FeedbackCount", count)
		local existingTitle = existing:WaitForChild("Title") :: TextLabel
		existingTitle.Text = title .. "  x" .. count
		local token = (existing:GetAttribute("LifetimeToken") or 0) + 1
		existing:SetAttribute("LifetimeToken", token)
		local pop = existing:WaitForChild("Pop") :: UIScale
		TweenService:Create(pop, TweenInfo.new(0.14, Enum.EasingStyle.Back), { Scale = 1.12 }):Play()
		task.delay(0.14, function()
			if pop.Parent then
				TweenService:Create(pop, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { Scale = 1 }):Play()
			end
		end)
		scheduleBannerExit(existing, key, token)
		return
	end
	compactBanners()
	if #activeBanners >= MAX_BANNERS then
		local oldest = activeBanners[1]
		local oldestKey = oldest:GetAttribute("FeedbackKey")
		removeBanner(oldest, typeof(oldestKey) == "string" and oldestKey or "")
		oldest:Destroy()
	end
	local card = source:Clone()
	local titleLabel = card:WaitForChild("Title") :: TextLabel
	local detailLabel = card:WaitForChild("Detail") :: TextLabel
	local pop = card:WaitForChild("Pop") :: UIScale
	card.Name = templateName .. "Feedback"
	card:SetAttribute("FeedbackKey", key)
	card:SetAttribute("FeedbackCount", 1)
	card:SetAttribute("LifetimeToken", 1)
	titleLabel.Text = title
	detailLabel.Text = detail
	card.GroupTransparency = 1
	local targetScale = pop.Scale
	pop.Scale = pop:GetAttribute("StartScale") or targetScale
	card.Visible = true
	card.Parent = feedback
	table.insert(activeBanners, card)
	bannersByKey[key] = card
	TweenService:Create(pop, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = targetScale }):Play()
	TweenService:Create(card, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { GroupTransparency = 0 }):Play()
	scheduleBannerExit(card, key, 1)
end

function Feedback.Status(effectId: string, category: string?, message: string?)
	local negative = category == "Debuff"
	local templateName = negative and "Debuff" or "Buff"
	banner(templateName, displayName(effectId), message or Feedback.Messages[templateName])
end

function Feedback.Passive(passiveId: string, message: string?)
	banner("Passive", displayName(passiveId), message or Feedback.Messages[passiveId] or Feedback.Messages.Passive)
end

return Feedback
