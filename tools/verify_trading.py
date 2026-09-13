import argparse
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument("--luau", required=True)
args = parser.parse_args()

source = (ROOT / "Common/src/Modules/TradeSystem.luau").read_text(encoding="utf-8-sig")
delimiter = "="
while "]" + delimiter + "]" in source:
    delimiter += "="
harness = (ROOT / "tools/trade_harness.luau").read_text(encoding="utf-8")
runner = f"local TRADE_SOURCE = [{delimiter}[{source}]{delimiter}]\n{harness}"

with tempfile.TemporaryDirectory(prefix="rpg-trade-check-") as directory:
    bundle = Path(directory) / "trade_check.luau"
    bundle.write_text(runner, encoding="utf-8")
    result = subprocess.run([args.luau, str(bundle)], cwd=ROOT, capture_output=True, text=True, encoding="utf-8")
    print(result.stdout, end="")
    print(result.stderr, end="")
    raise SystemExit(result.returncode)
