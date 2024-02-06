extends AudioStreamPlayer
class_name BGMController

@export var musicjsonfile:String;
var musicjson;

func _ready():
	if musicjsonfile == "":
		play();
		return;
	var json_as_text = FileAccess.get_file_as_string(musicjsonfile);
	musicjson = JSON.parse_string(json_as_text);
	
	self.stream = load(musicjson.filepath);
	self.play(musicjson.start);
