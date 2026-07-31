local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

print("[Preload] Iniciando...")

if not game:IsLoaded() then
	game.Loaded:Wait()
end
print("[Preload] Workspace carregado.")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local WeaponsFolder = Assets:WaitForChild("Weapons")
local AnimationsFolder = Assets:WaitForChild("Animations")

local function PreloadFolder(folder: Instance, label: string)
	local items = folder:GetDescendants()
	print("[Preload] Carregando " .. label .. " (" .. #items .. " itens)...")

	local loaded = 0
	ContentProvider:PreloadAsync(items, function(_assetId, status)
		loaded += 1
		if status == Enum.AssetFetchStatus.Failure then
			warn("[Preload] Falhou ao carregar asset em " .. label .. ": " .. tostring(_assetId))
		end
	end)

	print("[Preload] " .. label .. " concluído (" .. loaded .. "/" .. #items .. ").")
end

PreloadFolder(WeaponsFolder, "Weapons")
PreloadFolder(AnimationsFolder, "Animations")
PreloadFolder(workspace, "Workspace")

print("[Preload] Tudo pronto!")

ReplicatedFirst:RemoveDefaultLoadingScreen()
