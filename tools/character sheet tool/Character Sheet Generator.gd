extends Control

func _ready():
	for race in _Enums.RACES.keys(): $ContainerLeft/Race/Options.add_item(race);
	$ContainerLeft/Race/Options.select(_Enums.RACES.HUMAN+1);
	
	for pclass in _Enums.CLASSES.keys(): $ContainerLeft/Class/Options.add_item(pclass);
	
	for type in _Enums.TYPES.keys(): $ContainerLeft/Type/Options.add_item(type);
	
	for ethic in _Enums.ETHICS.keys(): $ContainerLeft/Ethics/Options.add_item(ethic);
	
	for moral in _Enums.MORALS.keys(): $ContainerLeft/Morals/Options.add_item(moral);
	
	for skill in GlobalBuilder.skills: $ContainerRight/SkillsDropdown.get_popup().add_item(skill.display_name);

func _on_player_bool_toggled(button_pressed):
	$ContainerLeft/Class.visible = button_pressed;
	$ContainerLeft/Type.visible = !button_pressed;

func _on_generate_pressed():
	var data = {
		"is_player": $ContainerLeft/PlayerBool.button_pressed,
		"display_name": $ContainerLeft/DisplayName.text,
		"description": $ContainerLeft/Description.text,
		"level": int($ContainerLeft/Level.text),
		"race": _Enums.RACES.keys()[$ContainerLeft/Race/Options.selected],
		"ethics": _Enums.ETHICS.keys()[$ContainerLeft/Ethics/Options.selected],
		"morals": _Enums.MORALS.keys()[$ContainerLeft/Morals/Options.selected],
		"languages": [],
		"senses": [],
		"maxhp": int($ContainerLeft/HP/Value.text),
		"hp": int($ContainerLeft/HP/Value.text),
		"maxsr": int($ContainerLeft/ST/Value.text),
		"sr": int($ContainerLeft/ST/Value.text),
		"profBonus": int($ContainerLeft/ProfBonus/Value.text),
		"skillProfs": [],
		"ability_scores": {
			"STR": {
				"value": int($ContainerMiddle/STR/LineEdit.text),
				"prof": $ContainerMiddle/STR/CheckButton.button_pressed
			},
			"DEX": {
				"value": int($ContainerMiddle/DEX/LineEdit.text),
				"prof": $ContainerMiddle/DEX/CheckButton.button_pressed
			},
			"CON": {
				"value": int($ContainerMiddle/CON/LineEdit.text),
				"prof": $ContainerMiddle/CON/CheckButton.button_pressed
			},
			"INT": {
				"value": int($ContainerMiddle/INT/LineEdit.text),
				"prof": $ContainerMiddle/INT/CheckButton.button_pressed
			},
			"WIS": {
				"value": int($ContainerMiddle/WIS/LineEdit.text),
				"prof": $ContainerMiddle/WIS/CheckButton.button_pressed
			},
			"CHA": {
				"value": int($ContainerMiddle/CHA/LineEdit.text),
				"prof": $ContainerMiddle/CHA/CheckButton.button_pressed
			}
		},
		"resistances": {},
		"skills": [],
		"spells": [],
		"inventory": [],
		"feats": []
	};
	
	if data.is_player: data["pclass"] = _Enums.CLASSES.keys()[$ContainerLeft/Class/Options.selected];
	else: data.type = _Enums.TYPES.keys()[$ContainerLeft/Type/Options.selected];
	
	for l in $ContainerLeft/Languages.text.split(","):
		if l == "": continue;
		if l.substr(0,1) == " ": l = l.substr(1);
		data.languages.append(l);
	
	for s in $ContainerLeft/Senses.text.split(","):
		if s == "": continue;
		if s.substr(0,1) == " ": s = s.substr(1);
		data.senses.append(s.substr(1) if s.substr(0,1) == " " else s);
	
	for sk in $ContainerLeft/SkillProfs.text.split(","):
		if sk == "": continue;
		if sk.substr(0,1) == " ": sk = sk.substr(1);
		data.skillProfs.append(sk.substr(1) if sk.substr(0,1) == " " else sk);
	
	for pair in $ContainerMiddle/Resistances.text.split(","):
		if pair == "": continue;
		if pair.substr(0,1) == " ": pair = pair.substr(1);
		
		pair = pair.split(":");
		data.resistances[pair[0].to_upper()] = float(pair[1]);
	
	save(data);

func save(data):
	var filename:String = str(data.display_name.replace(" ", "_"), "_", floor(Time.get_unix_time_from_system()), ".json");
	print(filename);
	var file = FileAccess.open(str("res://tools/character sheet tool/generated_data/", filename),FileAccess.WRITE);
	file.store_string(JSON.stringify(data, "\t", false));
	file.close();

func load(path):
	if not FileAccess.file_exists(path): return;
	var data = GlobalBuilder.json_parser(path);
