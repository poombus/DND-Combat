extends VBoxContainer

var indicator = preload("res://hud/Pawn/status_effect_indicator.tscn");

@onready var row1 = $Row1;
@onready var row2 = $Row2;

func update_display(status_effects:Array[StatusEffect]):
	var visible_count := row1.get_child_count()+row2.get_child_count();
	
	if status_effects.size() > visible_count:
		while visible_count < status_effects.size():
			var i = indicator.instantiate();
			if visible_count < 5: row1.add_child(i);
			elif visible_count < 10: row2.add_child(i);
			else:break;
			visible_count += 1;
	elif status_effects.size() < visible_count:
		while visible_count > status_effects.size():
			if visible_count <= 0: break;
			elif visible_count <= 5: row1.get_child(visible_count-1).queue_free();
			elif visible_count <= 10: row2.get_child(visible_count-6).queue_free();
			visible_count -= 1;
	
	var c = 0;
	for se in status_effects:
		if c < 5: row1.get_child(c).update_display(se);
		elif c < 10: row2.get_child(c).update_display(se);
		else: break;
		c += 1;
