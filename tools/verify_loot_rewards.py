"""Validate actual awarded quantities, including partial stacks and full inventories."""
import argparse
from pathlib import Path
import subprocess
import tempfile
parser = argparse.ArgumentParser()
parser.add_argument('--luau', required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
source = (root/'Common/src/Modules/InventoryManager.luau').read_text()
start = source.index('function InventoryManager:AddItem')
end = source.index('function InventoryManager:RemoveItem', start)
script = r'''local entries, space, cap = {}, 0, 2
local inventory = setmetatable({}, {
 __call = function() return entries end,
 __index = function(_, key)
  return setmetatable({Amount = function(value) entries[key].Amount = value end}, {
   __call = function(_, value) entries[key] = value end,
  })
 end,
})
local playerData = {Inventory = inventory, CurrentInventorySpace = function(value) if value then space = value end return space end, MaxInventorySpace = function() return cap end}
local Data = {Service = {waitForData = function() return playerData end}}
local ItemsData = {Claw = {Data = {ID = "Claw", Name = "Claw", Stackable = true, Cap = 5}}}
local seq = 0
local Functions = {GenUUID = function() seq += 1; return tostring(seq) end}
local InventoryManager = {}
SOURCE
local status, _, amount = InventoryManager:AddItem({}, "Claw", 7)
assert(status == "Successfully added item" and amount == 7 and space == 2)
status, _, amount = InventoryManager:AddItem({}, "Claw", 8)
assert(status == "Inventory full" and amount == 3, "Partial inventory must celebrate only received items")
status, _, amount = InventoryManager:AddItem({}, "Claw", 1)
assert(status == "Inventory full" and amount == 0, "Full inventory must not celebrate an unreceived item")
print("PASS: loot quantity on full award, partial stack and full inventory")
'''.replace('SOURCE', source[start:end])
with tempfile.TemporaryDirectory(prefix='loot-test-') as directory:
    file = Path(directory)/'test.luau'
    file.write_text(script)
    raise SystemExit(subprocess.run([args.luau, str(file)]).returncode)
