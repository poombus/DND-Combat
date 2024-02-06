extends Node
class_name CombatStats

var pawn:Pawn2D; #removed typing for Pawn so i can use Pawn2D
var team:int = 0;
var can_control:Array[int] = [0];
var nameplate:Nameplate;
var msc:MiniSkillChain;

var maxhp:int = 0;
var hp:int = 0;
var shield:int = 0;
var maxsr:int = 0;
var sr:int = 0;
var staggered:bool = false;
var stagger_level:int = 0;
var staggered_this_turn:bool = false;
var actionable:bool = true;
var sp:int = 0; #sanity
var resistances:Dictionary;

var reserve_dice:Array[Dice] = [];
var counter_dice:Array[Dice] = [];

var speed_dice_count:int = 1;
var energy:int = 3;

var skills:Array[Skill] = []; #unarmed combat and equipped weapons
var spells;
var othActions; #running
var invActions; #only show items that can be used in combat

var feats:Array[Feat] = [];
var status_effects:Array[StatusEffect] = [];

func _init(i_parent): pawn = i_parent;

func setup(charsheet:CharacterSheet):	
	maxhp = charsheet.maxhp;
	hp = charsheet.hp;
	shield = 0;
	maxsr = charsheet.maxsr;
	sr = charsheet.sr;
	staggered = false;
	stagger_level = 0;
	actionable = true;
	
	resistances = charsheet.resistances;
	
	skills = []; #create a function that returns skill data given the skill id
	for s in charsheet.skills: add_skill(s);
	feats = [];
	for feat in charsheet.feats: add_feat(feat);
	spells = []; #same as above
	invActions = []; #check items in inventory and check which can be used in combat
	othActions = []; #predefined (usually)
	
	energy = 3;
	sp = 0;

func add_skill(skill) -> void:
	skills.push_back(Registry.get_skill(skill));
func add_feat(feat) -> Feat:
	var f := Registry.get_feat(feat).deep_copy();
	f.pawn = self;
	feats.push_back(f);
	return f;

func give_shield(amount:int) -> void:
	shield += max(0, amount);

func remove_shield(amount:int = -1) -> int:
	if amount < 0: shield = 0; return 0;
	var excess = max(0, amount - shield);
	shield = max(0, shield-max(0,amount));
	return excess;

func apply_damage(inst:DamageInstance) -> int:
	var final_damage = inst.get_final_damage();
	var after_shield = remove_shield(final_damage);
	if inst.affect_hp: deal_damage(after_shield); #make it so shield reduction is done here
	if inst.affect_sr: deal_stagger(after_shield);
	return final_damage;

func heal(amount:int):
	if amount < 0: return;
	
	hp = min(hp+amount, maxhp);

func deal_damage(amount:int) -> bool:
	if amount <= 0: return false;
	if is_dead(): return true;
	
	hp = max(0,hp-amount);
	
	if pawn: pawn.update_nameplate();
	if hp <= 0: return die();
	return false;

func heal_sr(amount):
	if amount < 0 || staggered: return;
	
	sr = min(sr+amount, maxsr);

func deal_stagger(amount) -> bool:
	if amount <= 0: return false;
	
	sr = max(0,sr-amount);
	#nameplate.update_display();
	
	if pawn: pawn.update_nameplate();
	if sr <= 0 && !staggered: return stagger();
	return false;

func die() -> bool:
	_CM.pawn_died(pawn);
	counter_dice = [];
	reserve_dice = [];
	return true;

func is_dead() -> bool: return true if hp <= 0 else false;

func stagger() -> bool:
	staggered = true;
	staggered_this_turn = true;
	stagger_level += 1;
	#pawn.spawn_vfx("res://vfx/staggered_text/staggered_text.tscn", Vector3(0,0,0));
	counter_dice = [];
	reserve_dice = [];
	return true;

func unstagger() -> void:
	if not staggered: return;
	if staggered_this_turn: staggered_this_turn = false; return;
	
	staggered = false;
	maxsr = int(maxsr*1.5);
	heal_sr(maxsr);

func is_staggered() -> bool: return staggered;

func test(): print(pawn.char_sheet.display_name, ": ", hp, "/", maxhp, " -- ", sr, "/", maxsr);

func apply_status_effect(_id:String, _potency:int, _count:int = 0):
	var se := get_status_effect(_id);
	if se != null: 
		se.potency = clamp(se.potency+_potency, 0, se.max_potency);
		se.count = clamp(se.count+_count, 0, se.max_count);
		return;
	
	se = Registry.get_status_effect(_id).deep_copy();
	se.pawn = pawn.combat_stats;
	
	#Effect Stuff
	se.potency = clamp(_potency, 1, se.max_potency);
	se.count = clamp(_count, 1, se.max_count);
	
	status_effects.push_back(se);

func get_status_effect(_id:String) -> StatusEffect:
	for s in status_effects: if s.fullid == _id: return s;
	return null;

func get_stat_mod(stat:_Enums.AS) -> int: return pawn.char_sheet.get_as_mod(stat);

func get_offense_level(stat:=_Enums.AS.STR) -> int:
	return pawn.char_sheet.level+get_stat_mod(stat);

func get_defense_level(stat:=_Enums.AS.CON) -> int:
	return pawn.char_sheet.level+get_stat_mod(stat);

func get_speed_level(stat:=_Enums.AS.DEX) -> int:
	return pawn.char_sheet.level+get_stat_mod(stat);

func deep_copy() -> CombatStats:
	var cs = CombatStats.new(pawn);
	cs.maxhp = maxhp;
	cs.hp = hp;
	cs.shield = shield;
	cs.maxsr = maxsr;
	cs.sr = sr;
	cs.staggered = staggered;
	cs.staggered_this_turn = staggered_this_turn;
	cs.stagger_level = stagger_level;
	cs.actionable = actionable;
	cs.sp = sp;
	cs.resistances = resistances;
	
	for se in status_effects: 
		var se_copy = se.deep_copy();
		se_copy.pawn = pawn.virtual_cs;
		cs.status_effects.push_back(se_copy);
	
	cs.counter_dice = counter_dice;
	cs.reserve_dice = reserve_dice;
	
	return cs;

func event_triggered(_signal:String, source:Variant, data:Dictionary = {}):
	for s in status_effects: s.event_triggered(_signal, source, data);
	for f in feats: f.event_triggered(_signal, source, data);
