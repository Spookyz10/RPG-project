local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Abbreviation = require(ReplicatedStorage.Shared.Utils.Abbreviation)
local RemoteManager = require(ReplicatedStorage.Shared.Utils.RemoteManager)
local Theme = require(script.Parent.Parent.Theme)
local Toast = require(script.Parent.Parent.Toast)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)
local Windows = require(script.Parent.Parent.WindowManager)

local Trading = {}

local Screen: ScreenGui
local Root: Frame
local Composer: Frame
local Viewer: Frame
local Confirmation: Frame
local Quantity: Frame
local OfferSummary: Frame
local OfferQueue: ScrollingFrame
local OfferTemplate: CanvasGroup
local ItemTemplate: TextButton
local OfferItemTemplate: TextButton

local Catalog = nil
local Target: Player? = nil
local RequestToken = 0
local CurrentOfferId: string? = nil
local Offers = {}
local OfferCards = {}
local Selected = { Give = {}, Receive = {} }
local ActiveTabs = { Give = "Inventory", Receive = "Inventory" }
local PendingQuantity = nil

local function selectionKey(item): string
	return item.Container .. ":" .. item.UUID
end

local function clearChildren(container: Instance)
	for _, child in container:GetChildren() do
		if child:IsA("GuiButton") then
			child:Destroy()
		end
	end
end

local function setSelectionVisible(button: GuiButton, visible: boolean)
	-- "Selected" is also a GuiButton boolean property, so use child lookup for
	-- compatibility with already-generated UIs and "Selection" for new ones.
	local selection = button:FindFirstChild("Selection") or button:FindFirstChild("Selected")
	if selection and selection:IsA("GuiObject") then
		selection.Visible = visible
	end
end

local function packageText(package): string
	local lines = {}
	if (package.Gold or 0) > 0 then
		table.insert(lines, Abbreviation:Number(package.Gold) .. " Gold")
	end
	for _, item in package.Items or {} do
		local source = item.Container == "Storage" and "Storage" or "Backpack"
		table.insert(lines, "x" .. Abbreviation:Number(item.Amount) .. " " .. item.Name .. "  [" .. source .. "]")
	end
	return #lines > 0 and table.concat(lines, "\n") or "Nothing"
end

local function selectedPackage(side: string)
	local items = {}
	for _, item in Selected[side] do
		table.insert(items, item)
	end
	table.sort(items, function(a, b)
		return a.Name == b.Name and a.UUID < b.UUID or a.Name < b.Name
	end)
	local goldBox = side == "Give" and Composer.Mine.Gold or Composer.Theirs.Gold
	local gold = tonumber(goldBox.Text) or 0
	return { Gold = gold, Items = items }
end

local populateSide

local function updateOfferGold(side: string)
	local source = side == "Give" and Composer.Mine or Composer.Theirs
	local amount = tonumber(source.Gold.Text)
	OfferSummary[side].Gold.Text = Abbreviation:Number(amount and math.max(0, amount) or 0) .. " GOLD"
end

local function refreshSelection(side: string)
	local panel = OfferSummary[side]
	clearChildren(panel.Items)

	local selectedItems = {}
	for _, item in Selected[side] do
		table.insert(selectedItems, item)
	end
	table.sort(selectedItems, function(a, b)
		return a.Name == b.Name and a.UUID < b.UUID or a.Name < b.Name
	end)

	for index, item in selectedItems do
		local key = selectionKey(item)
		local button = OfferItemTemplate:Clone()
		button.Name = key
		button.LayoutOrder = index
		button.Visible = true
		button.Icon.Image = item.Icon or ""
		button.ItemName.Text = item.Name
		button.Amount.Text = "x" .. Abbreviation:Number(item.Amount)
		button.Source.Text = item.Container == "Storage" and "STORAGE" or "BACKPACK"
		UIFunctions:ApplyRarity(button, item.Rarity)
		button.Activated:Connect(function()
			Selected[side][key] = nil
			refreshSelection(side)
			populateSide(side)
		end)
		button.Parent = panel.Items
	end

	panel.Count.Text = #selectedItems .. (#selectedItems == 1 and " ITEM" or " ITEMS")
	panel.Empty.Visible = #selectedItems == 0
	updateOfferGold(side)
end

