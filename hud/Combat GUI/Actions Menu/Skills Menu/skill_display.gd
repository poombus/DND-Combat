extends VBoxContainer

@onready var n = $Name;
@onready var flavor = $Flavor;
@onready var stats = $Stats;
@onready var desc = $Description;
@onready var dice = $Dice;

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
