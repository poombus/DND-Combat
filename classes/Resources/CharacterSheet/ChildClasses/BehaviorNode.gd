extends Resource
class_name BehaviorNode

var condition:String = "default";
var skill_pool:PackedStringArray = [];

func pick_skill() -> Variant:
	if skill_pool.size(): return null;
	return skill_pool[randi_range(0, skill_pool.size()-1)];
