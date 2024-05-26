extends Resource
class_name StatModifiers

var calls_left = -1; #how many times this modifier can be called before it is removed/ignored
var event_call:String; #when this event is called, calls_left decreases

@export_category("Dice Power")
@export var dice_power:float = 0;
@export var min_power:float = 0;
@export var max_power:float = 0;
@export var clash_power:float = 0;

@export_category("Character Stats")
@export var strength:float = 0;
@export var dexterity:float = 0;
@export var constitution:float = 0;
@export var intelligence:float = 0;
@export var wisdom:float = 0;
@export var charisma:float = 0;

@export_category("Level Modifiers")
@export var offense_level:float = 0;
@export var defense_level:float = 0;

@export_category("Other")
@export var crit_chance:float = 0; #adds to base crit chance (x0)
@export var crit_damage:float = 0; #adds to base crit damage (x1.2)
