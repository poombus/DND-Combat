extends Control

const item_inst = preload("res://hud/Table Screen/Windows/Inventory/inventory_item.tscn");
@export var char:PlayerSheet;

@onready var pname = $Container/HBoxContainer/PlayerStats/Name;
@onready var pstats = $Container/HBoxContainer/PlayerStats/StatContainer;
@onready var baglist = $Container/HBoxContainer/Inventory/Bag/List;
@onready var eqlist = $Container/HBoxContainer/Inventory/Equiped/List;
@onready var timer = $Timer;
@onready var tooltip = $InventoryTooltip;
@onready var context_menu = $InventoryContextMenu;

var hover_item:ItemStack;

func _ready():
	context_menu.connect("close_context_menu", hide_context);
	
	pname.text = "%s\nLevel %d %s" % [char.display_name, char.level, Utils.get_enum_key(_Enums.CLASSES, char.pclass)];
	pstats.get_node("Strength").text = "STR:\n%d" % char.strength;
	pstats.get_node("Dexterity").text = "DEX:\n%d" % char.dexterity;
	pstats.get_node("Constitution").text = "CON:\n%d" % char.constitution;
	pstats.get_node("Intelligence").text = "INT:\n%d" % char.intelligence;
	pstats.get_node("Wisdom").text = "WIS:\n%d" % char.wisdom;
	pstats.get_node("Charisma").text = "CHA:\n%d" % char.charisma;
	char.inventory.add_item(Registry.get_item("base:dagger"), 2);
	char.inventory.add_item(Registry.get_item("base:gold_piece"), 4);
	char.inventory.add_item(Registry.get_item("base:silver_piece"), 10);
	char.inventory.add_item(Registry.get_item("base:copper_piece"), 20);
	char.inventory.add_item(Registry.get_item("base:black_silence_gloves"), 1);
	
	update_list();

func update_list():
	for c in baglist.get_children(): c.queue_free();
	for c in eqlist.get_children(): c.queue_free();
	for i in char.inventory.items: add_item(i);
	for i in char.inventory.get_equipped(): add_eq_item(i);

func add_item(_item:ItemStack):
	var item_disp = item_inst.instantiate();
	baglist.add_child(item_disp);
	item_disp.set_item(_item, self);

func add_eq_item(_item:EquippableItem):
	if not _item is EquippableItem: return;
	var item_disp = item_inst.instantiate();
	eqlist.add_child(item_disp);
	item_disp.set_item(ItemStack.new(_item), self, "equipment");

func show_tooltip():
	var t_size = tooltip.get_child(0).size;
	var mouse_pos = get_viewport().get_mouse_position();
	var box_offset := Vector2(15,0);
	if mouse_pos.x + t_size.x >= get_viewport_rect().size.x: box_offset.x = -t_size.x-15;
	else: box_offset.x = 15;
	if mouse_pos.y + t_size.y >= get_viewport_rect().size.y: box_offset.y = -t_size.y;
	else: box_offset.y = 0;
	tooltip.position = mouse_pos+box_offset;
	tooltip.visible = true;
	tooltip.set_item_data(hover_item);

func show_context(location = "inventory"):
	var c_size = context_menu.get_child(0).size;
	var mouse_pos := get_viewport().get_mouse_position();
	var box_offset := Vector2(20,-20);
	if mouse_pos.x + c_size.x >= get_viewport_rect().size.x: box_offset.x = -c_size.x+20;
	else: box_offset.x = -20;
	if mouse_pos.y + c_size.y >= get_viewport_rect().size.y: box_offset.y = -c_size.y+20;
	else: box_offset.y = -20;
	context_menu.position = mouse_pos+box_offset;
	context_menu.visible = true;
	context_menu.toggle_buttons(hover_item.item, location);

func hide_tooltip(): tooltip.visible = false;

func hide_context(): context_menu.visible = false;

func _on_inventory_context_menu_equip():
	var ind = char.inventory.items.find(hover_item);
	if ind != -1: char.inventory.equip(ind);
	hide_context();
	update_list();

func _on_inventory_context_menu_unequip():
	char.inventory.unequip(hover_item.item.equip_slot);
	hide_context();
	update_list();
