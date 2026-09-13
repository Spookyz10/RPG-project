local StatusEffects = require(script.Parent.Parent.StatusEffectManager)

return {
	BeforeAttack = function(context)
		if StatusEffects:HasEffect(context.Victim, "Venom") then
			context.Attack *= 1.2
			context.TriggeredPassives.VenomHunter = true
		end
	end,
}
