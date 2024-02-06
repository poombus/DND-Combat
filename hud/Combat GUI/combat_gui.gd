extends Control
class_name CombatGUI

var cur_pawn:Pawn2D;

@onready var skill_chain := $"Skill Chain";

@onready var action_menus := $"Action Menus";
@onready var skills_menu := $"Action Menus/Skills Menu"
@onready var spells_menu := $"Action Menus/Spells Menu"
@onready var misc_menu := $"Action Menus/Misc Menu"
@onready var items_menu := $"Action Menus/Item Menu"

@onready var turn_banner := $TurnBanner;
@onready var turn_banner_text := $TurnBanner/TurnCount;

@onready var anim := $AnimationPlayer;

@onready var skills_popup = skills_menu.get_popup();

func _ready():
	skills_popup.connect("id_pressed", _on_item_pressed);
	#new_turn_display(1);

func display_actions(pawn:Pawn2D):
	cur_pawn = pawn;
	skills_popup.clear()
	for skills in pawn.combat_stats.skills:
		skills_popup.add_item(skills.display_name);
	
	action_menus.visible = true;

func hide_actions(): action_menus.visible = false;

func display_skill(skill) -> void: skill_chain.display_skill(skill);

func hide_skill_chain() -> void: skill_chain.hide_chain();

func _on_item_pressed(id):
	var skill = cur_pawn.combat_stats.skills[id].deep_copy();
	GlobalMouseDiceTracker.selected.add_skill(skill);
	#print(cur_pawn.combatStats.skills[id]);
	#print(skills_popup.get_item_text(id), " pressed");

func new_turn_display(turn:int):
	turn_banner_text.text = str("[center]Turn ",turn);
	anim.play("New Turn");
