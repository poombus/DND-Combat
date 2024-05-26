extends Node

func frameFreeze(scale:float, duration:float):
	Engine.time_scale = scale;
	await get_tree().create_timer(duration*scale).timeout;
	Engine.time_scale = 1.0;

const dc_blacklist:PackedStringArray = [
	"RefCounted",
	"Resource",
	"resource_local_to_scene",
	"resource_path",
	"resource_name",
	"script"
];

func get_variable_list(object:Object) -> PackedStringArray:
	var list:PackedStringArray = [];
	for p in object.get_property_list():
		if dc_blacklist.has(p.name): continue;
		if p.type == 0: continue;
		list.push_back(p.name);
	return list;

func event_action_parse(action:String):
	pass;

func round_to(num:float, digit:int = 0) -> float: return round(num*pow(10, digit)) / pow(10, digit);

func schedule(function:Callable, delay:int):
	var timer = Timer.new();
	timer.connect("timeout", function);
	timer.connect("timeout", Callable(timer, "queue_free"));
	timer.wait_time = delay;
	get_tree().root.add_child(timer);
	timer.start();

func get_enum_key(_enum, ind:int) -> String:
	return _enum.keys()[ind];
