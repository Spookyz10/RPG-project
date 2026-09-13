local StatusEffects = require(script.Parent.Parent.StatusEffectManager)

local Fury = {}
local CHARGE_TIME = 15
local MAX_STACKS = 2

local function alive(character: Model): boolean
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	return character.Parent ~= nil and humanoid ~= nil and humanoid.Health > 0
end

local function sync(character: Model, state)
	if state.Stacks > 0 then
		StatusEffects:Apply(character, "Fury", { Stacks = state.Stacks })
	else
		StatusEffects:Remove(character, "Fury")
	end
end

local function scheduleCharge(character: Model, state)
	if not state.Active or state.ChargePending or state.Stacks >= MAX_STACKS then return end
	state.ChargePending = true
	local generation = state.Generation
	task.delay(CHARGE_TIME, function()
		if not state.Active or state.Generation ~= generation or not alive(character) then return end
		state.ChargePending = false
		state.Stacks = math.min(MAX_STACKS, state.Stacks + 1)
		sync(character, state)
		scheduleCharge(character, state)
	end)
end

function Fury.OnEquip(character: Model, state)
	state.Active = true
	state.Generation = (state.Generation or 0) + 1
	state.Stacks = 0
	state.ChargePending = false
	scheduleCharge(character, state)
end

function Fury.OnUnequip(character: Model, state)
	state.Active = false
	state.Generation = (state.Generation or 0) + 1
	state.ChargePending = false
	StatusEffects:Remove(character, "Fury")
end

function Fury.BeforeAttack(context, state)
	if state.Stacks <= 0 then return end
	context.ForceCritical = true
	context.CriticalMultiplier += 1.5
	context.TriggeredPassives.Fury = true
end

function Fury.OnHitConfirmed(context, state)
	if not context.TriggeredPassives.Fury then return end
	state.Stacks = math.max(0, state.Stacks - 1)
	sync(context.Caster, state)
	scheduleCharge(context.Caster, state)
end

return Fury
