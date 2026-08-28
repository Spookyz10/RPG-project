local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local Zones = require(ReplicatedStorage.Shared.Zones)
local LightingManager = require(ReplicatedStorage.Shared.LightingManager)
local MusicManager = require(ReplicatedStorage.Shared.MusicManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local ZoneSelector = {}

local Container: Instance = nil
local Template: GuiButton = nil

local function TeleportToZone(zoneName: string)
	local Character = UIConstants.Player.Character
	if not Character then
		return
	end

	local Teleporter = workspace:FindFirstChild("ZoneTeleporters")
	local TargetPart = Teleporter and Teleporter:FindFirstChild(zoneName)
	if not TargetPart then
		return
	end

	Character:PivotTo(TargetPart.CFrame + Vector3.new(0, 3, 0))
end

local function CreateEntry(zoneName: string, ZoneInfo: Types.Zone)
	local Button = Template:Clone()
	Button.Name = zoneName
	Button.LayoutOrder = ZoneInfo.Order
	Button.Visible = true

	Button.AreaName.Text = zoneName
	Button.LevelReq.Text = "Lv: " .. ZoneInfo.Level .. " - " .. ZoneInfo.MaxLevel
	Button.Image.Image = ZoneInfo.Icon
	Button.Image.UIStroke.Color = ZoneInfo.Theme
	Button.AreaName.UIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, ZoneInfo.Theme),
	})

	Button.Activated:Connect(function()
		if not Button.Active then
			return
		end

		Button.Active = false

		local PlayerLevel = UIConstants.Data.Level()
		if PlayerLevel >= ZoneInfo.Level then
			LightingManager:Apply(zoneName, ZoneInfo.getLighting())
			MusicManager:PlayZone(zoneName)
			TeleportToZone(zoneName)
		end

		task.wait(0.1)
		Button.Active = true
	end)

	Button.Parent = Container
end

function ZoneSelector.Init()
	Container = UIConstants.PlayerGui:WaitForChild("ZoneSelector"):WaitForChild("Main"):WaitForChild("Container")
	Template = ReplicatedStorage.Resources.UI.Templates:WaitForChild("ZoneTemplate") :: GuiButton

	for zoneName, ZoneInfo in Zones do
		CreateEntry(zoneName, ZoneInfo :: Types.Zone)
	end
end

return ZoneSelector
