extends PanelContainer

@onready var text = $Text;
@onready var anim = $AnimationPlayer;

@onready var min_size = size;

func _ready():
	visible = false;
	#new_message("(important message) you got 2 dirt!");

func new_message(message:String, speed:float = 1) -> void:
	if speed == 0: speed = 0.01;
	var wordcount = float(message.split(" ", 10).size());
	
	text.text = "[center]"+message;
	anim.stop();
	anim.speed_scale = anim.get_animation("FadeIn").length/speed;
	anim.play("FadeIn");
	
	hide_text(speed+wordcount*0.3);

func hide_text(wait:float = 1, speed:float = 1):
	if speed == 0: speed = 0.01;
	await get_tree().create_timer(wait+2).timeout;
	anim.speed_scale = anim.get_animation("FadeOut").length/speed;
	if !anim.is_playing(): anim.play("FadeOut");


func _on_gui_input(event):
	if event is InputEventMouseButton && event.pressed && visible: 
		anim.stop();
		visible = false;
