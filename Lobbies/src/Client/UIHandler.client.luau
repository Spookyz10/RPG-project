local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIModules = require(ReplicatedStorage.Shared.UI.Logic)

for _, UIModule in UIModules do
	if UIModule.Init then
		UIModule.Init()
	end
end
