extends Button

var container:Control;
@onready var image = $HBoxContainer/TextureRect;
@onready var label = $HBoxContainer/Control/RichTextLabel;
var item:ItemStack;
var location;

func set_item(_item:ItemStack, _container:Control = null, _loc:String = "inventory") -> void:
	container = _container;
	item = _item;
	location = _loc;
	set_label();

func set_image_size(_size:int) -> void:
	size.y = _size;

func set_label(_text:String = "") -> void:
	if _text == "": 
		_text = "[color=%s]%s"%[item.item.get_d_color(), item.item.display_name];
		if item.count > 1: _text += " [color=white](x%d)" % item.count;
	label.text = _text;

func _on_mouse_entered():
	if not container: return;
	container.timer.start();
	container.hover_item = item;
	container.hide_context();

func _on_mouse_exited():
	if not container: return;
	container.timer.stop();
	container.hide_tooltip();

func _on_pressed():
	if not container: return;
	container.timer.stop();
	container.hide_tooltip();
	container.show_context(location);
