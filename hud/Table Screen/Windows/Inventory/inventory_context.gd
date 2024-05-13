extends Control

@onready var list = $Container/VBoxContainer;
signal close_context_menu;
signal equip;
signal unequip;
signal give;
signal takel
signal drop;
signal buy;
signal sell;

func toggle_buttons(item:Item, location:String = "inventory"):
	var buttons:PackedStringArray = [];
	match location:
		"inventory":
			buttons = ["Give", "Drop"];
			if item is EquippableItem: buttons.push_back("Equip");
		"equipment":
			buttons = ["Unequip", "Give", "Drop"];
	
	for c in list.get_children(): c.visible = false;
	for n in buttons: list.get_node(n.to_pascal_case()).visible = true;

func _on_mouse_exited(): emit_signal("close_context_menu");

func _on_equip_pressed(): emit_signal("equip");

func _on_unequip_pressed(): emit_signal("unequip");

func _on_give_pressed(): emit_signal("give");

func _on_take_pressed(): emit_signal("take");

func _on_drop_pressed(): emit_signal("drop");

func _on_buy_pressed(): emit_signal("buy");

func _on_sell_pressed(): emit_signal("sell");
