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
		inventory[Functions:GenUUID()] = { ID = recipeID, Name = info.Data.Name, Amount = 1, Enchants = {}, Upgrades = 0, UpgradeCap = math.random(3, 10) }
		-- No yields between validated snapshot and commit; competing remote requests cannot interleave.
		data.Inventory(inventory)
		data.CurrentInventorySpace(count + 1)
		data.Currencies.Gold(data.Currencies().Gold - recipe.Gold)
		QuestManager:AddObjectiveProgress(player, "CraftItem", recipeID, 1)
		notify("Crafted " .. info.Data.Name .. "!")
	end, debug.traceback)
	Busy[player] = nil
	if not ok then warn(err) end
end

return Remote
