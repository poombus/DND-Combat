extends Node

#Player
enum AS{STR = 0, DEX, CON, INT, WIS, CHA}
const ability_scores = ["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"];

enum RACES{UNKNOWN = 0, DRAGONBORN, DWARF, ELF, GNOME, HALF_ELF, HALFLING, HALF_ORC, HUMAN, TIEFLING}

enum CLASSES {
	BARBARIAN = 0, 
	BARD, 
	CLERIC, 
	DRUID,
	FIGHTER, 
	MONK, 
	PALADIN, 
	RANGER, 
	ROGUE, 
	SORCERER, 
	WARLOCK, 
	WIZARD
}

enum ETHICS {LAWFUL = 0, NEUTRAL, CHAOTIC}
enum MORALS {GOOD = 0, NEUTRAL, EVIL}

enum NPC_TYPES {UNKNOWN = 0, RANDOM, ABERRATION, BEAST, CELESTIAL, CONSTRUCT, DRAGON, ELEMENTAL, FEY, FIEND, GIANT, HUMANOID, MONSTROSITY, OOZE, PLANT, UNDEAD}

#Skills
enum DMG_TYPES {FLAT, BLUNT, PIERCE, SLASH, ENERGY}
enum DMG_ELEMENTS {NORMAL, COLD, FIRE, FORCE, LIGHTNING, NECROTIC, POISON, PSYCHIC, RADIANT, NOISE, TRUE}

enum SKILL_TYPES {MELEE, RANGED, MASS, INSTANT}

enum DICE_TYPES {OFFENSE = 0, GUARD, EVADE, COUNTER};

#World
const LANGS:PackedStringArray = [
	"common",
	"dwarvish",
	"elvish",
	"giant",
	"gnomish",
	"goblin",
	"halfling",
	"orc",
	"abyssal",
	"celestial",
	"draconic",
	"deep speech",
	"infernal",
	"primordial",
	"sylvan",
	"undercommon"
];

const SENSES:PackedStringArray = [
	"blindsight",
	"darkvision",
	"tremorsense",
	"truesight"
]

#TRIGGERS
enum TRIGGERS {
	ON_TURN_START = 0, 
	ON_TURN_END, 
	ON_COMBAT_START, 
	ON_HIT,
	ON_DAMAGE_TAKEN,
	ON_DICE_ROLLED,
	ON_CLASH_START,
	ON_APPLIED,
	ON_REMOVED
}

enum RESPONSE {
	DEAL_DAMAGE = 0,
	HEAL_FLAT_SELF,
	APPLY_STATUS_TARGET
}

const element_colors = {
	"NORMAL": "#8a8a8a", 
	"COLD": "#29ffea", 
	"FIRE": "#ff9900", 
	"FORCE": "#ff0000",
	"LIGHTNING": "#eeff52", 
	"NECROTIC": "#299634",
	"POISON": "#00ff44",
	"PSYCHIC": "#ff00ea", 
	"RADIANT": "#fffbb5", 
	"NOISE": "#cd7dff",
	"TRUE": "#ffffff"
}

const dice_colors = {
	"OFFENSE": "#ff3d24",
	"GUARD": "#1ba5fa",
	"EVADE": "#1ba5fa",
	"COUNTER": "#bb00ff"
}

const expertise = {
	"str": ["athletics"],
	"dex": ["acrobatics", "sleight of hand", "stealth"],
	"con": [],
	"int": ["arcana", "history", "investigation", "nature", "religion"],
	"wis": ["animal handling", "insight", "medicine", "perception", "survival"],
	"cha": ["deception", "intimidation", "performance", "persuasion"]
}

func get_key(e:String, ind:int) -> String: return self[e].keys()[ind];
