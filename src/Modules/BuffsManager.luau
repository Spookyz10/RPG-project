local BuffsManager = {}

local Buffed = {}

-- [[ Buffed = {[Player] = {Damage, Defense}}

function BuffsManager:AddBuff(Player: Player, Stat: string, Duration: number, Amount: number)
	Buffed[Player][Stat] = Amount
	task.delay(Duration, function()
		Buffed[Player][Stat] = nil
	end)
end

function BuffsManager:RemoveBuff(Player: Player, Stat: string)
	if Buffed[Player] and Buffed[Player][Stat] then
		Buffed[Player][Stat] = nil
	end
end

function BuffsManager:GetBuffAmount(Player: Player, Stat: string)
	return Buffed[Player] and Buffed[Player][Stat]
end

return BuffsManager
