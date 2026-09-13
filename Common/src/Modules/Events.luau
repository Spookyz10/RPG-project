local Events = {}

local EventMultipliers = {
	Currencies = {
		Gold = 1,
	},
	XP = 1,
	Luck = 1,
}

local function IsWeekend(): boolean
	local currentDay = os.date("*t").wday
	return currentDay == 1 or currentDay == 7
end

function Events:GetEventMultipliers()
	if IsWeekend() then
		return {
			Currencies = {
				Gold = 1.25,
			},
			XP = 1.25,
			Luck = 1.1,
		}
	else
		return EventMultipliers
	end
end

return Events
