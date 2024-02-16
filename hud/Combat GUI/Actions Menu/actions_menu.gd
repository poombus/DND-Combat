extends Control

var viewing:int = 0;
var menu_resources := {
	"main_actions_res": preload("res://hud/Combat GUI/Actions Menu/Main Actions/main_actions.tscn"),
	"skills_menu_res": preload("res://hud/Combat GUI/Actions Menu/Skills Menu/skills_menu.tscn")
}

func view_menu(ind:int = viewing):
	viewing = ind;
	self.get_child(0).queue_free();
	var inst = menu_resources[menu_resources.keys()[viewing]].instantiate();
	self.add_child(inst);
