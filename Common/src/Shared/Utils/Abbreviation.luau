local Abbreviation = {}

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

local function trim(value: string): string
	return value:gsub("(%..-)0+$", "%1"):gsub("%.$", "")
end

function Abbreviation:Number(amount: number, decimals: number?): string
	if type(amount) ~= "number" or amount ~= amount then
		return "0"
	end
	if amount == math.huge then
		return "INF"
	end
	if amount == -math.huge then
		return "-INF"
	end

	local places = DECIMALS
	if decimals ~= nil then
		places = math.max(0, math.floor(decimals))
	end
	local sign = amount < 0 and "-" or ""
	local absolute = math.abs(amount)
	if absolute < 999.5 then
		local multiplier = 10 ^ places
		local rounded = math.round(absolute * multiplier) / multiplier
		if rounded == 0 then
			sign = ""
		end
		return sign .. trim(string.format("%." .. places .. "f", rounded))
	end

	local tier = 0
	local value = absolute
	while value >= THRESHOLD and tier < #Suffixes - 1 do
		value /= THRESHOLD
		tier += 1
	end

	local multiplier = 10 ^ places
	value = math.round(value * multiplier) / multiplier
	if value >= THRESHOLD and tier < #Suffixes - 1 then
		value /= THRESHOLD
		tier += 1
	end

	return sign .. trim(string.format("%." .. places .. "f", value)) .. Suffixes[tier + 1]
end

function Abbreviation:Percent(amount: number, decimals: number?): string
	local places = decimals
	if places == nil then
		places = 1
	end
	return self:Number(amount, places) .. "%"
end

return Abbreviation
