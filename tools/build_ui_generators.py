"""Bundle standalone, Edit-only Studio Command Bar scripts. No Rojo generator modules."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "tools/ui-source"
OUTPUT = ROOT / "tools/ui-generators"
ENTRIES = [
    ("Templates", "RPGUITemplates"), ("Loading", "LoadingScreen"),
    ("HUD", "HUD"), ("Navigation", "Buttons"), ("Combat", "Attack"),
    ("Inventory", "Inventory"), ("Skills", "SkillSelector"), ("Zones", "ZoneSelector"),
    ("Raids", "RaidsGUI"), ("Players", "Playerlist"), ("Party", "Partylist"),
    ("Dialogue", "Dialogue"), ("Shop", "Shop"), ("Journal", "Journal"),
    ("Notifications", "Notifications"), ("Tutorial", "Tutorial"), ("StylePreview", "UIStylePreview"),
    ("Admin", "Main"),
]


def inline(path):
    text = path.read_text(encoding="utf-8-sig")
    # Only the builders' two local dependencies are folded in; no dynamic code evaluation.
    return "\n".join(line for line in text.splitlines() if line not in {
        "local C = require(script.Parent.Parent.Components)",
        "local T = require(script.Parent.Parent.Theme)",
        "local T = require(script.Parent.Theme)",
    })


HEADER = '''-- STUDIO COMMAND BAR / EDIT MODE ONLY.
-- Standalone: paste this entire file; no plugin or generator module is required.
-- Existing UI is moved into ServerStorage.RPGUIBackups before replacement.
-- Runtime scripts bind the saved UI and never regenerate it.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before generating the UI.")
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
    output.append('''local staging = Instance.new("Folder")
local generated = {}
local ok, reason = pcall(function()
''')
    for module, screen in entries:
        target = "ReplicatedStorage" if module == "Templates" else "StarterGui"
        output.append(f'    table.insert(generated, {{ Object = builders.{module}(staging), Target = {target} }})\n')
    output.append('''for _, entry in generated do C.SaveScale(entry.Object) end
end)
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
-- Loading/tutorial are enabled by their client controllers, not while editing.
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
    (OUTPUT / f"{index:02d}_{entry[0]}.luau").write_text(bundle([entry]), encoding="utf-8")
(OUTPUT / "00_All.luau").write_text(bundle(ENTRIES), encoding="utf-8")
print(f"Bundled {len(ENTRIES)} standalone Edit generators + 00_All.luau.")
