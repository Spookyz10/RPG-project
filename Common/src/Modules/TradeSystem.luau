local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local ItemsDataByName = require(ReplicatedStorage.Shared.ItemsDataByName)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local TradeSystem = {}

local OFFER_LIFETIME = 120
local CREATE_COOLDOWN = 2
local CATALOG_COOLDOWN = 0.5
local RESPONSE_COOLDOWN = 0.35
local MAX_PENDING_PER_PLAYER = 5
local MAX_ITEMS_PER_SIDE = 30
local MAX_SAFE_INTEGER = 9_007_199_254_740_991

type Selection = {
	Container: "Inventory" | "Storage",
	UUID: string,
	Amount: number,
	Item: Types.ItemData,
}

type Offer = {
	Id: string,
	Sender: Player,
	Target: Player,
	GiveGold: number,
	ReceiveGold: number,
	GiveItems: { Selection },
	ReceiveItems: { Selection },
	CreatedAt: number,
	ExpiresAt: number,
	Status: string,
}

local Offers: { [string]: Offer } = {}
local OffersByPlayer: { [Player]: { [string]: boolean } } = {}
local LastCreate: { [Player]: number } = {}
local LastCatalog: { [Player]: number } = {}
local LastResponse: { [Player]: number } = {}
local Watchers: { [Player]: { () -> () } } = {}
local ValidationQueued: { [Player]: boolean } = {}

local function copyDeep(value: any): any
	if type(value) ~= "table" then
		return value
	end

	local result = {}
	for key, child in value do
		result[copyDeep(key)] = copyDeep(child)
	end
	return result
end

local function equalDeep(a: any, b: any): boolean
	if type(a) ~= type(b) then
		return false
	end
	if type(a) ~= "table" then
		return a == b
	end

	for key, value in a do
		if not equalDeep(value, b[key]) then
			return false
		end
	end
	for key in b do
		if a[key] == nil then
			return false
		end
	end
	return true
end

local function validWholeNumber(value: any): boolean
	return typeof(value) == "number"
		and value == value
		and value ~= math.huge
		and value ~= -math.huge
		and value >= 0
		and value <= MAX_SAFE_INTEGER
		and value % 1 == 0
end

local function getItemInfo(item: Types.ItemData): Types.Item?
	return ItemsData[item.ID] or ItemsDataByName[item.Name]
end

local function isUUIDInUse(playerData: Types.PlayerData, container: string, uuid: string): boolean
	if container ~= "Inventory" then
		return false
	end

	return Functions:IsInventoryItemInUse(playerData, uuid)
end

local function acceptsOffers(playerData: Types.PlayerData): boolean
	return playerData.Settings()["Trade Offers"] ~= false
end

local function itemSummary(container: string, uuid: string, item: Types.ItemData)
	local info = getItemInfo(item)
	if not info then
		return nil
	end
	return {
		Container = container,
		UUID = uuid,
		ID = info.Data.ID,
		Name = info.Data.Name,
		Icon = info.Data.Icon,
		Rarity = info.Data.Rarity,
		Amount = item.Amount,
		Upgrades = item.Upgrades or 0,
	}
end

local function catalogFor(player: Player, playerData: Types.PlayerData)
	local result = {
		Name = player.Name,
		DisplayName = player.DisplayName,
		UserId = player.UserId,
		Level = playerData.Level(),
		Gold = playerData.Currencies().Gold or 0,
		Inventory = {},
		Storage = {},
	}

	for _, container in { "Inventory", "Storage" } do
		for uuid, item in playerData[container]() do
			if not isUUIDInUse(playerData, container, uuid) then
				local summary = itemSummary(container, uuid, item)
				if summary then
					table.insert(result[container], summary)
				end
			end
		end
		table.sort(result[container], function(a, b)
			return a.Name == b.Name and a.UUID < b.UUID or a.Name < b.Name
		end)
	end

	return result
end

