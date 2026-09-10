return { AfterHit = function(ctx, state)
 local hum = ctx.Caster:FindFirstChildOfClass("Humanoid")
 if not hum or hum.Health <= 0 then return end
 state.Hits = (state.Hits or 0) + 1
 if state.Hits % 5 == 0 then hum.Health = math.min(hum.MaxHealth, hum.Health + hum.MaxHealth * 0.04) end
end }
