extends Resource
class_name StatusEffect

var pawn:CombatStats;

@export_category("Registry")
var fullid:String; #group:id
@export var id:String;
@export var display_name:String;

var description:String; #Full description.
var tooltip:String; #Shorter description.

@export_category("Value Limits")
@export var max_potency:int = 99;
@export var max_count:int = 99;
var potency:int = 0;
var count:int = 0;
@export var decrease_on_turn_end:int = 0;

@export_category("Visibility")
var visible:bool = true;
var show_potency:bool = true;
var show_count:bool = true;


@export_category("Events")
@export var events:Array[EventListener];
func update_desc(): pass;

@export_category("Stat Modifiers")
@export var stat_mods:StatModifiers;

#effects code
func on_turn_start(turn:int): 
	update_desc();

func on_turn_end(turn:int):
	if decrease_on_turn_end >= 0: decrease_count();

func decrease_count(): 
	count -= decrease_on_turn_end;
	if count <= 0: remove_effect();

func remove_effect():
	pawn.status_effects.erase(self);

func deep_copy() -> StatusEffect:
	var list = Utils.get_variable_list(self);
	var copy = StatusEffect.new();
	for v in list: copy[v] = self[v];
	return copy;

func event_triggered(_signal:String, source:Variant, data:Dictionary = {}):
	for e in events: if e.event_signal == _signal: e.event(self, source, data);
