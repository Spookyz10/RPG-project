local BodyQuery = {}

-- Walk through nested rig models, but do not turn weapon/accessory geometry into a body.
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
		if radius then
			-- Closest point on the limb bounds to the vertical attack axis.
			local axis = Vector3.new(cf.Position.X, math.clamp(part.Position.Y, cf.Position.Y - size.Y / 2, cf.Position.Y + size.Y / 2), cf.Position.Z)
			local localPoint = part.CFrame:PointToObjectSpace(axis)
			local half = part.Size / 2
			local closest = part.CFrame:PointToWorldSpace(Vector3.new(
				math.clamp(localPoint.X, -half.X, half.X), math.clamp(localPoint.Y, -half.Y, half.Y), math.clamp(localPoint.Z, -half.Z, half.Z)))
			local delta = closest - axis
			if Vector2.new(delta.X, delta.Z).Magnitude > radius then continue end
		end
		found[character] = true
	end
	return found
end

return BodyQuery
