extends Control

@onready var page1 := $"Page 1";
@onready var page2 := $"Page 2";
@onready var page3 := $"Page 3";

@onready var skill_list := $"Page 3/Skills/List";
@onready var skill_search_bar := $"Page 3/Skills/Search Bar";
@onready var skill_search_result := $"Page 3/Skills/Search Result";
var skill_search_cache := {};
var selected_skills:Array[String];

func _ready():
	for race in _Enums.RACES.keys(): $"Page 1/Race/OptionButton".add_item(race);
	$"Page 1/Race/OptionButton".select(_Enums.RACES.HUMAN+1);
	
	#for pclass in _Enums.CLASSES.keys(): $ContainerLeft/Class/Options.add_item(pclass);
	
	#for type in _Enums.TYPES.keys(): $ContainerLeft/Type/Options.add_item(type);
	
	for ethic in _Enums.ETHICS.keys(): $"Page 1/Ethics/OptionButton".add_item(ethic);
	
	for moral in _Enums.MORALS.keys(): $"Page 1/Morals/OptionButton".add_item(moral);

func _on_search_bar_text_changed(new_text):
	await get_tree().create_timer(0.5).timeout;
	var results;
	
	if skill_search_bar.text == new_text: results = GlobalBuilder.search_skills(new_text, skill_search_cache);
	else: return;
	
	skill_search_cache[new_text] = results;
	
	skill_search_result.clear();
	for r in results:
		skill_search_result.add_item(r);


func _on_search_result_item_selected(index):
	skill_search_result.deselect_all();
	if selected_skills.has(skill_search_result.get_item_text(index)): return;
	selected_skills.push_back(skill_search_result.get_item_text(index));
	skill_list.add_item(selected_skills[-1]);


func _on_skill_list_item_selected(index):
	selected_skills.pop_at(index);
	skill_list.remove_item(index);


func _on_next_page_pressed() -> void:
	if page1.visible: page1.visible = false; page2.visible = true; return;
	if page2.visible: page2.visible = false; page3.visible = true; return;
	if page3.visible: page3.visible = false; page1.visible = true; return;
	page1.visible = true;


func _on_generate_pressed():
	var data = {
		"display_name": $"Page 1/DisplayName".text,
		"description": $"Page 1/Description".text,
		"level": $"Page 2/Level/Value".get_value(),
		"typeclass": "",
		"race": _Enums.RACES.keys()[$"Page 1/Race/OptionButton".selected],
		"ethics": _Enums.ETHICS.keys()[$"Page 1/Ethics/OptionButton".selected],
		"morals": _Enums.MORALS.keys()[$"Page 1/Morals/OptionButton".selected],
		"languages": $"Page 1/Languages".text,
		"senses": $"Page 1/Senses".text,
		"maxhp": $"Page 2/Health/Value".get_value(),
		"hp": $"Page 2/Health/Value".get_value(),
		"maxsr": $"Page 2/Stagger/Value".get_value(),
		"sr": $"Page 2/Stagger/Value".get_value(),
		"profBonus": $"Page 2/ProfBonus/Value".get_value(),
		"skillProfs": [],
		"ability_scores": {
			"STR": {
				"value": $"Page 2/Stats/STR/Value".get_value(),
				"prof": $"Page 2/Stats/STR/CheckButton".button_pressed
			},
			"DEX": {
				"value": $"Page 2/Stats/DEX/Value".get_value(),
				"prof": $"Page 2/Stats/DEX/CheckButton".button_pressed
			},
			"CON": {
				"value": $"Page 2/Stats/CON/Value".get_value(),
				"prof": $"Page 2/Stats/CON/CheckButton".button_pressed
			},
			"INT": {
				"value": $"Page 2/Stats/INT/Value".get_value(),
				"prof": $"Page 2/Stats/INT/CheckButton".button_pressed
			},
			"WIS": {
				"value": $"Page 2/Stats/WIS/Value".get_value(),
				"prof": $"Page 2/Stats/WIS/CheckButton".button_pressed
			},
			"CHA": {
				"value": $"Page 2/Stats/CHA/Value".get_value(),
				"prof": $"Page 2/Stats/CHA/CheckButton".button_pressed
			}
		},
		"resistances": {},
		"skills": selected_skills,
		"spells": [],
		"inventory": [],
		"traits": []
	};
	
	for type in $"Page 2/Resistances".get_children():
		var value = type.get_child(1).get_value();
		if type.get_child(1).get_value() != 1: data.resistances[type.name] = value;
	
	#save(data);

func save(data):
	var filename:String = str(data.display_name.replace(" ", "_"), "_", floor(Time.get_unix_time_from_system()), ".json");
	print(filename);
	var file = FileAccess.open(str("res://tools/character sheet tool/generated_data/", filename),FileAccess.WRITE);
	file.store_string(JSON.stringify(data, "\t", false));
	file.close();
