local Events = require(script.Parent.Parent.EventBus)
return {
	OnTick = function(target, effect)
		local humanoid = target:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			local before = humanoid.Health
			humanoid:TakeDamage(2)
			local dealt = before - humanoid.Health
			if dealt > 0 then Events:Fire("StatusDamageDealt", target, dealt, "Poison", effect.Source) end
		end
	end,
}
