extends Control


@onready var parent = get_parent();

# Called when the node enters the scene tree for the first time.
func _ready():
	$Type.clear();
	for k in _Enums.DICE_TYPES.keys(): $Type.add_item(k);


func _on_add_pressed():
	if parent.selected_nub == null: return;
	var d = Dice.new();
	d.type = $Type.selected;
	d.min = int($Min.text);
	d.max = int($Max.text);
	parent.selected_nub.dice_chain.add_dice(d);


func _on_delete_pressed():
	if parent.selected_nub == null: return;
	parent.selected_nub.dice_chain.remove_dice();
