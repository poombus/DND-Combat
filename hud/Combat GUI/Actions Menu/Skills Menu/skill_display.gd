extends VBoxContainer

@onready var n = $Name;
@onready var flavor = $Flavor;
@onready var stats = $Stats;
@onready var desc = $Description;
@onready var dice = $Dice;

var dragging:bool = false;
var drag_start:int;
var scroll_start:int;

func _ready():
	self.visible = false;
	n.text = "";
	flavor.text = "";
	stats.text = "";
	dice.text = "";

func display(skill:Skill):
	self.visible = true;
	
	n.text = str(skill.display_name," ");
	if skill.has_offensive_dice():
		n.text += "[color=%s](%s %s)" % [
			_Enums.element_colors[_Enums.get_key("DMG_ELEMENTS", skill.element_type)], 
			_Enums.get_key("DMG_ELEMENTS", skill.element_type).to_pascal_case(),
			_Enums.get_key("DMG_TYPES", skill.damage_type).to_pascal_case()
		];
	else:
		n.text += "[color=#4293f5](Defense Skill)";
	
	if skill.flavor_text != "": 
		flavor.text = str("[color=gray][i]\"", skill.flavor_text, "\"");
		flavor.visible = true;
	else: flavor.visible = false;
	
	stats.text = str("[color=yellow]%s Energy\n[color=%s]%s Modifier %s");
	stats.text = stats.text % [
		skill.energy_cost, 
		"white" if skill.modifier == 0 else "red" if skill.modifier < 0 else "green",
		skill.modifier,
		"\n[color=%s]%s Attack Weight" if skill.weight > 1 else ""
	];
	
	
	if skill.description != "": 
		desc.text = str(skill.description);
		desc.visible = true;
	else: desc.visible = false;
	
	dice.text = "";
	for d in skill.dice:
		if dice.text != "": dice.text += "\n";
		dice.text += str("[color=%s](%s~%s) %s" % [
			_Enums.dice_colors[_Enums.get_key("DICE_TYPES", d.dice_type)],
			d.low, d.high, 
			_Enums.get_key("DICE_TYPES", d.dice_type).to_pascal_case()
		]);

func _input(event):
	if event is InputEventMouseButton: mouse_button_events(event);
	elif event is InputEventMouseMotion: mouse_motion_events(event);
	else: return;

func mouse_button_events(event):
	if event.is_action_pressed("scroll_click"): 
		dragging = true;
		drag_start = get_viewport().get_mouse_position().y;
		scroll_start = get_parent().get_v_scroll();
	else: dragging = false;

func mouse_motion_events(event):
	if !dragging: return;
	get_parent().set_v_scroll(scroll_start+(get_viewport().get_mouse_position().y-drag_start));
