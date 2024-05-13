extends Resource
class_name StatModifiers

var calls_left = -1; #how many times this modifier can be called before it is removed/ignored
var event_call:String; #when this event is called, calls_left decreases

@export_category("Dice Power")
@export var dice_power:int = 0;
@export var min_power:int = 0;
@export var max_power:int = 0;
@export var clash_power:int = 0;

@export_category("Character Stats")
@export var strength:int = 0;
@export var dexterity:int = 0;
@export var constitution:int = 0;
@export var intelligence:int = 0;
@export var wisdom:int = 0;
@export var charisma:int = 0;

@export_category("Level Modifiers")
@export var offense_level:int = 0;
@export var defense_level:int = 0;
