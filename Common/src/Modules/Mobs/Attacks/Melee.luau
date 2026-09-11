local Animations = require(game:GetService("ReplicatedStorage").Shared.MobAnimations)
return function(ctx, attack)
 local size = attack.Size or ctx.Config.Size
 -- Keep the telegraph and damage volume identical when a large body needs more clearance.
 if ctx.MeleeReach then
  size = Vector3.new(size.X, size.Y, math.max(size.Z, ctx.MeleeReach))
 end
 for _ = 1, attack.Count or 1 do
  local cf = ctx.Root.CFrame * CFrame.new(0, 0, -size.Z / 2)
  ctx.Indicator("Square", cf, Vector3.new(size.X, 0.15, size.Z), attack.Windup or 0.3)
  if not ctx.Pause(attack.Windup or 0.3) then break end
  Animations:PlayHit(ctx.Mob, 0.1)
  ctx.VFX(attack.Name == "DoubleSwipe" and "DoubleSwipe" or "Melee", cf)
  ctx.Hit(cf, size, nil, attack.Multiplier or 1, nil, attack.Status, {})
  if not ctx.Pause(0.15) then break end
 end
end
