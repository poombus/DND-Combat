extends TextureRect

var skill_name:String = "";
@onready var center = $Center;
@onready var header = $Header;
@onready var anim = $AnimationPlayer;
var ref_dice:Dice;

func update_display(dice:Dice):
	display_type(dice);
	display_average(dice);

func update_value(dice:Dice, value):
	display_type(dice);
	header.text = "";
	center.text = str("[center]", value, "[/center]");
	anim.play("New Value");

func display_type(dice:Dice):
	if dice.is_defensive(): #defensive - blue
		self_modulate = Color("#30aaff");
	elif dice.is_counter(): #counters - yellow
		self_modulate = Color("#feff51");
	else: #offensive - red
		self_modulate = Color("#ff3332");

func display_average(dice:Dice):
	var k;
	var letter;
	if dice.is_defensive():
		k = _Enums.DICE_TYPES.keys();
		letter = k[dice.dice_type].substr(0,1);
	else:
		k = _Enums.DMG_TYPES.keys();
		letter = k[dice.damage_type].substr(0,1);
	$Center.text = "[center]"+str(dice.low, "~", dice.high, letter)+"[/center]";
