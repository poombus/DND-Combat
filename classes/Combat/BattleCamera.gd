extends Camera2D
class_name BattleCamera

var cam_control:bool = true;
var can_zoom:bool = false;

@onready var combat_gui = get_parent().get_child(-1);
@onready var nameplate = preload("res://hud/Pawn/nameplate.tscn");
@onready var speed_dice_container = preload("res://hud/speed_dice_container.tscn");
@onready var arrow_gui = preload("res://hud/arrow.tscn");
@onready var mini_sc = preload("res://hud/Combat GUI/Skill Chain/mini_skill_chain.tscn");

var dragging:bool = false;
var drag_start:Vector2 = Vector2.ZERO;
var cam_start:Vector2 = global_position;

func get_2d_pos(object):
	return object.global_position;

func _ready(): #remove later
	GlobalSignals.connect("pawn_clicked", pawn_debug);
	_CM.setup([get_parent().get_child(1)], [get_parent().get_child(2)], self, get_parent().get_child(3).get_child(0), get_parent().get_child(3).get_child(1));

func _input(event):
	if !cam_control: return;
	if event is InputEventMouseButton: mouse_button_events(event);
	elif event is InputEventMouseMotion: mouse_motion_events(event);
	else: return;

func mouse_button_events(event):
	#Scroll to Zoom
	if event.is_action_pressed("scroll_up") && can_zoom: change_zoom(0.3);
	elif event.is_action_pressed("scroll_down") && can_zoom: change_zoom(-0.3);
	
	if event.is_action_pressed("scroll_click"): 
		dragging = true;
		drag_start = get_viewport().get_mouse_position();
		cam_start = global_position;
	else: dragging = false;

func mouse_motion_events(event):
	if !dragging: return;
	global_position = cam_start+(get_viewport().get_mouse_position()-drag_start)*(0.5/zoom.x);

func change_zoom(amount:float):
	var tween = create_tween();
	tween.tween_property(self, "zoom", clamp(zoom + Vector2(amount, amount), Vector2(0.5,0.5), Vector2(2,2)), 0.1);

func center_at(pos:Vector2, _zoom:float = -1):
	var tween = create_tween();
	tween.parallel().tween_property(self, "global_position", pos, 0.2);
	tween.parallel().tween_property(self, "zoom", Vector2(_zoom,_zoom), 0.4);

func pawn_debug(pawn = null):
	if pawn is Pawn2D: pass;
	center_at(pawn.global_position, 1.2);
	#OPEN DEBUG MENU FOR PAWN
	#FIND A WAY TO KNOW WHEN YOU "CLICK OFF" PAWN
