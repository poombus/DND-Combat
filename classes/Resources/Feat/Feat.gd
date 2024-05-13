extends Resource
class_name Feat

@export_category("Registry")
@export var id:String;
@export var display_name:String;

var tooltip:String; #Shorter description.

@export_category("Events")
@export var events:Array[EventListener];

@export_category("Stat Modifiers")
@export var stat_mods:StatModifiers;

var pawn:CombatStats;

func deep_copy() -> Feat:
	var list = Utils.get_variable_list(self);
	var copy = Feat.new();
	for v in list: copy[v] = self[v];
	return copy;

func event_triggered(_signal:String, source:Variant, data:Dictionary = {}):
	for e in events: if e.event_signal == _signal: e.event(self, source, data);
