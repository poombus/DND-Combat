extends HBoxContainer
class_name SpeedDiceContainer

@onready var dice_res = preload("res://hud/speed_dice.tscn");

@onready var pawn:Pawn2D = get_parent() if get_parent() is Pawn2D else null;
var sd_count:int = 2;

func init(i_pawn:Pawn2D):
	pawn = i_pawn;
	#update_container(); #it.... breaks it...

func _ready():
	regenerate_container();

func regenerate_container():
	for dice in get_children():
		dice.queue_free();
	if !pawn.stats.is_staggered():
		for dice in sd_count:
			var new_dice = dice_res.instantiate();
			add_child(new_dice);
			if pawn: new_dice.init(pawn);
			else: print("NO PAWN FOUND FOR SPEED DICE. PROCEEDING ANYWAY.");
	else:
		create_dummy_dice();

func create_dummy_dice():
	var new_dice = dice_res.instantiate();
	new_dice.value = 0;
	new_dice.selectable = false;
	new_dice.dummy = true;
	add_child(new_dice);
	if pawn: new_dice.init(pawn);

func manually_add_dice(dice:SpeedDice):
	add_child(dice);
	dice.init(pawn);

func roll_speed_dice(index:int) -> void:
	if index >= get_child_count(): index = index % get_child_count();
	get_child(index).roll(1,6);

func roll_all_speed_dice() -> void:
	for dice in get_children(): if !dice.dummy: dice.roll(1,6);
