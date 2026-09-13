assert(not game:GetService("RunService"):IsRunning(), "Stop Play before generating the UI.")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Selection = game:GetService("Selection")
local History = game:GetService("ChangeHistoryService")
local build = (function()
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
end)()
local recording
pcall(function() recording = History:TryBeginRecording("ApplyRPGUIPatch", "Apply RPG UI patch") end)
local ok, reason = pcall(build)
if recording then
    History:FinishRecording(recording, ok and Enum.FinishRecordingOperation.Commit or Enum.FinishRecordingOperation.Cancel)
end
if not ok then error("UI patch failed: " .. tostring(reason)) end
