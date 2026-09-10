local Players = game:GetService("Players")
local DSS = game:GetService("DataStoreService")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(RS.Shared.LeaderboardConfig)
local Data = require(RS.Shared.Data).server
local states, stores, names = {}, {}, {}
local closing = false
local folder = Instance.new("Folder")
folder.Name = "LeaderboardSnapshots"
folder.Parent = RS
for id in Config.Boards do
	stores[id] = DSS:GetOrderedDataStore(Config.StorePrefix .. (RunService:IsStudio() and "Studio_" or "") .. id)
	local board = Instance.new("Folder")
	board.Name = id
	board:SetAttribute("Status", "Loading rankings...")
	board.Parent = folder
end

local function flush(userId, state)
	if state.Saving then return end
	state.Saving = true
	for id, value in state.Values do
		if state.Saved[id] == value then continue end
		local ok, err = pcall(function() stores[id]:SetAsync(tostring(userId), value) end)
		if ok then state.Saved[id] = value else warn("[Leaderboards] Save " .. id .. ": " .. tostring(err)) end
	end
	state.Saving = false
	if state.Left then
		local clean = true
		for id, value in state.Values do if state.Saved[id] ~= value then clean = false end end
		if clean then states[userId] = nil end
	end
end

local function joined(player)
	local data = Data.Service:waitForData(player)
	if not data or not player.Parent then return end
	local state = { Values = {}, Saved = {}, Connections = {} }
	states[player.UserId] = state
	names[player.UserId] = player.Name
	for id, definition in Config.Boards do
		local node = data
		for _, key in definition.Path do node = node[key] end
		local function changed(value)
			if typeof(value) == "number" and value == value and value >= 0 and value < math.huge then
				state.Values[id] = math.min(math.floor(value), 9007199254740991)
			end
		end
		changed(node())
		table.insert(state.Connections, node.Changed(changed))
	end
	flush(player.UserId, state)
end

Players.PlayerAdded:Connect(function(player) task.spawn(joined, player) end)
for _, player in Players:GetPlayers() do task.spawn(joined, player) end
Players.PlayerRemoving:Connect(function(player)
	local state = states[player.UserId]
	if not state then return end
	state.Left = true
	for _, connection in state.Connections do
		if typeof(connection) == "RBXScriptConnection" then connection:Disconnect()
		elseif typeof(connection) == "function" then connection() end
	end
	task.spawn(flush, player.UserId, state)
end)

local function refresh(id)
	local board = folder[id]
	local ok, result = pcall(function() return stores[id]:GetSortedAsync(false, Config.Limit):GetCurrentPage() end)
	if not ok then board:SetAttribute("Status", "Temporarily unavailable - retrying soon"); return end
	local rows = {}
	for rank, item in result do
		local userId = tonumber(item.key)
		if not userId or item.value <= 0 then continue end
		local name = names[userId]
		if not name then
			local success, resolved = pcall(function() return Players:GetNameFromUserIdAsync(userId) end)
			name = success and resolved or "User " .. item.key
			if success then names[userId] = name end
		end
		table.insert(rows, { Rank = rank, UserId = userId, Username = name, Value = item.value })
	end
	-- Publish a single payload so clients never observe a partially rebuilt list.
	board:SetAttribute("Rows", game:GetService("HttpService"):JSONEncode(rows))
	board:SetAttribute("UpdatedAt", workspace:GetServerTimeNow())
	board:SetAttribute("Status", #rows == 0 and "Be the first on this leaderboard!" or "Global top " .. Config.Limit)
end

task.spawn(function()
	while not closing do
		task.wait(Config.SaveInterval)
		for userId, state in states do task.spawn(flush, userId, state) end
	end
end)
task.spawn(function()
	while not closing do
		for id in Config.Boards do refresh(id) end
		task.wait(Config.RefreshInterval)
	end
end)
game:BindToClose(function()
	closing = true
	for userId, state in states do task.spawn(flush, userId, state) end
	local deadline = os.clock() + 25
	repeat
		local pending = false
		for userId, state in states do
			for id, value in state.Values do
				if state.Saving or state.Saved[id] ~= value then pending = true; task.spawn(flush, userId, state); break end
			end
		end
		if not pending then break end
		task.wait(1)
	until os.clock() >= deadline
end)
