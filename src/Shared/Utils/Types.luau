export type Stats = {
	Attack: number,
	Defense: number,
	CriticalChance: number,
	CriticalPower: number,
	Luck: number,
	Speed: number,
	Health: number,
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
	Level: number,
	MaxLevel: number,
	Data: { Stats: Stats },
	XP: number,
	Currencies: { [string]: { Amount: number } },
	Drops: Drop,
	RespawnTime: number,
	Zone: string,
	GlobalDrops: boolean?,
}

export type HitboxInfo = {
	Size: Vector3,
	Part: BasePart,
	Offset: (Vector3 | CFrame)?,
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
	Equipped: boolean,
}

export type ItemInfo = {
	SellsFor: number,
	ItemType: string,
	SubType: string?,
	Name: string,
	Stackable: boolean,
	Cap: number?,
	Icon: string,
	Rarity: string,
	Description: string,
	Level: number,
	ActionName: string,
}

export type ItemBase<T> = {
	Data: ItemInfo,
	Elligable: (self: T, Data: PlayerData) -> boolean,
	Action: (self: T, UUID: string) -> (),
	OnDropped: (self: T, Data: PlayerData) -> (),
}

export type Equipment = ItemBase<Equipment> & {
	Kind: "Equipment",
	Stats: Stats,
	Passive: string,
}

export type Consumable = ItemBase<Consumable> & {
	Kind: "Consumable",
	Amount: number,
	Stat: string,
}

export type Item = Equipment | Consumable

export type ItemTable = {
	[string]: { Chance: number, Amount: number },
}

export type PlayerData = {
	FirstTimeJoined: boolean,
	Level: number,
	XP: number,
	Inventory: { [string]: ItemData },
	Settings: {
		Music: boolean,
		CameraShake: boolean,
	},
	Equipment: {
		Weapon: string,
		Armor: string,
		Ring: string,
		Necklace: string,
	},
	MaxInventorySpace: number,
	CurrentInventorySpace: number,
	Skills: {
		Q: string,
		E: string,
		R: string,
	},
	UnlockedSkills: { string },
	Currencies: { [string]: number },
	UnlockedRecipes: { string },
	ExtraStats: Stats,
}

export type Skill = {
	Name: string,
	Cooldown: number,
	Multiplier: number,
	Activate: (self: Skill, Player: Entity) -> (),
	GetRequirement: (self: Skill, Data: PlayerData) -> boolean,
}

export type Recipes = {
	Recipe: { [string]: { Amount: number } },
	GetRequirement: (Data: PlayerData) -> boolean,
}

export type Touch = {
	touchStarted: () -> (),
	touchEnded: () -> (),
}

return {}
