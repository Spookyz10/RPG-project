local Abbreviate = {}

local Suffixes = {
	"",
	"K",
	"M",
	"B",
	"T",
	"Qd",
	"Qt",
	"Sx",
	"Sp",
	"Oc",
	"No",
}

local THRESHOLD = 1000
local DECIMALS = 2

function Abbreviate:Number(amount: number): string
	if amount < 999.5 then
		return tostring(math.floor(amount))
	end

	local Tier = 0
	local Value = amount

	while Value >= THRESHOLD and Tier < #Suffixes - 1 do
		Value /= THRESHOLD
		Tier += 1
	end

	local Multiplier = 10 ^ DECIMALS
	Value = math.floor(Value * Multiplier) / Multiplier

	local Formatted = string.format("%." .. DECIMALS .. "f", Value)
	Formatted = Formatted:gsub("0+$", ""):gsub("%.$", "")

	return Formatted .. Suffixes[Tier + 1]
end

return Abbreviate
