extends Resource
class_name Dice

var skill:Skill;
var skill_name:String = "";

@export var dice_type:_Enums.DICE_TYPES = _Enums.DICE_TYPES.OFFENSE;

@export_category("Roll Range")
@export_range(0,999) var low:int = 1;
@export_range(0,999) var high:int = 20;

#Damage Types
var damage_type:DamageInstance.DMG_TYPES = DamageInstance.DMG_TYPES.FLAT;
var element_type:DamageInstance.DMG_ELEMENTS = DamageInstance.DMG_ELEMENTS.NORMAL;

@export_category("Effects")
@export var events:Array[EventListener];

func _init(i_min:int = 1, i_max:int = 20, i_dmgtype = _Enums.DMG_TYPES.FLAT, i_eletype = _Enums.DMG_ELEMENTS.TRUE):
	low = i_min;
	high = i_max;
	damage_type = i_dmgtype;
	element_type = i_eletype;

func impose_skill(_skill:Skill):
	skill = _skill;
	skill_name = skill.display_name;
	damage_type = skill.damage_type;
	element_type = skill.element_type;

func roll(advantage:float = 0, pawn:CombatStats = null) -> int:
	var r = apply_dice_power();
	
	if pawn: r = apply_dice_power(
		pawn.get_stat_modi("dice_power"),
		pawn.get_stat_modi("min_power"),
		pawn.get_stat_modi("max_power"),
	);
	r[0] = max(0, r[0]);
	r[1] = max(0, r[1]);
	
	#var val = randi_range(0,r[1]-r[0]);
	#var disadvantage = advantage < 0;
	#for i in absi(advantage):
	#	var new_val = randi_range(0,r[1]-r[0]);
	#	if disadvantage: val = mini(val, new_val);
	#	else: val = maxi(val, new_val);
	#	if val == r[1]-r[0]: break;
	
	var val = skewed_roll(r[0], r[1], advantage);
	if r[0] > r[1]: return r[1]-val;
	return val+r[0];

func custom_roll(low:int = 1, high:int = 20, advantage:int = 0) -> int: 
	var val = randi_range(0,high-low);
	#print("val ",val);
	var disadvantage = advantage < 0;
	for i in absi(advantage):
		var new_val = randi_range(0,high-low);
		if disadvantage: val = mini(val, new_val);
		else: val = maxi(val, new_val);
		#print("reroll ", new_val, " // keep ", new_val == val);
		if val == high-low: break;
	
	if low > high: return high-val;
	return val+low;

func skewed_roll(low:int = 1, high:int = 20, skew:float = 0) -> int:
	return clampi(roundi(custom_roll(low, high)*(1+randf()*skew)), low, high);
	#More controlled advantage. (For combat perhaps?)

func get_average() -> float: return (float(low)+float(high))/2;

func get_data() -> Dictionary:
	var data = {};
	
	data.min = low;
	data.max = high;
	data.damage_type = damage_type;
	data.element_type = element_type;
	return data;

func get_type_string() -> String: return _Enums.DICE_TYPES.keys()[dice_type];

func deep_copy() -> Dice:
	var dice = Dice.new();
	dice.skill = skill;
	dice.dice_type = dice_type;
	dice.low = low;
	dice.high = high;
	dice.damage_type = damage_type;
	dice.element_type = element_type;
	dice.events = events;
	return dice;

func is_counter() -> bool: return dice_type == _Enums.DICE_TYPES.COUNTER;

func is_offensive() -> bool: return dice_type == _Enums.DICE_TYPES.OFFENSE || dice_type == _Enums.DICE_TYPES.COUNTER;

func is_defensive() -> bool: return !is_offensive();

func is_guard() -> bool: return dice_type == _Enums.DICE_TYPES.GUARD;

func is_evade() -> bool: return dice_type == _Enums.DICE_TYPES.EVADE;

func get_damage_type() -> DamageInstance.DMG_TYPES: return skill.damage_type;

func get_element_type() -> DamageInstance.DMG_ELEMENTS: return skill.element_type;

func event_triggered(_signal:String, source, data = {}):
	for e in events: if e.event_signal == _signal: e.event(self, self, data);

func is_minus_dice() -> bool: return true if low > high else false;

func apply_dice_power(dice_power:int = 0, floor_power:int = 0, ceil_power:int = 0) -> PackedInt32Array:
	var floor := high if is_minus_dice() else low;
	var ceil := low if is_minus_dice() else high;
	floor += dice_power + floor_power;
	ceil += dice_power + ceil_power;
	
	return [ceil, floor] if is_minus_dice() else [floor, ceil];
