extends Node

func _ready():
	skillBuilder("res://assets/data/skills/");
	effectBuilder("res://assets/data/status_effects/");
	featBuilder("res://assets/data/feats/");
	print("Builder is finished.")

func skillBuilder(path:String):
	var dir = DirAccess.open(path);
	if not dir: print("[SKILLBUILDER] Directory \"", path, "\" does not exist..."); return;
	dir.list_dir_begin();
	var file_name = dir.get_next();
	while file_name != "": 
		if dir.current_is_dir(): file_name = dir.get_next(); continue;
		if file_name.split(".")[-1] != "tres": file_name = dir.get_next(); continue;
		var tres := ResourceLoader.load(path+file_name) as Skill;
		Registry.register(tres);
		file_name = dir.get_next();

func featBuilder(path:String):
	var dir = DirAccess.open(path);
	if not dir: print("[FEATBUILDER] Directory \"", path, "\" does not exist..."); return;
	dir.list_dir_begin();
	var file_name = dir.get_next();
	while file_name != "": 
		if dir.current_is_dir(): file_name = dir.get_next(); continue;
		if file_name.split(".")[-1] != "tres": file_name = dir.get_next(); continue;
		var tres := ResourceLoader.load(path+file_name) as Feat;
		Registry.register(tres);
		file_name = dir.get_next();

func diceBuilder(dice, skill_name:String = ""):
	var d = Dice.new();
	d.low = dice.minmax[0]; 
	d.high = dice.minmax[1];
	d.type = _Enums.DICE_TYPES[dice.type];
	
	if !dice.has('element'): 
		if d.is_offensive(): dice.element = "NORMAL";
		elif d.is_defensive(): dice.element = "NONE";
	
	d.element = _Enums.DMG_ELEMENTS[dice.element];
	
	d.skill_name = skill_name;
	
	return d;

func itemBuilder():
	pass

func effectBuilder(path:String):
	var dir = DirAccess.open(path);
	if not dir: print("[EFFECTBUILDER] Directory \"", path, "\" does not exist..."); return;
	dir.list_dir_begin();
	var file_name = dir.get_next();
	while file_name != "": 
		if dir.current_is_dir(): file_name = dir.get_next(); continue;
		if file_name.split(".")[-1] != "tres": file_name = dir.get_next(); continue;
		var tres := ResourceLoader.load(path+file_name) as StatusEffect;
		Registry.register(tres);
		file_name = dir.get_next();

func json_parser(file_path:String) -> Dictionary:
	var json_as_text = FileAccess.get_file_as_string(file_path);
	var json = JSON.parse_string(json_as_text);
	return json;

func search_skills(search_term:String, cached_results:Dictionary) -> Array[String]:
	var candidates:Array[String];
	
	var group:String;
	var id:String;
	
	var mode = "add";
	if cached_results.has(search_term): return cached_results[search_term];
#	else: for r in cached_results.keys(): 
#		if r.contains(search_term): 
#			#Broader search term - Add results
#			candidates.append_array(cached_results[r]);
#		elif search_term.contains(r): 
#			#Specified search term - Subtract results
#			candidates.append_array(cached_results[r]);
	
	if search_term.contains(":"):
		var s := search_term.split(":");
		group = s[0];
		id = s[1];
	else: id = search_term;
	
	if group != "": for s in Registry.skills[group].keys():
		if s.contains(id) || id == "": candidates.push_back(str(group, ":", s));
	else: for g in Registry.skills.keys(): for s in Registry.skills[g].keys(): 
		if s.contains(id): candidates.push_back(str(g, ":", s));
	
	return candidates;

func get_status_effect(id:String) -> StatusEffect:
	var params = id.split(":");
	var se = Registry.effects[params[0]][params[1]];
	return se;

