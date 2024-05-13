extends EquippableItem
class_name WeaponItem

enum WEAPON_TYPES {SHORTSWORD = 0, GREATSWORD, DAGGER, CLUB, AXE, SPEAR, MACE, STAFF, SICKLE, SCYTHE, BOW, CROSSBOW, GLAIVE, RAPIER, LANCE}
@export var weapon_types:Array[WEAPON_TYPES] = [];
@export var whitelist:bool = true; #true = is listed weapon types, false = is everything except weapon types

var unique_skills:Array[Skill] = [];

func is_type(type:WEAPON_TYPES) -> bool:
	if whitelist and weapon_types.has(type): return true;
	elif not whitelist and weapon_types.has(type): return false;
	return true;
