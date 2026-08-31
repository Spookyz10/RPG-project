local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Effect = {}

local EffectsFolder = ReplicatedStorage.Resources.BuffEffects["Lure Jab"]

local ActiveEmitters: { [Model]: { Instance } } = {}

function Effect.Apply(Character: Model)
	if ActiveEmitters[Character] then
		return
	end

	local RootPart = Character.PrimaryPart
	if not RootPart then
		return
	end

	local Emitter1 = EffectsFolder.Emitter:Clone()
	Emitter1.Parent = RootPart

	local Emitter2 = EffectsFolder.Emitter2:Clone()
	Emitter2.Parent = RootPart

	ActiveEmitters[Character] = { Emitter1, Emitter2 }
end

function Effect.Stop(Character: Model)
	local Emitters = ActiveEmitters[Character]
	if not Emitters then
		return
	end

	for _, emitter in Emitters do
		emitter:Destroy()
	end

	ActiveEmitters[Character] = nil
end

return Effect
