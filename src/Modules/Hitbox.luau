local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local MobClass = require(ReplicatedStorage.Shared.MobClass)
local PlayerClass = require(ReplicatedStorage.Shared.PlayerClass)
local Types = require(ReplicatedStorage.Shared.Utils.Types)

local Hitbox = {}

type HitboxResults = {
	Players: { [Model]: Types.Entity },
	Mobs: { [Model]: Types.Entity },
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
		local Character = part.Parent :: Model?
		if not Character then
			continue
		end
		local Humanoid = Character:FindFirstChild("Humanoid")
		if Humanoid then
			local isMob = Character:FindFirstChild("UUID") :: BoolValue
			if isMob then
				local MobData = MobClass.getMob(isMob.Value)

				if not MobData then
					continue
				end

				if MobData.HP <= 0 then
					continue
				end

				MobsHit[Character] = MobData
			else
				local player = Players:GetPlayerFromCharacter(Character)
				if player then
					local PlayerData = PlayerClass.getPlayerInfo(player)
					if not PlayerData then
						continue
					end

					if PlayerData.HP <= 0 then
						continue
					end

					PlayersHit[Character] = PlayerData
				end
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
	Part.Transparency = Debug and 0.6 or 1
	Part.Color = Color3.fromRGB(255, 0, 0)

	local HitList: { [Model]: true } = {}
	local AllPlayersHit: { [Model]: Types.Entity } = {}
	local AllMobsHit: { [Model]: Types.Entity } = {}

	local function ProcessHits()
		local Results = Hitbox.GetHitModels(Part)

		for Model, PlayerInfo in Results.Players do
			if HitList[Model] then
				continue
			end
			HitList[Model] = true
			AllPlayersHit[Model] = PlayerInfo

			if info.OnHit then
				info.OnHit(Model, PlayerInfo)
			end
		end

		for Model, MobInfo in Results.Mobs do
			if HitList[Model] then
				continue
			end
			HitList[Model] = true
			AllMobsHit[Model] = MobInfo

			if info.OnHit then
				info.OnHit(Model, MobInfo)
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

	Debris:AddItem(Part, 0.3)

	return Part, { Players = AllPlayersHit, Mobs = AllMobsHit }
end

return Hitbox
