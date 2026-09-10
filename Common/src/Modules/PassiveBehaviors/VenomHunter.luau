local StatusEffects = require(script.Parent.Parent.StatusEffectManager)
return { BeforeAttack = function(ctx)
 if StatusEffects:HasEffect(ctx.Victim, "Venom") then ctx.Attack *= 1.2 end
end }