local function pendingCount(player: Player): number
	local count = 0
	for _ in OffersByPlayer[player] or {} do
		count += 1
	end
	return count
end

local function linkOffer(offer: Offer)
	Offers[offer.Id] = offer
	for _, player in { offer.Sender, offer.Target } do
		OffersByPlayer[player] = OffersByPlayer[player] or {}
		OffersByPlayer[player][offer.Id] = true
	end
end

local function unlinkOffer(offer: Offer)
	Offers[offer.Id] = nil
	for _, player in { offer.Sender, offer.Target } do
		local playerOffers = OffersByPlayer[player]
		if playerOffers then
			playerOffers[offer.Id] = nil
			if next(playerOffers) == nil then
				OffersByPlayer[player] = nil
			end
		end
	end
end

local function sendStatus(offer: Offer, status: string, reason: string)
	for _, player in { offer.Sender, offer.Target } do
		if player.Parent == Players then
			RemoteManager.SendClientEvent("TradeOfferStatus", { Player = player }, offer.Id, status, reason)
		end
	end
end

local function closeOffer(offer: Offer, status: string, reason: string)
	if Offers[offer.Id] ~= offer or offer.Status ~= "Pending" then
		return
	end
	offer.Status = status
	unlinkOffer(offer)
	sendStatus(offer, status, reason)
end

local function sanitizeSelections(raw: any, playerData: Types.PlayerData): ({ Selection }?, string?)
	if typeof(raw) ~= "table" or #raw > MAX_ITEMS_PER_SIDE then
		return nil, "Invalid item selection"
	end

	local result = {}
	local seen = {}
	for index = 1, #raw do
		local request = raw[index]
		if typeof(request) ~= "table" then
			return nil, "Invalid item selection"
		end

		local container = request.Container
		local uuid = request.UUID
		local amount = request.Amount
		if (container ~= "Inventory" and container ~= "Storage")
			or typeof(uuid) ~= "string"
			or #uuid < 1
			or #uuid > 100
			or not validWholeNumber(amount)
			or amount < 1
		then
			return nil, "Invalid item selection"
		end

		local key = container .. ":" .. uuid
		if seen[key] then
			return nil, "The same item was selected more than once"
		end
		seen[key] = true

		local item = playerData[container][uuid]()
		local info = item and getItemInfo(item)
		if not item or not info or not validWholeNumber(item.Amount) or item.Amount < amount then
			return nil, "An item is no longer available"
		end
		if not info.Data.Stackable and amount ~= 1 then
			return nil, "Invalid equipment quantity"
		end
		if isUUIDInUse(playerData, container, uuid) then
			return nil, "Equipped items cannot be traded"
		end

		table.insert(result, {
			Container = container,
			UUID = uuid,
			Amount = amount,
			Item = copyDeep(item),
		})
	end
	return result, nil
end

local function selectionsStillValid(playerData: Types.PlayerData, selections: { Selection }): (boolean, string?)
	for _, selection in selections do
		local item = playerData[selection.Container][selection.UUID]()
		if not item or not equalDeep(item, selection.Item) or item.Amount < selection.Amount then
			return false, "A selected item changed or is no longer available"
		end
		if isUUIDInUse(playerData, selection.Container, selection.UUID) then
			return false, "A selected item was equipped"
		end
	end
	return true, nil
end

local function validateOffer(offer: Offer): (boolean, string?)
	if workspace:GetServerTimeNow() >= offer.ExpiresAt then
		return false, "The trade offer expired"
	end
	if offer.Sender.Parent ~= Players or offer.Target.Parent ~= Players then
		return false, "A player left the server"
	end

	local senderData = Data[offer.Sender] :: Types.PlayerData
	local targetData = Data[offer.Target] :: Types.PlayerData
	if not senderData or not targetData then
		return false, "Player data is unavailable"
	end
	if not acceptsOffers(targetData) then
		return false, "The receiving player disabled trade offers"
	end
	local senderGold = senderData.Currencies().Gold or 0
	local targetGold = targetData.Currencies().Gold or 0
	if not validWholeNumber(senderGold) or not validWholeNumber(targetGold) then
		return false, "Invalid Gold balance"
	end
	if senderGold < offer.GiveGold or targetGold < offer.ReceiveGold
	then
		return false, "A player no longer has enough Gold"
	end

	local ok, reason = selectionsStillValid(senderData, offer.GiveItems)
	if not ok then
		return false, reason
	end
	return selectionsStillValid(targetData, offer.ReceiveItems)
