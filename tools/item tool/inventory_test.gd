extends Control

@onready var item_texture = preload("res://assets/textures/icons/question_mark.png");
@onready var item_list = $ItemList;
@export var character:CharacterSheet;

func _ready():
	item_list.icon_scale = 0.2;
	character.inventory.add_item(Registry.get_item("base:shortsword"), 2);
	character.inventory.add_item(Registry.get_item("base:gold_piece"), 4);
	character.inventory.add_item(Registry.get_item("base:silver_piece"), 10);
	for i in character.inventory.items:
		item_list.add_item("%s (%d)"%[i.item.id, i.count]);
		if i.item.icon: item_list.set_item_icon(item_list.item_count-1, i.item.icon);
		else: item_list.set_item_icon(item_list.item_count-1, item_texture);
		item_list.set_item_metadata(item_list.item_count-1, i);
