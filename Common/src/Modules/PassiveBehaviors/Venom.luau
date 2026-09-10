local StatusEffects = require(script.Parent.Parent.StatusEffectManager)
return { AfterHit = function(ctx)
 local hum = ctx.Caster:FindFirstChildOfClass("Humanoid")
 if hum and hum.Health > 0 then StatusEffects:Apply(ctx.Victim, "Venom", { Source = ctx.Caster }) end
end }
