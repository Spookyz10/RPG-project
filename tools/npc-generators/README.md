# NPC generators

With Play stopped, paste each complete `.luau` file into Roblox Studio's Command Bar:

1. `01_Blacksmith.luau`
2. `02_WeakenedKnight.luau`

The scripts create R15 avatar NPCs in `Workspace.NPCs` from Roblox catalog accessories. They select the generated model so it can be positioned immediately. On a rerun, the old NPC is moved to `ServerStorage.NPCGeneratorBackups`, and the replacement keeps its ground position and rotation.

The runtime already watches `Workspace.NPCs` and adds the interaction prompt when the NPC's exact name has a module in `ReplicatedStorage.Shared.Dialogues`. Both generated names have dialogue definitions: `Blacksmith` and `Weakened Knight`.

Catalog loading requires Studio to have network access. Save the place after positioning the selected NPCs.

## Custom interaction

Run `tools/ui-generators/34_NPCInteractionTemplate.luau` once to install the editable interaction visual. The client no longer creates a `ProximityPrompt`; it shows this custom BillboardGui and a Highlight only for the closest available NPC.

Optional attributes on an NPC Model:

| Attribute | Type | Default |
| --- | --- | --- |
| `InteractionName` | string | NPC model name |
| `InteractionAction` | string | `Talk` |
| `InteractionKey` | string | `F` |
| `InteractionKeyLabel` | string | current input label |
| `InteractionGamepadKey` | string | `ButtonX` |
| `InteractionDistance` | number | `18` |
| `InteractionOffset` | Vector3 | `(0, 3.5, 0)` |
| `InteractionColor` | Color3 | blue |
| `InteractionHighlightColor` | Color3 | gold |
| `InteractionHighlightFillTransparency` | number | `0.82` |
| `InteractionHighlightOutlineTransparency` | number | `0.05` |
| `InteractionEnabled` | boolean | `true` |
