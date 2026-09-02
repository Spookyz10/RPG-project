local PetsData = {}

PetsData.MaxLevel = 150
PetsData.PetLimit = 50

PetsData.Rarities = {
	Common = {
		"Bat",
		"Guest",
		"Chicken",
		"Skeleton",
		"Wolf",
		"Zombie",
		"Noob",
		"Chicken2",
		"Duck Floater",
		"weather woman",
		"Lifeguard",
		"Deep Diver",
		"Robber",
		"Small Dragon",
		"Twisty Pet",
		"Strawberry",
	},

	Uncommon = {
		"Knight",
		"Mech",
		"Minotaur",
		"Ninja",
		"Pirate",
		"Robot",
		"Wizard",
		"Sand Knight",
		"Plague Doctor",
		"Purple Ghost",
		"Rubber Man",
		"Director",
		"One Fist Man",
		"Elf",
		"Santa's Helper",
		"IceCream Sandwich",
		"Ghost Costume",
		"Witch",
		"Popstar",
		"Snow Angel",
	},

	Rare = {
		"Angel",
		"Astronaut",
		"Devil",
		"Ghost Princess",
		"Punk Master",
		"Future Vint",
		"Ice Queen",
		"Rhythmic Hero",
		"Lobster",
		"Light Soul",
		"Easter Bunny",
		"Baby Green Alien",
		"Zero Times Two",
		"Cupid's Assistant",
		"Takayama Ghoul",
		"Shadow Soul",
	},

	Legendary = {
		"Chronos",
		"8-Bit King",
		"Biggest Head",
		"Useless Wizard",
		"Sun Destroyer",
		"Demon Princess",
		"Anime Rap God",
		"Demon King",
		"Biggest Pumpkin",
	},

	Godly = {
		"Exclusive",
		"DIO",
	},
}

PetsData.BoxCost = {
	Common = 5000,
	Uncommon = 15000,
	Rare = 50000,
}

PetsData.BoxChances = {
	Common = { Common = 80, Uncommon = 20 },
	Uncommon = { Common = 30, Uncommon = 50, Rare = 20 },
	Rare = { Uncommon = 24, Rare = 65, Legendary = 10, Godly = 1 },
}

PetsData.FusionInfo = {
	Common = { Boost = 50, Cost = 1000 },
	Uncommon = { Boost = 100, Cost = 2500 },
	Rare = { Boost = 250, Cost = 7500 },
	Legendary = { Boost = 500, Cost = 10000 },
	Godly = { Boost = 1500, Cost = 15000 },
}

local RarityByName = {}

for rarity, list in PetsData.Rarities do
	for _, petName in list do
		RarityByName[petName] = rarity
	end
end

function PetsData:GetRarity(petName: string): string?
	return RarityByName[petName]
end

function PetsData:RollPet(boxRarity: string): (string?, string?)
	local Chances = PetsData.BoxChances[boxRarity]
	if not Chances then
		return nil, nil
	end

	local TotalWeight = 0
	for _, weight in Chances do
		TotalWeight += weight
	end

	local Roll = math.random() * TotalWeight
	local Current = 0

	for resultRarity, weight in Chances do
		Current += weight
		if Roll <= Current then
			local Pool = PetsData.Rarities[resultRarity]
			if Pool and #Pool > 0 then
				return Pool[math.random(1, #Pool)], resultRarity
			end
		end
	end

	return nil, nil
end

function PetsData:GetXPNeeded(level: number): number
	return (150 * (level + 2) * (level + 2) - 150 * (level + 2)) * 0.25
end

function PetsData:GetLevelBonuses(level: number): (number, number)
	local Capped = math.min(level, PetsData.MaxLevel)
	local DamagePercent = Capped / 2.857142857142857 / 100
	local HealthPercent = Capped / 2 / 100
	return DamagePercent, HealthPercent
end

return PetsData
