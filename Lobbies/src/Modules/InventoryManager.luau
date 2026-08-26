local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Data = require(ReplicatedStorage.Shared.Data).server

local InventoryManager = {}

local VanitySlots = {
	Weapon = true,
}

function InventoryManager:AddItem(Player: Player, ItemName: string, Amount: number): (string, string?)
	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	local ItemInfo = ItemsData[ItemName] :: Types.Item

	if not PlayerData or not ItemInfo then
		return "Invalid player data or itemInfo", nil
	end

	local Remaining = Amount
	local LastUUID: string? = nil

	if ItemInfo.OnDropped then
		ItemInfo:OnDropped(PlayerData)
	end

	if ItemInfo.Data.Stackable then
		local Inventory = PlayerData.Inventory()
		local Cap = ItemInfo.Data.Cap

		for key, itemData in Inventory do
			if Remaining <= 0 then
				break
			end

			if itemData.Name ~= ItemName then
				continue
			end

			local SpaceInStack = Cap - itemData.Amount
			if SpaceInStack > 0 then
				local ToAdd = math.min(SpaceInStack, Remaining)
				PlayerData.Inventory[key].Amount(itemData.Amount + ToAdd)
				Remaining -= ToAdd
				LastUUID = key
			end
		end
	end

	while Remaining > 0 do
		if PlayerData.CurrentInventorySpace() >= PlayerData.MaxInventorySpace() then
			return "Inventory full", LastUUID
		end

		local UUID = Functions:GenUUID()
		local ToAdd = ItemInfo.Data.Stackable and math.min(ItemInfo.Data.Cap, Remaining) or 1

		local NewItem: Types.ItemData = {
			Name = ItemName,
			Amount = ToAdd,
			Enchants = {},
			Upgrades = 0,
			UpgradeCap = math.random(3, 10),
		}

		PlayerData.Inventory[UUID](NewItem)
		PlayerData.CurrentInventorySpace(PlayerData.CurrentInventorySpace() + 1)

		LastUUID = UUID
		Remaining -= ToAdd
	end

	return "Successfully added item", LastUUID
end

function InventoryManager:RemoveItem(Player: Player, ItemName: string, Amount: number): string
	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	local ItemInfo = ItemsData[ItemName] :: Types.Item

	if not PlayerData or not ItemInfo then
		return "Invalid player data or itemInfo", PlayerData, ItemInfo
	end

	local Remaining = Amount
	local Inventory = PlayerData.Inventory()

	local isInInventory, key = Functions:HasKeyWithValueIntable(Inventory, "Name", ItemName)
	while isInInventory and Remaining > 0 do
		local itemData = Inventory[key]
		local ToRemove = math.min(itemData.Amount, Remaining)
		local ResultingAmount = itemData.Amount - ToRemove

		if ResultingAmount <= 0 then
			PlayerData.Inventory[key](nil)
			PlayerData.CurrentInventorySpace(PlayerData.CurrentInventorySpace() - 1)
		else
			PlayerData.Inventory[key].Amount(ResultingAmount)
		end

		Remaining -= ToRemove
		Inventory = PlayerData.Inventory()
		isInInventory, key = Functions:HasKeyWithValueIntable(Inventory, "Name", ItemName)
	end

	if Remaining > 0 then
		return "Item not found or insufficient amount"
	end

	return "Successfully deleted item"
end

function InventoryManager:EquipSkill(player: Player, skill: string, slot: string)
	local Skills = require(script.Parent.Skills)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	local UnlockedSkills = PlayerData.UnlockedSkills()
	if not table.find(UnlockedSkills, skill) then
		return
	end

	local SkillInfo = Skills[skill] :: Types.Skill
	if not SkillInfo then
		return
	end

	local CanEquipSkill = SkillInfo:Elligable(PlayerData)
	if not CanEquipSkill then
		return
	end

	local EquippedSkills = PlayerData.Skills()
	for equippedSlot, equippedSkill in EquippedSkills do
		if equippedSkill == skill and equippedSlot ~= slot then
			PlayerData.Skills[equippedSlot]("")
		end
	end

	PlayerData.Skills[slot](skill)
end

function InventoryManager:ItemAction(player: Player, UUID: string)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "No player data?")
		return
	end

	local Item = PlayerData.Inventory[UUID]()
	if not Item then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "You don't have that item silly!")
		return
	end

	local Info = ItemsData[Item.Name] :: Types.Item
	if not Info then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "Item has no info, how.")
		return
	end

	local canEquip = Info:Elligable(PlayerData)
	if not canEquip then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "You don't meet the item's requirements")
		return
	end

	if Info.Data.ItemType == "Equipment" then
		PlayerData.Equipment[Info.Data.SubType](UUID)
		PlayerData.Inventory[UUID].Equipped(true)
	elseif Info.Data.ItemType == "Consumable" then
		Info:Use(PlayerData)
	end
end

function InventoryManager:UnequipItem(player: Player, UUID: string)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	local Item = PlayerData.Inventory[UUID]()
	if not Item then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "You don't have that item silly!")
		return
	end

	local Info = ItemsData[Item.Name] :: Types.Item
	if not Info then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "Item has no info, how.")
		return
	end

	if Info.Data.ItemType == "Equipment" then
		PlayerData.Equipment[Info.Data.SubType]("")
		PlayerData.Inventory[UUID].Equipped(false)
	end
end

function InventoryManager:VanityEquip(player: Player, UUID: string)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	local Item = PlayerData.Inventory[UUID]()
	if not Item then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "You don't have that item silly!")
		return
	end

	local Info = ItemsData[Item.Name] :: Types.Item
	if not Info or Info.Kind ~= "Equipment" then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "This item cannot be used as a vanity")
		return
	end

	local SubType = Info.Data.SubType
	if not VanitySlots[SubType] then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "This item type doesn't support vanity yet")
		return
	end

	local canEquip = Info:Elligable(PlayerData)
	if not canEquip then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "You don't meet the item's requirements")
		return
	end

	PlayerData.Vanity[SubType](UUID)
end

function InventoryManager:VanityUnequip(player: Player, slot: string)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	if not VanitySlots[slot] then
		return
	end

	PlayerData.Vanity[slot]("")
end

return InventoryManager
