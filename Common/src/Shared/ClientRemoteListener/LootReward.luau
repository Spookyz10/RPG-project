local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Items = require(RS.Shared.ItemsDataByName)
local Theme = require(RS.Shared.UI.Theme)
local WorldLoot = require(RS.Shared.WorldLoot)
local Remote = {}
local pending = {}
local running = false
local ranks = {Common = 1, Uncommon = 2, Rare = 3, Legendary = 4, Godly = 5, Ascendant = 6}
local function tween(obj, duration, props, style)
	local result = TweenService:Create(obj, TweenInfo.new(duration, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	result:Play()
	return result
end
local function present(gui, name, amount, slot)
	local data = Items[name] and Items[name].Data or {}
	local rarity = data.Rarity or "Common"
	local color = Theme.Rarities[rarity] or Theme.Gold
	local card = gui.Card:Clone()
	card.Name = "ActiveReward"
	card.Position = UDim2.fromScale(0.5, 0.43 + (slot - 1) * 0.2)
	card.Rarity.Text = string.upper(rarity) .. " DROP"
	card.Rarity.TextColor3 = color; card.UIStroke.Color = color
	card.Icon.Image = data.Icon or ""
	card.ItemName.Text = data.Name or name
	card.Amount.Text = "+" .. amount .. "  •  Added to inventory"
	card.GroupTransparency = 1; card.Pop.Scale = 0.65; card.Visible = true; card.Parent = gui
	Debris:AddItem(card, 5)
	tween(card, 0.16, {GroupTransparency = 0})
	tween(card.Pop, 0.38, {Scale = 1}, Enum.EasingStyle.Back)
	tween(card.Shine, 0.65, {Position = UDim2.fromScale(1.2, 0)})
	local count = (ranks[rarity] or 1) >= 3 and 18 or 10
	for i = 1, count do
		local spark = gui.Spark:Clone()
		spark.Name = "RewardSpark"; spark.Visible = true; spark.BackgroundColor3 = color
		spark.Position = card.Position; spark.Parent = gui
		local angle = i / count * math.pi * 2
		tween(spark, 0.6, {Position = card.Position + UDim2.fromScale(math.cos(angle) * 0.16, math.sin(angle) * 0.1), Rotation = i * 45, BackgroundTransparency = 1})
		Debris:AddItem(spark, 0.7)
	end
	task.wait((ranks[rarity] or 1) >= 3 and 1.8 or 1.25)
	if card.Parent then
		tween(card, 0.24, {GroupTransparency = 1, Position = card.Position - UDim2.fromScale(0, 0.035)})
		task.wait(0.24); card:Destroy()
	end
end
function Remote:Activate(items, origin)
	if typeof(items) ~= "table" then return end
	for name, amount in items do
		if typeof(name) == "string" and typeof(amount) == "number" and amount > 0 then
			pending[name] = (pending[name] or 0) + amount
		end
	end
	if typeof(origin) == "Vector3" then WorldLoot.Play(items, origin) end
	if running then return end
	running = true
	task.spawn(function()
		local gui = Players.LocalPlayer.PlayerGui:FindFirstChild("LootRewards")
		if not gui then
			warn("Run 24_LootRewards in Studio Edit mode to enable drop animations.")
			table.clear(pending); running = false; return
		end
		while next(pending) and gui.Parent do
			local names = {}
			for name in pending do table.insert(names, name) end
			table.sort(names, function(a, b)
				local ra = ranks[Items[a] and Items[a].Data.Rarity] or 1
				local rb = ranks[Items[b] and Items[b].Data.Rarity] or 1
				return ra == rb and a < b or ra > rb
			end)
			local remaining = math.min(3, #names)
			for slot = 1, remaining do
				local name = names[slot]; local amount = pending[name]; pending[name] = nil
				task.spawn(function()
					local ok, err = pcall(present, gui, name, amount, slot)
					if not ok then warn("Loot presentation: " .. tostring(err)) end
					remaining -= 1
				end)
			end
			repeat task.wait(0.05) until remaining == 0
		end
		table.clear(pending); running = false
	end)
end
return Remote
