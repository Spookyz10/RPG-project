local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local PlayerCardLogic = require(script.Parent.PlayerCard)

local UI = {}

local Entries = {} :: { [Player]: GuiObject }

function UI.Init()
	local PlayerListFrame = UIConstants.PlayerGui:WaitForChild("HUD").PlayerList
	local Action = PlayerListFrame.Action
	local List = PlayerListFrame.List
	local Template = ReplicatedStorage.Assets.UI.Templates.PlayerList

	local Expanded = true

	Action.MouseButton1Click:Connect(function()
		Expanded = not Expanded
		List.Visible = Expanded
		Action.TextLabel.Text = Expanded and ">" or "<"
	end)

	local function CreateEntry(player: Player)
		local Clone = Template:Clone()
		Clone.Name = player.Name
		Clone.PlayerName.Text = player.Name

		if player == UIConstants.Player then
			Clone.PlayerName.TextColor3 = Color3.fromRGB(85, 255, 255)
			Clone.LayoutOrder = -1
		else
			Clone.LayoutOrder = 0
		end

		Clone.MouseButton1Click:Connect(function()
			PlayerCardLogic.Open(player)
		end)

		Clone.Parent = List
		Entries[player] = Clone
	end

	local function RemoveEntry(player: Player)
		local Entry = Entries[player]
		if Entry then
			Entry:Destroy()
			Entries[player] = nil
		end
	end

	for _, player in Players:GetPlayers() do
		CreateEntry(player)
	end

	Players.PlayerAdded:Connect(CreateEntry)
	Players.PlayerRemoving:Connect(RemoveEntry)
end

return UI
