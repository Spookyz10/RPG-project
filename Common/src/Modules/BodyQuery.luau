local BodyQuery = {}

function BodyQuery.Resolve(part)
	if not part:IsA("BasePart") or part.Name == "Hitbox" then return nil end
	local ancestor = part.Parent
	while ancestor and ancestor ~= workspace do
		if ancestor:IsA("Accessory") or ancestor:IsA("Tool") then return nil end
		if ancestor:IsA("Model") then
			local humanoid = ancestor:FindFirstChildOfClass("Humanoid")
			if humanoid then return humanoid.Health > 0 and ancestor or nil end
		end
		ancestor = ancestor.Parent
	end
	return nil
end

function BodyQuery.PlayersInVolume(cf, size, radius)
	local players = game:GetService("Players")
	local filter = OverlapParams.new()
	filter.FilterType = Enum.RaycastFilterType.Include
	local characters = {}
	for _, player in players:GetPlayers() do
		if player.Character then table.insert(characters, player.Character) end
	end
	filter.FilterDescendantsInstances = characters
	local found = {}
	for _, part in workspace:GetPartBoundsInBox(cf, size, filter) do
		local character = BodyQuery.Resolve(part)
		if not character or not players:GetPlayerFromCharacter(character) then continue end
		found[character] = true
	end
	if radius then
		-- The box above is only a broad-phase query. Resolve circular attacks from
		-- each character's authoritative body position so the box corners cannot hit.
		local radiusSquared = radius * radius
		for character in found do
			local root = character:FindFirstChild("HumanoidRootPart")
			if not root or not root:IsA("BasePart") then
				found[character] = nil
				continue
			end
			local offset = root.Position - cf.Position
			if offset.X * offset.X + offset.Z * offset.Z > radiusSquared then
				found[character] = nil
			end
		end
	end
	return found
end

return BodyQuery
