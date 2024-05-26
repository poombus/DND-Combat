extends CharacterSheet
class_name NPCSheet

@export_category("NPC Classification")
@export var type:_Enums.NPC_TYPES; #NPC ONLY

@export_category("Loot Drops")
@export var loot_table = []; #MAKE A LOOT TABLE CLASS PLS

@export_category("Stat Variations")
@export var stat_variations:StatVariations = StatVariations.new();
