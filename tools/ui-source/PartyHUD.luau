local C = require(script.Parent.Parent.Components)
local T = require(script.Parent.Parent.Theme)

return function(parent)
	local overlay = C.Frame(parent, "PartyOverlay", UDim2.fromScale(0, 1.04), UDim2.fromScale(1, 2.75))
	overlay.BackgroundTransparency = 1

	local invites = C.New("ScrollingFrame", "InviteQueue", overlay, { Position = UDim2.fromScale(0, 0), Size = UDim2.fromScale(1, 0.25), BackgroundTransparency = 1, CanvasSize = UDim2.fromScale(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y })
	C.New("UIListLayout", "UIListLayout", invites, { Padding = UDim.new(0.04, 0), SortOrder = Enum.SortOrder.LayoutOrder })
	local invite = C.New("CanvasGroup", "InviteTemplate", invites, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = T.Paper, Visible = false, LayoutOrder = 0 })
	C.Round(invite, 12)
	C.Stroke(invite, T.Gold).Thickness = 2
	C.New("UIScale", "Pop", invite, { Scale = 1 })
	C.Frame(invite, "Accent", UDim2.fromScale(0, 0), UDim2.fromScale(0.018, 1), T.Gold).ZIndex = 2
	C.Label(invite, "Inviter", "Adventurer invited you to join their party", UDim2.fromScale(0.06, 0.1), UDim2.fromScale(0.88, 0.3), true).TextSize = 15
	local expires = C.Label(invite, "Expires", "Invitation expires soon", UDim2.fromScale(0.06, 0.4), UDim2.fromScale(0.88, 0.16))
	expires.TextColor3 = T.Muted
	expires.TextSize = 11
	C.Button(invite, "Accept", "ACCEPT", UDim2.fromScale(0.06, 0.65), UDim2.fromScale(0.42, 0.27), T.Mint).TextSize = 11
	C.Button(invite, "Decline", "DECLINE", UDim2.fromScale(0.52, 0.65), UDim2.fromScale(0.42, 0.27), T.Soft).TextSize = 11

	local party = C.Frame(overlay, "PartyPanel", UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.5), T.Paper)
	C.Round(party, 14)
	C.Stroke(party, T.Gold).Thickness = 2
	local header = C.Frame(party, "Header", UDim2.fromScale(0.04, 0.035), UDim2.fromScale(0.92, 0.12))
	header.BackgroundTransparency = 1
	local title = C.Label(header, "Title", "YOUR PARTY", UDim2.fromScale(0, 0), UDim2.fromScale(0.58, 1), true)
	title.TextColor3 = T.Gold
	title.TextSize = 16
	C.Button(party, "Leave", "LEAVE", UDim2.fromScale(0.72, 0.035), UDim2.fromScale(0.24, 0.12), T.Rose).TextSize = 11

	local members = C.New("ScrollingFrame", "Members", party, { Position = UDim2.fromScale(0.025, 0.18), Size = UDim2.fromScale(0.95, 0.78), BackgroundTransparency = 1, CanvasSize = UDim2.fromScale(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y })
	C.New("UIListLayout", "UIListLayout", members, { Padding = UDim.new(0.04, 0), SortOrder = Enum.SortOrder.LayoutOrder })
	local entry = C.Round(C.Frame(members, "EntryTemplate", UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.28), T.Surface), 9)
	entry.Visible = false
	C.Stroke(entry, T.Line).Thickness = 2
	C.Label(entry, "NameLabel", "Adventurer", UDim2.fromScale(0.04, 0.08), UDim2.fromScale(0.58, 0.32), true).TextSize = 13
	local leader = C.Label(entry, "Leader", "LEADER", UDim2.fromScale(0.64, 0.08), UDim2.fromScale(0.2, 0.3), true)
	leader.TextColor3 = T.Gold
	leader.TextSize = 9
	C.Button(entry, "Kick", "X", UDim2.fromScale(0.86, 0.1), UDim2.fromScale(0.1, 0.38), T.Rose).TextSize = 14
	local level = C.Label(entry, "Level", "LV. 1", UDim2.fromScale(0.04, 0.52), UDim2.fromScale(0.2, 0.3), true)
	level.TextColor3 = T.Muted
	level.TextSize = 10
	local health = C.Frame(entry, "Health", UDim2.fromScale(0.26, 0.56), UDim2.fromScale(0.68, 0.28))
	health.BackgroundTransparency = 1
	local track = C.Round(C.Frame(health, "Main", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), T.Soft), 6)
	track.ClipsDescendants = true
	C.Round(C.Frame(track, "Bar", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), T.Mint), 6)
	local amount = C.Label(track, "Amount", "-- / --", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), true)
	amount.TextXAlignment = Enum.TextXAlignment.Center
	amount.TextSize = 10
	return overlay
end
