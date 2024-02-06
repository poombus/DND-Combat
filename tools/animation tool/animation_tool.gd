extends Control

var cur_frame:int = 0;

func _ready():
	$PanelContainer/Sprite2D.hframes = 1;

func _on_line_edit_text_changed(new_text):
	var hframes = int(new_text);
	$PanelContainer/Sprite2D.hframes = max(1,hframes);
	if hframes <= cur_frame: cur_frame = hframes;

func _on_size_text_changed(new_text):
	var size = float(new_text);
	$PanelContainer/Sprite2D.scale = Vector2(size,size);
