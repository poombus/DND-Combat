extends Node
#Autoloaded Script

var selected:SpeedDice;

var cur_dice:SpeedDice = null;
var source:SpeedDice = null;

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and cur_dice != null: source = cur_dice;
		elif not event.pressed and source != null: connect_dice(cur_dice); 

func focus_dice(dice:SpeedDice) -> void: 
	cur_dice = dice;
	
func unfocus_dice(dice:SpeedDice) -> void: 
	if cur_dice == dice: cur_dice = null;

func connect_dice(target:SpeedDice):
	if source == null or target == null: return;
	if _CM.phase == _CM.PHASES.SKILLS:
		if source != target || !source.selectable: return;
		
		if source == selected: unselect_dice();
		else: select_dice(source);
	elif _CM.phase == _CM.PHASES.TARGET:
		if !source.selectable: return;
		if source == selected: unselect_dice();
		elif source.target != null: select_dice(source);
		
		if source == target: pass;
		elif source != target:
			source.target = target;
			select_dice(source);

func select_dice(dice):
	if selected != null: selected.unselected();
	selected = source;
	selected.selected();

func unselect_dice():
	if selected != null: selected.unselected();
	selected = null;
