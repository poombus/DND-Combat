extends Control

var mini_dice = load("res://hud/Combat GUI/Skill Chain/mini_dice.tscn");
@onready var container = $"HBoxContainer";

enum MODE {SINGLE, SKIRMISH}
var mode:MODE = MODE.SINGLE;

func display_skill(skill):
	if !skill: return;
	container.visible = true;
	clear_dice();
	for dice in skill.dice: add_dice(dice);

func hide_chain(): container.visible = false;

func add_dice(dice):
	var md = mini_dice.instantiate();
	md.update_display(dice);
	container.add_child(md);

func clear_dice():
	for child in container.get_children(): child.queue_free();
