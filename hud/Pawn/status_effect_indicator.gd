extends Control

@onready var icon := $Icon;
@onready var potency := $Potency;
@onready var count := $Count;

func update_display(se:StatusEffect):
	#do something with icon
	potency.text = str("[right]", se.potency);
	count.text = str(se.count);
