local Behavior = {}

Behavior.Active = {} :: { [Model]: boolean }

function Behavior:Move(Humanoid: Humanoid, Position: Vector3)
	Humanoid:MoveTo(Position)
end

function Behavior:Reset(mobModel: Model)
	if not mobModel then
		return
	end

	local UUID = mobModel:FindFirstChild("UUID")
	if not UUID then
		return
	end

	local origin = nil
	for _, spawnPart: BasePart in workspace:FindFirstChild("mobSpawns"):GetChildren() do
		local ID = spawnPart:FindFirstChild("UUID")
		if not ID then
			continue
		end

		if ID.Value == UUID.Value then
			origin = spawnPart
			break
		end
	end

	if origin then
		self:Cancel(mobModel)

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
