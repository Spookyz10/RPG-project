"""Exercise the production boss respawn clock and billboard lifecycle without Studio."""
import argparse
from pathlib import Path
import subprocess
import tempfile

parser = argparse.ArgumentParser()
parser.add_argument('--luau', required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
module = (root / 'Common/src/Modules/BossRespawn.luau').read_text(encoding='utf-8')
harness = r'''
local now = 100
local runner
local marker = {IsA = function() return true end}
local gui = {Countdown = {}, Destroy = function(self) self.Destroyed = true end}
local template = {Clone = function() return gui end}
local templates = {FindFirstChild = function() return template end}
local rs = {FindFirstChild = function() return templates end}
local folder = {FindFirstChild = function() return marker end}
local env = setmetatable({
 game = {GetService = function() return rs end},
 workspace = {GetServerTimeNow = function() return now end, FindFirstChild = function() return folder end},
 task = {spawn = function(fn) runner = coroutine.create(fn); assert(coroutine.resume(runner)) end, wait = coroutine.yield},
}, {__index = getfenv()})
local fn = assert(loadstring(SOURCE)); setfenv(fn, env)
local module = fn()
local origin = {Name = "Dire Bear", Parent = true, SetAttribute = function(self, key, value) self[key] = value end}
module.Start(origin, 30)
assert(origin.RespawnAt == 130)
assert(gui.Adornee == marker and gui.Parent == marker)
assert(gui.Countdown.Text == "Dire Bear\nRespawns in 30s")
now = 129.2; assert(coroutine.resume(runner))
assert(gui.Countdown.Text == "Dire Bear\nRespawns in 1s")
now = 130; assert(coroutine.resume(runner))
assert(gui.Destroyed and coroutine.status(runner) == "dead")
-- A missing visual template must not prevent scheduling the respawn.
templates.FindFirstChild = function() return nil end
module.Start(origin, 30)
assert(origin.RespawnAt == 160)
origin.Parent = nil; assert(coroutine.resume(runner))
assert(coroutine.status(runner) == "dead")
print("PASS: boss deadline, countdown rounding, cleanup and missing-template fallback")
'''.replace('SOURCE', '[====[' + module + ']====]')
with tempfile.TemporaryDirectory(prefix='boss-respawn-') as directory:
    path = Path(directory) / 'check.luau'
    path.write_text(harness, encoding='utf-8')
    raise SystemExit(subprocess.run([args.luau, str(path)]).returncode)
