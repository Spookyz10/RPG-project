local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)
local Data = require(ReplicatedStorage.Shared.Data).server
local getCappedInfo = require(ReplicatedStorage.Shared.getCappedInfo)

local InventoryManager = {}

local VanitySlots = {
	Weapon = true,
}

local function BackfillID(
	PlayerData: Types.PlayerData,
	container: string,
	UUID: string,
	ItemEntry: Types.ItemData,
	ItemInfo: Types.Item
)
	if ItemEntry.ID and ItemEntry.ID ~= "" then
		return
	end

	(PlayerData[container] :: any)[UUID].ID(ItemInfo.Data.ID)
end

function InventoryManager:AddItem(Player: Player, ItemID: string, Amount: number): (string, string?)
	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	local ItemInfo = ItemsData[ItemID] :: Types.Item

	if not PlayerData or not ItemInfo then
		return "Invalid player data or itemInfo", nil
	end

	local ID = ItemInfo.Data.ID

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

			if itemData.ID ~= ID then
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
			Name = ItemInfo.Data.Name,
			ID = ID,
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

function InventoryManager:RemoveItem(Player: Player, ItemID: string, Amount: number): string
	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	local ItemInfo = ItemsData[ItemID] :: Types.Item

	if not PlayerData or not ItemInfo then
		return "Invalid player data or itemInfo", PlayerData, ItemInfo
	end

	local ID = ItemInfo.Data.ID

	local Remaining = Amount
	local Inventory = PlayerData.Inventory()

	local isInInventory, key = Functions:HasKeyWithValueIntable(Inventory, "ID", ID)
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
		isInInventory, key = Functions:HasKeyWithValueIntable(Inventory, "ID", ID)
	end

	if Remaining > 0 then
		return "Item not found or insufficient amount"
	end

	return "Successfully deleted item"
end

function InventoryManager:RemoveItemByUUID(Player: Player, UUID: string, Amount: number): string
	local PlayerData = Data.Service:waitForData(Player) :: Types.PlayerData
	if not PlayerData then
		return "Invalid player data"
	end

	local ItemEntry = PlayerData.Inventory[UUID]()
	if not ItemEntry then
		return "Item not found"
	end

	local ToRemove = math.min(Amount, ItemEntry.Amount)
	local ResultingAmount = ItemEntry.Amount - ToRemove

	if ResultingAmount <= 0 then
		PlayerData.Inventory[UUID](nil)
		PlayerData.CurrentInventorySpace(PlayerData.CurrentInventorySpace() - 1)
	else
		PlayerData.Inventory[UUID].Amount(ResultingAmount)
	end

	return "Successfully deleted item"
end

function InventoryManager:EquipSkill(player: Player, skill: string, slot: string)
	local Skills = require(ReplicatedStorage.Shared.Skills)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	local UnlockedSkills = PlayerData.UnlockedSkills()
	if not table.find(UnlockedSkills, skill) then
		return
	end

	local SkillInfo = Skills[skill] :: Types.SkillDefinition
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

	local Info = Functions:GetItemInfo(Item) :: Types.Item
	if not Info then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "Item has no info, how.")
		return
	end

	BackfillID(PlayerData, "Inventory", UUID, Item, Info)

	local canEquip = Info:Elligable(PlayerData)
	if not canEquip then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "You don't meet the item's requirements")
		return
	end

	if Info.Data.ItemType == "Equipment" then
		PlayerData.Equipment[Info.Data.SubType](UUID)
		PlayerData.Inventory[UUID].Equipped(true)
	elseif Info.Data.ItemType == "Consumable" then
		InventoryManager:ConsumeItem(player, UUID, false)
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

	local Info = Functions:GetItemInfo(Item) :: Types.Item
	if not Info then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "Item has no info, how.")
		return
	end

	BackfillID(PlayerData, "Inventory", UUID, Item, Info)

	if Info.Data.ItemType == "Equipment" then
		PlayerData.Equipment[Info.Data.SubType]("")
		PlayerData.Inventory[UUID].Equipped(false)

		if Info.Data.SubType == "Weapon" then
			PlayerData.Vanity.Weapon("")
		end
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

	local Info = Functions:GetItemInfo(Item) :: Types.Item
	if not Info or Info.Kind ~= "Equipment" then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "This item cannot be used as a vanity")
		return
	end

	BackfillID(PlayerData, "Inventory", UUID, Item, Info)

	local SubType = Info.Data.SubType
	if not VanitySlots[SubType] then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "This item type doesn't support vanity yet")
		return
	end

	local EquippedUUID = PlayerData.Equipment[SubType]()
	if not EquippedUUID or EquippedUUID == "" then
		RemoteManager.SendClientEvent(
			"Notification",
			{ Player = player },
			"You need a " .. SubType .. " equipped to use vanity"
		)
		return
	end

	if UUID == EquippedUUID then
		RemoteManager.SendClientEvent(
			"Notification",
			{ Player = player },
			"This item is already equipped, pick a different one for vanity"
		)
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

function InventoryManager:ConsumeItem(player: Player, UUID: string, useAll: boolean?): string
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return "Invalid player data"
	end

	local ItemEntry = PlayerData.Inventory[UUID]()
	if not ItemEntry then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "You don't have that item silly!")
		return "Item not found"
	end

	local ItemInfo = Functions:GetItemInfo(ItemEntry) :: Types.Consumable
	if not ItemInfo or ItemInfo.Kind ~= "Consumable" then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "This item cannot be used")
		return "Not a consumable"
	end

	BackfillID(PlayerData, "Inventory", UUID, ItemEntry, ItemInfo)

	local canUse = ItemInfo:Elligable(PlayerData)
	if not canUse then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "You don't meet the item's requirements")
		return "Requirements not met"
	end

	local Stat = ItemInfo.Stat
	local Cap = getCappedInfo[Stat]
	local Current = PlayerData.ExtraStats[Stat]()

	if Current >= Cap then
		RemoteManager.SendClientEvent("Notification", { Player = player }, "You're already at max " .. Stat)
		return "Already at cap"
	end

	local RoomLeft = Cap - Current
	local UsesWanted = math.ceil(RoomLeft / ItemInfo.Amount)
	local UsesToApply = math.min(useAll and UsesWanted or 1, ItemEntry.Amount)

	if UsesToApply <= 0 then
		return "Nothing to use"
	end

	local NewStat = math.min(Current + UsesToApply * ItemInfo.Amount, Cap)
	PlayerData.ExtraStats[Stat](NewStat)

	InventoryManager:RemoveItemByUUID(player, UUID, UsesToApply)

	return "Used item"
end

function InventoryManager:DrinkAllPotions(player: Player)
	local PlayerData = Data.Service:waitForData(player) :: Types.PlayerData
	if not PlayerData then
		return
	end

	local Inventory = PlayerData.Inventory()

	for UUID, ItemEntry in Inventory do
		local ItemInfo = Functions:GetItemInfo(ItemEntry) :: Types.Item
		if not ItemInfo or ItemInfo.Kind ~= "Consumable" then
			continue
		end

		if ItemInfo.Data.SubType ~= "Potion" then
			continue
		end

		InventoryManager:ConsumeItem(player, UUID, true)
	end
end

return InventoryManager
