local StatusEffects = require(script.Parent.Parent.StatusEffectManager)
local Fury = {}
function Fury.OnEquip(character, state)
 state.Stacks, state.Next = 0, os.clock() + 15

end
function Fury.OnUnequip(character)
 StatusEffects:Remove(character, "Fury")
end
function Fury.Update(character, state)
 local now = os.clock()
 if state.Stacks < 2 and now >= state.Next then
  local count = math.floor((now - state.Next) / 15) + 1
  state.Stacks = math.min(2, state.Stacks + count)
  state.Next += count * 15
 end
 if state.Stacks > 0 then
  local current = StatusEffects:Get(character, "Fury")
  if not current or current.Stacks ~= state.Stacks then StatusEffects:Apply(character, "Fury", { Stacks = state.Stacks }) end
 end
end
function Fury.BeforeAttack(ctx, state)
 if state.Stacks > 0 then
  ctx.ForceCritical = true
  ctx.CriticalMultiplier += 1.5
  ctx.TriggeredPassives.Fury = true
 end
end
function Fury.OnHitConfirmed(ctx, state)
 if not ctx.TriggeredPassives.Fury then return end
 if state.Stacks == 2 then state.Next = os.clock() + 15 end
 state.Stacks = math.max(0, state.Stacks - 1)
 if state.Stacks > 0 then StatusEffects:Apply(ctx.Caster, "Fury", { Stacks = state.Stacks })
 else StatusEffects:Remove(ctx.Caster, "Fury") end
end
return Fury
