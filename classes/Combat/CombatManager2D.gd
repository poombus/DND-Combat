extends Node
class_name CombatManager2D

@onready var dice_res = preload("res://hud/speed_dice.tscn");
@onready var clash_info_res = preload("res://tools/basic_combat_visualizer/hud/clash_info.tscn");

var battle_cam:BattleCamera;
var combat_gui:CombatGUI;
var script_maker:ScriptMaker = ScriptMaker.new();
var combat_script:Array;
var clash_list;

enum PHASES {SPEED = 0, SKILLS, TARGET, COMBAT}
var phase:PHASES = PHASES.SPEED;

var pawns:Array[Pawn2D];
var dead_pawns:Array[Pawn2D];

var turn:int = 0;

func setup(pawns0:Array[Pawn2D], pawns1:Array[Pawn2D], battle_camera:BattleCamera, combat_gui_ref, clash_list_ref):
	#LOAD STAGE HERE
	await get_tree().create_timer(0.5).timeout;
	#EVENTUALLY, HAVE players AND enemies BE CHARACTERSHEETS. CREATE PAWNS BASED OFF THEM.
	battle_cam = battle_camera;
	combat_gui = combat_gui_ref;
	clash_list = clash_list_ref;
	
	pawns = pawns0;
	pawns.append_array(pawns1);
	
	for p in pawns0: p.combat_stats.team = 0;
	for p in pawns1: p.combat_stats.team = 1;
	for p in pawns: p.starting_pos = p.global_position;
	
	phase = PHASES.SPEED;
	
	for c in clash_list.get_children(): c.queue_free();
	new_turn(0);

func new_turn(set_turn:int = -1):
	if check_win() != -1: 
		print("Team ", check_win(), " wins!");
		return;
	if set_turn == -1: turn += 1;
	else: turn = set_turn;
	
	for pawn in pawns:
		#pawn.verify_parity(); #CONSOLE CHECK
		pawn.combat_stats.counter_dice = [];
		pawn.combat_stats.shield = 0;
		pawn.combat_stats.unstagger();
		pawn.global_position = pawn.starting_pos;
		pawn.update_nameplate();
		if pawn.get_sdc(): pawn.get_sdc().regenerate_container();
	
	combat_gui.new_turn_display(turn+1);

func next_phase():
	if phase == PHASES.SPEED: #ROLL SPEED DICE
		for pawn in pawns: pawn.sdc.roll_all_speed_dice();
		phase = PHASES.SKILLS;
		
	elif phase == PHASES.SKILLS: #REGISTER SKILLS
		GlobalMouseDiceTracker.unselect_dice();
		for p in pawns: p.prune_speed_dice();
		phase = PHASES.TARGET;
		
	elif phase == PHASES.TARGET: #REGISTER TARGETS
		GlobalMouseDiceTracker.unselect_dice();
		var sd_list:Array[SpeedDice] = [];
		for p in pawns: 
			sd_list.append_array(p.get_speed_dice());
			p.virtual = true;
			p.virtual_cs = p.combat_stats.deep_copy();
		combat_script = script_maker.create_script(sd_list);
		
		phase = PHASES.COMBAT;
		clash_list.visible = true;
		combat_phase();
		
	else:
		phase = PHASES.SPEED;
		clash_list.visible = false;
		new_turn();

func combat_phase() -> void:
	for c in clash_list.get_children(): c.queue_free();
	if combat_script.is_empty(): return;
	for sc in combat_script:
		var not_yet = false;
		for c in clash_list.get_children(): if c.pawns.has(sc.a.pawn) || c.pawns.has(sc.t.pawn): not_yet = true;
		if not_yet: continue;
		play_skirmish(sc);

func play_skirmish(sc):
	sc.playback = true;
	sc.onesided = false;
	
	var a = sc.a;
	var t = sc.t;
	
	for x in [a, t]:
		x.pawn.virtual = false;
		x.stats = x.pawn.get_cs();
		x.dice_chain = x.sd_ref.get_skill_dice();
		script_maker.add_counter_dice(x.sd_ref);
	
	var ci = clash_info_res.instantiate();
	clash_list.add_child(ci);
	ci.setup(a.pawn, t.pawn);
	sc.clash_info = ci;
	
	ci.toggle_dice(true, true);
	ci.toggle_dice(false, true);
	
	for x in [a, t]:
		x.dice = 0;
		x.current_roll = 0;
		x.roll_sum = 0;
		x.counter = false;
		if x.dice_chain.is_empty(): 
			x.dice_chain = x.stats.reserve_dice;
			x.counter = true;
		if x.stats.staggered: x.dice_chain = [];
	
	while not sc.onesided: 
		script_maker.calc_clash(sc);
		await get_tree().create_timer(1.0).timeout;
	if sc.onesided: for x in [[a,t], [t,a]]:
		if not x[0].clashwinner or x[0].dice_chain.is_empty() or x[0].counter: continue;
		x[0].dice = 0;
		x[1].cur_dice = null;
		x[1].val = 0;
		
		ci.toggle_dice(true, x[0] == a);
		ci.toggle_dice(false, x[0] == t);
		while not x[0].dice_chain.is_empty(): 
			script_maker.calc_onesided(sc, x[0], x[1]);
			await get_tree().create_timer(1.0).timeout;
	for x in [[a,t], [t,a]]:
		if not x[0].counter or x[0].stats.staggered: continue;
		x[0].dice_chain = x[0].stats.counter_dice;
		x[0].dice = 0;
		x[1].cur_dice = null;
		x[1].val = 0;
		
		ci.toggle_dice(true, x[0] == a);
		ci.toggle_dice(false, x[0] == t);
		while not x[0].dice_chain.is_empty(): 
			script_maker.calc_onesided(sc, x[0], x[1]);
			await get_tree().create_timer(1.0).timeout;
	
	ci.free();
	combat_script.pop_at(combat_script.find(sc));
	combat_phase();

func pawn_died(p:Pawn2D):
	var ind = pawns.find(p);
	if ind != -1:
		pawns.remove_at(ind);
		dead_pawns.push_back(p);
		p.anim.play_death();

func check_win() -> int:
	if pawns.is_empty(): return 0;
	var winning = pawns[0].combat_stats.team;
	for p in pawns: if p.combat_stats.team != winning: return -1;
	
	return winning;
