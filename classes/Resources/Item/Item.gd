extends Resource
class_name Item

@export var id:String = "";
@export_category("Display Stuff")
@export var display_name:String = "";
@export var display_color:Color;
@export var use_display_color:bool = false;
@export var description:String = "";
@export var icon:Texture2D;

@export_category("Inventory Stats")
enum RARITIES {UNKNOWN, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}
const R_COLORS:Array[Color] = [Color.GRAY, Color.WHITE, Color.LAWN_GREEN, Color.DEEP_SKY_BLUE, Color.MEDIUM_PURPLE, Color.ORANGE];
@export var rarity:RARITIES = RARITIES.COMMON;
@export var value:float = 0; #value in gold
@export var size:float = 0; #negative numbers will counted as 0

var data:Dictionary = {};

func get_d_color() -> String:
	if not use_display_color: return get_r_color();
	return display_color.to_html(true);

func get_r_color() -> String:
	if rarity < 0: return R_COLORS[0].to_html(true);
	return R_COLORS[rarity].to_html(true);
