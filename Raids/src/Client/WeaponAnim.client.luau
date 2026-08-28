local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).client
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local AnimationHandler = require(ReplicatedStorage.Shared.AnimationHandler)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Player = Players.LocalPlayer

local function refresh(character: Model)
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
		return
	end

	local ItemInfo = ItemsData[ItemEntry.Name] :: Types.Equipment
	local Handler = AnimationHandler.GetOrCreate(character)
	Handler:PlayWeaponIdle(ItemInfo and ItemInfo.WeaponType)
end

local function onCharacterAdded(character: Model)
	refresh(character)
end

Data.Equipment.Weapon.Changed(function()
	if Player.Character then
		refresh(Player.Character)
	end
end)

if Player.Character then
	onCharacterAdded(Player.Character)
end

Player.CharacterAdded:Connect(onCharacterAdded)
