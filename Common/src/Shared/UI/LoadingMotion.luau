local TweenService = game:GetService("TweenService")
local Motion = {}

function Motion.Start(screen)
	local frame = screen.Frame
	local tweens = {}
	local closed = false
	local progressTween
	local function tween(object, duration, goal, repeatCount, reverse)
		local animation = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, repeatCount or 0, reverse or false), goal)
		table.insert(tweens, animation)
		animation:Play()
		return animation
	end
	for index, name in { "Chapter", "Title", "Subtitle", "Edition", "Tip" } do
		local label = frame:FindFirstChild(name)
		if label then
			local position = label.Position
			label.Position = position + UDim2.fromScale(0, 0.018)
			label.TextTransparency = 1
			task.delay((index - 1) * 0.09, function()
				if not closed and label.Parent then tween(label, 0.65, { Position = position, TextTransparency = 0 }) end
			end)
		end
	end
	local spark = frame:FindFirstChild("Spark")
	if spark then tween(spark, 2.4, { Rotation = 225, BackgroundTransparency = 0.5 }, -1, true) end
	local atmosphere = frame:FindFirstChild("Atmosphere")
	if atmosphere then tween(atmosphere, 7, { Rotation = 65 }, -1, true) end
	local function cleanup()
		closed = true
		for _, animation in tweens do animation:Cancel() end
		if progressTween then progressTween:Cancel() end
	end
	screen.Destroying:Connect(cleanup)
	return {
		Progress = function(ratio)
			if closed then return end
			if progressTween then progressTween:Cancel() end
			progressTween = TweenService:Create(frame.Progress.Fill, TweenInfo.new(0.25), { Size = UDim2.fromScale(ratio, 1) })
			progressTween:Play()
			local percent = frame:FindFirstChild("Percent")
			if percent then percent.Text = tostring(math.floor(ratio * 100)) .. "%" end
		end,
		Ready = function()
			if closed then return end
			frame.Play.Visible = true
			local scale = Instance.new("UIScale")
			scale.Scale = 0.92
			scale.Parent = frame.Play
			tween(scale, 0.45, { Scale = 1 })
		end,
		Close = function()
			cleanup()
			for _, object in frame:GetDescendants() do
				if object:IsA("GuiObject") then
					local goal = { BackgroundTransparency = 1 }
					if object:IsA("TextLabel") or object:IsA("TextButton") then goal.TextTransparency = 1; goal.TextStrokeTransparency = 1 end
					if object:IsA("ImageLabel") then goal.ImageTransparency = 1 end
					tween(object, 0.35, goal)
				elseif object:IsA("UIStroke") then tween(object, 0.35, { Transparency = 1 }) end
			end
			tween(frame, 0.35, { BackgroundTransparency = 1 })
			task.wait(0.35)
		end,
	}
end
return Motion
