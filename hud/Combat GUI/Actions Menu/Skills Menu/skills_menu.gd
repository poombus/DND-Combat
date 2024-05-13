extends HBoxContainer

@onready var skill_list = $"Skill List";
@onready var skill_display = $"C/Skill Display".get_child(0);
var pawn:Pawn2D;
var selected:int = -1;

func _ready():
	if not (get_parent() is Window): list_skills(get_parent().cgui.cur_pawn);
	else: list_all_skills();

func list_all_skills():
	skill_list.clear();
	for i in Registry.skills.base.size():
		var s = Registry.skills.base.keys()[i];
		var skill = Registry.get_skill(str("base:",s));
		skill_list.add_item(str(skill.display_name));
		skill_list.set_item_metadata(i, skill);

func list_skills(_pawn:Pawn2D):
	if pawn == _pawn: return;
	pawn = _pawn;
	var skills = pawn.get_cs().skills;
	skill_list.clear();
	for i in skills.size():
		skill_list.add_item(str(skills[i].display_name));
		skill_list.set_item_metadata(i, skills[i]);

func _on_skill_list_item_selected(index):
	#if index == selected: confirm_selection(index);
	#else: select_skill(index);
	select_skill(index);

func select_skill(index):
	selected = index;
	skill_display.display(skill_list.get_item_metadata(index));
	confirm_selection(index);

func confirm_selection(index):
	if not GlobalMouseDiceTracker.selected: return;
	var skill = skill_list.get_item_metadata(index).deep_copy();
	GlobalMouseDiceTracker.selected.add_skill(skill);
