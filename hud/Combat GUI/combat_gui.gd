extends Control
class_name CombatGUI

var cur_pawn:Pawn2D;

@onready var skill_chain := $"Skill Chain";

@onready var action_menu := $"Actions Menu";

@onready var turn_banner := $TurnBanner;
@onready var turn_banner_text := $TurnBanner/TurnCount;

@onready var anim := $AnimationPlayer;

func display_actions(pawn:Pawn2D):
	cur_pawn = pawn;
	action_menu.list_skills(pawn.combat_stats.skills);
	
	action_menu.visible = true;

func hide_actions(): action_menu.visible = false;

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
