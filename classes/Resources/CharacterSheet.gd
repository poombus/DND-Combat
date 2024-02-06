extends Resource
class_name CharacterSheet

#EVENTUALLY HAVE PROF KEY IN ABILITY SCORES BE AN INT.
#PROFICIENCY BONUS WILL BE MULTIPIED BY THE PROF KEY IN AS.
#PROF KEY 0 * BONUS +2 = +0 PROFICIENCY
#PROF KEY 1 * BONUS +2 = +2 PROFICIENCY
#PROF KEY 2 (double proficiency) * BONUS +2 = +4 PROFICIENCY

var file_path:String;

func _ready(): setup_as();

var is_player:bool = true;


var display_name:String; #readable name
var description:String; #description (will be seen by players)
var level:int = 1;

var race:_Enums.RACES = _Enums.RACES.HUMAN;
var pclass:_Enums.CLASSES; #PLAYER ONLY
var type:_Enums.TYPES; #NPC ONLY

var ethics:_Enums.ETHICS;
var morals:_Enums.MORALS;
var languages:Array;
var senses:Array;

var maxhp:int = 20;
var hp:int = 20;
var maxsr:int = 20;
var sr:int = 20;

var ability_scores:Dictionary;

var profBonus:int; #extra value to add to rolls involving skill proficiencies
var skillProfs:Array; #skill proficiencies; acrobatics, animal handling, arcana, etc.


var conditions:Array; #status effects

var resistances:Dictionary = {}; #unless explicitly stated, dmg modifiers default to x1.0

#collection (dunno whether to use arrays or dicts)
var skills:Array;
var spells:Array;
var inventory:Array;
var feats:Array; #feats and traits


func setup_as():
	for stat in _Enums.AS: 
		ability_scores[stat] = {
			"value": 1,
			"prof": false
		}

#getters n' setters
func set_as(a:_Enums.AS, val:int, bonus:String = "base") -> void:
	var id = _Enums.AS.keys()[a];
	if bonus not in ability_scores[id]: bonus = "base";
	ability_scores[id][bonus] = val;
func get_as(a:_Enums.AS) -> int:
	var id = _Enums.AS.keys()[a];
	return ability_scores[id].value;
func get_as_mod(a:_Enums.AS) -> int:
	return (get_as(a)-10)/2;

func unpack_json(path):
	var json = GlobalBuilder.json_parser(path);
	for key in json.keys():
		self[key] = json[key];
	file_path = path;
