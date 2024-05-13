extends Resource
class_name EGOComp
#EGO Component (for weapon, armor, trinkets)

#EGO :: NAME HERE (not the anomaly name)
@export var display_name:String = "Mimicry";
@export var danger_level:int = 5;

#Sanity Lost per Turn
@export var sanity_cost:int = 5;

#how likely corrosion skill will be used instead of panicking
@export var panic_weight:int = 3;

@export var corrosion_skill_id:String = "";
var corrosion_skill:Skill;

#Awakening: "In order to change, one must break free from their shell..."
#Corrosion: "H-... hel... lo...? Yeah... I'm almos-... home..."
