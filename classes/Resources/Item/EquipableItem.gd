extends Item
class_name EquippableItem

@export var equip_slot:Inventory.EQUIP_SLOTS = Inventory.EQUIP_SLOTS.TRINKETS;
@export var stats:StatModifiers;
var ego_comp:EGOComp;

func is_ego() -> bool: return true if ego_comp else false;
