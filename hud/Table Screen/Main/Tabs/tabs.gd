extends Control

const tabs = ["Party", "Roll", "Inventory", "Shop"];
const dmtabs = ["Party", "Roll", "Items", "Encounter", "Scenery", "FX"];

var table_screen:Control;
@onready var tab_bar = $TabBar;

var party_window_dm := preload("res://hud/Table Screen/Mini Windows/Party/party_window_dm.tscn");
var roll := preload("res://hud/Table Screen/Mini Windows/Roll/roll_window.tscn");

func _ready():
	for tab in dmtabs:
		tab_bar.add_tab(tab);

func _on_tab_bar_tab_clicked(tab):
	var window;
	if tab_bar.get_tab_title(tab) == "Party": 
		window = party_window_dm.instantiate();
	elif tab_bar.get_tab_title(tab) == "Roll": 
		window = roll.instantiate();
	
	for child in table_screen.mini_window.get_children(): child.queue_free();
	if window == null: return;
	table_screen.mini_window.add_child(window);
	window.table_screen = table_screen;
