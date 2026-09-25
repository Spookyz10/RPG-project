local CycleOfLife = {}

function CycleOfLife.OnEquip(_, state)
	state.Hits = 0
end

function CycleOfLife.BeforeAttack(context, state)
	if state.Hits < 3 then
		return
	end

	local humanoid = context.Caster:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > humanoid.MaxHealth * 0.5 then
		context.Attack *= 1.2
	end
	context.TriggeredPassives.CycleOfLife = true
end

function CycleOfLife.OnHitConfirmed(context, state)
	if context.TriggeredPassives.CycleOfLife then
		state.Hits = 0
	else
		state.Hits = math.min(3, state.Hits + 1)
	end
end

function CycleOfLife.AfterHit(context)
	if not context.TriggeredPassives.CycleOfLife then
		return
	end

	local humanoid = context.Caster:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 and humanoid.Health <= humanoid.MaxHealth * 0.5 then
		humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + humanoid.MaxHealth * 0.07)
	end
end

return CycleOfLife
