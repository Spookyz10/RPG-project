return {
	BeforeAttack = function(context)
		if context.Multiplier ~= nil then
			context.Attack *= 1.15
			context.TriggeredPassives.CanopyResonance = true
		end
	end,
}
