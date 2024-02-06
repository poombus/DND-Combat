extends Resource
class_name EventAction

@export var conditions:Array[EventConditional];
@export var action:ACTS;
@export var params:Dictionary;
var listener:EventListener;
var data:Dictionary;

enum ACTS { #list of actions
	TEST = 0,
	SELF_HEAL,
	SELF_DAMAGE,
	DEAL_DAMAGE,
	INFLICT_STATUS,
	STAT_CHANGE
}

func event_action(_listener:EventListener, _data := {}):
	data = _data;
	listener = _listener;
	params = Utils.interp_params(params, data, listener);
	for c in conditions:
		if c.check_conditional(true, true) == false: return;
	
	var action_name = ACTS.keys()[action].to_lower();
	self.call(action_name);
	#print(listener.event_signal, ": ", listener.listener.pawn.pawn.char_sheet.display_name);

func convert_params(p:Dictionary):
	for param in params:
		if !p.has(param): return null;
		var type = typeof(p[param]);
		p[param] = type_convert(params[param], type);
	return p;

func test(): print(params.text);

func self_heal():
	var p = convert_params({"amount": 0, "hp": true, "sr": false});
	if !p: return;
	data.source.heal(p.amount);
	#if p.amount != 0: print("healed for ",p.amount);

func self_damage():
	var p = convert_params({"amount": 0, "hp": true, "sr": false});
	if !p: return;
	var di = DamageInstance.new(p.amount);
	di.affect_hp = p.hp;
	di.affect_sr = p.sr;
	data.source.apply_damage(di);
	#if p.amount != 0: print("damaged for ",p.amount);

func deal_damage():
	var p = convert_params({"amount": 0, "hp": true, "sr": false});
	if !p: return;
	var di = DamageInstance.new(p.amount);
	di.affect_hp = p.hp;
	di.affect_sr = p.sr;
	data.target.apply_damage(di);

func inflict_status():
	var p = convert_params({"id": "group:id", "potency": 0, "count": 0});
	if !p: return;
	data.target.apply_status_effect(p.id, p.potency, p.count);

func stat_change():
	var p = convert_params({"stat": "", "amount": 0});
	if !p: return;
