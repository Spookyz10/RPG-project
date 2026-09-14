from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "tools/ui-source"
OUTPUT = ROOT / "tools/ui-generators"
ENTRIES = [
    ("Templates", "RPGUITemplates"), ("Loading", "LoadingScreen"),
    ("HUD", "HUD"), ("Navigation", "Buttons"), ("Combat", "Attack"),
    ("Inventory", "Inventory"), ("Skills", "SkillSelector"), ("Zones", "ZoneSelector"),
    ("Raids", "RaidsGUI"), ("Players", "Playerlist"),
    ("Dialogue", "Dialogue"), ("Shop", "Shop"), ("Journal", "Journal"),
    ("Notifications", "Notifications"), ("Tutorial", "Tutorial"), ("StylePreview", "UIStylePreview"),
    ("ZoneTransition", "ZoneTransition"), ("DeathScreen", "DeathScreen"),
    ("Admin", "Main"), ("PlayerCard", "PlayerCard"),
    ("Crafting", "Crafting"),
    ("Leaderboards", "Leaderboards"),
    ("LootRewards", "LootRewards"),
    ("Trading", "Trading"),
    ("DailyRewards", "DailyRewards"),
]


def inline(path):
    text = path.read_text(encoding="utf-8-sig")
    if path.name == "Templates.luau":
        text = text.replace("require(script.Parent.MobOverhead)(folder)", "(function()\n" + inline(SOURCE / "MobOverhead.luau") + "\nend)()(folder)")
        text = text.replace("require(script.Parent.ToastTemplate)(folder)", "(function()\n" + inline(SOURCE / "ToastTemplate.luau") + "\nend)()(folder)")
        text = text.replace("require(script.Parent.NPCInteractionTemplate)(folder)", "(function()\n" + inline(SOURCE / "NPCInteractionTemplate.luau") + "\nend)()(folder)")
        text = text.replace(
            "require(script.Parent.FeedbackTemplates)(folder)",
            "local buildFeedbackTemplates = (function()\n"
            + inline(SOURCE / "FeedbackTemplates.luau")
            + "\nend)()\nbuildFeedbackTemplates(folder)",
        )
    return "\n".join(line for line in text.splitlines() if line not in {
        "local C = require(script.Parent.Parent.Components)",
        "local C = require(script.Parent.Parent.ScaleComponents)",
        "local T = require(script.Parent.Parent.Theme)",
        "local T = require(script.Parent.Theme)",
    })


HEADER = '''assert(not game:GetService("RunService"):IsRunning(), "Stop Play before generating the UI.")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Selection = game:GetService("Selection")
local History = game:GetService("ChangeHistoryService")
'''


