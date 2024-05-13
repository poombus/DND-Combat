extends Node

var feats:Dictionary = {};
var items:Dictionary = {};
var skills:Dictionary = {};
var effects:Dictionary = {};

func _ready(): manual_registration(); print("Registry is ready.");

func register(i, _group:String = ""):
	if _group == "": _group = "base";
	
	if i is Feat: add_feat(i, _group);
	elif i is Item: add_item(i, _group);
	elif i is Skill: add_skill(i, _group);
	elif i is StatusEffect: add_effect(i, _group);

func add_feat(i, group:String):
	if !feats.has(group): feats[group] = {};
	feats[group][i.id] = i;
	print("[Feat] Added ",group,":",i.id);

func add_item(i, group:String):
	if !items.has(group): items[group] = {};
	items[group][i.id] = i;
	print("[Item] Added ",group,":",i.id);

func add_skill(i, group:String):
	if !skills.has(group): skills[group] = {};
	skills[group][i.id] = i;
	print("[Skill] Added ",group,":",i.id);

func add_effect(i, group:String):
	if !effects.has(group): effects[group] = {};
	i.fullid = str(group,":",i.id);
	effects[group][i.id] = i;
	print("[StatusEffect] Added ",group,":",i.id);

func get_skill(id:String) -> Skill:
	var params = id.split(":");
	if params.size() == 1: params.insert(0, "base");
	var skill = skills[params[0]][params[1]];
	return skill;

func get_status_effect(id:String) -> StatusEffect:
	var params = id.split(":");
	if params.length == 1: params.insert(0, "base");
	var se = effects[params[0]][params[1]];
	if effects[params[0]].has(params[1]): se = effects[params[0]][params[1]];
	else: 
		se = StatusEffect.new();
		se.fullid = "base:unknown404";
		se.id = "unknown404";
		se.display_name = "Unknown";
		se.tooltip = "If you have this, then that means one of your status ailments doesn't exist!";
	return se;

func get_feat(id:String) -> Feat:
	var params = id.split(":");
	if params.size() == 1: params.insert(0, "base");
	var feat;
	if feats[params[0]].has(params[1]): feat = feats[params[0]][params[1]];
	else: 
		feat = Feat.new();
		feat.id = "unknown404";
		feat.display_name = "Unknown";
		feat.tooltip = "If you have this, then that means one of your features doesn't exist!";
	return feat;

func get_item(id:String) -> Item:
	var params = id.split(":");
	if params.size() == 1: params.insert(0, "base");
	var item:Item;
	if items[params[0]].has(params[1]): item = items[params[0]][params[1]];
	else:
		item = Item.new();
		item.id = "unknown404";
		item.display_name = "Unknown";
	return item;

func manual_registration():
	pass; #register(OBJ, "base");
