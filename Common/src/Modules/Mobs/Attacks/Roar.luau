local Players = game:GetService("Players")
local StunManager = require(game:GetService("ServerStorage").Modules.StunManager)
local StatusEffects = require(game:GetService("ServerStorage").Modules.StatusEffectManager)

return function(ctx)
	local root, indicator, pause, hit = ctx.Root, ctx.Indicator, ctx.Pause, ctx.Hit
	local cf = root.CFrame
	indicator("Circle", cf, Vector3.new(48, 0.15, 48), 1.8)
	ctx.VFX("Roar", ctx.Ground(cf), 1.1)
	if not pause(1.8) then return end
	local seen = {}
	hit(cf, Vector3.new(48, 12, 48), 24, 1.1, 75, false, seen)
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local part = character and character:FindFirstChild("HumanoidRootPart")
		if part and ctx.Alive(character) and (part.Position - root.Position).Magnitude <= 24 then
			StunManager:HardStun(player, 3)
			StatusEffects:Apply(character, "Dire Bear Roar", { Source = ctx.Mob })
		end
	end
end