end

local function publicItems(selections: { Selection })
	local result = {}
	for _, selection in selections do
		local summary = itemSummary(selection.Container, selection.UUID, selection.Item)
		if summary then
			summary.Amount = selection.Amount
			table.insert(result, summary)
		end
	end
	return result
end

local function publicOffer(offer: Offer)
	local senderData = Data[offer.Sender] :: Types.PlayerData
	return {
		Id = offer.Id,
		ExpiresAt = offer.ExpiresAt,
		Sender = {
			Name = offer.Sender.Name,
			DisplayName = offer.Sender.DisplayName,
			UserId = offer.Sender.UserId,
			Level = senderData and senderData.Level() or 0,
		},
		Give = { Gold = offer.GiveGold, Items = publicItems(offer.GiveItems) },
		Receive = { Gold = offer.ReceiveGold, Items = publicItems(offer.ReceiveItems) },
	}
end

local function removeSelections(state, selections: { Selection })
	for _, selection in selections do
		local container = state[selection.Container]
		local item = container[selection.UUID]
		local remaining = item.Amount - selection.Amount
		if remaining == 0 then
			container[selection.UUID] = nil
		else
			item = copyDeep(item)
			item.Amount = remaining
			container[selection.UUID] = item
		end
	end
end

local function sameStack(a: Types.ItemData, b: Types.ItemData): boolean
	local aCopy = copyDeep(a)
	local bCopy = copyDeep(b)
	aCopy.Amount = nil
	bCopy.Amount = nil
	aCopy.Equipped = nil
	bCopy.Equipped = nil
	return equalDeep(aCopy, bCopy)
end

local function addSelections(state, selections: { Selection }): (boolean, string?)
	for _, selection in selections do
		local container = state[selection.Container]
		local info = getItemInfo(selection.Item)
		if not info then
			return false, "Invalid item data"
		end

		local transferItem = copyDeep(selection.Item)
		transferItem.ID = info.Data.ID
		transferItem.Name = info.Data.Name
		transferItem.Equipped = false
		local remaining = selection.Amount
		if info.Data.Stackable then
			local cap = info.Data.Cap or MAX_SAFE_INTEGER
			for uuid, existing in container do
				if remaining <= 0 then
					break
				end
				if existing.ID == transferItem.ID and sameStack(existing, transferItem) and existing.Amount < cap then
					local added = math.min(cap - existing.Amount, remaining)
					local updated = copyDeep(existing)
					updated.Amount += added
					container[uuid] = updated
					remaining -= added
				end
			end
		end

		while remaining > 0 do
			local uuid = Functions:GenUUID()
			while container[uuid] do
				uuid = Functions:GenUUID()
			end
			local item = copyDeep(transferItem)
			item.Amount = info.Data.Stackable and math.min(info.Data.Cap or remaining, remaining) or 1
			container[uuid] = item
			remaining -= item.Amount
		end
	end
	return true, nil
end

local function entryCount(container): number
	local count = 0
	for _ in container do
		count += 1
	end
	return count
end

local function makeState(playerData: Types.PlayerData)
	return {
		Inventory = copyDeep(playerData.Inventory()),
		Storage = copyDeep(playerData.Storage()),
		Gold = playerData.Currencies().Gold or 0,
		MaxInventory = playerData.MaxInventorySpace(),
		MaxStorage = playerData.MaxStorageSpace(),
	}
