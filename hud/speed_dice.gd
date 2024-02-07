extends TextureRect
class_name SpeedDice

@onready var arrow:Arrow = $Arrow;

var skill:Skill;
var target:SpeedDice;

@onready var pawn:Pawn2D = get_parent().get_parent() if get_parent().get_parent() is Pawn2D else null;
var value:int;

var dummy:bool = false;
var selectable:bool = true;

func _ready():
	if arrow: arrow.visible = false;

func init(i_pawn:Pawn2D):
	pawn = i_pawn;

func _on_mouse_entered() -> void: 
	GlobalMouseDiceTracker.focus_dice(self);

func _on_mouse_exited() -> void: 
	GlobalMouseDiceTracker.unfocus_dice(self);

func roll(min:int, max:int) -> void:
	value = randi_range(min,max);
	update_number();

func update_number() -> void:
	if value == null or value == 0: $Number.text = "[center]--[/center]";
	else: $Number.text = "[center]"+str(value)+"[/center]";	

func is_selected() -> bool:
	return GlobalMouseDiceTracker.selected == self;

func selected() -> void:
	if !selectable: return;
	self_modulate = Color("#ff98ff");
	
	if _CM.phase == _CM.PHASES.SKILLS:
		_CM.combat_gui.display_actions(pawn);
		_CM.combat_gui.display_skill(skill);
	
	if target != null:
		arrow.visible = true;
		var diff = target.global_position-global_position;
#		var body_curve = arrow.get_node("Arrow Body").get_curve();
#		body_curve.set_point_value(0, clampf(pow(get_parent().scale.x,2)*3, 0.2, 1));
#		body_curve.set_point_value(1, clampf(pow(target.get_parent().scale.x, 2)*3, 0.2, 1));
		
		arrow.set_target(Vector2(0,0), diff);

func unselected() -> void:
	_CM.combat_gui.hide_actions();
	_CM.combat_gui.hide_skill_chain();
	arrow.visible = false;
	
	if !selectable: return;
	
	if _CM.phase == _CM.PHASES.SKILLS:
		if skill == null: self_modulate = Color(1,1,1,1);
		else: self_modulate = Color(1,1,0.78,1);
	elif _CM.phase == _CM.PHASES.TARGET:
		if target == null: self_modulate = Color(1,1,1,1);
		else: self_modulate = Color(1,1,0.78,1);

func add_skill(_skill):
	skill = _skill;
	_CM.combat_gui.display_skill(skill);

func no_sc_lock():
	if skill == null: set_selectable(false);
	else: set_selectable();

func set_selectable(s:bool = true):
	selectable = s;
	if s: 
		self_modulate = Color(1,1,1,1);
		return;
		
	self_modulate = Color(0.6,0.6,0.6);
	$Number.text = "[center]"+"--"+"[/center]"

func get_skill_dice() -> Array[Dice]: #get_skill_dice()
	if skill: return skill.deep_copy_dice();
	return [];
