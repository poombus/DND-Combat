extends Control

@onready var cgui = $"CanvasLayer/Combat GUI";
@onready var t1list = $Team1;
@onready var t2list = $Team2;
@onready var clashlist = $ClashList;
@onready var hidden_pawn_layer = $HiddenPawns;

@onready var player_info_scene = load("res://tools/basic_combat_visualizer/hud/bcv_player_info.tscn");
@onready var clash_info_scene = load("res://tools/basic_combat_visualizer/hud/clash_info.tscn");

# Called when the node enters the scene tree for the first time.
func _ready():
	var p1 = $HiddenPawns/Pawn2D;
	var e1 = $HiddenPawns/Pawn2D2;
	
	_CM.setup([p1], [e1], null, cgui);
	
	for c in t1list.get_children(): c.queue_free();
	for c in t2list.get_children(): c.queue_free();
	for c in clashlist.get_children(): c.queue_free();
	
	for p in _CM.pawns:
		var p_info = player_info_scene.instantiate();
		if p.combat_stats.team == 0: t1list.add_child(p_info);
		elif p.combat_stats.team == 1: t2list.add_child(p_info);
		
		p_info.setup(p);
