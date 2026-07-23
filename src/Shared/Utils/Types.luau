export type Stats = {
	Attack: number,
	Defense: number,
	CriticalChance: number,
	CriticalPower: number,
	Luck: number,
}

export type Entity = {
	HP: number,
	MaxHP: number,
	HitList: { [Player]: number },
	Model: Model,
	Buffs: {
		[string]: { Value: number, Duration: number },
	},
}

export type Drop = {
	[string]: { Chance: number, Amount: number },
}

export type MobInfo = {
	HP: number,
	MaxHP: number,
	Data: { Stats: Stats },
	XP: number,
	Gold: number,
	Drops: Drop,
	RespawnTime: number,
}

export type HitboxInfo = {
	Size: Vector3,
	Part: BasePart,
	Offset: Vector3 | CFrame,
	Drag: boolean,
	Time: number,
	OnHit: ((Model, Entity) -> ())?,
}

export type ItemData = {
	Enchants: {
		[string]: number,
	},
	Upgrades: number,
	Amount: number,
	Name: string,
}

export type ItemInfo = {
	SellsFor: number,
	ItemType: string,
	Name: string,
	Stackable: boolean,
}

export type Equipment = {
	Stats: Stats,
	Passive: string,
	Data: ItemInfo,
}

export type Consumable = {
	Amount: number,
	Stat: string,
	Data: ItemInfo,
}

export type ItemTable = {
	[string]: { Chance: number, Amount: number },
}

return {}
