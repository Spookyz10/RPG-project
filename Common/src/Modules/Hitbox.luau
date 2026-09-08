local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Hitbox = {}

type HitboxResults = {
	Players: { [Model]: Model },
	Mobs: { [Model]: Model },
}

local DebugBool = ServerScriptService:FindFirstChild("DebugHitboxes") :: BoolValue
local Debug = DebugBool.Value

DebugBool.Changed:Connect(function(value: boolean)
	Debug = value
end)

function Hitbox.GetHitModels(hitbox: BasePart): HitboxResults
	local PlayersHit = {}
	local MobsHit = {}

	local partsHit = workspace:GetPartsInPart(hitbox)
	for _, part in partsHit do
		if part.Name == "Hitbox" then
			local Character = part.Parent :: Model?
			if not Character then
				continue
			end

			local Humanoid = Character:FindFirstChildOfClass("Humanoid")
			if not Humanoid or Humanoid.Health <= 0 then
				continue
			end

			MobsHit[Character] = Character
		else
			local Character = part.Parent :: Model?
			if not Character then
				continue
			end

			local Humanoid = Character:FindFirstChildOfClass("Humanoid")
			if not Humanoid or Humanoid.Health <= 0 then
				continue
			end

			local player = Players:GetPlayerFromCharacter(Character)
			if player then
				PlayersHit[Character] = Character
			end
		end
	end

	return { Players = PlayersHit, Mobs = MobsHit }
end

local function SetHitboxPosition(hitbox: BasePart, goalPart: BasePart, Offset: (Vector3 | CFrame)?)
	if Offset == nil then
		hitbox.CFrame = goalPart.CFrame
	elseif typeof(Offset) == "Vector3" then
		hitbox.Position = goalPart.Position + Offset
	else
		hitbox.CFrame = goalPart.CFrame * Offset
	end
end

function Hitbox:Create(info: Types.HitboxInfo): (BasePart, HitboxResults)
	local Part = Instance.new("Part")
	Part.Parent = workspace
	Part.Size = info.Size
	SetHitboxPosition(Part, info.Part, info.Offset)
	Part.CanCollide = false
	Part.Anchored = true
	Part.Transparency = Debug and RunService:IsStudio() and 0.6 or 1
	Part.Color = Color3.fromRGB(255, 0, 0)

	local HitList: { [Model]: true } = {}
	local AllPlayersHit: { [Model]: Model } = {}
	local AllMobsHit: { [Model]: Model } = {}

	local CasterIsPlayer = info.Caster ~= nil and Players:GetPlayerFromCharacter(info.Caster) ~= nil

	local function ShouldSkipForPvP(Model: Model): boolean
		if not CasterIsPlayer then
			return false
		end
		return Players:GetPlayerFromCharacter(Model) ~= nil
	end

	local function ProcessHits()
		local Results = Hitbox.GetHitModels(Part)

		for Model in Results.Players do
			if HitList[Model] or Model == info.Caster then
				continue
			end
			if ShouldSkipForPvP(Model) then
				continue
			end
			HitList[Model] = true
			AllPlayersHit[Model] = Model

			if info.OnHit then
				info.OnHit(Model, Model)
			end
		end

		for Model in Results.Mobs do
			if HitList[Model] or Model == info.Caster then
				continue
			end
			if ShouldSkipForPvP(Model) then
				continue
			end
			HitList[Model] = true
			AllMobsHit[Model] = Model

			if info.OnHit then
				info.OnHit(Model, Model)
			end
		end
	end

	if info.Drag then
		local connection
		local startTime = os.clock()

		connection = RunService.Heartbeat:Connect(function()
			local elapsed = os.clock() - startTime
			if elapsed >= info.Time then
				connection:Disconnect()
				return
			end

			SetHitboxPosition(Part, info.Part, info.Offset)
			ProcessHits()
		end)
	else
		ProcessHits()
	end

	Debris:AddItem(Part, math.max(info.Time or 0, 0.3))

	return Part, { Players = AllPlayersHit, Mobs = AllMobsHit }
end

return Hitbox
