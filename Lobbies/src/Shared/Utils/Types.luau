export type Stats = {
	Attack: number,
	Defense: number,
	Critical: number,
	Speed: number,
	Health: number,
}

export type PlayerData = {
	FirstTimeJoined: boolean,
	Level: number,
	XP: number,
	Kills: number,
	Deaths: number,
	PlayTime: number,
	Honor: number,
	Inventory: { [string]: ItemData },
	Storage: { [string]: ItemData },
	Pets: { [string]: PetData },
	Settings: {
		Music: boolean,
		CameraShake: boolean,
	},
	Equipment: {
		Weapon: string,
		Armor: string,
		Ring: string,
		Necklace: string,
		Aura: string,
		Rune: string,
	},
	Vanity: {
		Weapon: string,
		Aura: string,
	},
	MaxInventorySpace: number,
	CurrentInventorySpace: number,
	MaxStorageSpace: number,
	CurrentStorageSpace: number,
	Skills: {
		Q: string,
		E: string,
		R: string,
	},
	UnlockedSkills: { string },
	Currencies: { [string]: number },
	ExtraStats: Stats,
	MobIndex: { [string]: number },
	Quests: { [string]: QuestProgress },
	CompletedQuests: { [string]: QuestCompletion },
	LastDailyReward: number,
	TotalDailyRewards: number,
	DailyStreak: number,
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
	OnHit: ((Model, Model) -> ())?,
}

export type ItemData = {
	Enchants: {
		[string]: number,
	},
	Upgrades: number,
	Amount: number,
	Name: string,
	ID: string,
	Equipped: boolean,
	UpgradeCap: number,
}

export type ItemInfo = {
	SellsFor: number,
	ItemType: string,
	SubType: string?,
	Name: string,
	ID: string,
	Stackable: boolean,
	Cap: number?,
	Icon: string,
	Rarity: string,
	Description: string,
	Level: number,
	ActionName: string?,
}

export type ItemBase<T> = {
	Data: ItemInfo,
	Elligable: (self: T, Data: PlayerData) -> boolean,
	Action: (self: T, UUID: string) -> (),
	OnDropped: (self: T, Data: PlayerData) -> (),
	OnUse: (self: T, Data: PlayerData) -> ()?,
}

export type Equipment = ItemBase<Equipment> & {
	Kind: "Equipment",
	Stats: Stats,
	Passive: string,
	WeaponType: string,
	SkillOverrides: {
		[string]: {
			Name: string?,
			Icon: string?,
			Description: string?,
			Cooldown: number?,
			EffectValue: number?,
			EffectDuration: number?,
			HealPercent: number?,
		},
	}?,
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

export type SkillDefinition = {
	Name: string,
	Cooldown: number,
	Multiplier: number,
	LevelRequirement: number,
	Icon: string,
	Description: string,
	SkillType: string,
	Elligable: (self: SkillDefinition, Data: PlayerData) -> boolean,
}

export type SkillBehavior = {
	Execute: (self: SkillBehavior, caster: Player, definition: SkillDefinition) -> (),
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
	Order: number,
	Theme: Color3,
	getLighting: () -> (),
}

export type DialogueOption = {
	Text: string | ((PlayerData) -> string),
	Condition: ((PlayerData) -> boolean)?,
	Action: (self: DialogueOption, PlayerData: PlayerData, Goto: (node: string) -> (), Close: () -> ()) -> (),
}

export type DialogueNode = {
	Text: string | ((PlayerData) -> string),
	Options: { DialogueOption }?,
	Next: string | ((PlayerData) -> string),
	Action: ((self: DialogueNode, PlayerData: PlayerData, Goto: (node: string) -> (), Close: () -> ()) -> ())?,
}

export type Dialogue = {
	[string]: DialogueNode,
}

export type Shop = {
	[string]: { Cost: { [string]: number }, itemType: string },
}

export type QuestObjectiveType = "KillMob" | "CraftItem"

export type QuestObjective = {
	Type: QuestObjectiveType,
	Target: string,
	Amount: number,
}

export type QuestReward = {
	Currencies: { [string]: number }?,
	XP: number?,
	Items: { [string]: number }?,
}

export type QuestProgress = {
	Objectives: { [number]: number },
	StartedAt: number,
}

export type QuestCompletion = {
	Count: number,
	LastCompletedAt: number,
}

export type QuestInfo = {
	Name: string,
	Description: string,
	Repeatable: boolean,
	Cooldown: number?,
	RequiredLevel: number?,
	MaxLevel: number?,
	RequiredQuest: string?,
	SkipIfOverleveled: boolean?,
	Objectives: { QuestObjective },
	Rewards: QuestReward,
}

export type RaidInfo = {
	Name: string,
	RequiredLevel: number,
	Drops: { [string]: number },
	HCDrops: { [string]: number },
}

export type DamageContext = {
	Caster: Model,
	Victim: Model,
	CasterPlayer: Player?,
	VictimPlayer: Player?,
	Damage: number,
	IsCrit: boolean,
	Multiplier: number?,
	Tags: { string },
	Cancelled: boolean,
}

export type PetData = {
	Name: string,
	Level: number,
	Talent: string,
}

return {}
