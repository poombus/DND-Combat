extends Resource
class_name StatVariations

#STAT BOOSTS SHOULD BE PROJECTED LEVEL 10 STATS

@export var hp_max:float = 0;
var hp_boost = 0;

@export var sr_max:float = 0;
var sr_boost = 0;


@export var str_max:float = 0;
var str_boost = 0;

@export var dex_max:float = 0;
var dex_boost = 0;

@export var con_max:float = 0;
var con_boost = 0;

@export var int_max:float = 0;
var int_boost = 0;

@export var wis_max:float = 0;
var wis_boost = 0;

@export var cha_max:float = 0;
var cha_boost = 0;

func roll_boosts(lvl:int = 1):
	var stats = ["hp", "sr", "str", "dex", "con", "int", "wis", "cha"];
	for s in stats: 
		var low = (self[s+"_max"]/(10/lvl))*0.7; 
		var hi = (self[s+"_max"]/(10/lvl))*1.3;
		self[s+"_boost"] = floor(randf_range(low, hi));
