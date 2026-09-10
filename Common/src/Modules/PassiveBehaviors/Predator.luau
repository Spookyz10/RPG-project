return { AfterHit = function(ctx)
 local hum = ctx.Caster:FindFirstChildOfClass("Humanoid")
 if hum and hum.Health > 0 and ctx.IsCrit then hum.Health = math.min(hum.MaxHealth, hum.Health + ctx.Damage * 0.08) end
end }
