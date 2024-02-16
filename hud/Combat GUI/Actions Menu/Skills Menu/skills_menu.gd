extends HBoxContainer

@onready var skill_list = $"Skill List";
@onready var skill_display = $"C/Skill Display".get_child(0);
var selected:int = -1;

func list_all_skills():
	skill_list.clear();
	for i in Registry.skills.base.size():
		var s = Registry.skills.base.keys()[i];
		var skill = Registry.get_skill(str("base:",s));
		skill_list.add_item(str(skill.display_name));
		skill_list.set_item_metadata(i, skill);

func list_skills(skills:Array[Skill]):
	pass

func _ready():
	list_all_skills();

func _on_skill_list_item_selected(index):
	if index == selected: confirm_selection(index);
	else: select_skill(index);

func select_skill(index):
	selected = index;
	skill_display.display(skill_list.get_item_metadata(index));

func confirm_selection(index):
	print("selected ", skill_list.get_item_metadata(index).id);
