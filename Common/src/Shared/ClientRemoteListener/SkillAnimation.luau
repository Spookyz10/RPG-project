local Motion = require(game:GetService("ReplicatedStorage").Shared.MobAnimations)
return {
	Activate = function(_, character, name, startedAt)
		if character and character:IsDescendantOf(workspace) then
			Motion:Play(character, name, startedAt)
		end
	end,
}
