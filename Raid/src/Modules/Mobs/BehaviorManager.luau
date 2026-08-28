local Behavior = {}

Behavior.Active = {} :: { [Model]: boolean }

function Behavior:Move(Humanoid: Humanoid, Position: Vector3)
	Humanoid:MoveTo(Position)
end

function Behavior:Reset(mobModel: Model)
	if not mobModel then
		return
	end

	self:Cancel(mobModel)

	local UUID = mobModel:FindFirstChild("UUID")
	if not UUID then
		return
	end

	local origin = nil
	local MobSpawns = workspace:FindFirstChild("MobSpawns")
	if MobSpawns then
		for _, spawnPart: BasePart in MobSpawns:GetDescendants() do
			local ID = spawnPart:FindFirstChild("ID")
			if not ID then
				continue
			end

			if ID.Value == UUID.Value then
				origin = spawnPart
				break
			end
		end
	end

	if origin then
		local Humanoid = mobModel:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			Humanoid.Health = Humanoid.MaxHealth
			Humanoid.WalkSpeed = 16
		end

		mobModel:PivotTo(origin.CFrame)
	end
end

function Behavior:Cancel(mobModel: Model)
	if mobModel and Behavior.Active[mobModel] then
		Behavior.Active[mobModel] = nil
	end
end

return Behavior