end

local function buildFinalStates(offer: Offer, senderData: Types.PlayerData, targetData: Types.PlayerData)
	local senderState = makeState(senderData)
	local targetState = makeState(targetData)
	removeSelections(senderState, offer.GiveItems)
	removeSelections(targetState, offer.ReceiveItems)

	local ok, reason = addSelections(targetState, offer.GiveItems)
	if not ok then
		return nil, nil, reason
	end
	ok, reason = addSelections(senderState, offer.ReceiveItems)
	if not ok then
		return nil, nil, reason
	end

	if entryCount(senderState.Inventory) > senderState.MaxInventory
		or entryCount(targetState.Inventory) > targetState.MaxInventory
	then
		return nil, nil, "A backpack does not have enough space"
	end
	if entryCount(senderState.Storage) > senderState.MaxStorage
		or entryCount(targetState.Storage) > targetState.MaxStorage
	then
		return nil, nil, "A storage does not have enough space"
	end

	senderState.Gold = senderState.Gold - offer.GiveGold + offer.ReceiveGold
	targetState.Gold = targetState.Gold - offer.ReceiveGold + offer.GiveGold
	if not validWholeNumber(senderState.Gold) or not validWholeNumber(targetState.Gold) then
		return nil, nil, "The resulting Gold balance is invalid"
	end
	return senderState, targetState, nil
end

local function applyContainer(value, oldContainer, newContainer)
	for uuid in oldContainer do
		if newContainer[uuid] == nil then
			value[uuid](nil)
		end
	end
	for uuid, item in newContainer do
		local old = oldContainer[uuid]
		if not old then
			value[uuid](copyDeep(item))
		elseif old.Amount ~= item.Amount then
			value[uuid].Amount(item.Amount)
		end
	end
end

local function applyState(playerData: Types.PlayerData, state)
	local oldInventory = playerData.Inventory()
	local oldStorage = playerData.Storage()
	applyContainer(playerData.Inventory, oldInventory, state.Inventory)
	applyContainer(playerData.Storage, oldStorage, state.Storage)
	playerData.CurrentInventorySpace(entryCount(state.Inventory))
	playerData.CurrentStorageSpace(entryCount(state.Storage))
	playerData.Currencies.Gold(state.Gold)
end

local function validatePlayerOffers(player: Player)
	ValidationQueued[player] = nil
	local ids = OffersByPlayer[player]
	if not ids then
		return
	end
	local snapshot = {}
	for id in ids do
		table.insert(snapshot, id)
	end
	for _, id in snapshot do
		local offer = Offers[id]
		if offer and offer.Status == "Pending" then
			local ok, reason = validateOffer(offer)
			if not ok then
				closeOffer(offer, "Cancelled", reason or "The offer is no longer valid")
			end
		end
	end
end

local function watchPlayer(player: Player, playerData: Types.PlayerData)
	if Watchers[player] then
		return
	end
	local disconnects = {}
	local function changed()
		if ValidationQueued[player] then
			return
		end
		ValidationQueued[player] = true
		task.defer(validatePlayerOffers, player)
	end
	for _, value in {
		playerData.Inventory,
		playerData.Storage,
		playerData.Equipment,
		playerData.Vanity,
		playerData.Currencies.Gold,
		playerData.Settings["Trade Offers"],
		playerData.MaxInventorySpace,
		playerData.MaxStorageSpace,
	} do
		table.insert(disconnects, value.Changed(changed))
	end
	Watchers[player] = disconnects
end

