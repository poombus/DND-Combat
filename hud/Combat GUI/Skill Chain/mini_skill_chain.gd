extends Control
class_name MiniSkillChain

var pawn:Pawn2D;

@onready var mini_dice = preload("res://hud/Combat GUI/Skill Chain/mini_dice.tscn");
@onready var skill_name = $"Skill Name";
@onready var container = $"Mini Dice Container";

const queue_display_limit = 10;

var skill_chain = [];
var d = [];

func _ready():
	for child in container.get_children():
		child.queue_free();

func generate_dice(sc):
	skill_chain = [];
	d = [];
	for child in container.get_children():
		child.queue_free();
	
	for dice in sc:
		var md = mini_dice.instantiate();
		md.update_display(dice);
		d.push_back(md);
	
	var count = 0;
	for dice in d:
		container.add_child(dice);
		dice.update_display(sc[count]);
		dice.scale = Vector2(0.2,0.2);
		dice.position = Vector2(154+(count*(10+dice.size.x*dice.scale.x)),10);
		if count >= queue_display_limit: dice.visible = false;
		count += 1;

func update_display(ind:int = 0, value:int = 0):
	if ind >= d.size(): 
		visible = false;
		return;
	#else: skill_name.text = skill_chain[skill].display_name;
	var cur_dice = d[ind];
	cur_dice.scale = Vector2(0.8,0.8);
	cur_dice.position = Vector2(0,0);
	
	skill_name.text = cur_dice.skill_name;
	
	var i:int = ind+1;
	var c:int = 0;
	while i < ind || c < d.size()-1:
		if i >= d.size(): i = 0;
		var dice = d[i];
		dice.scale = Vector2(0.2, 0.2);
		dice.position = Vector2(154+(c*(10+dice.size.x*dice.scale.x)),10);
		if c < queue_display_limit: dice.visible = true;
		else: dice.visible = false;
		c += 1;
		i += 1;

func change_dice_value(ind:int, value):
	var cur_dice = d[ind];
	cur_dice.center.text = "[center]"+str(value)+"[/center]";
	cur_dice.anim.play("New Value");

func remove_dice(ind:int) -> void:
	var child = d[ind];
	child.queue_free();
	d.remove_at(ind);
