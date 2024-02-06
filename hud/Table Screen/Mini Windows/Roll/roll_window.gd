extends MiniWindow

@onready var roll_name := $RollName;
@onready var min_roll := $MinRoll;
@onready var max_roll := $MaxRoll;
@onready var mod := $Modifier;

func _on_roll_button_pressed():
	var val := randi_range(int(min_roll.text), int(max_roll.text));
	var modi = int(mod.text);
	
	if roll_name.text == "": roll_name.text = "Custom";
	
	var msg := str(MultiplayerManager.display_name, " got a [color=#ffff00]", roll_name.text, "[color=#888888] (", min_roll.text, "~", max_roll.text ,") [color=#ffffff] roll of [color=#ffff00]", val+modi, "[color=#888888] (", "[color=lime]" if val == int(max_roll.text) else "[color=red]" if val == int(min_roll.text) else "", val, "[color=#888888]+", modi,")[color=#ffffff].");
	
	if table_screen != null: table_screen.chatbox.system_msg(msg);
