return {
	None = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
	Common = ColorSequence.new(Color3.fromRGB(254, 255, 183)),
	Rare = ColorSequence.new(Color3.fromRGB(0, 255, 255)),
	Legendary = ColorSequence.new(Color3.fromRGB(255, 0, 166)),
	Godly = ColorSequence.new(Color3.fromRGB(255, 213, 0)),
	Ascendant = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(106, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
	}),
	Secret = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
	}),
}