local function refreshOfferSummary()
	refreshSelection("Give")
	refreshSelection("Receive")
end

local function updateTabButtons(side: string)
	local panel = side == "Give" and Composer.Mine or Composer.Theirs
	for _, containerName in { "Inventory", "Storage" } do
		panel.Tabs[containerName].BackgroundColor3 = ActiveTabs[side] == containerName and Theme.Sky or Theme.Soft
	end
end

populateSide = function(side: string)
	if not Catalog then
		return
	end
	local panel = side == "Give" and Composer.Mine or Composer.Theirs
	local source = side == "Give" and Catalog.Self or Catalog.Target
	local containerName = ActiveTabs[side]
	clearChildren(panel.Items)
	local count = 0
	for index, item in source[containerName] or {} do
		local button = ItemTemplate:Clone()
		button.Name = item.UUID
		button.LayoutOrder = index
		button.Visible = true
		button.Icon.Image = item.Icon or ""
		button.ItemName.Text = item.Name
		local selected = Selected[side][selectionKey(item)]
		button.Amount.Text = selected and ("x" .. Abbreviation:Number(selected.Amount) .. " SELECTED")
			or ("x" .. Abbreviation:Number(item.Amount))
		button.Source.Text = containerName == "Storage" and "STORAGE" or "BACKPACK"
		UIFunctions:ApplyRarity(button, item.Rarity)
		local key = selectionKey(item)
		setSelectionVisible(button, selected ~= nil)
		button.Activated:Connect(function()
			if Selected[side][key] then
				Selected[side][key] = nil
				setSelectionVisible(button, false)
				button.Amount.Text = "x" .. Abbreviation:Number(item.Amount)
				refreshSelection(side)
			elseif item.Amount > 1 then
				PendingQuantity = { Side = side, Item = item, Button = button }
				Quantity.Title.Text = side == "Give" and "QUANTITY TO GIVE" or "QUANTITY TO REQUEST"
				Quantity.Item.Text = item.Name .. "  (max " .. Abbreviation:Number(item.Amount) .. ")"
				Quantity.Amount.Text = tostring(item.Amount)
				Quantity.Visible = true
			else
				Selected[side][key] = item
				setSelectionVisible(button, true)
				button.Amount.Text = "x1 SELECTED"
				refreshSelection(side)
			end
		end)
		button.Parent = panel.Items
		count += 1
	end
	panel.Empty.Visible = count == 0
	updateTabButtons(side)
end

local function setTab(side: string, containerName: string)
	ActiveTabs[side] = containerName
	populateSide(side)
end

local function normalizeGold(box: TextBox, maximum: number): number?
	local amount = tonumber(box.Text)
	if
		not amount
		or amount ~= amount
		or amount == math.huge
		or amount == -math.huge
		or amount < 0
		or amount % 1 ~= 0
	then
		Toast.Show("Gold must be a non-negative whole number.")
		return nil
	end
	if amount > maximum then
		Toast.Show("That player does not have enough Gold.")
		return nil
	end
	box.Text = tostring(amount)
	return amount
end

local function resetComposer()
	table.clear(Selected.Give)
	table.clear(Selected.Receive)
	ActiveTabs.Give = "Inventory"
	ActiveTabs.Receive = "Inventory"
	Composer.Mine.Gold.Text = "0"
	Composer.Theirs.Gold.Text = "0"
	Composer.Mine.Balance.Text = "LOADING BALANCE"
	Composer.Theirs.Balance.Text = "LOADING BALANCE"
	Confirmation.Visible = false
	Quantity.Visible = false
	PendingQuantity = nil
	Viewer.Visible = false
	Composer.Visible = true
	refreshOfferSummary()
end

local function reviewOffer()
	if not Catalog then
		return
	end
	local giveGold = normalizeGold(Composer.Mine.Gold, Catalog.Self.Gold)
	local receiveGold = normalizeGold(Composer.Theirs.Gold, Catalog.Target.Gold)
	if giveGold == nil or receiveGold == nil then
		return
	end
	local give = selectedPackage("Give")
	local receive = selectedPackage("Receive")
	if giveGold == 0 and receiveGold == 0 and #give.Items == 0 and #receive.Items == 0 then
		Toast.Show("Choose at least one item or some Gold.")
		return
	end
	Confirmation.Summary.Text = "YOU WILL GIVE\n"
		.. packageText(give)
		.. "\n\nYOU WILL RECEIVE\n"
		.. packageText(receive)
	Confirmation.Visible = true
