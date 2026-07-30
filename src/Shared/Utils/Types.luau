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
	OnHPChanged: RBXScriptSignal<number, number>,
	OnMaxHPChanged: RBXScriptSignal<number, number>,
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
	GlobalDrops: boolean?,
}

export type HitboxInfo = {
	Size: Vector3,
	Part: BasePart,
	Offset: (Vector3 | CFrame)?,
	Drag: boolean,
	Time: number,
	Caster: Model?,
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
	Kills: number,
	Deaths: number,
	PlayTime: number,
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
	MobIndex: { [string]: number },
}

export type SkillData = {
	Name: string,
	Cooldown: number,
	Multiplier: number,
	LevelRequirement: number,
	Elligable: (self: SkillData, Data: PlayerData) -> boolean,
}

export type Skill = SkillData & {
	Activate: (self: Skill, Player: Entity) -> (),
}

export type Recipes = {
	Recipe: { [string]: { Amount: number } },
	GetRequirement: (Data: PlayerData) -> boolean,
}

export type Touch = {
	touchStarted: () -> (),
	touchEnded: () -> (),
}

export type Zone = {
	Icon: string,
	Description: string,
	Level: number,
	MaxLevel: number,
	Mobs: { string },
	ApplyLighting: () -> (),
}

export type DialogueOption = {
	Text: string | ((PlayerData) -> string),
	Condition: ((PlayerData) -> boolean)?,
	Action: (self: DialogueOption, PlayerData: PlayerData, Goto: (node: string) -> (), Close: () -> ()) -> (),
}

export type DialogueNode = {
	Text: string | ((PlayerData) -> string),
	Options: { DialogueOption }?,
	Next: string?,
}

export type Dialogue = {
	[string]: DialogueNode,
}

return {}
