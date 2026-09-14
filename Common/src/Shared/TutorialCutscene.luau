local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Data = require(ReplicatedStorage.Shared.Data).client
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Theme = require(ReplicatedStorage.Shared.UI.Theme)
local Windows = require(ReplicatedStorage.Shared.UI.WindowManager)

local Tutorial = {}
local Playing = false
local STEP_COUNT = 12
local FIRST_QUEST = "Tutorial1"
local FIRST_QUEST_GOAL = 3
local STARTER_WEAPON = "Wooden Sword"

type Step = {
	Title: string,
	Prompt: string,
	Objective: string,
	Counter: string?,
	Target: (() -> GuiObject?)?,
	Top: boolean?,
	Bind: (complete: () -> ()) -> (),
}

type Cleanup = RBXScriptConnection | (() -> ())

local function disconnectAll(cleanups: { Cleanup })
	for _, cleanup in cleanups do
		if type(cleanup) == "function" then
			cleanup()
		else
			cleanup:Disconnect()
		end
	end
	table.clear(cleanups)
end

function Tutorial:Play()
	if Playing then
		return
	end
	Playing = true

	local gui = require(ReplicatedStorage.Shared.UI.Bootstrap).Ensure()
	local screen = gui:FindFirstChild("Tutorial")
	if not screen or not screen:IsA("ScreenGui") then
		Playing = false
		warn("Tutorial UI is missing. Run tools/ui-generators/16_Tutorial.luau in Studio Edit mode.")
		return
	end

	local overlay = screen:WaitForChild("Overlay") :: Frame
	local scrim = overlay:WaitForChild("Scrim") :: TextButton
	local focus = overlay:WaitForChild("FocusRing") :: Frame
	local coach = overlay:WaitForChild("Coach") :: Frame
	local objective = coach:WaitForChild("Objective") :: Frame
	local objectiveText = objective:WaitForChild("Text") :: TextLabel
	local objectiveCounter = objective:WaitForChild("Counter") :: TextLabel
	local progressFill = coach.Progress.Fill :: Frame
	local continueButton = coach.Continue :: TextButton
	local sessionConnections = {} :: { Cleanup }
	local stepConnections = {} :: { Cleanup }
	local focusConnections = {} :: { Cleanup }
	local currentStep = 0
	local finished = false
	local completingStep = false
	local focusTween: Tween? = nil
	local progressTween: Tween? = nil

	local function addSession(cleanup: Cleanup)
		table.insert(sessionConnections, cleanup)
	end

	local function addStep(cleanup: Cleanup)
		table.insert(stepConnections, cleanup)
	end

	local function addFocus(cleanup: Cleanup)
		table.insert(focusConnections, cleanup)
	end

	local function tween(object: Instance, duration: number, properties: { [string]: any }, style: Enum.EasingStyle?)
		local motion = TweenService:Create(
			object,
			TweenInfo.new(duration, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			properties
		)
		motion:Play()
		return motion
	end

	local function animateProgress(fromAmount: number, toAmount: number)
		if progressTween then
			progressTween:Cancel()
		end
		progressFill.Size = UDim2.fromScale(fromAmount / STEP_COUNT, 1)
		progressTween = tween(
			progressFill,
			0.34,
			{ Size = UDim2.fromScale(toAmount / STEP_COUNT, 1) },
			Enum.EasingStyle.Quart
		)
	end

	local function burst()
		local particles = overlay.Celebration:GetChildren()
		for index, particle in particles do
			if not particle:IsA("GuiObject") then
				continue
			end
			local angle = ((index - 1) / math.max(1, #particles)) * math.pi * 2
			local distance = 0.12 + (index % 4) * 0.025
			particle.Position = UDim2.fromScale(0.5, 0.53)
			particle.Rotation = index * 19
			particle.BackgroundTransparency = 0
			particle.Visible = true
			tween(particle, 0.55, {
				Position = UDim2.fromScale(0.5 + math.cos(angle) * distance, 0.53 + math.sin(angle) * distance),
				Rotation = particle.Rotation + 150,
				BackgroundTransparency = 1,
			}, Enum.EasingStyle.Quart)
		end
		task.delay(0.6, function()
			if not screen.Parent then
				return
			end
			for _, particle in overlay.Celebration:GetChildren() do
				if particle:IsA("GuiObject") then
					particle.Visible = false
				end
			end
		end)
	end

	local function animateCoach()
		coach.MotionScale.Scale = 0.9
		tween(coach.MotionScale, 0.32, { Scale = 1 }, Enum.EasingStyle.Back)
	end

	local function stopFocusTween()
		if focusTween then
			focusTween:Cancel()
			focusTween = nil
		end
	end

	local function clearFocus()
		stopFocusTween()
		focus.Visible = false
		disconnectAll(focusConnections)
	end

	local function clearStep()
		clearFocus()
		disconnectAll(stepConnections)
	end

	local function focusTarget(target: GuiObject?)
		clearFocus()
		if not target then
			return
		end

		local function isVisible()
			local current: Instance? = target
			while current and current ~= gui do
				if current:IsA("GuiObject") and not current.Visible then
					return false
				end
				if current:IsA("LayerCollector") and not current.Enabled then
					return false
				end
				current = current.Parent
			end
			return true
		end

		local function update()
			if not target.Parent or not isVisible() then
				focus.Visible = false
				return
			end
			local origin = overlay.AbsolutePosition
			local bounds = overlay.AbsoluteSize
			if bounds.X <= 0 or bounds.Y <= 0 then
				return
			end
			local position = target.AbsolutePosition - origin
			local size = target.AbsoluteSize
			focus.Position = UDim2.fromScale((position.X + size.X * 0.5) / bounds.X, (position.Y + size.Y * 0.5) / bounds.Y)
			focus.Size = UDim2.fromScale((size.X + 18) / bounds.X, (size.Y + 18) / bounds.Y)
			if focus.Position.Y.Scale < 0.22 then
				focus.Marker.Position = UDim2.fromScale(0.5, 1.02)
			else
				focus.Marker.Position = UDim2.fromScale(0.5, -0.28)
			end
			focus.Visible = true
		end

		update()
		addFocus(target:GetPropertyChangedSignal("AbsolutePosition"):Connect(update))
		addFocus(target:GetPropertyChangedSignal("AbsoluteSize"):Connect(update))
		addFocus(target:GetPropertyChangedSignal("Visible"):Connect(update))
		addFocus(overlay:GetPropertyChangedSignal("AbsoluteSize"):Connect(update))
		focus.Pulse.Scale = 0.82
		tween(focus.Pulse, 0.38, { Scale = 1 }, Enum.EasingStyle.Back)
		focus.Glow.Transparency = 0.05
		focusTween = TweenService:Create(
			focus.Glow,
			TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ Transparency = 0.55 }
		)
		focusTween:Play()
	end

	local inventoryWindow = gui.Inventory.Main
	local inventoryContainer = inventoryWindow.Body.Content.Items.Container
	local actionFrame = inventoryWindow.ActionFrame
	local skillWindow = gui.SkillSelector.Frame
	local skillContainer = skillWindow.Body.Content.Holder.Attack

	local function getStarterWeaponUUID(): string?
		for uuid, item in Data.Inventory() do
			if item.ID == STARTER_WEAPON or item.Name == STARTER_WEAPON then
				return uuid
			end
		end
		return nil
	end

	local function getStarterWeaponButton(): GuiObject?
		local uuid = getStarterWeaponUUID()
		local entry = uuid and inventoryContainer:FindFirstChild(uuid)
		return if entry and entry:IsA("GuiObject") then entry else nil
	end

	local function getCycloneSlotButton(): GuiObject?
		local entry = skillContainer:FindFirstChild("Cyclone")
		local slot = entry and entry:FindFirstChild("Slot1")
		return if slot and slot:IsA("GuiObject") then slot else nil
	end

	local steps = {} :: { Step }
	local beginStep: (number) -> ()

	local function completeCurrent()
		local completedStep = currentStep
		if completedStep < 1 or finished or completingStep then
			return
		end

		completingStep = true
		clearStep()
		burst()

		if completedStep == STEP_COUNT then
			-- Persist immediately: leaving during the final card must not restart the tutorial.
			RemoteManager.SendServerEvent("CompleteTutorial")
			currentStep = STEP_COUNT + 1
			scrim.Visible = true
			gui:SetAttribute("UIBlocking", true)
			coach.Position = UDim2.fromScale(0.5, 0.5)
			coach.AnchorPoint = Vector2.new(0.5, 0.5)
			coach.Step.Text = "TUTORIAL COMPLETE"
			coach.Step.BackgroundColor3 = Theme.Green
			coach.Title.Text = "The village is your compass"
			coach.Prompt.Text = "Talk to villagers for new quests, then use Explore whenever you are ready for another adventure."
			objective.Visible = false
			continueButton.Text = "START EXPLORING"
			continueButton.Visible = true
			coach.Status.Visible = false
			screen:SetAttribute("TutorialState", "Reward")
			animateProgress(STEP_COUNT - 1, STEP_COUNT)
			animateCoach()
			return
		end

		beginStep(completedStep + 1)
		animateProgress(completedStep - 1, completedStep)
	end

	steps = {
		{
			Title = "Your starter gear",
			Prompt = "Your Wooden Sword is waiting inside. The Backpack stores every weapon, potion, and material you earn.",
			Objective = "Open your Backpack",
			Target = function()
				return gui.Buttons.Main.Backpack
			end,
			Bind = function(complete)
				if inventoryWindow.Visible then
					complete()
					return
				end
				addStep(inventoryWindow:GetPropertyChangedSignal("Visible"):Connect(function()
					if inventoryWindow.Visible then
						complete()
					end
				end))
			end,
		},
		{
			Title = "Know what you carry",
			Prompt = "Item cards reveal rarity, stats, and actions. Inspect the Wooden Sword prepared for you.",
			Objective = "Select the Wooden Sword",
			Target = getStarterWeaponButton,
			Bind = function(complete)
				local function refreshTarget()
					if inventoryWindow.Visible then
						focusTarget(getStarterWeaponButton())
					else
						focusTarget(gui.Buttons.Main.Backpack)
					end
				end

				addStep(inventoryWindow:GetPropertyChangedSignal("Visible"):Connect(refreshTarget))
				addStep(inventoryContainer.ChildAdded:Connect(function(child)
					if child == getStarterWeaponButton() then
						refreshTarget()
					end
				end))
				refreshTarget()

				local function checkInspection()
					if actionFrame.Visible and actionFrame.Inner.ItemName.Text == STARTER_WEAPON then
						complete()
					end
				end
				addStep(actionFrame:GetPropertyChangedSignal("Visible"):Connect(checkInspection))
				checkInspection()
			end,
		},
		{
			Title = "Equip your first weapon",
			Prompt = "Equipped gear changes your stats and prepares it for combat. Put the Wooden Sword in your weapon slot.",
			Objective = "Equip the Wooden Sword",
			Bind = function(complete)
				local function refreshTarget()
					local uuid = getStarterWeaponUUID()
					if uuid and Data.Equipment.Weapon() == uuid then
						complete()
					elseif not inventoryWindow.Visible then
						objectiveText.Text = "Open your Backpack"
						focusTarget(gui.Buttons.Main.Backpack)
					elseif actionFrame.Visible and actionFrame.Inner.ItemName.Text == STARTER_WEAPON then
						objectiveText.Text = "Press Equip"
						focusTarget(actionFrame.Inner.Action)
					else
						objectiveText.Text = "Select the Wooden Sword"
						focusTarget(getStarterWeaponButton())
					end
				end

				addStep(inventoryWindow:GetPropertyChangedSignal("Visible"):Connect(refreshTarget))
				addStep(actionFrame:GetPropertyChangedSignal("Visible"):Connect(refreshTarget))
				addStep(inventoryContainer.ChildAdded:Connect(refreshTarget))
				addStep(Data.Equipment.Weapon.Changed(refreshTarget))
				refreshTarget()
			end,
		},
		{
			Title = "Back to the adventure",
			Prompt = "Your sword is equipped. Close the Backpack so you can return to the world.",
			Objective = "Close your Backpack",
			Target = function()
				return inventoryWindow.Close
			end,
			Bind = function(complete)
				if not inventoryWindow.Visible then
					complete()
					return
				end
				addStep(inventoryWindow:GetPropertyChangedSignal("Visible"):Connect(function()
					if not inventoryWindow.Visible then
						complete()
					end
				end))
			end,
		},
		{
			Title = "Choose your next hunt",
			Prompt = "The Menu connects your Backpack, Skills, Quests, and every destination.",
			Objective = "Open Menu",
			Target = function()
				return gui.Buttons.Main.Menu
			end,
			Bind = function(complete)
				local drawer = gui.Buttons.Main.Drawer
				if drawer.Visible then
					complete()
					return
				end
				addStep(drawer:GetPropertyChangedSignal("Visible"):Connect(function()
					if drawer.Visible then
						complete()
					end
				end))
			end,
		},
		{
			Title = "Discover your first skill",
			Prompt = "Skills are special attacks with their own cooldowns. Open the Skills screen before leaving the village.",
			Objective = "Choose Skills",
			Bind = function(complete)
				local drawer = gui.Buttons.Main.Drawer
				local function refreshTarget()
					if skillWindow.Visible then
						complete()
					elseif drawer.Visible then
						objectiveText.Text = "Choose Skills"
						focusTarget(drawer.Items.Skills)
					else
						objectiveText.Text = "Open Menu"
						focusTarget(gui.Buttons.Main.Menu)
					end
				end

				addStep(drawer:GetPropertyChangedSignal("Visible"):Connect(refreshTarget))
				addStep(skillWindow:GetPropertyChangedSignal("Visible"):Connect(refreshTarget))
				refreshTarget()
			end,
		},
		{
			Title = "Equip Cyclone",
			Prompt = "Cyclone spins around your hero and damages nearby enemies. Equip it in your first skill slot.",
			Objective = "Equip Cyclone to Q",
			Bind = function(complete)
				local drawer = gui.Buttons.Main.Drawer
				local function refreshTarget()
					if Data.Skills.Q() == "Cyclone" then
						complete()
						Windows.Close(true)
					elseif skillWindow.Visible then
						objectiveText.Text = "Equip Cyclone to Q"
						focusTarget(getCycloneSlotButton())
					elseif drawer.Visible then
						objectiveText.Text = "Choose Skills"
						focusTarget(drawer.Items.Skills)
					else
						objectiveText.Text = "Open Menu"
						focusTarget(gui.Buttons.Main.Menu)
					end
				end

				addStep(Data.Skills.Q.Changed(refreshTarget))
				addStep(skillWindow:GetPropertyChangedSignal("Visible"):Connect(refreshTarget))
				addStep(drawer:GetPropertyChangedSignal("Visible"):Connect(refreshTarget))
				addStep(skillContainer.ChildAdded:Connect(refreshTarget))
				refreshTarget()
			end,
		},
		{
			Title = "Unleash Cyclone",
			Prompt = "Your equipped skills appear beside the attack button. Activate Cyclone once to feel how it works.",
			Objective = "Use Cyclone once",
			Target = function()
				return gui.Attack.Slots.Slot1
			end,
			Top = true,
			Bind = function(complete)
				local cooldownRemote = RemoteManager.GetRemote("SkillCooldown", "Client")
				if not cooldownRemote or not cooldownRemote:IsA("RemoteEvent") then
					warn("Tutorial could not observe Cyclone because SkillCooldown is missing.")
					return
				end
				addStep(cooldownRemote.OnClientEvent:Connect(function(slot, _, skillName)
					if slot == "Q" and skillName == "Cyclone" then
						complete()
					end
				end))
			end,
		},
		{
			Title = "Open the Adventure Atlas",
			Prompt = "Explore shows each zone's level range, creatures, rewards, and possible drops.",
			Objective = "Choose Explore",
			Bind = function(complete)
				local window = gui.ZoneSelector.Main
				local drawer = gui.Buttons.Main.Drawer
				local function refreshTarget()
					if drawer.Visible then
						objectiveText.Text = "Choose Explore"
						focusTarget(drawer.Items.Zones)
					else
						objectiveText.Text = "Open Menu"
						focusTarget(gui.Buttons.Main.Menu)
					end
				end
				if window.Visible then
					complete()
					return
				end
				addStep(drawer:GetPropertyChangedSignal("Visible"):Connect(refreshTarget))
				addStep(window:GetPropertyChangedSignal("Visible"):Connect(function()
					if window.Visible then
						complete()
					end
				end))
				refreshTarget()
			end,
		},
		{
			Title = "Study before you hunt",
			Prompt = "Grasslands starts with Bushlings. The atlas reveals their stats and every item they can drop.",
			Objective = "Enter Grasslands",
			Top = true,
			Bind = function(complete)
				local window = gui.ZoneSelector.Main
				local drawer = gui.Buttons.Main.Drawer
				local enter = window.Body.Content.Details.Enter
				local function refreshTarget()
					if window.Visible then
						objectiveText.Text = "Enter Grasslands"
						focusTarget(enter)
					elseif drawer.Visible then
						objectiveText.Text = "Choose Explore"
						focusTarget(drawer.Items.Zones)
					else
						objectiveText.Text = "Open Menu"
						focusTarget(gui.Buttons.Main.Menu)
					end
				end
				addStep(window:GetPropertyChangedSignal("Visible"):Connect(refreshTarget))
				addStep(drawer:GetPropertyChangedSignal("Visible"):Connect(refreshTarget))
				addStep(enter.Activated:Connect(function()
					if enter.Text == "Enter Grasslands" then
						complete()
					end
				end))
				refreshTarget()
			end,
		},
		{
			Title = "Your first contract",
			Prompt = "Bushlings can drop Dark Ivy, potions, rings, and pendants. Defeat three to claim your first reward.",
			Objective = "Defeat Bushlings",
			Counter = "0 / 3",
			Top = true,
			Bind = function(complete)
				RemoteManager.SendServerEvent("AcceptQuest", FIRST_QUEST)

				local function refreshQuest()
					local completed = Data.CompletedQuests()[FIRST_QUEST]
					local active = Data.Quests()[FIRST_QUEST]
					local amount = if active and active.Objectives then active.Objectives[1] or 0 else 0
					if completed then
						amount = FIRST_QUEST_GOAL
					end
					objectiveCounter.Text = string.format("%d / %d", math.clamp(amount, 0, FIRST_QUEST_GOAL), FIRST_QUEST_GOAL)
					if completed then
						complete()
					end
				end

				addStep(Data.Quests.Changed(refreshQuest))
				addStep(Data.CompletedQuests.Changed(refreshQuest))
				refreshQuest()
			end,
		},
		{
			Title = "Bring your victory home",
			Prompt = "Return to the village after a hunt. It is the safest place to meet NPCs and discover your next quest.",
			Objective = "Open Menu",
			Top = true,
			Bind = function(complete)
				local drawer = gui.Buttons.Main.Drawer
				local home = drawer.Items.Home
				local character = LocalPlayer.Character
				local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
				local teleporters = workspace:FindFirstChild("ZoneTeleporters")
				local lobby = teleporters and teleporters:FindFirstChild("Lobby") :: BasePart?
				local attempted = false

				local function refreshTarget()
					if drawer.Visible then
						objectiveText.Text = "Choose Return to village"
						focusTarget(home)
					else
						objectiveText.Text = "Open Menu"
						focusTarget(gui.Buttons.Main.Menu)
					end
				end

				local function checkArrival()
					if attempted and root and root.Parent and lobby and lobby:IsA("BasePart") then
						if (root.Position - lobby.Position).Magnitude <= 12 then
							complete()
						end
					end
				end

				local function bindCharacter(newCharacter: Model)
					local newRoot = newCharacter:FindFirstChild("HumanoidRootPart")
						or newCharacter:WaitForChild("HumanoidRootPart", 5)
					if newRoot and newRoot:IsA("BasePart") then
						root = newRoot
						addStep(newRoot:GetPropertyChangedSignal("CFrame"):Connect(checkArrival))
						checkArrival()
					end
				end

				addStep(drawer:GetPropertyChangedSignal("Visible"):Connect(refreshTarget))
				addStep(home.Activated:Connect(function()
					attempted = true
					task.defer(checkArrival)
				end))
				addStep(LocalPlayer.CharacterAdded:Connect(bindCharacter))
				if character then
					bindCharacter(character)
				end
				refreshTarget()
			end,
		},
	}

	beginStep = function(index: number)
		clearStep()
		completingStep = false
		currentStep = index
		screen:SetAttribute("TutorialState", "Step" .. index)
		local step = steps[index]
		coach.AnchorPoint = Vector2.new(0.5, step.Top and 0 or 1)
		coach.Position = step.Top and UDim2.fromScale(0.5, 0.02) or UDim2.fromScale(0.5, 0.98)
		coach.Step.Text = string.format("STEP %d / %d", index, STEP_COUNT)
		coach.Step.BackgroundColor3 = Theme.Sky
		coach.Title.Text = step.Title
		coach.Prompt.Text = step.Prompt
		coach.Status.Visible = false
		continueButton.Visible = false
		objective.Visible = true
		objectiveText.Text = step.Objective
		objectiveCounter.Text = step.Counter or ""
		progressFill.Size = UDim2.fromScale((index - 1) / STEP_COUNT, 1)
		animateCoach()
		focusTarget(step.Target and step.Target() or nil)
		step.Bind(completeCurrent)
	end

	local function finishTutorial()
		if finished then
			return
		end
		finished = true
		if progressTween then
			progressTween:Cancel()
			progressTween = nil
		end
		clearStep()
		disconnectAll(sessionConnections)
		Windows.Close(true)
		screen.Enabled = false
		gui:SetAttribute("UIBlocking", false)
		LocalPlayer:SetAttribute("ShowTutorial", false)
		RemoteManager.SendServerEvent("CompleteTutorial")
		screen:SetAttribute("TutorialState", "Completed")
		Playing = false
	end

	local function handleContinue()
		if currentStep == 0 then
			scrim.Visible = false
			gui:SetAttribute("UIBlocking", false)
			beginStep(1)
		elseif currentStep == STEP_COUNT + 1 then
			finishTutorial()
		end
	end

	addSession(continueButton.Activated:Connect(handleContinue))

	Windows.Close(true)
	screen.Enabled = true
	screen.DisplayOrder = 200
	overlay.Visible = true
	scrim.Visible = true
	focus.Visible = false
	coach.Visible = true
	coach.BackgroundTransparency = 0
	coach.MotionScale.Scale = 1
	gui:SetAttribute("UIBlocking", true)
	currentStep = 0
	screen:SetAttribute("TutorialState", "Welcome")
	coach.AnchorPoint = Vector2.new(0.5, 0.5)
	coach.Position = UDim2.fromScale(0.5, 0.5)
	coach.Step.Text = "WELCOME"
	coach.Step.BackgroundColor3 = Theme.Sky
	coach.Title.Text = "Ready for your first adventure?"
	coach.Prompt.Text = "We will prepare your first weapon and complete your first contract together."
	objective.Visible = false
	progressFill.Size = UDim2.fromScale(0, 1)
	continueButton.Text = "LET'S GO"
	continueButton.Visible = true
	coach.Status.Visible = false
	animateCoach()
	burst()
end

return Tutorial
