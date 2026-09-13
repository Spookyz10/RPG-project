local UI = script.Parent.Parent
local Constants = require(UI.UIConstants)
local Windows = require(UI.WindowManager)
local Toast = require(UI.Toast)
local LightingManager = require(UI.Parent.LightingManager)
local MusicManager = require(UI.Parent.MusicManager)
local Abbreviation = require(UI.Parent.Utils.Abbreviation)
local Buttons = {}

function Buttons.Init()
	local main = Constants.PlayerGui.Buttons.Main
	local drawer = main.Drawer
	local quickJournal = main:FindFirstChild("Journal")
	local drawerItems = drawer:FindFirstChild("Items")
	local drawerJournal = drawerItems and drawerItems:FindFirstChild("Journal")
	local unreadQuests = 0

	local function setShortcutsVisible(visible: boolean)
		main.Backpack.Visible = visible
		if quickJournal and quickJournal:IsA("GuiObject") then
			quickJournal.Visible = visible
		end
	end

	local function updateQuestNotifications()
		local text = unreadQuests > 99 and "99+" or tostring(unreadQuests)
		for _, button in { main.Menu, quickJournal, drawerJournal } do
			local notification = button and button:FindFirstChild("Notification")
			if notification and notification:IsA("GuiObject") then
				notification.Visible = unreadQuests > 0
				local label = if notification:IsA("TextLabel") or notification:IsA("TextButton")
					then notification
					else notification:FindFirstChildWhichIsA("TextLabel")
				if label then label.Text = text end
			end
		end
	end

	local function clearQuestNotifications()
		unreadQuests = 0
		updateQuestNotifications()
	end

	main.Menu.Activated:Connect(function()
		drawer.Visible = not drawer.Visible
		setShortcutsVisible(not drawer.Visible)
	end)
	Constants.PlayerGui:GetAttributeChangedSignal("UIWindowOpen"):Connect(function()
		if Constants.PlayerGui:GetAttribute("UIWindowOpen") then
			drawer.Visible = false
			setShortcutsVisible(true)
		end
	end)
	for _, button in main:GetDescendants() do
		local target = button:GetAttribute("OpenScreen")
		if target and button:IsA("GuiButton") then
			button.Activated:Connect(function()
				drawer.Visible = false
				setShortcutsVisible(true)
				if target == "Journal" then clearQuestNotifications() end
				if target == "Home" then
					local teleporters = workspace:FindFirstChild("ZoneTeleporters")
					local lobby = teleporters and teleporters:FindFirstChild("Lobby")
					if lobby and lobby:IsA("BasePart") and Constants.Player.Character then
						require(UI.ZoneTransition).Play("Lobby", function()
							Constants.Player.Character:PivotTo(lobby.CFrame + Vector3.new(0, 3, 0))
							LightingManager:ResetToDefault()
							MusicManager:PlayLobby()
							Windows.Close()
						end)
					else
						Toast.Show("The village is not available from here.")
					end
				else
					Windows.Open(target, true)
				end
			end)
		end
	end
	local function refresh()
		main.Backpack.Amount.Text = Abbreviation:Number(Constants.Data.CurrentInventorySpace()) .. " / " .. Abbreviation:Number(Constants.Data.MaxInventorySpace())
	end
	Constants.Data.CurrentInventorySpace.Changed(refresh)
	Constants.Data.MaxInventorySpace.Changed(refresh)
	Constants.Data.Quests.OnKeyAdded(function()
		unreadQuests += 1
		updateQuestNotifications()
	end)
	local journalWindow = Constants.PlayerGui.Journal.Main
	journalWindow:GetPropertyChangedSignal("Visible"):Connect(function()
		if journalWindow.Visible then clearQuestNotifications() end
	end)
	updateQuestNotifications()
	refresh()
end

return Buttons
