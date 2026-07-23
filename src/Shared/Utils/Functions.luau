local HttpService = game:GetService("HttpService")
local Functions = {}

local Types = require(script.Parent.Types)

function Functions:getDistance(part1: BasePart, part2: BasePart): number
	return (part1.Position - part2.Position).Magnitude
end

function Functions:isEntityAlive(class: Types.EntityLike): boolean
	return class.HP > 0
end

function Functions:isClassMob(class: Types.EntityLike): boolean
	return class.isPlayer
end

function Functions:GenUUID(): string
	return HttpService:GenerateGUID(false)
end

return Functions
