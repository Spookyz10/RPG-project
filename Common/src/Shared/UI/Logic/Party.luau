local Theme = require(script.Parent.Parent.Theme)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)

local PartyUI = {}

local LEADER_COLOR = Theme.Gold
local INVITE_TIMEOUT_FALLBACK = 10

local Partylist: ScreenGui = nil
local Frame: Frame = nil
local LeaveButton: TextButton = nil
local Template: Frame = nil

local function ClearEntries()
	for _, child in Frame:GetChildren() do
		if child:IsA("Frame") and child.Name ~= "HP" then
			child:Destroy()
		end
	end
end

local function GetMemberLevel(memberName: string): number
	local Member = Players:FindFirstChild(memberName)
	local Stats = Member and Member:FindFirstChild("PublicStats")
	local LevelValue = Stats and Stats:FindFirstChild("Level") :: NumberValue?
	return LevelValue and LevelValue.Value or 0
end

function PartyUI.OnUpdate(members: { [string]: boolean }, leaderName: string)
	ClearEntries()

	LeaveButton.Visible = true
	Frame.Visible = true
	Frame.Parent.Empty.Visible = false

	for memberName in members do

		local Entry = Template:Clone()
		Entry.Name = memberName
		Entry.Visible = true
		Entry.Parent = Frame

		Entry.User.Text = memberName .. "(" .. GetMemberLevel(memberName) .. ")"

		if memberName == leaderName then
			Entry.User.TextColor3 = LEADER_COLOR
		end

		if leaderName == UIConstants.Player.Name and memberName ~= UIConstants.Player.Name then
			Entry.Kick.Visible = true
			Entry.Kick.Activated:Connect(function()
				RemoteManager.SendServerEvent("KickFromParty", memberName)
			end)
		else
			Entry.Kick:Destroy()
		end
	end
end

function PartyUI.OnLeave()
	ClearEntries()
	Frame.Visible = false
	Frame.Parent.Empty.Visible = true
	LeaveButton.Visible = false
end

function PartyUI.OnInvite(inviterName: string, duration: number?)
	local Template2 = require(ReplicatedStorage.Shared.UI.Bootstrap).GetTemplates():WaitForChild("PartyInvite") :: Frame
	local Prompt = Template2:Clone()
	Prompt.Visible = true
	Prompt.TextLabel.Text = inviterName .. " has invited you to a raid"
	local old = Partylist:FindFirstChild("PartyInvite")
	if old then old:Destroy() end
	Prompt.Parent = Partylist

	local Answered = false
	local function Cleanup()
		if Answered then
			return
		end
		Answered = true
		Prompt:Destroy()
	end

	Prompt.YES.Activated:Connect(function()
		RemoteManager.SendServerEvent("AcceptPartyInvite", inviterName)
		Cleanup()
	end)

	Prompt.NO.Activated:Connect(function()
		RemoteManager.SendServerEvent("DeclinePartyInvite", inviterName)
		Cleanup()
	end)

	task.delay(duration or INVITE_TIMEOUT_FALLBACK, Cleanup)
end

function PartyUI.Init()
	Partylist = UIConstants.PlayerGui:WaitForChild("Partylist") :: ScreenGui
	Frame = Partylist.Panel.Body.Content:WaitForChild("Frame") :: Frame
	LeaveButton = Partylist.Panel.Body.Content:WaitForChild("Leave") :: TextButton
	Template = require(ReplicatedStorage.Shared.UI.Bootstrap).GetTemplates():WaitForChild("PartyEntry") :: Frame

	Frame.Visible = false
	Frame.Parent.Empty.Visible = true
	LeaveButton.Visible = false

	LeaveButton.Activated:Connect(function()
		RemoteManager.SendServerEvent("LeaveParty")
	end)
end

return PartyUI
