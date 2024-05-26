extends Control

@onready var team0_list = $"Team 1/VBoxContainer";
@onready var team1_list = $"Team 2/VBoxContainer";

var t0 = [
	"res://tools/character sheet tool/generated_data/Klaus.res"
];

var t1 = [
	"res://tools/character sheet tool/generated_data/wolf.tres"
];

func _ready():
	var team0:Array[Pawn2D] = [];
	var team1:Array[Pawn2D] = [];
	
	for p in t0:
		var controlnode = Control.new();
		var unit:Pawn2D = Pawn2D.new_test_unit(ResourceLoader.load(p));
		team0_list.add_child(controlnode);
		controlnode.size_flags_vertical = Control.SIZE_EXPAND_FILL;
		controlnode.custom_minimum_size = Vector2(0,170);
		controlnode.add_child(unit);
		team0.push_back(unit);
	
	for p in t1:
		var char_sheet = ResourceLoader.load(p);
		char_sheet.level = 10;
		var controlnode = Control.new();
		var unit:Pawn2D = Pawn2D.new_test_unit(char_sheet);
		team1_list.add_child(controlnode);
		controlnode.size_flags_vertical = Control.SIZE_EXPAND_FILL;
		controlnode.custom_minimum_size = Vector2(0,170);
		controlnode.add_child(unit);
		team1.push_back(unit);
	
	_CM.setup(team0, team1, BattleCamera.new(), $"Combat GUI", $ClashList);
