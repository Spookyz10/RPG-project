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
paths = [
    (path, path.relative_to(ROOT / "Common/src/Shared").as_posix().removesuffix(".luau"))
    for path in sorted((ROOT / "Common/src/Shared").rglob("*.luau"))
]
paths += [
    (path, "UI/Components" if path.stem == "Components" else "UI/Generators/" + path.stem)
    for path in sorted((ROOT / "tools/ui-source").glob("*.luau"))
]
paths += [(ROOT / "tools/ui-generators/00_All.luau", "StandaloneGenerator")]
for path, name in paths:
    name = name.removesuffix("/init")
    source = path.read_text(encoding="utf-8-sig")
    delimiter = "="
    while "]" + delimiter + "]" in source:
        delimiter += "="
    sources.append(f"sources[{json.dumps(name, ensure_ascii=False)}] = [{delimiter}[{source}]{delimiter}]")

harness = (ROOT / "tools/ui_harness.luau").read_text(encoding="utf-8")
harness = harness[: harness.index("local recipeRow =")]
harness += r'''
local trader = folder(players, "Trader", "Player")
trader.UserId = 456
trader.DisplayName = "Trader Display"
folder(folder(trader, "PublicStats"), "Level", "NumberValue").Value = 30

remotes.InvokeServerFunction = function(name, target)
	assert(name == "GetTradeCatalog" and target == trader)
	return {
		Self = {
			Name = "Tester", DisplayName = "Aster", UserId = 123, Level = 25, Gold = 500,
			Inventory = {
				{ Container = "Inventory", UUID = "potions", ID = "Small Health Potion", Name = "Small Health Potion", Icon = "", Rarity = "Common", Amount = 8 },
			},
			Storage = {
				{ Container = "Storage", UUID = "stored", ID = "Small Health Potion", Name = "Small Health Potion", Icon = "", Rarity = "Common", Amount = 3 },
			},
		},
		Target = {
			Name = "Trader", DisplayName = "Trader Display", UserId = 456, Level = 30, Gold = 250,
			Inventory = {
				{ Container = "Inventory", UUID = "fang", ID = "Wolf's Fang", Name = "Wolf's Fang", Icon = "", Rarity = "Common", Amount = 4 },
			},
			Storage = {},
		},
	}
end

logic.Trading.Open(trader)
local trading = gui.Trading.Main
assert(trading.Visible and trading.Composer.Visible and trading.Composer.Target.Text:find("Trader Display"))
assert(trading.Composer.Mine.Items.potions and trading.Composer.Theirs.Items.fang)
assert(trading.Composer.Mine.Balance.Text == "500 GOLD AVAILABLE")
assert(trading.Composer.Theirs.Balance.Text == "250 GOLD AVAILABLE")
local offerSummary = trading.Composer.OfferSummary
assert(offerSummary.Give.Empty.Visible and offerSummary.Receive.Empty.Visible)

click(trading.Composer.Mine.Items.potions)
assert(trading.Quantity.Visible)
trading.Quantity.Amount.Text = "2"
click(trading.Quantity.Add)
assert(offerSummary.Give.Items:FindFirstChild("Inventory:potions"))
assert(offerSummary.Give.Count.Text == "1 ITEM")
click(offerSummary.Give.Items:FindFirstChild("Inventory:potions"))
assert(not offerSummary.Give.Items:FindFirstChild("Inventory:potions"), "Offer item could not be removed from summary")
assert(not trading.Composer.Mine.Items.potions.Amount.Text:find("SELECTED"))
click(trading.Composer.Mine.Items.potions)
trading.Quantity.Amount.Text = "2"
click(trading.Quantity.Add)
click(trading.Composer.Theirs.Items.fang)
trading.Quantity.Amount.Text = "1"
click(trading.Quantity.Add)
assert(offerSummary.Receive.Items:FindFirstChild("Inventory:fang"))
trading.Composer.Mine.Gold.Text = "25"
trading.Composer.Theirs.Gold.Text = "10"
assert(offerSummary.Give.Gold.Text == "25 GOLD" and offerSummary.Receive.Gold.Text == "10 GOLD")
click(trading.Composer.Review)
assert(trading.Confirmation.Visible and trading.Confirmation.Summary.Text:find("YOU WILL GIVE"))
click(trading.Confirmation.Send)
local sent = last("CreateTradeOffer")
assert(sent[2] == trader and sent[3].Give.Gold == 25 and sent[3].Receive.Gold == 10)
assert(sent[3].Give.Items[1].UUID == "potions" and sent[3].Give.Items[1].Amount == 2)
assert(sent[3].Receive.Items[1].UUID == "fang" and sent[3].Receive.Items[1].Amount == 1)

local offer = {
	Id = "offer-1", ExpiresAt = 1120,
	Sender = { Name = "Trader", DisplayName = "Trader Display", UserId = 456, Level = 30 },
	Give = { Gold = 100, Items = { { Container = "Inventory", Name = "Wolf's Fang", Amount = 2 } } },
	Receive = { Gold = 5, Items = {} },
}
logic.Trading.OnOfferReceived(offer)
local card = gui.Trading.OfferQueue["Offer_offer-1"]
assert(card and card.PlayerName.Text:find("Trader Display") and card.Level.Text == "LEVEL 30")
assert(card.Avatar.Image:find("456"), "Offer avatar was not populated")
assert(card.Expires.Text == "Expires in 120s")
click(card.View)
assert(trading.Viewer.Visible and trading.Viewer.Receive.Summary.Text:find("Wolf's Fang"))
click(trading.Viewer.Accept)
local accepted = last("RespondTradeOffer")
assert(accepted[2] == "offer-1" and accepted[3] == true)
logic.Trading.OnOfferStatus("offer-1", "Completed", "Trade completed successfully")
assert(not gui.Trading.OfferQueue:FindFirstChild("Offer_offer-1") and not trading.Visible)

offer.Id = "offer-2"
logic.Trading.OnOfferReceived(offer)
click(gui.Trading.OfferQueue["Offer_offer-2"].View)
click(trading.Viewer.Decline)
local denied = last("RespondTradeOffer")
assert(denied[2] == "offer-2" and denied[3] == false)
logic.Trading.OnOfferStatus("offer-2", "Declined", "Trade declined")

offer.Id = "offer-3"
logic.Trading.OnOfferReceived(offer)
click(gui.Trading.OfferQueue["Offer_offer-3"].Ignore)
assert(not gui.Trading.OfferQueue:FindFirstChild("Offer_offer-3"), "Ignore did not dismiss offer card")

print("PASS: trade composer, removable offer summary, balances, quantities, Gold, review, accept, decline and ignore")
'''

runner = "local sources = {}\n" + "\n".join(sources) + "\n" + harness
with tempfile.TemporaryDirectory(prefix="rpg-trade-ui-check-") as directory:
    bundle = Path(directory) / "trade_ui_check.luau"
    bundle.write_text(runner, encoding="utf-8")
    result = subprocess.run([args.luau, str(bundle)], cwd=ROOT, capture_output=True, text=True, encoding="utf-8")
    print(result.stdout, end="")
    print(result.stderr, end="")
    raise SystemExit(result.returncode)
