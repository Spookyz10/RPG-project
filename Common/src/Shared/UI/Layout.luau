-- Studio owns positions, sizes and grid settings, on every device.
-- Optional tabs only change visibility when explicitly activated by the player.
local Layout = {}
local bound = setmetatable({}, { __mode = "k" })

function Layout.Bind(screen)
	if bound[screen] then return end
	bound[screen] = true
	local root = screen:FindFirstChild("Main")
	local body = root and root:FindFirstChild("Body")
	local content = body and body:FindFirstChild("Content")
	local tabs = content and content:FindFirstChild("MobileTabs")
	if not tabs then return end
	local connections = {}
	for _, entry in { { "Character", "Hero" }, { "Bag", "Items" } } do
		table.insert(connections, tabs[entry[1]].Activated:Connect(function()
			if not tabs.Visible then return end
			content.Hero.Visible = entry[2] == "Hero"
			content.Items.Visible = entry[2] == "Items"
		end))
	end
	screen.Destroying:Connect(function()
		for _, connection in connections do connection:Disconnect() end
	end)
end

return Layout
