extends PanelContainer

@onready var display_name = $"ScrollContainer/VBoxContainer/Display Name/LineEdit";
@onready var level = $"ScrollContainer/VBoxContainer/Level/LineEdit";
@onready var race = $ScrollContainer/VBoxContainer/Race/OptionButton;
@onready var pclass = $ScrollContainer/VBoxContainer/Class/OptionButton;
@onready var ethics = $ScrollContainer/VBoxContainer/Ethics/OptionButton;
@onready var morals = $ScrollContainer/VBoxContainer/Morals/OptionButton;
@onready var languages = $ScrollContainer/VBoxContainer/Languages/LineEdit;
@onready var senses = $ScrollContainer/VBoxContainer/Senses/LineEdit;
@onready var strength = $ScrollContainer/VBoxContainer/Strength/LineEdit;
@onready var dexterity = $ScrollContainer/VBoxContainer/Dexterity/LineEdit;
@onready var constitution = $ScrollContainer/VBoxContainer/Constitution/LineEdit;
@onready var intelligence = $ScrollContainer/VBoxContainer/Intelligence/LineEdit;
@onready var wisdom = $ScrollContainer/VBoxContainer/Wisdom/LineEdit;
@onready var charisma = $ScrollContainer/VBoxContainer/Charisma/LineEdit;
@onready var hpoverride = $ScrollContainer/VBoxContainer/HPOverride/LineEdit;
@onready var sroverride = $ScrollContainer/VBoxContainer/SROverride/LineEdit;
@onready var skills = $"ScrollContainer/VBoxContainer/Skills/LineEdit";
@onready var spells = $"ScrollContainer/VBoxContainer/Spells/LineEdit";
@onready var feats = $"ScrollContainer/VBoxContainer/Feats/LineEdit";

func _ready():
	for e in _Enums.RACES.keys(): 
		race.add_item(e);
		race.set_item_metadata(race.item_count-1, _Enums.RACES[e]);
	for e in _Enums.CLASSES.keys(): 
		pclass.add_item(e);
		pclass.set_item_metadata(pclass.item_count-1, _Enums.CLASSES[e]);
	for e in _Enums.ETHICS.keys(): 
		ethics.add_item(e);
		ethics.set_item_metadata(ethics.item_count-1, _Enums.ETHICS[e]);
	for e in _Enums.MORALS.keys(): 
		morals.add_item(e);
		morals.set_item_metadata(morals.item_count-1, _Enums.MORALS[e]);


func _on_button_pressed():
	var charsheet = PlayerSheet.new();
	charsheet.display_name = display_name.text;
	charsheet.level = level.get_value();
	charsheet.race = race.get_item_metadata(race.get_selected_id());
	charsheet.pclass = pclass.get_item_metadata(pclass.get_selected_id());
	charsheet.ethics = ethics.get_item_metadata(ethics.get_selected_id());
	charsheet.morals = morals.get_item_metadata(morals.get_selected_id());
	for i in languages.text.split(",", false): charsheet.languages.append(i.strip_edges(true, true));
	for i in senses.text.split(",", false): charsheet.senses.append(i.strip_edges(true, true));
	charsheet.strength = strength.get_value();
	charsheet.dexterity = dexterity.get_value();
	charsheet.constitution = constitution.get_value();
	charsheet.intelligence = intelligence.get_value();
	charsheet.wisdom = wisdom.get_value();
	charsheet.charisma = charisma.get_value();
	charsheet.maxhp = hpoverride.get_value() if hpoverride.get_value() != -1 else 20;
	charsheet.hp = charsheet.maxhp;
	charsheet.maxsr = sroverride.get_value() if sroverride.get_value() != -1 else 15;
	charsheet.sr = charsheet.maxsr
	
	for i in skills.text.replace(" ", "").split(",", false): charsheet.skill_ids.append(i);
	for i in spells.text.replace(" ", "").split(",", false): charsheet.spell_ids.append(i);
	for i in feats.text.replace(" ", "").split(",", false): charsheet.feat_ids.append(i);
	
	if charsheet.display_name.replace(" ", "") == "": charsheet.display_name = "_";
	ResourceSaver.save(charsheet, "res://tools/character sheet tool/generated_data/%s.res" % charsheet.display_name.replace(" ", "_"));
	print("Saving Player Sheet!");
