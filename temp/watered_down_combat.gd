extends Control

@onready var t0 = $"Team0Pawns";
@onready var t1 = $"Team1Pawns";
@onready var phase_label = $"PhaseLabel";
@onready var player_nub = load("res://temp/player_nub.tscn");
@onready var enemy_nub = load("res://temp/player_nub_right.tscn");
@onready var bgm = $AudioStreamPlayer;
@onready var swtich = $"Math Menu/CheckButton";

var phase:int = -1; #0-initiative, 1-skills, 2-target, 3-math
var selected_nub;

var left_nub;
var right_nub;

func _ready():
	$"Setup Menu".visible = true;
	$"Skills Menu".visible = false;
	$"Math Menu".visible = false;

func _on_next_phase_pressed():
	if phase == -1: $"Setup Menu".visible = false;
	
	phase += 1;
	if phase > 2: phase = 0;
	
	match phase:
		0: phase_initiative()
		1: phase_skills()
		2: phase_math()

func phase_initiative():
	phase_label.text = "Initiative";
	for child in t0.get_children(): child.roll_initiative();
	for child in t1.get_children(): child.roll_initiative();
	$"Math Menu".visible = false;

func phase_skills(): 
	phase_label.text = "Skills";
	$"Skills Menu".visible = true;

func phase_math():
	phase_label.text = "Rolling";
	$"Skills Menu".visible = false;
	$"Math Menu".visible = true;

func _on_music_text_submitted(new_text):
	bgm.stream = load(new_text);
	bgm.play(0);

func _on_volume_text_submitted(new_text):
	bgm.volume_db = float(new_text)-80;

func select(nub):
	if phase == 1: selected_nub = nub;
	if phase == 2: 
		if !$"Math Menu/CheckButton".pressed: left_nub = nub;
		else: right_nub = nub;
		$"Math Menu".update_display();
