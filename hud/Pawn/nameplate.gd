extends Control
class_name Nameplate

var pawn;
var char_sheet;
var combat_stats;

@onready var display_name := $Background/Name;
@onready var hpbar := $Background/HitpointBar;
@onready var sanity_bubble := $Background/SanityBubble;
@onready var sanity_value := $Background/SanityBubble/SanityValue;
@onready var status_effect_display := $StatusEffectDisplay;

func init(p_pawn):
	pawn = p_pawn;
	char_sheet = pawn.char_sheet;
	combat_stats = pawn.combat_stats;
	
	display_name.text = str(char_sheet.display_name);
	
	sanity_value.text = str("[center]", combat_stats.sp);
	update_display();

func update_display(): 
	hpbar.total = combat_stats.maxhp;
	hpbar.health = combat_stats.hp;
	hpbar.stagger = combat_stats.sr;
	hpbar.shield = combat_stats.shield;
	hpbar.update_bar();
	status_effect_display.update_display(combat_stats.status_effects);
