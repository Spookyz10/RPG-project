local Sporeguard = {}

function Sporeguard.OnEquip(_, state)
	state.Primed = false
end

function Sporeguard.BeforeAttack(context, state)
	if state.Primed then
		context.TriggeredPassives.Sporeguard = true
	end
end

function Sporeguard.OnHitConfirmed(context, state)
	if context.TriggeredPassives.Sporeguard then
		state.Primed = false
	end
end

function Sporeguard.AfterHit(context)
	if not context.TriggeredPassives.Sporeguard then
		return
	end

	local humanoid = context.Caster:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + humanoid.MaxHealth * 0.05)
	end
end

function Sporeguard.AfterDamageReceived(context, state)
	if context.Damage and context.Damage > 0 then
		state.Primed = true
	end
end

return Sporeguard
