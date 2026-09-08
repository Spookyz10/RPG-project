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
runner = "local sources = {}\n" + "\n".join(sources) + "\n" + (ROOT / "tools/ui_harness.luau").read_text(encoding="utf-8")
with tempfile.TemporaryDirectory(prefix="rpg-ui-check-") as directory:
    bundle = Path(directory) / "ui_check.luau"
    bundle.write_text(runner, encoding="utf-8")
    result = subprocess.run([args.luau, str(bundle)], cwd=ROOT, capture_output=True, text=True, encoding="utf-8")
    print(result.stdout, end="")
    print(result.stderr, end="")
    raise SystemExit(result.returncode)
