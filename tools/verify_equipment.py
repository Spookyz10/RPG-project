"""Run production Fury/damage/crafting modules in a deterministic Luau mock."""
import argparse
from pathlib import Path
import subprocess
import tempfile

parser = argparse.ArgumentParser()
parser.add_argument('--luau', required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
sources = {name: (root / path).read_text() for name, path in {
    'Statuses': 'Common/src/Modules/StatusEffectManager.luau',
    'StatusDefinitions': 'Common/src/Shared/StatusEffects.luau',
    'StatusBehaviors': 'Common/src/Modules/StatusEffectBehaviors/Poison.luau',
    'Modifiers': 'Common/src/Modules/ModifierSystem.luau',
    'Events': 'Common/src/Modules/EventBus.luau',
    'Passives': 'Common/src/Modules/EquipmentPassives.luau',
    'Damage': 'Common/src/Modules/DamageHandler.luau',
    'Craft': 'Common/src/Modules/ServerRemoteListener/Inventory/CraftItem.luau',
}.items()}
script = r'''
local now = 0
local player = {UserId = 1}
local items = {fang = {Passive="Fury", Data={ID="Fang Dagger",Name="Fang Daggers"}}, ivy = {Data={ID="Dark Ivy"}}}
local snapshot = {Equipment={Weapon="w"},Inventory={w=items.fang}}
local functions = {
    GetItemInfo=function(_, entry) return entry end,
    GetTotalStats=function(_, char) return char.Stats end,
    isClassMob=function() return false end,
    isEntityAlive=function(_, char) return char.Humanoid.Health > 0 end,
    GenUUID=function() return "crafted" end,
}
local function entity(isPlayer)
    local c = {Parent=true,Player=isPlayer and player, Humanoid={Health=1000,MaxHealth=1000},Stats={Attack=10,Defense=0,Critical=0,["Critical Power"]=20}}
    function c:FindFirstChildOfClass() return self.Humanoid end
    function c:FindFirstChild() return nil end
    function c:SetAttribute(k,v) self[k]=v end
    function c:GetAttribute(k) return self[k] end
    return c
end
local caster,victim=entity(true),entity(false)
local data=function() return snapshot end
local dataService={server={Service={waitForData=function() return data end}}}
local shared={Utils={Functions=functions,RemoteManager={SendClientEvent=function() end},Types={}},Data=dataService}
local modules={ModifierSystem={Aggregate=function(_, _, _, value) return value end},EventBus={Fire=function() end}}
local services={Players={GetPlayerFromCharacter=function(_, c) return c.Player end},ReplicatedStorage={Shared=shared},ServerStorage={Modules=modules}}
local env=setmetatable({game={GetService=function(_,n) return services[n] end},workspace={GetServerTimeNow=function() return now end},os={clock=function() return now end},require=function(x) return x end},{__index=getfenv()})
local function load(source)
    local fn=assert(loadstring(source))
    setfenv(fn,setmetatable({script={Parent=modules}},{__index=env}))
    return fn()
end
modules.Parent=modules
modules.EventBus=load(EVENTS)
modules.ModifierSystem=load(MODIFIERS)
shared.StatusEffects=load(STATUSDEFINITIONS)
modules.StatusEffectBehaviors={Poison=load(STATUSBEHAVIORS)}
modules.StatusEffectManager=load(STATUSES)
local status=modules.StatusEffectManager
local function charges(c) local effect=status:Get(c,"Fury"); return effect and effect.Stacks or 0 end
modules.PassiveBehaviors = {}
__PASSIVE_MODULES__
local passives=load(PASSIVES)
modules.EquipmentPassives=passives
local damage=load(DAMAGE)
local active=passives:Get(caster,snapshot)
local state=active[1].State
assert(state.Stacks==0)
now=14.99; passives:Get(caster,snapshot); assert(state.Stacks==0)
now=15; passives:Get(caster,snapshot); assert(state.Stacks==1)
now=90; passives:Get(caster,snapshot); assert(state.Stacks==2)
local amount,crit=damage:dealDamage(caster,victim)
assert(crit and math.abs(amount-37)<0.0001 and state.Stacks==1, "Fury must be 2x + 20% + 150%")
damage:dealDamage(caster,victim); assert(state.Stacks==0)
local normal,normalCrit=damage:dealDamage(caster,victim)
assert(normal==10 and not normalCrit)
now=105; passives:Get(caster,snapshot); assert(state.Stacks==1)
local unsubscribe=modules.EventBus:Subscribe("BeforeDamageCalculated",function(context) context.Cancelled=true end)
damage:dealDamage(caster,victim); assert(state.Stacks==1,"Cancelled hit consumed Fury")
unsubscribe()
snapshot.Equipment.Weapon="other"; passives:Get(caster,snapshot); assert(charges(caster)==0)
snapshot.Equipment.Weapon="w"; passives:Get(caster,snapshot); assert(charges(caster)==0)
local fresh=entity(true); passives:Get(fresh,snapshot); assert(charges(fresh)==0)
caster.Humanoid.Health=800
local health=caster.Humanoid.Health
snapshot.Inventory.r={Passive="Predator"}; snapshot.Equipment.Ring="r"
passives:Run(passives:Get(caster,snapshot),"AfterHit",{Caster=caster,Victim=victim,Damage=100,IsCrit=true})
assert(caster.Humanoid.Health==math.min(1000,health+8))
snapshot.Inventory.r.Passive="Venom"
passives:Run(passives:Get(caster,snapshot),"AfterHit",{Caster=caster,Victim=victim,Damage=10,IsCrit=false})
assert(status:HasEffect(victim,"Venom"))
snapshot.Inventory.w.Passive="VenomHunter"
assert(math.abs(damage:BuildContext(caster,victim).Damage-12)<0.001)
print("PASS: Fury timing/cap/consumption/cancellation/swap/respawn, Critical Power, healing and Venom synergy")

-- Maul counts confirmed damage, never previews, cancelled hits or zero damage.
snapshot.Equipment.Ring=nil
snapshot.Inventory.w.Passive="Maul"
caster.Stats.Attack=9
for i=1,3 do assert(damage:dealDamage(caster,victim)==9) end
assert(damage:BuildContext(caster,victim).Damage==13)
assert(damage:BuildContext(caster,victim).Damage==13,"Preview consumed Maul")
local cancelMaul=modules.EventBus:Subscribe("BeforeDamageCalculated",function(context) context.Cancelled=true end)
damage:dealDamage(caster,victim)
cancelMaul()
victim.Stats.Defense=100
assert(damage:dealDamage(caster,victim)==0)
victim.Stats.Defense=0
assert(damage:dealDamage(caster,victim)==13,"Cancelled/zero hit consumed Maul")
assert(damage:dealDamage(caster,victim)==9,"Maul did not reset")
snapshot.Equipment.Weapon="other"; passives:Get(caster,snapshot)
snapshot.Equipment.Weapon="w"
assert(passives:Get(caster,snapshot)[1].State.Hits==0,"Unequip did not reset Maul")
caster.Stats.Attack=10
print("PASS: Maul fourth hit, previews, cancellation, zero damage and unequip reset")

-- Defender thresholds and unrelated equipment changes.
local defender=entity(true)
local defenseData={Equipment={Armor="armor"},Inventory={armor={Passive="Bulwark"}}}
local ctx={Victim=defender,Damage=100}
passives:Run(passives:Get(defender,defenseData),"BeforeIncomingDamage",ctx)
assert(ctx.Damage==85)
defender.Humanoid.Health=699; ctx.Damage=100
passives:Run(passives:Get(defender,defenseData),"BeforeIncomingDamage",ctx); assert(ctx.Damage==100)
defenseData.Inventory.armor.Passive="LastStand"; defender.Humanoid.Health=350; ctx.Damage=100
passives:Run(passives:Get(defender,defenseData),"BeforeIncomingDamage",ctx); assert(ctx.Damage==75)
defender.Humanoid.Health=351; ctx.Damage=100
passives:Run(passives:Get(defender,defenseData),"BeforeIncomingDamage",ctx); assert(ctx.Damage==100)
snapshot.Inventory.w.Passive="Fury"; passives:Get(caster,snapshot)
now+=15; passives:Get(caster,snapshot); assert(charges(caster)==1)
snapshot.Inventory.r.Passive="Regrowth"; passives:Get(caster,snapshot); assert(charges(caster)==1)
passives:Clear(caster); assert(charges(caster)==0 and not status:HasEffect(caster,"Fury"))
-- A new module's hook executes without changes to DamageHandler or dispatcher.
modules.PassiveBehaviors.TestExtension={BeforeAttack=function(c) c.Attack+=7 end}
snapshot.Inventory.w.Passive="TestExtension"
assert(damage:BuildContext(caster,victim).Damage==17)
snapshot.Equipment.Ring=""; snapshot.Equipment.Weapon=""
assert(damage:BuildContext(caster,victim).Damage==10)
print("PASS: defensive thresholds, independent state, cleanup and new passive extension")


-- Status effects: tick, refresh, priority fallback, removal and modifier ownership.
local poisoned=entity(false)
function poisoned.Humanoid:TakeDamage(n) self.Health-=n end
status:Apply(poisoned,"Poison")
for _=1,10 do now+=1; status:Step(now) end
assert(poisoned.Humanoid.Health==980 and not status:HasEffect(poisoned,"Poison") and not poisoned.Poisoned)
status:Apply(poisoned,"Poison"); now+=3; status:Step(now)
status:Apply(poisoned,"Poison"); now+=10; status:Step(now)
assert(poisoned.Humanoid.Health==954 and not poisoned.Poisoned)
status:Apply(poisoned,"Lure Jab",{Duration=10,Value=0.8,Priority=1})
status:Apply(poisoned,"Lure Jab",{Duration=2,Value=0.5,Priority=2})
assert(modules.ModifierSystem:Aggregate(poisoned,"Defense",100)==50)
now+=2; status:Step(now)
assert(modules.ModifierSystem:Aggregate(poisoned,"Defense",100)==80)
modules.ModifierSystem:AddModifier(poisoned,"Defense","Equipment","Add",10)
status:ClearEntity(poisoned)
assert(modules.ModifierSystem:Aggregate(poisoned,"Defense",100)==110)
status:Apply(poisoned,"Poison"); poisoned.Humanoid.Health=0; status:Step(now)
assert(not status:HasEffect(poisoned,"Poison") and not poisoned.Poisoned)
print("PASS: unified statuses, periodic damage, refresh, priority fallback, death and modifier cleanup")

-- Cleansing removes all debuff groups, including suppressed entries, but preserves buffs.
caster.Humanoid.Health=500
status:Apply(caster,"Poison",{Duration=10})
status:Apply(caster,"Poison",{Duration=20,Priority=2})
status:Apply(caster,"Venom",{Duration=6})
status:Apply(caster,"Lure Jab",{Duration=5})
status:Apply(caster,"Fury",{Stacks=1})
status:Apply(caster,"Safeguard",{Duration=5})
status:ClearDebuffs(caster)
assert(not status:HasEffect(caster,"Poison") and not status:HasEffect(caster,"Venom") and not status:HasEffect(caster,"Lure Jab"))
assert(status:HasEffect(caster,"Fury") and status:HasEffect(caster,"Safeguard"))
assert(damage:heal(caster,caster,caster.Humanoid.MaxHealth)==500)
assert(caster.Humanoid.Health==caster.Humanoid.MaxHealth)
print("PASS: full healing and debuff cleanse preserve beneficial statuses")

-- Crafting: use callable data cells and the actual remote handler.
local function cell(initial)
    local value=initial
    return function(...) if select('#',...)>0 then value=(...) end; return value end
end
local inv={a={Data={ID="Dark Ivy"},Amount=3}}
data={Inventory=cell(inv),Equipment=cell({}),Level=cell(12),CurrentInventorySpace=cell(1),MaxInventorySpace=cell(1)}
local gold=cell(100)
data.Currencies=setmetatable({Gold=gold},{__call=function() return {Gold=gold()} end})
shared.ItemsData={["Fang Dagger"]={Data={Name="Fang Daggers"}}}
shared.CraftingRecipes={["Fang Dagger"]={Level=12,Gold=75,Ingredients={["Dark Ivy"]=3}}}
local progress=0
modules.QuestManager={AddObjectiveProgress=function() progress+=1 end}
local craft=load(CRAFT)
craft:Activate(player,"unknown"); assert(gold()==100 and data.Inventory()==inv)
craft:Activate(player,"Fang Dagger")
assert(gold()==25 and data.Inventory().crafted.ID=="Fang Dagger" and not data.Inventory().a and progress==1)
craft:Activate(player,"Fang Dagger"); assert(gold()==25 and progress==1)
gold(100); data.Inventory({a={Data={ID="Dark Ivy"},Amount=2}})
craft:Activate(player,"Fang Dagger"); assert(gold()==100 and data.Inventory().a.Amount==2)
data.Inventory({a={Data={ID="Dark Ivy"},Amount=4}})
craft:Activate(player,"Fang Dagger"); assert(gold()==100 and data.Inventory().a.Amount==4,"Full inventory consumed resources")
data.Level(1); craft:Activate(player,"Fang Dagger"); assert(gold()==100)
print("PASS: crafting success, quest progress, unknown recipe, repeated request, missing materials, capacity and level failures")
'''
definitions = '\n'.join('modules.PassiveBehaviors["' + p.stem + '"] = load([====[' + p.read_text() + ']====])' for p in sorted((root / 'Common/src/Modules/PassiveBehaviors').glob('*.luau')) if p.stem != 'init')
script = script.replace('__PASSIVE_MODULES__', definitions)
for marker, name in [('STATUSES', 'Statuses'), ('STATUSDEFINITIONS', 'StatusDefinitions'), ('STATUSBEHAVIORS', 'StatusBehaviors'), ('MODIFIERS', 'Modifiers'), ('EVENTS', 'Events'), ('PASSIVES', 'Passives'), ('DAMAGE', 'Damage'), ('CRAFT', 'Craft')]:
    script = script.replace(marker, '[====[' + sources[name] + ']====]')
with tempfile.TemporaryDirectory(prefix='equipment-check-') as folder:
    path = Path(folder) / 'check.luau'
    path.write_text(script)
    raise SystemExit(subprocess.run([args.luau, str(path)]).returncode)
