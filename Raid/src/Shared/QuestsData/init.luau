local quests = {}

for _, quest in script:GetDescendants() do
	if quest:IsA("ModuleScript") then
		quests[quest.Name] = require(quest)
	end
end

return quests
