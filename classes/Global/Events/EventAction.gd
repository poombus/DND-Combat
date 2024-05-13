extends Resource
class_name EventAction

@export var description:String;
@export var conditions:Array[EventConditional];
@export var action:ACTS;
@export var params:String;
var parsed_params:Dictionary;
var listener:EventListener;
var data:Dictionary;

enum ACTS { #list of actions
	TEST = 0,
	SELF_HEAL,
	SELF_DAMAGE,
	DEAL_DAMAGE,
	INFLICT_STATUS,
	STAT_CHANGE,
	APPLY_HIDDEN_STAT,
	GAIN_DICE_POWER_SELF,
	LOSE_DICE_POWER_SELF
}

func event_action(_listener:EventListener, _data := {}):
	data = _data;
	listener = _listener;
	parsed_params = Utils.parse_params(params, data, listener);
	for c in conditions:
		if c.check_conditional(true, true) == false: return;
	
	var action_name = ACTS.keys()[action].to_lower();
	self.call(action_name);
	#print(listener.event_signal, ": ", listener.listener.pawn.pawn.char_sheet.display_name);

func convert_params(p:Dictionary):
	for param in parsed_params:
		if !p.has(param): return null;
		var type = typeof(p[param]);
		p[param] = type_convert(parsed_params[param], type);
	return p;

func test(): print("test");

func self_heal():
	var p = convert_params({"amount": 0, "hp": true, "sr": false});
	if !p: return;
	data.source.heal_hp(p.amount);
	print(parsed_params);
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

func apply_hidden_stat():
	var p = convert_params({"name": "hidden_stat", "amount": 0, "target": 0});
	if !p: return;
	if p.target == 0: data.source.apply_hidden_stat(p.name, p.amount);
	else: data.target.apply_hidden_stat(p.name, p.amount);
	
func gain_dice_power_self():
	var p = convert_params({"amount": 0});
	if !p: return;
	data.source.apply_hidden_stat("dice_power", p.amount);

func lose_dice_power_self():
	var p = convert_params({"amount": 0});
	if !p: return;
	data.source.apply_hidden_stat("dice_power", -p.amount);
