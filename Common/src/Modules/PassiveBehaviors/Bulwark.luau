return { BeforeIncomingDamage = function(ctx)
 local hum = ctx.Victim:FindFirstChildOfClass("Humanoid")
 if hum and hum.Health >= hum.MaxHealth * 0.7 then ctx.Damage *= 0.85 end
end }
