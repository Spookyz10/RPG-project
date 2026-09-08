local UI = script.Parent.Parent
local Constants = require(UI.UIConstants)
local Windows = require(UI.WindowManager)
local Toast = require(UI.Toast)
local LightingManager = require(UI.Parent.LightingManager)
local MusicManager = require(UI.Parent.MusicManager)
local Buttons = {}

function Buttons.Init()
	local main = Constants.PlayerGui.Buttons.Main
	local drawer = main.Drawer
	main.Menu.Activated:Connect(function()
		drawer.Visible = not drawer.Visible
		main.Backpack.Visible = not drawer.Visible
	end)
	Constants.PlayerGui:GetAttributeChangedSignal("UIWindowOpen"):Connect(function()
		if Constants.PlayerGui:GetAttribute("UIWindowOpen") then
			drawer.Visible = false
			main.Backpack.Visible = true
		end
	end)
	for _, button in main:GetDescendants() do
		local target = button:GetAttribute("OpenScreen")
		if target and button:IsA("GuiButton") then
			button.Activated:Connect(function()
				drawer.Visible = false
				main.Backpack.Visible = true
				if target == "Playerlist" then
					require(script.Parent.PlayerList).Toggle()
				elseif target == "Home" then
					local teleporters = workspace:FindFirstChild("ZoneTeleporters")
					local lobby = teleporters and teleporters:FindFirstChild("Lobby")
					if lobby and lobby:IsA("BasePart") and Constants.Player.Character then
						Constants.Player.Character:PivotTo(lobby.CFrame + Vector3.new(0, 3, 0))
						LightingManager:ResetToDefault()
						MusicManager:PlayLobby()
						Windows.Close()
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
		main.Backpack.Amount.Text = Constants.Data.CurrentInventorySpace() .. " / " .. Constants.Data.MaxInventorySpace()
	end
	Constants.Data.CurrentInventorySpace.Changed(refresh)
	Constants.Data.MaxInventorySpace.Changed(refresh)
	refresh()
end

return Buttons
