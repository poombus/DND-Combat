extends PanelContainer

var pawns:Array[Pawn2D];

func setup(pawn1:Pawn2D, pawn2:Pawn2D):
	pawns = [pawn1, pawn2];
	$HBoxContainer/Pawn1/Name.text = str("[left]", pawn1.char_sheet.display_name, "[/left]");
	$HBoxContainer/Pawn2/Name.text = str("[right]", pawn2.char_sheet.display_name, "[/right]");

func set_dice(left:bool, dice, value):
	var dice_display = $"HBoxContainer/Pawn1/Mini Dice" if left else $"HBoxContainer/Pawn2/Mini Dice";
	
	dice_display.modulate = "#ffffff";
	if dice: dice_display.update_value(dice, value);

func set_clash(dice1, v1, dice2, v2):
	set_dice(true, dice1, v1);
	set_dice(false, dice2, v2);
	
	if v1 < v2 && $"HBoxContainer/Pawn2/Mini Dice".visible: $"HBoxContainer/Pawn1/Mini Dice".modulate = "#565656";
	elif v2 < v1 && $"HBoxContainer/Pawn1/Mini Dice".visible: $"HBoxContainer/Pawn2/Mini Dice".modulate = "#565656";

func toggle_dice(left:bool, show:bool):
	var dice_display = $"HBoxContainer/Pawn1/Mini Dice" if left else $"HBoxContainer/Pawn2/Mini Dice";
	
	dice_display.visible = show;
