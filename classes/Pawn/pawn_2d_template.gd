extends CharacterBody2D
class_name Pawn2D

var starting_pos:Vector2;

@export var char_sheet:CharacterSheet;
var stats := CombatStats.new(self);
var virtual_cs:CombatStats; #used during script making to predict outcomes
var virtual:bool = false;

@export var height:int = 0;

@onready var sprite := $"Sprite2D";
@onready var nameplate := $"Nameplate";
@onready var sdc := $"Speed Dice Container";
@onready var anim = $AnimationPlayer;

func _ready():
	#await get_tree().create_timer(1).timeout;
	char_sheet = char_sheet.duplicate();
	char_sheet.setup();
	stats.setup(char_sheet);
	nameplate.init(self);
	sdc.init(self);

func apply_friction(delta:float):
	pass;

func apply_knockback(source:Vector2, amount:int):
	velocity = (global_position-source).normalized()*amount;

func move_to():
	pass

func update_nameplate(): 
	if nameplate: nameplate.update_display();

func prune_speed_dice():
	var d_left = sdc.get_child_count();
	for sd in sdc.get_children(): if !sd.skill: sd.queue_free(); d_left -= 1;
	if d_left == 0: sdc.create_dummy_dice();

func get_speed_dice() -> Array[SpeedDice]:
	var sd_list:Array[SpeedDice] = [];
	for sd in sdc.get_children(): sd_list.push_back(sd);
	return sd_list;

func get_sdc() -> SpeedDiceContainer: return sdc;

func get_cs() -> CombatStats:
	return stats;

func setup_virtual_cs(): 
	#virtual_cs = combat_stats.deep_copy();
	stats.setup_virtual_cs();

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1: pass;
	else: return;
	GlobalSignals.emit_signal("pawn_clicked", self);
