extends Control

@onready var timer_bar = $PanelContainer/TimerBar;
@onready var button_container = $PanelContainer/HBoxContainer;
@onready var header = $PanelContainer/Header;
@onready var question = $PanelContainer/Question;

var max_timer:float = 15;
var timer:float = 0; #seconds

func _ready():
	set_process(false);
	start_timer(15);

func _process(delta):
	if timer > max_timer: timer = max_timer;
	if timer > 0: 
		timer += -delta;
		timer_bar.value = timer;
	elif timer <= 0: set_process(false);

func start_timer(time:float):
	set_process(true);
	max_timer = time;
	timer = time;
	
	timer_bar.max_value = time;
	timer_bar.value = time;


func _on_yes_pressed():
	voted(true);

func _on_no_pressed():
	voted(false);

func voted(is_yes:bool):
	button_container.visible = false;
	question.text = str("You voted...\n", "YES" if is_yes else "NO");
	question.self_modulate = Color("green") if is_yes else Color("red");
