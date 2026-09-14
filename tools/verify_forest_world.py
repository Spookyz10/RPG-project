"""Execute the real Forest generators with conservative offline geometry checks.

Roblox Random differs from the harness PRNG; run 08_ForestAudit in Studio too.
This verifies integration/math, not rendered appearance or navigation physics.
"""
import argparse
from pathlib import Path
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True

parser = argparse.ArgumentParser()
parser.add_argument("--luau", required=True)
parser.add_argument("--seed-offset", type=int, default=0)
parser.add_argument("--reinstall", action="store_true")
parser.add_argument("--transform", action="store_true")
parser.add_argument("--plan", type=Path, help="Optional annotated spatial plan PNG; requires Pillow")
parser.add_argument("--models-preview", type=Path, help="Optional geometry inspection PNG; requires Pillow")
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
world = root / "tools/world-generators"
files = ["04_Forest.luau", "05_ForestMobModels.luau", "06_ForestSpawnsAndLighting.luau", "07_ForestCombatAssets.luau", "08_ForestAudit.luau"]
program = (root / "tools/forest_geometry_harness.luau").read_text()
program = program.replace("local state=seed", f"local state=seed+{args.seed_offset}")
calls = []
for name in files:
    if name == "06_ForestSpawnsAndLighting.luau" and args.transform:
        calls.append('''for _,p in workspace.Maps.Forest:GetDescendants() do
 if p:IsA("BasePart") then p.CFrame=CFrame.new(800,15,-400)*CFrame.Angles(0,0.7,0)*p.CFrame end
end''')
    calls.append(f'run([====[{(world / name).read_text()}]====], "{name}")')
generators = "\n".join(calls)
if args.reinstall:
    generators += '\nlocal previousMap=workspace.Maps.Forest\n' + "\n".join(calls)
    generators += '\nassert(previousMap:IsDescendantOf(game:GetService("ServerStorage").WorldGeneratorBackups), "Old map was not preserved")\n'
program = program.replace("-- GENERATORS", generators)
with tempfile.TemporaryDirectory(prefix="forest-world-") as tmp:
    script = Path(tmp) / "world.luau"
    script.write_text(program, encoding="utf-8")
    result = subprocess.run([args.luau, str(script)], capture_output=True, text=True)
    lines = result.stdout.splitlines()
    for line in lines:
        if not line.startswith("GEOM|"):
            print(line)
    if result.stderr:
        print(result.stderr)
    if result.returncode == 0 and args.models_preview:
        from forest_preview import render_models
        render_models(lines, args.models_preview)
    if result.returncode == 0 and args.plan:
        assert not args.transform, "Use the default map pose when exporting the plan"
        from PIL import Image, ImageDraw, ImageFont
        image = Image.new("RGB", (1500, 1600), "#152722")
        draw = ImageDraw.Draw(image)
        font_dir = Path("C:/Windows/Fonts")
        font = ImageFont.truetype(str(font_dir / "segoeui.ttf"), 21)
        title = ImageFont.truetype(str(font_dir / "segoeuib.ttf"), 44)
        small = ImageFont.truetype(str(font_dir / "segoeui.ttf"), 17)
        draw.text((65, 35), "FOREST / AMBERWOOD", font=title, fill="#f1d5a1")
        draw.text((65, 94), "Plano espacial dos geradores · não é uma renderização do Studio", font=font, fill="#afc4b3")
        def point(x, z):
            return 750 + x * 2, 775 + (z - 2400) * 2
        records = []
        for line in lines:
            if line.startswith("GEOM|"):
                _, parent, name, x, y, z, hx, hy, hz, solid = line.split("|")[:10]
                records.append((parent, name, *map(float, (x, y, z, hx, hy, hz))))
        for target, color, ellipse in [("ForestFloor", "#496546", False), ("Bedrock", "#708078", True),
                                      ("WaterSurface", "#3f8f97", True), ("PackedEarth", "#ab966e", False),
                                      ("DeckPlank", "#b09572", False), ("RootTrunk", "#293f30", True)]:
            for parent, name, x, y, z, hx, hy, hz in records:
                if name != target or (name == "RootTrunk" and y > 40):
                    continue
                if name == "RootTrunk":
                    hx = hz = 5
                bounds = (*point(x-hx,z-hz), *point(x+hx,z+hz))
                (draw.ellipse if ellipse else draw.rectangle)(bounds, fill=color)
        for parent, name, x, y, z, hx, hy, hz in records:
            if parent == "EncounterMarkers":
                color = "#e0a5b8" if "Mosscap" in name else "#e6cd90" if "Stag" in name else "#b0dce3" if "Sentinel" in name else "#f08c60"
                px, py = point(x,z)
                draw.ellipse((px-7,py-7,px+7,py+7),fill=color,outline="#172a24",width=2)
        labels = {"Entry":"Entrada", "Mosscap":"Jardim dos esporos", "Moonwater":"Lago Moonwater", "HeartTree":"Árvore ancestral",
                  "Ruins":"Observatório", "Elderbark":"Bosque de Elderbark", "Shrine":"Santuário", "Lookout":"Mirante"}
        for parent, name, x, y, z, hx, hy, hz in records:
            if parent == "PlanningMarkers" and name in labels:
                px, py = point(x,z)
                if name == "Moonwater": px += 75; py -= 34
                if name == "HeartTree": px -= 80; py += 48
                if name == "Shrine": px -= 15; py -= 40
                if name == "Lookout": px += 20; py += 20
                text = labels[name]
                box = draw.textbbox((px,py),text,font=small)
                draw.rounded_rectangle((box[0]-8,box[1]-5,box[2]+8,box[3]+5),5,fill="#152722")
                draw.text((px,py),text,font=small,fill="#f1dfbc")
        for i,(text,color) in enumerate([("8 Mosscaps","#e0a5b8"),("6 Stags","#e6cd90"),("5 Sentinels","#b0dce3"),("1 Elderbark","#f08c60")]):
            px=70+i*350
            draw.ellipse((px,1450,px+13,1463),fill=color)
            draw.text((px+23,1441),text,font=font,fill="#e1e8da")
        draw.text((65,1510),"Os troncos indicam ocupação no solo. Copas, altura e iluminação precisam de revisão no Studio.",font=small,fill="#afc4b3")
        args.plan.parent.mkdir(parents=True, exist_ok=True)
        image.save(args.plan)
        print(f"Spatial plan saved: {args.plan}")
    raise SystemExit(result.returncode)
