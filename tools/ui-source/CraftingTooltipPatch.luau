return function()
	local crafting = StarterGui:FindFirstChild("Crafting")
	assert(crafting and crafting:IsA("ScreenGui"), "StarterGui.Crafting must exist before installing its item tooltip.")
	local existing = crafting:FindFirstChild("ItemTooltip")
	if existing then
		Selection:Set({ existing })
		print("Crafting already has an ItemTooltip; nothing was replaced.")
		return
	end
	local inventory = StarterGui:FindFirstChild("Inventory")
	local source = inventory and inventory:FindFirstChild("ItemTooltip")
	assert(source and source:IsA("GuiObject"), "StarterGui.Inventory.ItemTooltip is required as the visual source.")
	local tooltip = source:Clone()
	tooltip.Name = "ItemTooltip"
	tooltip.Visible = false
	tooltip.Parent = crafting
	Selection:Set({ tooltip })
	print("Crafting ItemTooltip installed without replacing the Crafting screen.")
end
