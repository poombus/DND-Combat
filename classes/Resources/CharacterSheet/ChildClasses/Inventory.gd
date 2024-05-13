extends Resource
class_name Inventory

var size_limit:int = 200; #how much a player can hold
var current_size:int = 0;
var items:Array[ItemStack] = [];
enum EQUIP_SLOTS {HEAD = 0, CHEST, LEGS, FEET, HANDS, BOTH_HANDS, TRINKETS}
var head:EquippableItem = null;
var chest:EquippableItem;
var legs:EquippableItem;
var feet:EquippableItem;
@export var hands:Array[EquippableItem] = [];
var trinkets:Array[EquippableItem] = [];
var max_trinkets:int = 2;

func equip(ind:int) -> void:
	var i_stack:ItemStack = items[ind];
	var i:Item = i_stack.item;
	if not i is EquippableItem: return;
	if i.equip_slot == EQUIP_SLOTS.TRINKETS:
		if trinkets.size() >= max_trinkets: return;
		trinkets.push_back(i);
		remove_count(i_stack);
	elif i.equip_slot == EQUIP_SLOTS.HANDS || i.equip_slot == EQUIP_SLOTS.BOTH_HANDS:
		if hands.size() >= 2: return;
		if hands.size() == 1: if hands[0].equip_slot == EQUIP_SLOTS.BOTH_HANDS || i.equip_slot == EQUIP_SLOTS.BOTH_HANDS: return;
		hands.push_back(i);
		remove_count(i_stack);
	else:
		unequip(i.equip_slot);
		self[Utils.get_enum_key(EQUIP_SLOTS, i.equip_slot).to_lower()] = i;
		remove_count(i_stack);
	

func unequip(slot:EQUIP_SLOTS, ind:int = 0) -> void:
	var i:Item;
	var arr:String;
	if slot == EQUIP_SLOTS.TRINKETS && trinkets.size() > 0: 
		ind = clamp(ind, 0, trinkets.size()-1);
		i = trinkets[ind].duplicate();
		trinkets.pop_at(ind);
	elif (slot == EQUIP_SLOTS.HANDS || slot == EQUIP_SLOTS.BOTH_HANDS):
		if hands.size() == 0: return;
		ind = clamp(ind, 0, hands.size()-1);
		i = hands[ind].duplicate();
		hands.pop_at(ind);
	else: 
		i = self[Utils.get_enum_key(EQUIP_SLOTS, slot).to_lower()].duplicate();
		self[Utils.get_enum_key(EQUIP_SLOTS, slot).to_lower()] = null;
	if i: add_item(i);

func add_item(_item:Item, count:int = 1) -> void:
	var stack:ItemStack = ItemStack.new(_item, count);
	add_item_stack(stack);
	current_size += stack.get_total_size();

func add_item_stack(_item:ItemStack) -> ItemStack:
	for i in items:
		if not i.can_stack(_item): continue;
		var remainder = i.stack(_item, size_limit-current_size); #uh, if this works, make the functions return void
		current_size += _item.get_total_size() - remainder.get_total_size();
		return remainder;
	
	if _item.get_total_size() + current_size <= size_limit:
		items.push_back(_item);
		current_size += _item.get_total_size();
		return ItemStack.new(Item.new(), 0);
	elif _item.item.size + current_size <= size_limit:
		var split:ItemStack = _item.duplicate();
		split.count = floor((size_limit-current_size)/_item.item.size);
		_item.count -= split.count;
		items.push_back(split);
		current_size += split.get_total_size();
		
	return _item;

func recount_size() -> int:
	current_size = 0;
	for i in items: current_size += i.get_total_size();
	return current_size;

func validate_inventory():
	for i in items.size()-1:
		if items[-1-i].is_empty(): items.pop_at(-1-i);
	recount_size();

func get_equipped() -> Array[EquippableItem]:
	var equipped:Array[EquippableItem];
	for i in [head, chest, legs, feet]: if i is EquippableItem: equipped.push_back(i);
	equipped.append_array(trinkets);
	equipped.append_array(hands);
	return equipped;

func remove_count(_item:ItemStack, amount:int = 1) -> void:
	amount = min(amount, _item.count);
	_item.count -= amount;
	current_size -= amount*_item.item.size;
	if _item.is_empty(): items.erase(_item);
