local VerdantPact = {}

function VerdantPact.OnEquip(_, state)
	state.Hits = 0
end

function VerdantPact.BeforeAttack(context)
	local humanoid = context.Caster:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health <= humanoid.MaxHealth * 0.5 then
		context.Attack *= 1.1
	end
end

function VerdantPact.AfterHit(context, state)
	state.Hits = (state.Hits or 0) + 1
	if state.Hits < 5 then
		return
	end
	state.Hits = 0

	local humanoid = context.Caster:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		local previousHealth = humanoid.Health
		humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + humanoid.MaxHealth * 0.06)
		if humanoid.Health > previousHealth then
			context.TriggeredPassives.VerdantPact = true
		end
	end
end

return VerdantPact
