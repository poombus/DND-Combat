extends Resource
class_name AIBehavior

var nodes:Array[BehaviorNode];
var current_behavior:int = 0;

func choose_skill(options:Array[Skill]) -> Skill:
	var chosen_skill = nodes[current_behavior].pick_skill();
	if chosen_skill == null || !(chosen_skill is String): return options[randi_range(0, options.size()-1)];
	for o in options: if o.id == chosen_skill: return o;
	return options[randi_range(0, options.size()-1)];
