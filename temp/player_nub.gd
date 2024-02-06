extends Control

var combat_screen;

var char_sheet;

@onready var hp_bar := $HP;
@onready var hp_label := $"HP/Label";
@onready var sr_bar := $SR;
@onready var sr_label := $"SR/Label";
@onready var dmg_line := $Damage;
@onready var dice_chain := $"Dice Chain";

func _ready():
	deal_damage(-30, 30);
	deal_stagger(-15, 15);

func setup_char_sheet(path):
	char_sheet = GlobalBuilder.json_parser(path);
	deal_damage(-char_sheet.maxhp,char_sheet.maxhp);
	deal_stagger(-char_sheet.maxsr,char_sheet.maxsr);
	$Name.text = char_sheet.display_name;
	dice_chain.scale = Vector2(0.2,0.2);

func set_combat_screen(c): combat_screen = c;

func deal_damage(amount:int, max:int = -1):
	if max > -1: hp_bar.max_value = max;
	hp_bar.value -= amount;
	hp_label.text = str(hp_bar.value,"/",hp_bar.max_value);

func deal_stagger(amount:int, max:int = -1):
	if max > -1: sr_bar.max_value = max;
	sr_bar.value -= amount;
	sr_label.text = str(sr_bar.value,"/",sr_bar.max_value);

func _on_deal_hp_pressed():
	deal_damage(int(dmg_line.text));


func _on_deal_sr_pressed():
	deal_stagger(int(dmg_line.text));

func _on_deal_both_pressed():
	deal_damage(int(dmg_line.text));
	deal_stagger(int(dmg_line.text));

func roll_initiative():
	var dex_mod = int(char_sheet.ability_scores.DEX.value/20)-10;
	var range = [1,6];
	range[0] = max(1, 1+dex_mod);
	range[1] = max(4, 1+dex_mod);
	$Initiative.text = str("Initiative: ", randi_range(range[0], range[1]));

func _on_select_pressed():
	if combat_screen == null: return;
	combat_screen.select(self);