function TradeSystem:GetCatalog(requester: Player, target: Player)
	local now = os.clock()
	local lastCatalog = LastCatalog[requester]
	if lastCatalog and lastCatalog + CATALOG_COOLDOWN > now then
		return nil, "Please wait before refreshing trade data"
	end
	LastCatalog[requester] = now

	if typeof(target) ~= "Instance" or not target:IsA("Player") or target.Parent ~= Players or target == requester then
		return nil, "Invalid trade target"
	end
	local requesterData = Data.Service:waitForData(requester) :: Types.PlayerData
	local targetData = Data.Service:waitForData(target) :: Types.PlayerData
	if not requesterData or not targetData or requester.Parent ~= Players or target.Parent ~= Players then
		return nil, "Player data is unavailable"
	end
	if not acceptsOffers(targetData) then
		return nil, "This player is not accepting trade offers"
	end
	return {
		Self = catalogFor(requester, requesterData),
		Target = catalogFor(target, targetData),
		OfferLifetime = OFFER_LIFETIME,
	}, nil
end

function TradeSystem:CreateOffer(sender: Player, target: Player, payload: any): (boolean, string)
	local now = os.clock()
	local lastCreate = LastCreate[sender]
	if lastCreate and lastCreate + CREATE_COOLDOWN > now then
		return false, "Please wait before sending another trade offer"
	end
	LastCreate[sender] = now

	if typeof(target) ~= "Instance" or not target:IsA("Player") or target.Parent ~= Players or target == sender then
		return false, "Invalid trade target"
	end
	if typeof(payload) ~= "table" or typeof(payload.Give) ~= "table" or typeof(payload.Receive) ~= "table" then
		return false, "Invalid trade offer"
	end
	if pendingCount(sender) >= MAX_PENDING_PER_PLAYER or pendingCount(target) >= MAX_PENDING_PER_PLAYER then
		return false, "A player has too many pending trade offers"
	end
	for offerId in OffersByPlayer[sender] or {} do
		local existing = Offers[offerId]
		if existing and existing.Status == "Pending" and existing.Sender == sender and existing.Target == target then
			return false, "You already have a pending offer for this player"
		end
	end

	local senderData = Data.Service:waitForData(sender) :: Types.PlayerData
	local targetData = Data.Service:waitForData(target) :: Types.PlayerData
	if not senderData or not targetData or sender.Parent ~= Players or target.Parent ~= Players then
		return false, "Player data is unavailable"
	end
	if not acceptsOffers(targetData) then
		return false, "This player is not accepting trade offers"
	end

	local giveGold = payload.Give.Gold
	local receiveGold = payload.Receive.Gold
	if not validWholeNumber(giveGold) or not validWholeNumber(receiveGold) then
		return false, "Gold must be a non-negative whole number"
	end
	local senderGold = senderData.Currencies().Gold or 0
	local targetGold = targetData.Currencies().Gold or 0
	if not validWholeNumber(senderGold) or not validWholeNumber(targetGold) then
		return false, "Invalid Gold balance"
	end
	if senderGold < giveGold or targetGold < receiveGold then
		return false, "A player does not have enough Gold"
	end

	local giveItems, reason = sanitizeSelections(payload.Give.Items, senderData)
	if not giveItems then
		return false, reason or "Invalid offered items"
	end
	local receiveItems
	receiveItems, reason = sanitizeSelections(payload.Receive.Items, targetData)
	if not receiveItems then
		return false, reason or "Invalid requested items"
	end
	if giveGold == 0 and receiveGold == 0 and #giveItems == 0 and #receiveItems == 0 then
		return false, "A trade offer cannot be empty"
	end

	local createdAt = workspace:GetServerTimeNow()
	local offer: Offer = {
		Id = HttpService:GenerateGUID(false),
		Sender = sender,
		Target = target,
		GiveGold = giveGold,
		ReceiveGold = receiveGold,
		GiveItems = giveItems,
		ReceiveItems = receiveItems,
		CreatedAt = createdAt,
		ExpiresAt = createdAt + OFFER_LIFETIME,
		Status = "Pending",
	}
	linkOffer(offer)
	watchPlayer(sender, senderData)
	watchPlayer(target, targetData)

	RemoteManager.SendClientEvent("TradeOfferReceived", { Player = target }, publicOffer(offer))
	RemoteManager.SendClientEvent("Notification", { Player = sender }, "Trade offer sent to " .. target.Name)

	task.delay(OFFER_LIFETIME, function()
		if Offers[offer.Id] == offer and offer.Status == "Pending" then
			closeOffer(offer, "Expired", "The trade offer expired")
		end
	end)
	return true, "Trade offer sent"
