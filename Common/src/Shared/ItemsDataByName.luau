local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)

local ItemsByName = {}

for _, ItemModule in ItemsData do
	ItemsByName[ItemModule.Data.Name] = ItemModule
end

return ItemsByName