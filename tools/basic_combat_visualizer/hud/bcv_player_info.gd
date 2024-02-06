extends PanelContainer

@onready var pawn:Pawn2D = Pawn2D.new();
@onready var pname := $"Player Name";
@onready var sdc := $"SDC/Speed Dice Container";

func _ready():
	pawn.unpack_charsheet();
	setup(pawn);

func setup(pawn:Pawn2D):
	pawn.unpack_charsheet();
	pname.text = str("[b]", pawn.char_sheet.display_name, "[/b] (",pawn.combat_stats.sp,")");
	sdc = pawn.sdc;
