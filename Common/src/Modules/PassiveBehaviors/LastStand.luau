return { BeforeIncomingDamage = function(ctx)
 local hum = ctx.Victim:FindFirstChildOfClass("Humanoid")
 if hum and hum.Health <= hum.MaxHealth * 0.35 then ctx.Damage *= 0.75 end
end }
