local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Touched = require(ReplicatedStorage.Shared.Touched)

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local TouchZones = workspace:WaitForChild("touchZones")

local ActiveTouches = {} :: { [Instance]: number }

Player.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
	table.clear(ActiveTouches)
end)

local function onTouched(zone: BasePart, hit: BasePart)
	if not hit:IsDescendantOf(Character) then
		return
	end

	local Module = Touched[zone.Name]
	if not Module then
		return
	end

	ActiveTouches[zone] = (ActiveTouches[zone] or 0) + 1

	if ActiveTouches[zone] == 1 and Module.touchStarted then
		Module.touchStarted()
	end
end

local function onTouchEnded(zone: BasePart, hit: BasePart)
	if not hit:IsDescendantOf(Character) then
		return
	end

	local Module = Touched[zone.Name]
	if not Module then
		return
	end

	ActiveTouches[zone] = math.max((ActiveTouches[zone] or 1) - 1, 0)

	if ActiveTouches[zone] == 0 and Module.touchEnded then
		Module.touchEnded()
	end
end

local function setupZone(zone: Instance)
	if not zone:IsA("BasePart") then
		return
	end

	zone.Touched:Connect(function(hit)
		onTouched(zone, hit)
	end)

	zone.TouchEnded:Connect(function(hit)
		onTouchEnded(zone, hit)
	end)
end

for _, zone in TouchZones:GetChildren() do
	setupZone(zone)
end

TouchZones.ChildAdded:Connect(setupZone)
