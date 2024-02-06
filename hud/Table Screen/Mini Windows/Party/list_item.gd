extends HBoxContainer

@onready var party_window = get_parent().get_parent();

@onready var display_name := $Name;
var id:int = -1;

func setup(p_name:String, p_id:int):
	if multiplayer.get_unique_id() != 1: $SetButton.visible = false;
	display_name.text = p_name;
	id = p_id;

func _on_set_button_pressed(): party_window.set_char_sheet(id);

func _on_view_button_pressed(): party_window.view_char_sheet(id);
