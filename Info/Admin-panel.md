# Admin panel

Access is defined only in `Common/src/Shared/AdminAccess.luau`: 8896668669, 531376199 and 1016292619. The client hides the screen for everyone else; both admin server remotes independently check the allowlist.

Run `tools/ui-generators/18_Admin.luau` in Studio Edit mode and save, then sync Common. The screen is saved disabled and enabled by the authorized client. The persistent ADMIN button opens the panel without F8.

Click the target button to cycle through connected players. Search and select an item, then enter its quantity in the amount field (1–100). The same field supplies the amount for Give gold (1–10,000,000) or Set level (1–the configured level cap). Heal, Go to player and Bring player do not use the field. Server results appear at the bottom of the panel. ResetData is no longer exposed.

Validation: `python tools/verify_admin.py --luau PATH_TO_LUAU` checks the three authorized accounts, unauthorized callers, malformed numbers, level limits, request cooldown and disconnected targets. Check the final layout and actions in Studio Play.