def bundle(entries):
    output = [HEADER]
    output.append("local T = (function()\n" + inline(ROOT / "Common/src/Shared/UI/Theme.luau") + "\nend)()\n")
    output.append("local C = (function()\n" + inline(SOURCE / "Components.luau") + "\nend)()\n")
    output.append("local builders = {}\n")
    for module, _ in entries:
        output.append(f'builders.{module} = (function()\n{inline(SOURCE / (module + ".luau"))}\nend)()\n')
    if len(entries) > 1:
        output.append("builders.PartyHUD = (function()\n" + inline(SOURCE / "PartyHUD.luau") + "\nend)()\n")
    output.append('''local staging = Instance.new("Folder")
local generated = {}
local ok, reason = pcall(function()
''')
    for module, screen in entries:
        target = "ReplicatedStorage" if module == "Templates" else "StarterGui"
        output.append(f'    table.insert(generated, {{ Object = builders.{module}(staging), Target = {target} }})\n')
    output.append('''for _, entry in generated do C.SaveScale(entry.Object) end''')
    if len(entries) > 1:
        output.append('''for _, entry in generated do
    if entry.Object.Name == "HUD" then
        builders.PartyHUD(entry.Object.Main)
        break
    end
end''')
    output.append('''end)
if not ok then staging:Destroy(); error("UI generation failed; existing screens were preserved: " .. tostring(reason)) end
local recording
pcall(function() recording = History:TryBeginRecording("GenerateRPGUI", "Generate RPG interface") end)
local backupRoot = ServerStorage:FindFirstChild("RPGUIBackups")
local backup
for _, entry in generated do
    local old = entry.Target:FindFirstChild(entry.Object.Name)
    if old then
        if not backupRoot then backupRoot = Instance.new("Folder"); backupRoot.Name = "RPGUIBackups"; backupRoot.Parent = ServerStorage end
        if not backup then
            backup = Instance.new("Folder")
            backup.Name = os.date("%Y-%m-%d_%H-%M-%S")
            backup.Parent = backupRoot
        end
        old:SetAttribute("OriginalService", entry.Target.Name)
        old.Parent = backup
    end
    entry.Object:SetAttribute("RPGUIVersion", 2)
    entry.Object.Parent = entry.Target
end
staging:Destroy()
local selected
''')
    preferred = "Inventory" if any(m == "Inventory" for m, _ in entries) else entries[0][1]
    output.append(f'local preferred = "{preferred}"\n')
    output.append('''for _, entry in generated do
    local object = entry.Object
    if object.Name == preferred then
        selected = object
        if object:IsA("ScreenGui") then
            for _, child in object:GetChildren() do
                if child:IsA("GuiObject") and child:GetAttribute("Window") then child.Visible = true end
            end
        end
    end
end
for _, name in { "LoadingScreen", "Tutorial", "UIStylePreview" } do
    local screen = StarterGui:FindFirstChild(name)
    if screen then screen.Enabled = preferred == name end
end
if selected then Selection:Set({ selected }) end
if recording then History:FinishRecording(recording, Enum.FinishRecordingOperation.Commit) end
print("RPG UI saved as editable instances. Save the place before Play. Backups: ServerStorage.RPGUIBackups")
''')
    return "\n".join(output)


OUTPUT.mkdir(parents=True, exist_ok=True)
for index, entry in enumerate(ENTRIES, 1):
    number = {
        "Templates": 1, "Loading": 2, "HUD": 3, "Navigation": 4,
        "Combat": 5, "Inventory": 6, "Skills": 7, "Zones": 8,
        "Raids": 9, "Players": 10, "Dialogue": 12,
        "Shop": 13, "Journal": 14, "Notifications": 15, "Tutorial": 16,
        "StylePreview": 17, "Admin": 18, "PlayerCard": 19, "Crafting": 20,
        "Leaderboards": 22, "LootRewards": 24, "ZoneTransition": 25,
        "DeathScreen": 26,
        "Trading": 28,
        "DailyRewards": 36,
    }[entry[0]]
    (OUTPUT / f"{number:02d}_{entry[0]}.luau").write_text(bundle([entry]), encoding="utf-8")
(OUTPUT / "00_All.luau").write_text(bundle(ENTRIES), encoding="utf-8")
print(f"Bundled {len(ENTRIES)} standalone Edit generators + 00_All.luau.")

def incremental_template(source_name, target_name, include_ui):
    output = HEADER
    if include_ui:
        output += "local T = (function()\n" + inline(ROOT / "Common/src/Shared/UI/Theme.luau") + "\nend)()\n"
        output += "local C = (function()\n" + inline(SOURCE / "Components.luau") + "\nend)()\n"
    output += "local build = (function()\n" + inline(SOURCE / (source_name + ".luau")) + "\nend)()\n"
    output += '''local templates = ReplicatedStorage:FindFirstChild("RPGUITemplates")
if not templates then
    templates = Instance.new("Folder")
    templates.Name = "RPGUITemplates"
    templates.Parent = ReplicatedStorage
end

local replacement = build(nil)
local targetName = "''' + target_name + '''"
local old = templates:FindFirstChild(targetName)
if old then
    local backups = ServerStorage:FindFirstChild("RPGUIBackups")
    if not backups then
        backups = Instance.new("Folder")
        backups.Name = "RPGUIBackups"
        backups.Parent = ServerStorage
    end
    local backup = Instance.new("Folder")
    backup.Name = targetName .. "_" .. os.date("%Y-%m-%d_%H-%M-%S")
    backup.Parent = backups
    old.Parent = backup
end
replacement.Parent = templates
Selection:Set({ replacement })
print(targetName .. " upgraded. Only this template changed; the prior version is in ServerStorage.RPGUIBackups.")
'''
    return output


