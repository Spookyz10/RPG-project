local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local StatusEffects = require(script.Parent.Parent.StatusEffectManager)
local Remote = require(RS.Shared.Utils.RemoteManager)
return {
	Execute = function(_, caster)
		local character = caster.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local hum = character and character:FindFirstChildOfClass("Humanoid")
		if not root or not hum or hum.Health <= 0 then return end
		Remote.SendClientEvent("SkillVFX", { All = true }, "Renewal", character)
		for _, player in Players:GetPlayers() do
			local target = player.Character
			local targetRoot = target and target:FindFirstChild("HumanoidRootPart")
			if targetRoot and (targetRoot.Position - root.Position).Magnitude <= 20 then
				StatusEffects:Apply(target, "Renewal", { Source = character })
			end
		end
	end,
}
