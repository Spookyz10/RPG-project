local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local PreloadStatus = require(ReplicatedFirst:WaitForChild("First"):WaitForChild("PreloadStatus"))

local Data = require(ReplicatedStorage.Shared.Data).client
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local AnimationHandler = require(ReplicatedStorage.Shared.AnimationHandler)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Player = Players.LocalPlayer
local readyCharacter: Model? = nil

-- Asset preload completion is earlier than the player pressing Play.
PreloadStatus:WaitUntilLoadingClosed()

local function refresh(character: Model)
	if character ~= readyCharacter or character ~= Player.Character or not character.Parent then
		return
	end
	local UUID = Data.Equipment.Weapon()
	if not UUID or UUID == "" then
		local Handler = AnimationHandler.Get(character)
		if Handler then
			Handler:PlayWeaponIdle(nil)
		end
		return
	end

	local ItemEntry = Data.Inventory[UUID]()
	if not ItemEntry then
		local handler = AnimationHandler.Get(character)
		if handler then handler:PlayWeaponIdle(nil) end
		return
	end

	local ItemInfo = ItemsData[ItemEntry.ID] :: Types.Equipment
	local Handler = AnimationHandler.GetOrCreate(character)
	Handler:PlayWeaponIdle(ItemInfo and ItemInfo.WeaponType)
end

local function onCharacterAdded(character: Model)
	-- Replication may still be completing, including on respawn. Do not create
	-- a handler with a readiness timeout until the server's Animator exists.
	while Player.Character == character do
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if character:IsDescendantOf(workspace) and humanoid and humanoid:FindFirstChildOfClass("Animator")
			and character:FindFirstChild("HumanoidRootPart") then
			readyCharacter = character
			refresh(character)
			return
		end
		task.wait(0.1)
	end
end

Data.Equipment.Weapon.Changed(function()
	if Player.Character then
		refresh(Player.Character)
	end
end)

Player.CharacterAdded:Connect(onCharacterAdded)
Player.CharacterRemoving:Connect(function(character)
	if readyCharacter == character then readyCharacter = nil end
end)

if Player.Character then
	task.spawn(onCharacterAdded, Player.Character)
end

Data.Inventory.Changed(function()
	if Player.Character then refresh(Player.Character) end
end)
