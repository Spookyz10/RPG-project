local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Assets = ReplicatedStorage:WaitForChild("Assets")
local WeaponsFolder = Assets:WaitForChild("Weapons")
local AnimationsFolder = Assets:WaitForChild("Animations")

local function PreloadFolder(folder: Instance, label: string)
	local items = folder:GetDescendants()

	local loaded = 0
	ContentProvider:PreloadAsync(items, function(_assetId, _)
		loaded += 1
	end)
end

PreloadFolder(WeaponsFolder, "Weapons")
PreloadFolder(AnimationsFolder, "Animations")
PreloadFolder(workspace, "Workspace")

ReplicatedFirst:RemoveDefaultLoadingScreen()
