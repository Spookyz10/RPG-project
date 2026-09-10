return { BeforeAttack = function(ctx)
 local hum = ctx.Caster:FindFirstChildOfClass("Humanoid")
 if hum and hum.Health <= hum.MaxHealth * 0.4 then ctx.Attack *= 1.25 end
end }
