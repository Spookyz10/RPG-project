local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Items = require(RS.Shared.ItemsDataByName)
local Theme = require(RS.Shared.UI.Theme)
local WorldLoot = require(RS.Shared.WorldLoot)
local Remote = {}
local sequence = 0
local ranks = {Common = 1, Uncommon = 2, Rare = 3, Legendary = 4, Godly = 5, Ascendant = 6}
local function tween(obj, duration, props, style)
	local result = TweenService:Create(obj, TweenInfo.new(duration, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	result:Play()
	return result
end
local function present(gui, name, amount, order)
	local data = Items[name] and Items[name].Data or {}
	local rarity = data.Rarity or "Common"
	local color = Theme.Rarities[rarity] or Theme.Gold
	local card = gui.Card:Clone()
	card.Name = "ActiveReward"
	card.LayoutOrder = order
	card.Rarity.Text = string.upper(rarity) .. " DROP"
	card.Rarity.TextColor3 = color; card.UIStroke.Color = color
	card.Icon.Image = data.Icon or ""
	card.ItemName.Text = data.Name or name
	card.Amount.Text = "+" .. amount .. " - Added to inventory"
	card.GroupTransparency = 1; card.Pop.Scale = 0.65; card.Visible = true; card.Parent = gui.List
	Debris:AddItem(card, 5)
	local strokes = {}
	for _, child in card:GetDescendants() do
		if child:IsA("UIStroke") then
			strokes[child] = child.Transparency
			child.Transparency = 1
		end
	end
	for stroke, transparency in strokes do tween(stroke, 0.16, {Transparency = transparency}) end
	tween(card, 0.16, {GroupTransparency = 0})
	game:GetService("RunService").RenderStepped:Wait()
	gui.List.CanvasPosition = Vector2.new(0, math.max(0, gui.List.AbsoluteCanvasSize.Y - gui.List.AbsoluteWindowSize.Y))
	tween(card.Pop, 0.38, {Scale = 1}, Enum.EasingStyle.Back)
	tween(card.Shine, 0.65, {Position = UDim2.fromScale(1.2, 0)})
	local count = (ranks[rarity] or 1) >= 3 and 18 or 10
	for i = 1, count do
		local spark = gui.Spark:Clone()
		spark.Name = "RewardSpark"; spark.Visible = true; spark.BackgroundColor3 = color
		local center = card.AbsolutePosition + card.AbsoluteSize / 2
		spark.Position = UDim2.fromScale(center.X / math.max(1, gui.AbsoluteSize.X), center.Y / math.max(1, gui.AbsoluteSize.Y)); spark.Parent = gui
		local angle = i / count * math.pi * 2
		tween(spark, 0.6, {Position = spark.Position + UDim2.fromScale(math.cos(angle) * 0.16, math.sin(angle) * 0.1), Rotation = i * 45, BackgroundTransparency = 1})
		Debris:AddItem(spark, 0.7)
	end
	task.wait((ranks[rarity] or 1) >= 3 and 1.8 or 1.25)
	if card.Parent then
		for stroke in strokes do if stroke.Parent then tween(stroke, 0.24, {Transparency = 1}) end end
		tween(card, 0.24, {GroupTransparency = 1})
		task.wait(0.24); card:Destroy()
	end
end
function Remote:Activate(items, origin)
	if typeof(items) ~= "table" then return end
	if typeof(origin) == "Vector3" then WorldLoot.Play(items, origin) end
	local gui = Players.LocalPlayer.PlayerGui:FindFirstChild("LootRewards")
	if not gui or not gui:FindFirstChild("List") then
		warn("Run the updated 24_LootRewards generator in Edit mode.")
		return
	end
	local names = {}
	for name, amount in items do
		if typeof(name) == "string" and typeof(amount) == "number" and amount > 0 then table.insert(names, name) end
	end
	table.sort(names)
	for _, name in names do
		sequence += 1
		local order = sequence
		task.spawn(function()
			local ok, err = pcall(present, gui, name, items[name], order)
			if not ok then warn("Loot presentation: " .. tostring(err)) end
		end)
	end
end
return Remote
