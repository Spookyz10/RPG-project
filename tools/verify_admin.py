"""Exercise the production admin remote authorization and input validation."""
import argparse
from pathlib import Path
import subprocess
import tempfile
parser = argparse.ArgumentParser()
parser.add_argument('--luau', required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
source = (root/'Common/src/Modules/ServerRemoteListener/Admin.luau').read_text()
access = (root/'Common/src/Shared/AdminAccess.luau').read_text()
harness = r'''
local allowed = (function() ACCESS end)()
local now, changes, feedback = 0, 0, 0
local players = {PlayerRemoving = {Connect = function() end}}
local target = {Parent = players, Name = "Target", IsA = function(_, class) return class == "Player" end}
local data = {Level = function() changes += 1 end, Currencies = {Gold = function(fn) fn(10); changes += 1 end}}
local shared = {Data = "Data", AdminAccess = "Access", Utils = {RemoteManager = "Remotes"}, getCappedInfo = "Limits"}
local modules = {Data = {server = {Service = {waitForData = function() return data end}}}, Access = allowed,
 Remotes = {SendClientEvent = function() feedback += 1 end}, Limits = {Level = 100}}
local env = setmetatable({game = {GetService = function(_, name) if name == "Players" then return players else return {Shared = shared} end end},
 require = function(key) return modules[key] end, typeof = function(v) if v == target then return "Instance" else return type(v) end end,
 os = {clock = function() return now end}, warn = function() end}, {__index = getfenv()})
local fn = assert(loadstring(SOURCE)); setfenv(fn, env); local remote = fn()
remote:Activate({UserId = 123}, "GiveGold", target, 100)
assert(changes == 0 and feedback == 0, "Unauthorized caller reached handler")
for id in allowed do
 now += 1
 remote:Activate({UserId = id}, "GiveGold", target, 100)
end
assert(changes == 3, "All three admins must work")
local caller = {UserId = 531376199}
for _, value in {0/0, math.huge, -1, 1.5, 10000001} do
 now += 1; remote:Activate(caller, "GiveGold", target, value)
end
assert(changes == 3, "Invalid gold changed data")
now += 1; remote:Activate(caller, "UpdateLevel", target, 101)
assert(changes == 3)
now += 1; remote:Activate(caller, "UpdateLevel", target, 20)
assert(changes == 4)
remote:Activate(caller, "UpdateLevel", target, 21)
assert(changes == 4, "Cooldown failed")
now += 1; target.Parent = nil; remote:Activate(caller, "GiveGold", target, 100)
assert(changes == 4, "Disconnected target modified")
now += 1; remote:Activate(caller, "ResetData", target)
assert(changes == 4)
print("PASS: three admins, unauthorized denial, invalid amounts, level cap, cooldown and disconnected target")
'''.replace('ACCESS', access).replace('SOURCE', '[====[' + source + ']====]')
with tempfile.TemporaryDirectory(prefix='admin-check-') as directory:
    path = Path(directory)/'check.luau'
    path.write_text(harness)
    raise SystemExit(subprocess.run([args.luau, str(path)]).returncode)