def incremental_hud_child(source_name, target_name):
    output = HEADER
    output += "local T = (function()\n" + inline(ROOT / "Common/src/Shared/UI/Theme.luau") + "\nend)()\n"
    output += "local C = (function()\n" + inline(SOURCE / "ScaleComponents.luau") + "\nend)()\n"
    output += "local build = (function()\n" + inline(SOURCE / (source_name + ".luau")) + "\nend)()\n"
    output += '''local hud = StarterGui:FindFirstChild("HUD")
assert(hud and hud:IsA("ScreenGui"), "StarterGui.HUD must exist before generating the party HUD.")
local main = hud:FindFirstChild("Main")
assert(main and main:IsA("Frame"), "StarterGui.HUD.Main must exist before generating the party HUD.")

local replacement = build(nil)
local old = main:FindFirstChild("''' + target_name + '''")
if old then
    local backups = ServerStorage:FindFirstChild("RPGUIBackups")
    if not backups then
        backups = Instance.new("Folder")
        backups.Name = "RPGUIBackups"
        backups.Parent = ServerStorage
    end
    local backup = Instance.new("Folder")
    backup.Name = "''' + target_name + '''_" .. os.date("%Y-%m-%d_%H-%M-%S")
    backup.Parent = backups
    old.Parent = backup
end
replacement.Parent = main
Selection:Set({ replacement })
print("Party HUD installed below StarterGui.HUD.Main. The prior PartyOverlay is in ServerStorage.RPGUIBackups.")
'''
    return output


(OUTPUT / "21_MobOverhead.luau").write_text(incremental_template("MobOverhead", "MobOverhead", False), encoding="utf-8")
(OUTPUT / "23_ToastTemplate.luau").write_text(incremental_template("ToastTemplate", "ToastTemplate", True), encoding="utf-8")
(OUTPUT / "29_FeedbackTemplates.luau").write_text(incremental_template("FeedbackTemplates", "FeedbackTemplates", True), encoding="utf-8")
(OUTPUT / "30_LevelUpFeedback.luau").write_text(incremental_template("LevelUpFeedback", "LevelUpFeedback", True), encoding="utf-8")
(OUTPUT / "31_PartyHUD.luau").write_text(incremental_hud_child("PartyHUD", "PartyOverlay"), encoding="utf-8")
(OUTPUT / "34_NPCInteractionTemplate.luau").write_text(incremental_template("NPCInteractionTemplate", "NPCInteractionTemplate", True), encoding="utf-8")


def incremental_patch(source_name, include_ui):
    output = HEADER
    if include_ui:
        output += "local T = (function()\n" + inline(ROOT / "Common/src/Shared/UI/Theme.luau") + "\nend)()\n"
        output += "local C = (function()\n" + inline(SOURCE / "ScaleComponents.luau") + "\nend)()\n"
    output += "local build = (function()\n" + inline(SOURCE / (source_name + ".luau")) + "\nend)()\n"
    output += '''local recording
pcall(function() recording = History:TryBeginRecording("ApplyRPGUIPatch", "Apply RPG UI patch") end)
local ok, reason = pcall(build)
if recording then
    History:FinishRecording(recording, ok and Enum.FinishRecordingOperation.Commit or Enum.FinishRecordingOperation.Cancel)
end
if not ok then error("UI patch failed: " .. tostring(reason)) end
'''
    return output


(OUTPUT / "32_JournalIndicators.luau").write_text(incremental_patch("JournalIndicators", True), encoding="utf-8")
(OUTPUT / "33_CraftingTooltip.luau").write_text(incremental_patch("CraftingTooltipPatch", False), encoding="utf-8")
(OUTPUT / "35_CraftingRecipeTemplate.luau").write_text(incremental_patch("CraftingRecipeTemplatePatch", True), encoding="utf-8")
(OUTPUT / "37_ShopTemplate.luau").write_text(incremental_patch("ShopTemplatePatch", True), encoding="utf-8")
