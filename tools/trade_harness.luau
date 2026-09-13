local callbacks = {}

local function pathId(path, length)
	local parts = {}
	for index = 1, length or #path do
		parts[index] = tostring(path[index])
	end
	return table.concat(parts, ".")
end

local function node(rawRoot, path)
	local function read()
		local value = rawRoot
		for _, key in path do
			value = value and value[key]
		end
		return value
	end
	return setmetatable({}, {
		__call = function(_, ...)
			if select("#", ...) == 0 then
				return read()
			end
			local value = ...
			local parent = rawRoot
			for index = 1, #path - 1 do
				parent = parent[path[index]]
			end
			parent[path[#path]] = value
			for length = #path, 1, -1 do
				for _, callback in callbacks[pathId(path, length)] or {} do
					callback()
				end
			end
			return value
		end,
		__index = function(_, key)
			if key == "Changed" then
				return function(callback)
					local id = pathId(path)
					callbacks[id] = callbacks[id] or {}
					table.insert(callbacks[id], callback)
					return function()
						local index = table.find(callbacks[id], callback)
						if index then table.remove(callbacks[id], index) end
					end
				end
			end
			local nested = table.clone(path)
			table.insert(nested, key)
			return node(rawRoot, nested)
		end,
	})
end

local players = {}
local function makePlayer(name, userId, raw)
	local player = { Name = name, DisplayName = name .. " Display", UserId = userId, Parent = players }
	function player:IsA(className) return className == "Player" end
	player._type = "Instance"
	player._raw = raw
	player._data = node(raw, {})
	return player
end

local function item(id, amount, equipped)
	return { ID = id, Name = id, Amount = amount, Enchants = {}, Upgrades = 0, UpgradeCap = 5, Equipped = equipped }
end

local function rawData(inventory, storage, gold, maxInventory, maxStorage)
	local inventoryCount = 0
	local storageCount = 0
	for _ in inventory do inventoryCount += 1 end
	for _ in storage do storageCount += 1 end
	return {
		Level = 20,
		Inventory = inventory,
		Storage = storage,
		Equipment = { Weapon = "", Armor = "", Ring = "", Necklace = "", Aura = "", Rune = "" },
		Vanity = { Weapon = "", Aura = "" },
		Currencies = { Gold = gold },
		Settings = { ["Trade Offers"] = true },
		CurrentInventorySpace = inventoryCount,
		CurrentStorageSpace = storageCount,
		MaxInventorySpace = maxInventory or 100,
		MaxStorageSpace = maxStorage or 100,
	}
end

local sender = makePlayer("Sender", 1, rawData({
	fangs = item("Wolf's Fang", 5),
	sword = item("Wooden Sword", 1, true),
}, {}, 1000))
sender._raw.Equipment.Weapon = "sword"
local target = makePlayer("Target", 2, rawData({
	bush = item("Dark Ivy", 2),
}, {
	ivy = item("Dark Ivy", 3),
}, 500))

local roots = { [sender] = sender._data, [target] = target._data }
local data = setmetatable({
	Service = {
		waitForData = function(_, player) return roots[player] end,
	},
}, { __index = function(_, player) return roots[player] end })

local itemDefinitions = {
	["Wolf's Fang"] = { Kind = "Material", Data = { ID = "Wolf's Fang", Name = "Wolf's Fang", Icon = "fang", Rarity = "Common", Stackable = true, Cap = 99 } },
	["Dark Ivy"] = { Kind = "Material", Data = { ID = "Dark Ivy", Name = "Dark Ivy", Icon = "ivy", Rarity = "Uncommon", Stackable = true, Cap = 99 } },
	["Wooden Sword"] = { Kind = "Equipment", Data = { ID = "Wooden Sword", Name = "Wooden Sword", Icon = "sword", Rarity = "Common", Stackable = false, SubType = "Weapon" } },
}

local calls = {}
local remotes = {
	SendClientEvent = function(name, params, ...)
		table.insert(calls, { name, params, ... })
	end,
}

local uuid = 0
local functions = {
	GenUUID = function()
		uuid += 1
		return "generated-" .. uuid
	end,
}

local moduleData = {}
local moduleFunctions = {}
local moduleItems = {}
local moduleItemsByName = {}
local moduleRemotes = {}
local moduleTypes = {}
local replicatedStorage = {
	Shared = {
		Data = moduleData,
		ItemsData = moduleItems,
		ItemsDataByName = moduleItemsByName,
		Utils = { Functions = moduleFunctions, RemoteManager = moduleRemotes, Types = moduleTypes },
	},
}
local services = {
	HttpService = { GenerateGUID = function() uuid += 1; return "offer-" .. uuid end },
	Players = players,
	ReplicatedStorage = replicatedStorage,
}
local game = { GetService = function(_, name) return services[name] end }
local now = 10
local workspace = { GetServerTimeNow = function() return now end }
local delayed = {}
local task = {
	defer = function(callback, ...) callback(...) end,
	delay = function(_, callback) table.insert(delayed, callback) end,
}
local standardTypeof = typeof
local function mockTypeof(value)
	return type(value) == "table" and value._type or standardTypeof(value)
end
local dependencies = {
	[moduleData] = { server = data },
	[moduleFunctions] = functions,
	[moduleItems] = itemDefinitions,
	[moduleItemsByName] = itemDefinitions,
	[moduleRemotes] = remotes,
	[moduleTypes] = {},
}
local function mockRequire(module)
	return assert(dependencies[module], "Unknown dependency")
end

local tradeChunk = assert(loadstring(TRADE_SOURCE, "TradeSystem"))
setfenv(tradeChunk, setmetatable({
	game = game,
	workspace = workspace,
	task = task,
	os = { clock = function() return now end },
	typeof = mockTypeof,
	require = mockRequire,
}, { __index = getfenv() }))
local TradeSystem = tradeChunk()

local function offerPayload(giveGold, receiveGold, giveItems, receiveItems)
	return {
		Give = { Gold = giveGold, Items = giveItems or {} },
		Receive = { Gold = receiveGold, Items = receiveItems or {} },
	}
end

local catalog = assert(TradeSystem:GetCatalog(sender, target))
assert(#catalog.Self.Inventory == 1 and catalog.Self.Inventory[1].UUID == "fangs", "Equipped item leaked into catalog")
assert(#catalog.Target.Storage == 1 and catalog.Target.Storage[1].UUID == "ivy", "Storage catalog missing")

local ok = TradeSystem:CreateOffer(sender, target, offerPayload(0 / 0, 0))
assert(not ok, "NaN Gold was accepted")
now = 13
ok = TradeSystem:CreateOffer(sender, target, offerPayload(0, 0, {
	{ Container = "Inventory", UUID = "sword", Amount = 1 },
}))
assert(not ok, "Equipped item was accepted")
now = 16
ok = TradeSystem:CreateOffer(sender, target, offerPayload(0, 0, {
	{ Container = "Inventory", UUID = "fangs", Amount = 1 },
	{ Container = "Inventory", UUID = "fangs", Amount = 1 },
}))
assert(not ok, "Duplicate selection was accepted")

now = 20
local createMessage
ok, createMessage = TradeSystem:CreateOffer(sender, target, offerPayload(25, 0, {
	{ Container = "Inventory", UUID = "fangs", Amount = 1 },
}))
assert(ok, "Valid offer was rejected: " .. tostring(createMessage))
local received = calls[#calls - 1]
assert(received[1] == "TradeOfferReceived", "Target did not receive offer notification")
local invalidatedId = received[3].Id
now = 23
local duplicatePair = TradeSystem:CreateOffer(sender, target, offerPayload(1, 0))
assert(not duplicatePair, "Multiple pending offers to the same target were accepted")
sender._data.Equipment.Weapon("fangs")
assert(calls[#calls][1] == "TradeOfferStatus" and calls[#calls][3] == invalidatedId and calls[#calls][4] == "Cancelled", "Equipping did not cancel offer")
sender._data.Equipment.Weapon("sword")

now = 30
ok = TradeSystem:CreateOffer(sender, target, offerPayload(50, 10, {
	{ Container = "Inventory", UUID = "fangs", Amount = 2 },
}, {
	{ Container = "Storage", UUID = "ivy", Amount = 1 },
}))
assert(ok, "Valid exchange offer was rejected")
received = calls[#calls - 1]
local offerId = received[3].Id
local beforeFangs = sender._raw.Inventory.fangs.Amount
local forged = TradeSystem:Respond(sender, offerId, true)
assert(not forged and sender._raw.Inventory.fangs.Amount == beforeFangs, "Non-target accepted an offer")
local accepted, message = TradeSystem:Respond(target, offerId, true)
assert(accepted, message)
assert(sender._raw.Currencies.Gold == 960 and target._raw.Currencies.Gold == 540, "Gold was not conserved")
assert(sender._raw.Inventory.fangs.Amount == 3 and target._raw.Storage.ivy.Amount == 2, "Sources were not debited exactly once")
assert(sender._raw.Storage["generated-4"].ID == "Dark Ivy" and sender._raw.Storage["generated-4"].Amount == 1, "Requested storage item was not delivered")
assert(target._raw.Inventory["generated-3"].ID == "Wolf's Fang" and target._raw.Inventory["generated-3"].Amount == 2, "Offered backpack item was not delivered")
local goldSnapshot = sender._raw.Currencies.Gold
accepted = TradeSystem:Respond(target, offerId, true)
assert(not accepted and sender._raw.Currencies.Gold == goldSnapshot, "Duplicate accept mutated economy")

now = 40
ok = TradeSystem:CreateOffer(sender, target, offerPayload(0, 0, {
	{ Container = "Inventory", UUID = "fangs", Amount = 1 },
}))
assert(ok)
received = calls[#calls - 1]
local changedId = received[3].Id
sender._data.Inventory.fangs.Amount(2)
assert(calls[#calls][3] == changedId and calls[#calls][4] == "Cancelled", "Changed stack did not cancel offer")

local full = makePlayer("Full", 3, rawData({ sword = item("Wooden Sword", 1, true) }, {}, 100, 1, 1))
full._raw.Equipment.Weapon = "sword"
local giver = makePlayer("Giver", 4, rawData({ bush = item("Dark Ivy", 1) }, {}, 100))
roots[full] = full._data
roots[giver] = giver._data
now = 50
ok = TradeSystem:CreateOffer(full, giver, offerPayload(1, 0, {}, {
	{ Container = "Inventory", UUID = "bush", Amount = 1 },
}))
assert(ok)
received = calls[#calls - 1]
local capacityId = received[3].Id
accepted = TradeSystem:Respond(giver, capacityId, true)
assert(not accepted and full._raw.Currencies.Gold == 100 and giver._raw.Inventory.bush, "Capacity failure partially committed")

now = 60
ok = TradeSystem:CreateOffer(sender, target, offerPayload(1, 0))
assert(ok)
received = calls[#calls - 1]
local leavingId = received[3].Id
TradeSystem:OnPlayerRemoved(sender)
assert(calls[#calls][3] == leavingId and calls[#calls][4] == "Cancelled", "Leaving did not cancel pending offer")

now = 200
ok = TradeSystem:CreateOffer(full, giver, offerPayload(1, 0))
assert(ok)
received = calls[#calls - 1]
local expiredId = received[3].Id
now = 321
accepted = TradeSystem:Respond(giver, expiredId, true)
assert(not accepted and calls[#calls][3] == expiredId and calls[#calls][4] == "Cancelled", "Expired offer was accepted")

now = 400
ok = TradeSystem:CreateOffer(full, giver, offerPayload(1, 0))
assert(ok)
received = calls[#calls - 1]
local declinedId = received[3].Id
local declined = TradeSystem:Respond(giver, declinedId, false)
assert(declined and calls[#calls][3] == declinedId and calls[#calls][4] == "Declined", "Decline did not close offer")

target._data.Settings["Trade Offers"](false)
now = 500
ok = TradeSystem:CreateOffer(sender, target, offerPayload(1, 0))
assert(not ok, "Disabled trade setting was ignored")

print("PASS: server validation, equipped protection, invalidation, single commit, conservation, capacity rollback, expiry, decline, settings and leave cleanup")
