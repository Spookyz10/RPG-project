local EmitterSystem = {}

function EmitterSystem:Emit(Object: Instance)
	if Object:IsA("ParticleEmitter") then
		Object:Emit(Object:GetAttribute("EmitCount") or 1)
		return
	end

	for _, Descendant in Object:GetDescendants() do
		if Descendant:IsA("ParticleEmitter") then
			Descendant:Emit(Descendant:GetAttribute("EmitCount") or 1)
		end
	end
end

return EmitterSystem
