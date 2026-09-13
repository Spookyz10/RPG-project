local Remote = {}

function Remote:Activate(player: Player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health > 0 then return end
	player:SetAttribute("RespawnToken", (player:GetAttribute("RespawnToken") or 0) + 1)
	player:LoadCharacterAsync()
end

return Remote
