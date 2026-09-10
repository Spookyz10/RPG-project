local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)
local Definitions = require(script.Parent.PassiveBehaviors)
local Passives = {}
local States = setmetatable({}, { __mode = "k" })

-- State belongs to a passive and its equipped item sources, never another passive.
function Passives:Clear(character)
 local state = States[character]
 if not state then return end
 for id, entry in state do
  local definition = Definitions[id]
  if definition.OnUnequip then definition.OnUnequip(character, entry.Data) end
 end
 States[character] = nil
end

function Passives:Get(character, data)
 local state = States[character]
 if not state then state = {}; States[character] = state end
 local sources = {}
 for slot, uuid in data.Equipment do
  local item = Functions:GetItemInfo(data.Inventory[uuid])
  local id = item and item.Passive
  if id and Definitions[id] then
   sources[id] = sources[id] or {}
   table.insert(sources[id], slot .. ":" .. uuid)
  end
 end
 for id, entry in state do
  if not sources[id] then
   local definition = Definitions[id]
   if definition.OnUnequip then definition.OnUnequip(character, entry.Data) end
   state[id] = nil
  end
 end
 local active = {}
 for id, equippedSources in sources do
  table.sort(equippedSources)
  local key = table.concat(equippedSources, "|")
  local definition = Definitions[id]
  local entry = state[id]
  if not entry or entry.Source ~= key then
   if entry and definition.OnUnequip then definition.OnUnequip(character, entry.Data) end
   entry = { Source = key, Data = {} }
   state[id] = entry
   if definition.OnEquip then definition.OnEquip(character, entry.Data) end
  end
  if definition.Update then definition.Update(character, entry.Data) end
  table.insert(active, { ID = id, Definition = definition, State = entry.Data })
 end
 -- Stable ordering makes combinations reproducible. Higher Priority executes first.
 table.sort(active, function(a, b)
  local ap, bp = a.Definition.Priority or 0, b.Definition.Priority or 0
  return ap > bp or (ap == bp and a.ID < b.ID)
 end)
 return active
end

-- Hooks must not yield. All callbacks in one damage transaction use this snapshot.
function Passives:Run(active, hook, context)
 for _, entry in active do
  local callback = entry.Definition[hook]
  if callback then callback(context, entry.State) end
 end
end

function Passives:Listen(player, data)
 local function refresh()
  local char = player.Character
  local hum = char and char:FindFirstChildOfClass("Humanoid")
  if hum and hum.Health > 0 then self:Get(char, data())
  elseif char then self:Clear(char) end
 end
 data.Equipment.Changed(refresh)
 player.CharacterRemoving:Connect(function(character) self:Clear(character) end)
 task.spawn(function()
  while player.Parent do
   refresh()
   task.wait(0.2)
  end
 end)
end

-- Register once when this service is loaded; combat publishes phases, not passive rules.
local Events = require(script.Parent.EventBus)
Events:Subscribe("BeforeAttack", function(ctx) Passives:Run(ctx.AttackerPassives, "BeforeAttack", ctx) end)
Events:Subscribe("BeforeIncomingDamage", function(ctx) Passives:Run(ctx.DefenderPassives, "BeforeIncomingDamage", ctx) end)
Events:Subscribe("HitConfirmed", function(ctx) Passives:Run(ctx.AttackerPassives, "OnHitConfirmed", ctx) end)
Events:Subscribe("HitApplied", function(ctx)
 Passives:Run(ctx.AttackerPassives, "AfterHit", ctx)
 Passives:Run(ctx.DefenderPassives, "AfterDamageReceived", ctx)
end)
return Passives
