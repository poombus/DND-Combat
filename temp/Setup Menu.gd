extends Control

var temp_sheets_path := "res://localdata/temp_character_sheets/";

@onready var parent := get_parent();
@onready var char_sheet_list := $"Pawns/CharSheetList";

func _ready():
	var files = [];
	var dir = DirAccess.open("res://localdata/temp_character_sheets/");
	dir.list_dir_begin();
	
	for file in dir.get_files():
		char_sheet_list.add_item(file);

func _on_add_player_pressed():
	var pn = parent.player_nub.instantiate();
	parent.t0.add_child(pn);
	var path = str("res://localdata/temp_character_sheets/", char_sheet_list.get_item_text(char_sheet_list.selected));
	pn.setup_char_sheet(path)
	pn.set_combat_screen(parent);


func _on_add_enemy_pressed():
	var en = parent.player_nub.instantiate();
	parent.t1.add_child(en);
	var path = str("res://localdata/temp_character_sheets/", char_sheet_list.get_item_text(char_sheet_list.selected));
	en.setup_char_sheet(path)
	en.set_combat_screen(parent);
