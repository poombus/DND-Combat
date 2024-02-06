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
				params[p] = subcode_parser(code, data);
			
			if val is String:
				pos = val.find("{", end+1);
				end = val.find("}", pos+1);
			else: break;
	return params;

func subcode_parser(code:String, data:Dictionary):
	var subcodes:PackedStringArray = code.split("/", false);
	var ind := -1;
	var value;
	for s in subcodes:
		ind += 1;
		if !value: value = data[s];
		if s == "se":
			var se = value.get_status_effect(subcodes[ind+1]);
			if !se: return 0;
			if subcodes.size() >= ind+3: value = se[subcodes[ind+2]];
	return value;

func round_to(num:float, digit:int = 0) -> float: return round(num*pow(10, digit)) / pow(10, digit);
