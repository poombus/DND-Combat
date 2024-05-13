extends Resource
class_name ItemStack

var item:Item;
var count:int = 0;

func _init(_item:Item, _count:int = 1):
	item = _item;
	count = _count;

func can_stack(_item:ItemStack) -> bool:
	var i:Item = _item.item;
	if i.id != item.id: return false;
	if i.rarity != item.rarity: return false;
	for d in i.data:
		if not item.data.has(d): return false;
		if i.data[d] != item.data[d]: return false;
	return true;

func stack(_item:ItemStack, space_left:int) -> ItemStack:
	if _item.get_total_size() <= space_left: #no remainer
		count += _item.count;
		_item.count = 0;
	else:
		count += space_left/_item.item.size;
		_item.count -= space_left/_item.item.size;
	return _item;

func is_empty() -> bool: return true if count <= 0 else false;

func get_total_size() -> float: return count * item.size;
func get_total_value() -> float: return count * item.value;
