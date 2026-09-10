return { BeforeAttack = function(ctx)
 local hum = ctx.Victim:FindFirstChildOfClass("Humanoid")
 if hum and hum.Health <= hum.MaxHealth * 0.3 then ctx.Attack *= 1.25 end
end }
