extends Control

@onready var icon := $Icon;
@onready var potency := $Potency;
@onready var count := $Count;

func update_display(se:StatusEffect):
	if se.icon: icon.texture = se.icon;
	potency.text = str("[right]", se.potency);
	count.text = str(se.count);
