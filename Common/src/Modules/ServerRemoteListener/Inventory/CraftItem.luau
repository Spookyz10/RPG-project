local RS = game:GetService("ReplicatedStorage")
local Data = require(RS.Shared.Data).server
local Recipes = require(RS.Shared.CraftingRecipes)
local Items = require(RS.Shared.ItemsData)
local Functions = require(RS.Shared.Utils.Functions)
local RemoteManager = require(RS.Shared.Utils.RemoteManager)
local QuestManager = require(game:GetService("ServerStorage").Modules.QuestManager)
local Remote = {}
local Busy = {}

function Remote:Activate(player, recipeID)
	if typeof(recipeID) ~= "string" or not Recipes[recipeID] or Busy[player] then return end
	Busy[player] = true
	local ok, err = xpcall(function()
		local data = Data.Service:waitForData(player)
		if not data then return end
		local recipe = Recipes[recipeID]
		local function notify(message) RemoteManager.SendClientEvent("Notification", { Player = player }, message) end
		if data.Level() < recipe.Level then notify("Requires level " .. recipe.Level); return end
		if (data.Currencies().Gold or 0) < recipe.Gold then notify("Not enough Gold."); return end
		local inventory = table.clone(data.Inventory())
		local equipment = data.Equipment()
		local equipped = {}
		for _, uuid in equipment do equipped[uuid] = true end
		for id, required in recipe.Ingredients do
			local remaining = required
			for uuid, entry in inventory do
				local info = Functions:GetItemInfo(entry)
				if info and info.Data.ID == id and not equipped[uuid] then
					local used = math.min(remaining, entry.Amount)
					local copy = table.clone(entry)
					copy.Amount -= used
					inventory[uuid] = copy.Amount > 0 and copy or nil
					remaining -= used
					if remaining == 0 then break end
				end
			end
			if remaining > 0 then notify("Not enough " .. id .. "."); return end
		end
		local count = 0
		for _ in inventory do count += 1 end
		if count >= data.MaxInventorySpace() then notify("Inventory full."); return end
		local info = Items[recipeID]
		if not info then return end
		local craftedUUID = Functions:GenUUID()
		local craftedItem = {
			ID = recipeID,
			Name = info.Data.Name,
			Amount = 1,
			Enchants = {},
			Upgrades = 0,
			UpgradeCap = math.random(3, 10),
		}
		inventory[craftedUUID] = craftedItem

		-- Update individual slots instead of replacing the entire inventory table.
		-- The client inventory UI listens for slot additions/removals, which are not
		-- emitted when the parent table itself is replaced.
		local originalInventory = data.Inventory()
		for uuid, originalItem in originalInventory do
			local updatedItem = inventory[uuid]
			if updatedItem == nil or updatedItem.Amount ~= originalItem.Amount then
				data.Inventory[uuid](updatedItem)
			end
		end
		data.Inventory[craftedUUID](craftedItem)
		data.CurrentInventorySpace(count + 1)
		data.Currencies.Gold(data.Currencies().Gold - recipe.Gold)
		QuestManager:AddObjectiveProgress(player, "CraftItem", recipeID, 1)
		notify("Crafted " .. info.Data.Name .. "!")
	end, debug.traceback)
	Busy[player] = nil
	if not ok then warn(err) end
end

return Remote
