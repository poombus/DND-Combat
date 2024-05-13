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

func interp_params(params:Dictionary, data:Dictionary, _listener:EventListener):
	var listener = _listener.listener;
	for p in params:
		var val = str(params[p]);
		var pos:int = val.find("{", 0);
		var end:int = val.find("}", pos+1);
		while pos != -1 && end != -1:
			var code:String = val.substr(pos+1, end-pos-1);
			if listener is StatusEffect:
				if code == "potency": params[p] = listener.potency;
				elif code == "count": params[p] = listener.count;
			else:
				pass;
				#params[p] = special_parse(code, data);
			
			if val is String:
				pos = val.find("{", end+1);
				end = val.find("}", pos+1);
			else: break;
	return params;

func parse_params(params:String, data:Dictionary, _listener:EventListener) -> Dictionary:
	if params == "" or params == null: return {};
	
	var json = JSON.parse_string(params);
	if json == null: return {};
	else: json = Dictionary(json);
	for k in json.keys(): 
		if not (json[k] is String): continue;
		json[k] = json[k].format(data);
		json[k] = special_parse(json[k], data);
		var expr = Expression.new();
		var err = expr.parse(json[k]);
		if err != OK: print(expr.get_error_text()); continue;
		var result = expr.execute();
		if not expr.has_execute_failed(): json[k] = result;
	return json;

func special_parse(str:String, data:Dictionary) -> String:
	var pos:int = str.find("{", 0);
	var end:int = str.find("}", pos+1);
	while pos != -1 && end != -1:
		var code:String = str.substr(pos+1, end-pos-1);
		var path:PackedStringArray = code.split(".", false);
		var ind := -1;
		var value;
		for s in path:
			ind += 1;
			if !value: value = data[s];
			if s == "status_effects":
				var se = value.get_status_effect(path[ind+1]);
				if !se: return str(str);
				if path.size() >= ind+3: value = se[path[ind+2]];
	return str(str);

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
