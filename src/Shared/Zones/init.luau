local Zones = {}

for _, zone in script:GetDescendants() do
	if zone:IsA("ModuleScript") then
		Zones[zone.Name] = require(zone)
	end
end
