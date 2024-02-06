extends Control

@onready var parent = get_parent();

var d1:Dice;
var d2:Dice;

func update_display():
	if parent.left_nub != null:
		var d1 = parent.left_nub.dice_chain.current_dice();
		if d1 == null: 
			$D1Type.text = "EMPTY";
			$D1Result.text = "";
			return;
	if parent.right_nub != null:
		var d2 = parent.right_nub.dice_chain.current_dice();
		if d2 == null: 
			$D2Type.text = "EMPTY";
			$D2Result.text = "";
			return;

func _on_roll_pressed():
	if d1 != null: d1.roll();
	if d2 != null: d2.roll();


func _on_remove_pressed():
	if !$CheckButton.pressed: parent.left_nub.dice_chain.remove_dice();
	else: parent.right_nub.dice_chain.remove_dice();


func _on_next_pressed():
	if !$CheckButton.pressed: parent.left_nub.dice_chain.num += 1;
	else: parent.right_nub.dice_chain.num += 1;
