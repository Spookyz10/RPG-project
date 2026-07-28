local BuffsManager = {}

local Buffed = {}

-- [[ Buffed = {[Entity] = {Damage, Defense}}

function BuffsManager:AddBuff(Entity: Model, Stat: string, Duration: number, Amount: number)
	Buffed[Entity][Stat] = Amount
	task.delay(Duration, function()
		Buffed[Entity][Stat] = nil
	end)
end

function BuffsManager:RemoveBuff(Entity: Model, Stat: string)
	if Buffed[Entity] and Buffed[Entity][Stat] then
		Buffed[Entity][Stat] = nil
	end
end

function BuffsManager:GetBuffAmount(Entity: Model, Stat: string): number
	return Buffed[Entity] and Buffed[Entity][Stat] or 0
end

return BuffsManager