end

local function wirePackage(package)
	local items = {}
	for _, item in package.Items do
		table.insert(items, {
			Container = item.Container,
			UUID = item.UUID,
			Amount = item.Amount,
		})
	end
	return { Gold = package.Gold, Items = items }
end

local function sendOffer()
	if not Catalog or not Target or Target.Parent ~= Players then
		Toast.Show("That player is no longer available.")
		return
	end
	local give = selectedPackage("Give")
	local receive = selectedPackage("Receive")
	RemoteManager.SendServerEvent("CreateTradeOffer", Target, {
		Give = wirePackage(give),
		Receive = wirePackage(receive),
	})
	Confirmation.Visible = false
	Windows.CloseScreen("Trading")
end

local function removeOfferCard(offerId: string)
	local card = OfferCards[offerId]
	if card then
		card:Destroy()
		OfferCards[offerId] = nil
	end
end

local function showOffer(offer)
	CurrentOfferId = offer.Id
	Composer.Visible = false
	Confirmation.Visible = false
	Viewer.Visible = true
	Viewer.Sender.PlayerName.Text = offer.Sender.DisplayName .. "  @" .. offer.Sender.Name
	Viewer.Sender.Level.Text = "LEVEL " .. Abbreviation:Number(offer.Sender.Level)
	Viewer.Sender.Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. offer.Sender.UserId .. "&w=150&h=150"
	Viewer.Receive.Summary.Text = packageText(offer.Give)
	Viewer.Give.Summary.Text = packageText(offer.Receive)
	Windows.Open("Trading")
	task.spawn(function()
		while CurrentOfferId == offer.Id and Viewer.Visible and Offers[offer.Id] do
			local remaining = math.max(0, math.ceil(offer.ExpiresAt - workspace:GetServerTimeNow()))
			Viewer.Expires.Text = "Offer expires in " .. remaining .. "s"
			if remaining <= 0 then
				break
			end
			task.wait(1)
		end
	end)
end

function Trading.Open(target: Player)
	if not Root or not target or target == UIConstants.Player or target.Parent ~= Players then
		return
	end
	RequestToken += 1
	local token = RequestToken
	Target = target
	Catalog = nil
	resetComposer()
	Composer.Target.Text = "Loading trade with " .. target.Name .. "..."
	Windows.Open("Trading")
	local ok, catalog, reason = pcall(function()
		return RemoteManager.InvokeServerFunction("GetTradeCatalog", target)
	end)
	if token ~= RequestToken or not Root.Visible then
		return
	end
	if not ok or not catalog then
		Toast.Show(reason or "Trade data is unavailable.")
		Windows.CloseScreen("Trading")
		return
	end
	Catalog = catalog
	Composer.Target.Text = "Trading with " .. catalog.Target.DisplayName .. "  @" .. catalog.Target.Name
	Composer.Mine.Balance.Text = Abbreviation:Number(catalog.Self.Gold) .. " GOLD AVAILABLE"
	Composer.Theirs.Balance.Text = Abbreviation:Number(catalog.Target.Gold) .. " GOLD AVAILABLE"
	populateSide("Give")
	populateSide("Receive")
	refreshOfferSummary()
end

function Trading.OnOfferReceived(offer)
	if typeof(offer) ~= "table" or typeof(offer.Id) ~= "string" or typeof(offer.Sender) ~= "table" then
		return
	end
	Offers[offer.Id] = offer
	removeOfferCard(offer.Id)
	local card = OfferTemplate:Clone()
	card.Name = "Offer_" .. offer.Id
	card.Visible = true
	card.PlayerName.Text = offer.Sender.DisplayName .. " sent a trade offer"
	card.Level.Text = "LEVEL " .. Abbreviation:Number(offer.Sender.Level)
	card.Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. offer.Sender.UserId .. "&w=150&h=150"
	card.Ignore.Activated:Connect(function()
		removeOfferCard(offer.Id)
	end)
	card.View.Activated:Connect(function()
		if Offers[offer.Id] then
			showOffer(offer)
		end
	end)
	card.Parent = OfferQueue
	OfferCards[offer.Id] = card
	task.spawn(function()
		while card.Parent and Offers[offer.Id] do
			local remaining = math.max(0, math.ceil(offer.ExpiresAt - workspace:GetServerTimeNow()))
			card.Expires.Text = "Expires in " .. remaining .. "s"
			if remaining <= 0 then
				break
			end
			task.wait(1)
		end
	end)
