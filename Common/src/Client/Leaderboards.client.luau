local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local Config = require(RS.Shared.LeaderboardConfig)
local screen = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Leaderboards")
local snapshots = RS:WaitForChild("LeaderboardSnapshots")
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
	local function render()
		main.Status.Text = board:GetAttribute("Status") or "Loading rankings..."
		local payload = board:GetAttribute("Rows")
		if not payload then return end
		local ok, rows = pcall(Http.JSONDecode, Http, payload)
		if not ok then return end
		for _, child in main.Rows:GetChildren() do if child:IsA("GuiObject") then child:Destroy() end end
		for _, entry in rows do
			local row = main.RowTemplate:Clone()
			row.Name = tostring(entry.UserId)
			row.LayoutOrder = entry.Rank
			row.Rank.Text = "#" .. entry.Rank
			row.Username.Text = entry.Username
			row.Value.Text = id == "PlayTime" and string.format("%dh %02dm", math.floor(entry.Value / 3600), math.floor(entry.Value / 60) % 60) or tostring(entry.Value)
			row.Rank.TextColor3 = entry.Rank == 1 and Color3.fromRGB(255,208,81) or Color3.fromRGB(191,197,215)
			row.Visible = true
			row.Parent = main.Rows
		end
	end
	board:GetAttributeChangedSignal("Rows"):Connect(render)
	board:GetAttributeChangedSignal("Status"):Connect(render)
	render()
end
