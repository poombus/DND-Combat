extends Item
class_name ArmorItem

var hp_boost:int = 0;
var sr_boost:int = 0;

var str_boost:int = 0;
var dex_boost:int = 0;
var con_boost:int = 0;
var int_boost:int = 0;
var wis_boost:int = 0;
var cha_boost:int = 0;

var resistances:Dictionary = {};

func passive(): pass;