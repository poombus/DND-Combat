extends Control

@onready var question := $Panel/LineEdit;
@onready var opinion_button := $Panel/HBoxContainer/CheckButton;
@onready var opinion_label := $Panel/HBoxContainer/RichTextLabel;
@onready var feedback := $Panel/Feedback;

func _ready():
	feedback.text = "";
	question.text = "";
	opinion_label.text = "[color=red]No";

func _on_send_pressed(): 
	if false:
		feedback.text = "[center][color=red]Error text goes here.";
		return;
	
	visible = false;

func _on_check_button_toggled(button_pressed):
	if button_pressed: opinion_label.text = "[color=green]Yes";
	else: opinion_label.text = "[color=red]No";