end

function TradeSystem:Respond(player: Player, offerId: any, accept: any): (boolean, string)
	local now = os.clock()
	local lastResponse = LastResponse[player]
	if lastResponse and lastResponse + RESPONSE_COOLDOWN > now then
		return false, "Please wait before responding again"
	end
	LastResponse[player] = now

	if typeof(offerId) ~= "string" or #offerId > 100 or typeof(accept) ~= "boolean" then
		return false, "Invalid trade response"
	end
	local offer = Offers[offerId]
	if not offer or offer.Target ~= player or offer.Status ~= "Pending" then
		return false, "Trade offer is no longer available"
	end
	if not accept then
		closeOffer(offer, "Declined", player.Name .. " declined the trade offer")
		return true, "Trade offer declined"
	end

	-- Status is changed before any mutation, so duplicate accepts cannot enter the commit path.
	offer.Status = "Processing"
	local valid, reason = validateOffer(offer)
	if not valid then
		offer.Status = "Pending"
		closeOffer(offer, "Cancelled", reason or "The trade offer is no longer valid")
		return false, reason or "The trade offer is no longer valid"
	end

	local senderData = Data[offer.Sender] :: Types.PlayerData
	local targetData = Data[offer.Target] :: Types.PlayerData
	local senderBefore = makeState(senderData)
	local targetBefore = makeState(targetData)
	local senderState, targetState
	senderState, targetState, reason = buildFinalStates(offer, senderData, targetData)
	if not senderState or not targetState then
		offer.Status = "Pending"
		closeOffer(offer, "Cancelled", reason or "The trade could not be completed")
		return false, reason or "The trade could not be completed"
	end

	-- Everything above may validate or allocate. The commit below never yields: both loaded
	-- profiles are updated in one scheduler turn, after both final states are fully prepared.
	local committed, commitError = xpcall(function()
		applyState(senderData, senderState)
		applyState(targetData, targetState)
	end, debug.traceback)
	if not committed then
		local senderRolledBack = pcall(applyState, senderData, senderBefore)
		local targetRolledBack = pcall(applyState, targetData, targetBefore)
		warn("Trade commit failed and was rolled back: " .. tostring(commitError))
		if not senderRolledBack and offer.Sender.Parent == Players then
			offer.Sender:Kick("Your trade was stopped safely. Please rejoin.")
		end
		if not targetRolledBack and offer.Target.Parent == Players then
			offer.Target:Kick("Your trade was stopped safely. Please rejoin.")
		end
		offer.Status = "Pending"
		closeOffer(offer, "Cancelled", "The trade could not be committed safely")
		return false, "The trade could not be committed safely"
	end
	offer.Status = "Completed"
	unlinkOffer(offer)
	sendStatus(offer, "Completed", "Trade completed successfully")
	return true, "Trade completed successfully"
end

function TradeSystem:OnPlayerRemoved(player: Player)
	local ids = OffersByPlayer[player]
	if ids then
		local snapshot = {}
		for id in ids do
			table.insert(snapshot, id)
		end
		for _, id in snapshot do
			local offer = Offers[id]
			if offer and offer.Status == "Pending" then
				closeOffer(offer, "Cancelled", player.Name .. " left the server")
			end
		end
	end

	for _, disconnect in Watchers[player] or {} do
		disconnect()
	end
	Watchers[player] = nil
	ValidationQueued[player] = nil
	LastCreate[player] = nil
	LastCatalog[player] = nil
	LastResponse[player] = nil
end

return TradeSystem
