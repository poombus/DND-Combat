extends Control

@onready var label = $Container/VBoxContainer/RichTextLabel;
var _text = "No data found.";

func _ready():
	label.text = _text;

func set_item_data(_item:ItemStack):
	_text = "[color=%s]%s" % [_item.item.get_d_color(), _item.item.display_name];
	if _item.count > 1: _text += " [color=white](x%d)" % _item.count;
	_text += "\n[color=gray][i]\"%s\"[/i]\n" % [_item.item.description];
	_text += "[color=white]Rarity: [color=%s]%s\n" % [_item.item.get_r_color(), Item.RARITIES.keys()[_item.item.rarity]];
	_text += "[color=white]Size: [color=red]%.2f [color=gray](%.2f per)\n" % [_item.get_total_size(), _item.item.size];
	_text += "[color=white]Value: [color=yellow]%.2fgp [color=gray](%.2f per)" % [_item.get_total_value(), _item.item.value];
	label.text = _text;
