extends Control

@onready var hpbar = $"Container/Health";
@onready var stbar = $"Container/Stagger";
@onready var shbar = $"Container/Shield";
@onready var nubar = $"Container/Null";

var total:float = 100; #most likely max hp

var health:float = 100;
var stagger:float = 10;
var shield:float = 0;

func _ready(): update_bar();

func update_bar():
	hpbar.size_flags_stretch_ratio = health;
	stbar.size_flags_stretch_ratio = stagger;
	shbar.size_flags_stretch_ratio = shield;
	nubar.size_flags_stretch_ratio = total-(health+stagger+shield);
