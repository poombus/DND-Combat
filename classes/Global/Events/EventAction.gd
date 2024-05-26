extends Resource
class_name EventAction

var description:String;
@export var conditions:Array[EventConditional];
@export var action:String;
var listener:EventListener;
var data:Dictionary;

func event_action(_listener:EventListener, _data := {}):
	data = _data;
	listener = _listener;
	for c in conditions:
		if c.check_conditional(true, true) == false: return;
	
	parse();

func parse():
	var split = Array(action.split(" ", false)); #action is 0, params is everything else
	if split.size() == 0: return;
	var a = split.pop_front();
	
	for s in split.size():
		split[s] = data_ref(split[s]);
	
	if self.has_method(a.to_lower()): self.call(a.to_lower(), split);
	else: print_rich("[color=red]Could not find action '%s'."%a);

func data_ref(s:String):
	match s:
		"main_target": return data.main_target;
		"self": return data.source;
		"potency": if listener.listener is StatusEffect: return listener.listener.potency;
	return s;

func fill_parameters(params:Array, default_data:Array) -> Array:
	while params.size() < default_data.size(): params[params.size()-1] = default_data[params.size()-1];
	return params;

func test(): print("test");

func inflict(p:Array):
	#inflict target status potency count
	p = fill_parameters(p, [null, null, 0, 0]);
	if not p[0] is CombatStats: print_rich("[color=red] Could not inflict status on %s."%p[0]); return;
	elif p[1] == null: print_rich("[color=red] No status provided."); return;
	p[0].apply_status_effect(p[1], int(p[2]), int(p[3]));

func damage(p:Array):
	#damage target amount element type [hp/sr/both] [bool:ignore stagger?]
	p = fill_parameters(p, [null, 0, "normal", "flat", "both", false]);
	if not p[0] is CombatStats: print_rich("[color=red] Could not damage %s."%p[0]); return;
	var el = DamageInstance.DMG_ELEMENTS[p[2].to_upper()];
	var ty = DamageInstance.DMG_TYPES[p[3].to_upper()];
	var di = DamageInstance.new(int(p[1]), el, ty);
	
	if p[4] == "hp": di.affect_sr = false;
	elif p[4] == "sr": di.affect_hp = false;
	
	if p[5] == "true": di.ignore_stagger = true;
	
	p[0].apply_damage(di);

func sanity(p:Array):
	#sanity target [add/remove/set] amount
	p = fill_parameters(p, [null, "add", 0]);
	if not p[0] is CombatStats: print_rich("[color=red] Could not damage %s."%p[0]); return;
	if not ["add","remove","set"].has(p[1]): print_rich("[color=red] No operation named '%s'. Must be 'add', 'remove', or 'set'."%p[1])
	
	if p[1] == "add": p[0].heal_sp(p[2]);
	elif p[1] == "remove": p[0].dmg_sp(p[2]);
	elif p[1] == "set": p[0].sp = p[2];
