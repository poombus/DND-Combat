extends Resource
class_name Skill

#Combat Actions that aren't spells

@export_category("Registry")
@export var id:String;
@export var display_name:String = "Unnamed Skill";
@export var description:String = "";
@export var flavor_text:String = "";

@export_category("Stats")
@export var modifier:int = 0;
@export var energy_cost = 5;
@export var weight = 1;

@export_category("Dice")
@export var type:_Enums.SKILL_TYPES = _Enums.SKILL_TYPES.MELEE;
@export var damage_type:_Enums.DMG_TYPES = _Enums.DMG_TYPES.FLAT;
@export var element_type:_Enums.DMG_ELEMENTS = _Enums.DMG_ELEMENTS.TRUE;
@export var dice:Array[Dice];
var counter_dice:Array[Dice];

func impose_self():
	for d in dice: d.impose_skill(self);
	for d in counter_dice: d.impose_skill(self);

func get_dice_data(ind:int) -> Dictionary:
	if ind > dice.size(): return dice[0].get_data();
	return dice[ind].get_data();

func deep_copy() -> Skill:
	var list := Utils.get_variable_list(self);
	var copy := Skill.new();
	for v in list: copy[v] = self[v];
	
	copy.dice = deep_copy_dice();
	copy.impose_self();
	
	return copy;

func deep_copy_dice() -> Array[Dice]:
	var new_dice:Array[Dice] = [];
	for d in dice: 
		new_dice.push_back(d.deep_copy());
		#print(new_dice[-1].dice_type);
	return new_dice;

func seperate_counter_dice():
	for i in range(dice.size()-1, -1, -1):
		if dice[i].dice_type != _Enums.DICE_TYPES.COUNTER: continue;
		counter_dice.push_front(dice[i].deep_copy());
		dice.remove_at(i);

func get_modifier(pawn:Pawn2D, stat:=_Enums.AS.STR) -> int:
	var final = modifier+pawn.get_cs().get_offense_level(stat);
	return final;

func has_offensive_dice() -> bool:
	for d in dice: if d.is_offensive(): return true;
	for d in counter_dice: if d.is_offensive(): return true;
	return false;