end

function Trading.OnOfferStatus(offerId: string, status: string, reason: string)
	removeOfferCard(offerId)
	Offers[offerId] = nil
	if CurrentOfferId == offerId then
		CurrentOfferId = nil
		Viewer.Visible = false
		Windows.CloseScreen("Trading")
	end
	if status ~= "Sent" then
		Toast.Show(reason or ("Trade " .. string.lower(status)))
	end
end

function Trading.Init()
	Screen = UIConstants.PlayerGui:WaitForChild("Trading") :: ScreenGui
	Root = Screen:WaitForChild("Main") :: Frame
	Composer = Root:WaitForChild("Composer") :: Frame
	Viewer = Root:WaitForChild("Viewer") :: Frame
	Confirmation = Root:WaitForChild("Confirmation") :: Frame
	Quantity = Root:WaitForChild("Quantity") :: Frame
	OfferSummary = Composer:WaitForChild("OfferSummary") :: Frame
	OfferQueue = Screen:WaitForChild("OfferQueue") :: ScrollingFrame
	OfferTemplate = OfferQueue:WaitForChild("OfferTemplate") :: CanvasGroup
	ItemTemplate = Screen:WaitForChild("ItemTemplate") :: TextButton
	OfferItemTemplate = Screen:WaitForChild("OfferItemTemplate") :: TextButton

	for side, panel in { Give = Composer.Mine, Receive = Composer.Theirs } do
		panel.Tabs.Inventory.Activated:Connect(function()
			setTab(side, "Inventory")
		end)
		panel.Tabs.Storage.Activated:Connect(function()
			setTab(side, "Storage")
		end)
	end
	Composer.Review.Activated:Connect(reviewOffer)
	Composer.Mine.Gold:GetPropertyChangedSignal("Text"):Connect(function()
		updateOfferGold("Give")
	end)
	Composer.Theirs.Gold:GetPropertyChangedSignal("Text"):Connect(function()
		updateOfferGold("Receive")
	end)
	Confirmation.Cancel.Activated:Connect(function()
		Confirmation.Visible = false
	end)
	Confirmation.Send.Activated:Connect(sendOffer)
	Quantity.Cancel.Activated:Connect(function()
		Quantity.Visible = false
		PendingQuantity = nil
	end)
	Quantity.Add.Activated:Connect(function()
		local pending = PendingQuantity
		if not pending then
			Quantity.Visible = false
			return
		end
		local amount = tonumber(Quantity.Amount.Text)
		if not amount or amount ~= amount or amount < 1 or amount > pending.Item.Amount or amount % 1 ~= 0 then
			Toast.Show("Enter a whole quantity between 1 and " .. pending.Item.Amount .. ".")
			return
		end
		local selected = table.clone(pending.Item)
		selected.Amount = amount
		Selected[pending.Side][selectionKey(pending.Item)] = selected
		setSelectionVisible(pending.Button, true)
		pending.Button.Amount.Text = "x" .. Abbreviation:Number(amount) .. " SELECTED"
		refreshSelection(pending.Side)
		Quantity.Visible = false
		PendingQuantity = nil
	end)
	Viewer.Accept.Activated:Connect(function()
		if CurrentOfferId then
			RemoteManager.SendServerEvent("RespondTradeOffer", CurrentOfferId, true)
		end
	end)
	Viewer.Decline.Activated:Connect(function()
		if CurrentOfferId then
			RemoteManager.SendServerEvent("RespondTradeOffer", CurrentOfferId, false)
		end
	end)
	Root:GetPropertyChangedSignal("Visible"):Connect(function()
		if not Root.Visible then
			RequestToken += 1
			Confirmation.Visible = false
			Quantity.Visible = false
			PendingQuantity = nil
			Viewer.Visible = false
			CurrentOfferId = nil
		end
	end)

	OfferTemplate.Visible = false
	ItemTemplate.Visible = false
	OfferItemTemplate.Visible = false
	Root.Visible = false
end

return Trading
