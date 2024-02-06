extends HBoxContainer

var mini_dice = load("res://hud/Combat GUI/Skill Chain/mini_dice.tscn");

var num = 0;

func current_dice():
	if get_children().is_empty(): return null;
	return get_child(num).ref_dice;

func setup_chain(skill):
	clear_dice();
	for dice in skill.dice: add_dice(dice);
	for dice in skill.counter_dice: add_dice(dice);

func add_dice(dice):
	var md = mini_dice.instantiate();
	add_child(md);
	md.update_display(dice);
	md.ref_dice = dice;
	md.scale = Vector2(0.2,0.2);

func clear_dice():
	for child in get_children(): child.queue_free();

func remove_dice():
	if !get_children().is_empty(): get_child(-1).queue_free();
	if num > get_child_count()-1: num = get_child_count()-1;
