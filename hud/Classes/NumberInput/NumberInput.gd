extends TextEdit
class_name NumberInput

@export var is_integer := false;

func _ready():
	self.placeholder_text = "INT" if is_integer else "FLT";

func get_value():
	return int(self.text) if is_integer else float(self.text);
