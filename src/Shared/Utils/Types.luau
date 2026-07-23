export type Stats = {
	Attack: number,
	Defense: number,
	CriticalChance: number,
	CriticalPower: number,
}

export type EntityData = {
	Stats: Stats,
	HitList: { [Player]: number },
}

export type PlayerInfo = {
	Player: Player,
	HP: number,
	MaxHP: number,
	isPlayer: boolean,
}
export type MobInfo = {
	HP: number,
	MaxHP: number,
	XP: number,
	Gold: number,
	Data: EntityData,
	Model: Model,
	isPlayer: boolean,
	Drops: Drop,
}

export type HitboxInfo = {
	Size: Vector3,
	Position: Vector3 | CFrame,
	Drag: boolean,
	Time: number,
	OnHit: ((Model, PlayerInfo | MobInfo) -> ())?,
}

export type ItemData = {
	Enchants: {
		[string]: number,
	},
	Amount: number,
	Name: string,
}

export type EntityLike = {
	HP: number,
	MaxHP: number,
	Data: EntityData,
	Model: Model,
	isPlayer: boolean,
}

export type Drop = {
	[string]: { Chance: number, Amount: number },
}

export type ItemInfo = {
	SellsFor: number,
	ItemType: string,
	Name: string,
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

return {}
