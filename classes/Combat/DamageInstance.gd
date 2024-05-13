extends Node
class_name DamageInstance

enum SOURCES {MISC = 0, FEAT, STATUS_EFFECT, SKILL}
var source_type:SOURCES = SOURCES.MISC;
var source = null; #if source type is applicable, what pawn was the cause?

var type:_Enums.DMG_TYPES = _Enums.DMG_TYPES.FLAT;
var element:_Enums.DMG_ELEMENTS = _Enums.DMG_ELEMENTS.TRUE;
var value:int = 0;
var multiplier:float = 1;

var affect_hp:bool = true;
var affect_sr:bool = true;

func _init(_value:int, _element:_Enums.DMG_ELEMENTS = _Enums.DMG_ELEMENTS.TRUE, _type:_Enums.DMG_TYPES = _Enums.DMG_TYPES.FLAT, _source_type:SOURCES = SOURCES.MISC, _source = null):
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

func apply_resistances(pawn:CombatStats) -> void:
	var cs:CombatStats = pawn.get_cs();
	multiplier *= cs.resistances.get_mult(_Enums.get_key("DMG_ELEMENTS", element));
	multiplier *= cs.resistances.get_mult(_Enums.get_key("DMG_TYPES", type));
	print(multiplier);
	
	if cs.staggered: multiplier *= (2+(cs.stagger_level-1)*0.5);

func get_final_damage() -> int: 
	var total:int = max(int(value*multiplier),1);
	return total;
