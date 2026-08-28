local ModifierSystem = {}

export type Operation = "Add" | "Multiply" | "Override"

export type Modifier = {
	ID: string,
	Value: number,
	Operation: Operation,
	Priority: number,
	Source: any?,
}

local Modifiers: { [any]: { [string]: { [string]: Modifier } } } = {}

local function getPropertyModifiers(target: any, property: string): { [string]: Modifier }
	local targetModifiers = Modifiers[target]
	if not targetModifiers then
		targetModifiers = {}
		Modifiers[target] = targetModifiers
	end

	local propertyModifiers = targetModifiers[property]
	if not propertyModifiers then
		propertyModifiers = {}
		targetModifiers[property] = propertyModifiers
	end

	return propertyModifiers
end

function ModifierSystem:AddModifier(
	target: any,
	property: string,
	id: string,
	operation: Operation,
	value: number,
	priority: number?,
	source: any?
)
	local propertyModifiers = getPropertyModifiers(target, property)
	propertyModifiers[id] = {
		ID = id,
		Value = value,
		Operation = operation,
		Priority = priority or 0,
		Source = source,
	}
end

function ModifierSystem:RemoveModifier(target: any, property: string, id: string)
	local targetModifiers = Modifiers[target]
	if not targetModifiers then
		return
	end

	local propertyModifiers = targetModifiers[property]
	if not propertyModifiers then
		return
	end

	propertyModifiers[id] = nil

	if next(propertyModifiers) == nil then
		targetModifiers[property] = nil
	end

	if next(targetModifiers) == nil then
		Modifiers[target] = nil
	end
end

function ModifierSystem:ClearTarget(target: any)
	Modifiers[target] = nil
end

function ModifierSystem:ClearSource(target: any, source: any)
	local targetModifiers = Modifiers[target]
	if not targetModifiers then
		return
	end

	for property, propertyModifiers in targetModifiers do
		for id, modifier in propertyModifiers do
			if modifier.Source == source then
				propertyModifiers[id] = nil
			end
		end

		if next(propertyModifiers) == nil then
			targetModifiers[property] = nil
		end
	end

	if next(targetModifiers) == nil then
		Modifiers[target] = nil
	end
end

function ModifierSystem:GetModifiers(target: any, property: string): { Modifier }
	local propertyModifiers = Modifiers[target] and Modifiers[target][property]
	if not propertyModifiers then
		return {}
	end

	local list = {}
	for _, modifier in propertyModifiers do
		table.insert(list, modifier)
	end

	table.sort(list, function(a, b)
		return a.Priority < b.Priority
	end)

	return list
end

function ModifierSystem:Aggregate(target: any, property: string, baseValue: number): number
	local list = self:GetModifiers(target, property)

	local result = baseValue
	local overrideValue: number? = nil

	for _, modifier in list do
		if modifier.Operation == "Override" then
			overrideValue = modifier.Value
		end
	end

	if overrideValue ~= nil then
		result = overrideValue
	end

	for _, modifier in list do
		if modifier.Operation == "Add" then
			result += modifier.Value
		end
	end

	for _, modifier in list do
		if modifier.Operation == "Multiply" then
			result *= modifier.Value
		end
	end

	return result
end

return ModifierSystem
