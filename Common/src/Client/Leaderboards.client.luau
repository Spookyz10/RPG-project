local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local Config = require(RS.Shared.LeaderboardConfig)
local screen = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Leaderboards")
local snapshots = RS:WaitForChild("LeaderboardSnapshots")
local template = RS:WaitForChild("RPGUITemplates"):WaitForChild("Leaderboard")
local labels = {Gold = "Gold", Kills = "Kills", Donations = "Donated", PlayTime = "Play time"}
local colors = {
	Gold = Color3.fromRGB(255, 208, 81), Kills = Color3.fromRGB(255, 0, 0),
	Donations = Color3.fromRGB(15, 218, 0), PlayTime = Color3.fromRGB(76, 184, 255),
}
local thumbnails = {}
local function formatValue(id, value)
	if id == "PlayTime" then return string.format("%dh %02dm", math.floor(value / 3600), math.floor(value / 60) % 60) end
	if value >= 1000000 then return string.format("%.1fM", value / 1000000) end
	if value >= 1000 then return string.format("%.1fK", value / 1000) end
	return tostring(value)
end
local function applyRank(row, rank)
	-- Only toggle the saved gradients; their colors and sequences stay editable.
	for _, style in row:GetDescendants() do
		if style:IsA("UIGradient") then
			if style.Name == "Basic" then style.Enabled = rank > 3
			elseif style.Name == "Top1" then style.Enabled = rank == 1
			elseif style.Name == "Top2" then style.Enabled = rank == 2
			elseif style.Name == "Top3" then style.Enabled = rank == 3 end
		end
	end
end
local function bind()
	local models = workspace:FindFirstChild("Leaderboards")
	for id in Config.Boards do
		local model = models and models:FindFirstChild(id)
		local img = model and model:FindFirstChild("IMG", true)
		screen[id].Adornee = img and img:IsA("BasePart") and img or nil
	end
end
workspace.DescendantAdded:Connect(function(object) if object.Name == "IMG" or object.Name == "Leaderboards" then bind() end end)
bind()
for id in Config.Boards do
	local board = snapshots:WaitForChild(id)
	local main = screen[id].Main
	local renderVersion = 0
	local lastPayload
	local function render()
		main.Status.Text = board:GetAttribute("Status") or "Loading rankings..."
		local payload = board:GetAttribute("Rows")
		if not payload then return end
		if payload == lastPayload then return end
		local ok, rows = pcall(Http.JSONDecode, Http, payload)
		if not ok or typeof(rows) ~= "table" then return end
		lastPayload = payload
		renderVersion += 1
		local version = renderVersion
		for _, child in main.Rows:GetChildren() do if child:IsA("GuiObject") then child:Destroy() end end
		for _, entry in rows do
			local row = template:Clone()
			row.Name = tostring(entry.UserId)
			row.LayoutOrder = entry.Rank
			applyRank(row, entry.Rank)
			row.PlayerName.Text = entry.Username
			local rankLabel = row:FindFirstChild("Rank", true)
			if rankLabel and rankLabel:IsA("TextLabel") then rankLabel.Text = "#" .. entry.Rank end
			row.Stat.RichText = true
			row.Stat.TextColor3 = colors[id]
			row.Stat.Text = labels[id] .. ':<br/><font color="rgb(255,255,255)">' .. formatValue(id, entry.Value) .. '</font>'
			row.Visible = true
			row.Parent = main.Rows
			-- Thumbnail requests yield, so they must never interrupt row creation.
			task.spawn(function()
				local image = thumbnails[entry.UserId]
				if not image then
					local success, result, ready = pcall(Players.GetUserThumbnailAsync, Players, entry.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
					if success then image = result; if ready then thumbnails[entry.UserId] = result end end
				end
				if image and row.Parent and renderVersion == version then row.Player.Image = image end
			end)
		end
	end
	board:GetAttributeChangedSignal("Rows"):Connect(render)
	board:GetAttributeChangedSignal("Status"):Connect(render)
	render()
end
