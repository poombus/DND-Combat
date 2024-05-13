extends Resource
class_name CharacterSheet

@export var display_name:String; #readable name
var description:String; #description (will be seen by players)
@export var level:int = 1;

@export_category("Classification")
@export var race:_Enums.RACES = _Enums.RACES.HUMAN;

@export_category("Alignment")
@export var ethics:_Enums.ETHICS;
@export var morals:_Enums.MORALS;

@export_category("Extra")
@export var languages:PackedStringArray;
@export var senses:PackedStringArray;

@export_category("Health")
@export var maxhp:int = 20;
@export var hp:int = 20;
@export var maxsr:int = 20;
@export var sr:int = 20;
@export var sp:int = 0;

#Stats
@export_category("Stats")
@export var strength:int = 0;
@export var dexterity:int = 0;
@export var constitution:int = 0;
@export var intelligence:int = 0;
@export var wisdom:int = 0;
@export var charisma:int = 0;

var profBonus:int = 2; #extra value to add to rolls involving skill proficiencies
var skillProfs:Array; #skill proficiencies; acrobatics, animal handling, arcana, etc.

var conditions:Array[StatusEffect]; #status effects

@export var resistances:Resistances = Resistances.new(); #unless explicitly stated, dmg modifiers default to x1.0

#collection (dunno whether to use arrays or dicts)
@export_category("Skills")
@export var skill_ids:PackedStringArray;
var skills:Array[Skill];
var prepared_skills:Array[Skill];
@export var spell_ids:PackedStringArray;
var spells:Array;
var prepared_spells:Array;

@export_category("Feats")
@export var feat_ids:PackedStringArray; #feats and traits
var feats:Array[Feat];

@export_category("Inventory")
@export var inventory:Inventory = Inventory.new();

func setup():
	for i in skill_ids: skills.push_back(Registry.get_skill(i));
	for i in feat_ids: feats.push_back(Registry.get_feat(i).deep_copy());

func get_stat_total(stat:String):
	var total:int = 0;
	for i in inventory.get_equipped():
		if stat in i.stats: total += i.stats[stat];
	if stat in self: total += self[stat];
	return total;
