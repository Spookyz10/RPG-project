local Maul = {}

function Maul.OnEquip(character, state)
	state.Hits = 0
end

function Maul.BeforeAttack(ctx, state)
	if state.Hits >= 3 then
		ctx.Attack += 4
		ctx.TriggeredPassives.Maul = true
	end
end

function Maul.OnHitConfirmed(ctx, state)
	-- Only confirmed positive damage advances or consumes the combo.
	if ctx.TriggeredPassives.Maul then
		state.Hits = 0
	else
		state.Hits = math.min(3, state.Hits + 1)
	end
end

return Maul
