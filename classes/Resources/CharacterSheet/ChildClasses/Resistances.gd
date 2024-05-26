extends Resource
class_name Resistances

@export_category("Primary Damage Types")
@export var slash:float = 1.0;
@export var blunt:float = 1.0;
@export var pierce:float = 1.0;

@export_category("Secondary Damage Types")
@export var normal:float = 1.0;
@export var cold:float = 1.0;
@export var fire:float = 1.0;
@export var force:float = 1.0;
@export var lightning:float = 1.0;
@export var necrotic:float = 1.0;
@export var poison:float = 1.0;
@export var psychic:float = 1.0;
@export var radiant:float = 1.0;
@export var thunder:float = 1.0;

func get_mult(s:String):
	if s.to_lower() in self: return self[s.to_lower()];
	else: return 1.0;

func get_total_mult(pri:String = "slash", sec:String = "normal"):
	var p_mult = self[pri] if self[pri] else 1.0;
	var s_mult = self[sec] if self[sec] else 1.0;
	return p_mult*s_mult;
