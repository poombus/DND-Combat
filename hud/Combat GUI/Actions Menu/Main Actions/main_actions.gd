extends HBoxContainer

signal open_skills
signal open_items
signal open_spells
signal open_misc

func _on_items_gui_input(event):
	if not (event is InputEventMouseButton): return;
	if event.button_index != 1 or not event.pressed: return;
	print("items");

func _on_spells_gui_input(event):
	if not (event is InputEventMouseButton): return;
	if event.button_index != 1 or not event.pressed: return;
	print("spells");

func _on_misc_gui_input(event):
	if not (event is InputEventMouseButton): return;
	if event.button_index != 1 or not event.pressed: return;
	print("misc");


func _on_skills_pressed():
	get_parent().view_menu(1);

func _on_items_pressed():
	pass # Replace with function body.

func _on_spells_pressed():
	pass # Replace with function body.


func _on_misc_pressed():
	pass # Replace with function body.
