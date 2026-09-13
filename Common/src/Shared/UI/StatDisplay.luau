local Abbreviation = require(script.Parent.Parent.Utils.Abbreviation)
local Caps = require(script.Parent.Parent.getCappedInfo)

local StatDisplay = {}

function StatDisplay.Value(stat: string, value: number): string
	return stat == "Critical" and Abbreviation:Percent(value) or Abbreviation:Number(value)
end

function StatDisplay.PotionProgress(stat: string, added: number): string
	local maximum = Caps[stat]
	if not maximum then
		return ""
	end
	local current = math.clamp(added or 0, 0, maximum)
	local progress = "POTIONS  " .. Abbreviation:Number(current) .. "/" .. Abbreviation:Number(maximum) .. "  |  "
	return current >= maximum and (progress .. "MAX") or (progress .. Abbreviation:Number(maximum - current) .. " TO MAX")
end

function StatDisplay.PotionCompact(stat: string, added: number): string
	local maximum = Caps[stat]
	if not maximum then return "" end
	local current = math.clamp(added or 0, 0, maximum)
	if current >= maximum then
		return Abbreviation:Number(current) .. "/" .. Abbreviation:Number(maximum) .. "  |  MAX"
	end
	return Abbreviation:Number(current) .. "/" .. Abbreviation:Number(maximum) .. "  |  " .. Abbreviation:Number(maximum - current) .. " LEFT"
end

function StatDisplay.PotionRatio(stat: string, added: number): number
	local maximum = Caps[stat]
	if not maximum or maximum <= 0 then return 0 end
	return math.clamp((added or 0) / maximum, 0, 1)
end

function StatDisplay.ApplyPotion(row: Frame, stat: string, added: number)
	local cap = row:FindFirstChild("Cap")
	if cap and cap:IsA("TextLabel") then
		cap.Text = StatDisplay.PotionProgress(stat, added)
	end
	local potion = row:FindFirstChild("Potion", true)
	if potion and potion:IsA("TextLabel") then
		potion.Text = potion.Parent == row and StatDisplay.PotionCompact(stat, added) or StatDisplay.PotionProgress(stat, added)
	end
	local progress = row:FindFirstChild("Progress")
	local fill = progress and progress:FindFirstChild("Fill")
	if fill and fill:IsA("GuiObject") then
		fill.Size = UDim2.fromScale(StatDisplay.PotionRatio(stat, added), 1)
	end
end

function StatDisplay.ApplyRow(row: Frame, stat: string, total: number, added: number)
	local value = row:FindFirstChild("Value")
	if value and value:IsA("TextLabel") then
		value.Text = StatDisplay.Value(stat, total)
	end
	StatDisplay.ApplyPotion(row, stat, added)
end

return StatDisplay
