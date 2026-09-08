local WeldSystem = {}

function WeldSystem:Weld(PartA: BasePart, PartB: BasePart): WeldConstraint
	local Weld = Instance.new("WeldConstraint")
	Weld.Part0 = PartA
	Weld.Part1 = PartB
	Weld.Parent = PartA
	return Weld
end

return WeldSystem
