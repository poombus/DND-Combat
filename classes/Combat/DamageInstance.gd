extends Node
class_name DamageInstance

enum SOURCES {MISC = 0, FEAT, STATUS_EFFECT, SKILL}
var source_type:SOURCES = SOURCES.MISC;
var source = null; #if source type is applicable, what pawn was the cause?

enum DMG_TYPES {FLAT, BLUNT, PIERCE, SLASH}
enum DMG_ELEMENTS {NORMAL, COLD, FIRE, FORCE, LIGHTNING, NECROTIC, POISON, PSYCHIC, RADIANT, THUNDER, PALE}
var type:DMG_TYPES = DMG_TYPES.FLAT;
var element:DMG_ELEMENTS = DMG_ELEMENTS.NORMAL;
var value:int = 0;
var multiplier:float = 1;

var affect_hp:bool = true;
var affect_sr:bool = true;

var ignore_stagger:bool = false;

var was_crit:bool = false;

func _init(_value:int, _element:DMG_ELEMENTS = DMG_ELEMENTS.NORMAL, _type:DMG_TYPES = DMG_TYPES.FLAT, _source_type:SOURCES = SOURCES.MISC, _source = null):
	value = _value;
	element = _element;
	type = _type;
	source_type = _source_type;
	source = _source;

func apply_types(skill:Skill):
	type = skill.damage_type;
	element = skill.element_type;

func apply_modifiers(skill:Skill, attacker:CombatStats, target:CombatStats) -> void:
	var olevel = skill.get_modifier(attacker);
	var dlevel = target.get_cs().get_defense_level();
	
	if olevel >= dlevel: multiplier *= 1+(0.05*(olevel-dlevel));
	else: multiplier *= Utils.round_to(pow(0.97, dlevel-olevel), 3);
	
	var crit_chance = max((attacker.pawn.char_sheet.dexterity-10)*0.02+(attacker.get_stat_modi("crit_chance")/100), 0);
	if randf() <= crit_chance || was_crit: 
		was_crit = true;
		var crit_damage = 1.2+max(attacker.get_stat_modi("crit_damage"),0);
		var poise = attacker.get_status_effect("base:poise");
		if poise != null: 
			crit_damage += max(crit_chance-1, 0);
			poise.count -= 1;
		multiplier *= crit_damage;
		print("hit a x%.2f crit (%.2f%% chance)"%[crit_damage, crit_chance*100]);

func apply_resistances(pawn:CombatStats) -> void:
	var cs:CombatStats = pawn.get_cs();
	multiplier *= cs.resistances.get_mult(_Enums.get_key("DMG_ELEMENTS", element));
	multiplier *= cs.resistances.get_mult(_Enums.get_key("DMG_TYPES", type));
	
	if cs.staggered && !ignore_stagger: multiplier *= (2+(cs.stagger_level-1)*0.5);

func get_final_damage() -> int: 
	var total:int = max(int(value*multiplier),1);
	return total;
