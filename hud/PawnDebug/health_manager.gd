extends PanelContainer

var pawn:Pawn2D;
var maxtarget:int = 150;
var target:int = 60;

@onready var target_option = $_/Target/Option;
@onready var math_option = $_/Math/Option;
@onready var type_option = $_/Type/Option;
@onready var element_option = $_/Element/Option;
@onready var numinput = $_/NumberInput;

func _ready():
	#Set Type Options
	type_option.clear();
	for t in _Enums.DMG_TYPES: type_option.add_item(t);
	#Set Element Options
	element_option.clear();
	for e in _Enums.DMG_ELEMENTS: element_option.add_item(e);
	inputs_changed();

func setup(_pawn:Pawn2D):
	pawn = _pawn;
	inputs_changed();

func inputs_changed():
	var val = numinput.get_value();
	if math_option.get_selected_id() == 0: show_change(val);
	elif math_option.get_selected_id() == 1: show_change(target+val);
	elif math_option.get_selected_id() == 2: show_change(target+(maxtarget*(val/100)));
	elif math_option.get_selected_id() == 3: show_change(target+((maxtarget-target)*(val/100)));
	elif math_option.get_selected_id() == 4: show_change(target+(target*(val/100)));

func show_change(new_val:int): 
	var color := "red";
	if new_val < 0: new_val = 0;
	elif new_val > maxtarget: new_val = maxtarget;
	if new_val >= target: color = "green";
	$_/MaxHP.text = str("Max: [color=green]",maxtarget);
	$_/HPChange.text = str("[color=yellow] ", target," [color=white] => [color=",color,"] ", new_val);

func _on_option_item_selected(index): inputs_changed();

func _input(event):
	if event is InputEventMouseButton:
		if not event.pressed: return;
		var e = event.position;
		var gp = global_position;
		if e.x < gp.x || e.x > gp.x+size.x: clicked_off();
		elif e.y < gp.y || e.y > gp.y+size.y: clicked_off();

func clicked_off(): print("Client clicked off of window.");
