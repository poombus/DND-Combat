extends Control

@onready var anim = $AnimationPlayer;

@onready var player_name = $Panel/Name;
@onready var lrc = $Panel/LevelRaceClass;
@onready var health_bar = $Panel/HealthBar
@onready var health_bar_text = $Panel/HealthBar/Label;
@onready var str = $Panel/Stats/StrContainer/Strength;
@onready var dex = $Panel/Stats/DexContainer/Dexterity;
@onready var con = $Panel/Stats/ConContainer/Constitution;
@onready var inte = $Panel/Stats/IntContainer/Intelligence;
@onready var wis = $Panel/Stats/WisContainer/Wisdom;
@onready var cha = $Panel/Stats/ChaContainer/Charisma;

var is_open:bool = false;

func _ready():
	#var char = GlobalBuilder.json_parser("res://localdata/player_sheets/Abby_1690657127_2.json");
	#update_display(char);
	pass;

func open(): 
	anim.play("Show");
	is_open = true;

func close(): 
	anim.play("Hide");
	is_open = false;

func update_display(data):
	player_name.text = data.display_name;
	lrc.text = str("Level ", data.level, " [color=green]", data.race, " [color=yellow]", data.pclass);
	
	health_bar.max_value = data.maxhp;
	health_bar.value = data.hp;
	health_bar_text.text = str(data.hp, "/", data.maxhp);
	
	str.text = str("STR ", data.ability_scores.STR.value);
	dex.text = str("DEX ", data.ability_scores.DEX.value);
	con.text = str("CON ", data.ability_scores.CON.value);
	inte.text = str("INT ", data.ability_scores.INT.value);
	wis.text = str("WIS ", data.ability_scores.WIS.value);
	cha.text = str("CHA ", data.ability_scores.CHA.value);


func _on_open_close_pressed():
	if is_open: close();
	else: open();
