"""Run generated UI contract/interaction checks with the official Luau CLI.

This is an Instance/data mock, not a substitute for Studio's device emulator.
Usage: python tools/verify_ui.py --luau PATH_TO_LUAU
"""
import argparse
import json
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument("--luau", required=True)
parser.add_argument("--zones-only", action="store_true")
args = parser.parse_args()
sources = []
paths = [(path, path.relative_to(ROOT / "Common/src/Shared").as_posix().removesuffix(".luau")) for path in sorted((ROOT / "Common/src/Shared").rglob("*.luau"))]
# The harness loads Edit-only builder sources in a virtual namespace, never into the game.
paths += [(path, "UI/Components" if path.stem == "Components" else "UI/Generators/" + path.stem) for path in sorted((ROOT / "tools/ui-source").glob("*.luau"))]
paths += [(ROOT / "tools/ui-generators/00_All.luau", "StandaloneGenerator")]
for path, name in paths:
    name = name.removesuffix("/init")
    source = path.read_text(encoding="utf-8-sig")
    delimiter = "="
    while "]" + delimiter + "]" in source:
        delimiter += "="
    sources.append(f"sources[{json.dumps(name, ensure_ascii=False)}] = [{delimiter}[{source}]{delimiter}]")
harness = (ROOT / "tools/ui_harness.luau").read_text(encoding="utf-8")
if args.zones_only:
    harness = harness.replace("local overrides = {", 'local overrides = {\n [modules["Utils/Types"]] = {},')
    harness = harness[:harness.index('local logic = loadModule')] + r'''
local selector = loadModule(modules["UI/Logic/ZoneSelector"])
selector.Init()
local content = gui.ZoneSelector.Main.Body.Content
assert(content.Details.Visible and content.Container.Visible)
assert(gui.ZoneSelector.ScreenInsets == Enum.ScreenInsets.DeviceSafeInsets)
assert(gui.ZoneSelector.Main.Size.X.Scale == 0.6 and gui.ZoneSelector.Main.Size.Y.Scale == 0.85)
assert(gui.ZoneSelector.Templates.MobEntry.Stats.TextLimit.MaxTextSize <= 18)
assert(not gui.ZoneSelector.Templates.ZoneEntry:FindFirstChild("Image"))
content.Container.Grasslands.Activated:Fire()
assert(content.Details.Visible and content.Container.Visible)
content.Details.Roster["Dire Bear"].Activated:Fire()
assert(content.Details.Mobs["Dire Bear"].Visible and not content.Details.Mobs.Bushling.Visible)
local bear = content.Details.Mobs["Dire Bear"]
assert(string.find(bear.MobName.Text, "BOSS"))
assert(string.find(bear.Stats.Text, "2400") and string.find(bear.Stats.Text, "30s"))
assert(bear.Preview:IsA("ViewportFrame"))
local claw = bear.Drops["Dire Claw"]
assert(claw.Icon.Image ~= "" and claw.Chance.Text == "100%")
assert(claw.ItemName.Text == "Dire Claw")
gui.ZoneSelector.Main.Visible = true
claw.MouseEnter:Fire()
assert(gui.ZoneSelector.ItemTooltip.Visible, "Drop hover did not open")
assert(gui.ZoneSelector.ItemTooltip.ItemName.Text == "Dire Claw")
claw.MouseLeave:Fire()
assert(not gui.ZoneSelector.ItemTooltip.Visible)
assert(content.Container.Grasslands.Selected.Visible)
assert(gui.LootRewards.List.UIListLayout)
assert(gui.LootRewards.List.Position.X.Scale > 0.9)
assert(string.find(content.Details.Mobs.Boar.Stats.Text, "120"))
content.Details.Roster.Bushling.Activated:Fire()
assert(content.Details.Mobs.Bushling.Visible and not bear.Visible)
content.Container.Grasslands.Activated:Fire()
local count = 0
for _, child in content.Details.Mobs:GetChildren() do if child:GetAttribute("ZoneMobEntry") then count += 1 end end
assert(count == 4, "Repeated selection duplicated mob cards")

data.Level(1)
content.Container.Forest.Activated:Fire()
assert(content.Details.Mobs.Empty.Visible)
assert(not content.Details.Enter.Active, "Locked zone can be entered")
assert(content.Details.Progress.Fill.Size.X.Scale < 1)
assert(string.find(content.Details.Journey.Text, "14 levels"))
data.Level(15)
assert(content.Details.Enter.Active and content.Details.Progress.Fill.Size.X.Scale == 1)
print("PASS: atlas tabs, creature switching, drop hover, combat stats, empty roster, discovery progress, level unlock and repeated selection")
'''
runner = "local sources = {}\n" + "\n".join(sources) + "\n" + harness
with tempfile.TemporaryDirectory(prefix="rpg-ui-check-") as directory:
    bundle = Path(directory) / "ui_check.luau"
    bundle.write_text(runner, encoding="utf-8")
    result = subprocess.run([args.luau, str(bundle)], cwd=ROOT, capture_output=True, text=True, encoding="utf-8")
    print(result.stdout, end="")
    print(result.stderr, end="")
    raise SystemExit(result.returncode)
