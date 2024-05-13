extends Node
class_name ScriptMaker

var skirmishes:Array[Dictionary] = [];

#Function should take in all pawns and their speed dice.

#Script will create batches. Batches should not have conflicts in active pawns.
#Batches just allow combat phases to pass quicker.

#Each batch contains 1 or more skirmishes.

#Skirmishes have a Clash phase and a One-Sided phase. 
#Clash phase occurs when both combatants have dice.
#One-Sided phase (or the damage phase) occurs when one side runs out of dice and the other has attack dice.

#Skirmishes are just lists of dice rolls. This is so there are no desyncs over the network.
#Should also calculate Status effects.

func create_script(sd_list:Array[SpeedDice]) -> Array[Dictionary]:
	sd_list = order_sd_list(sd_list);
	skirmishes = [];
	
	for pawn in _CM.pawns: 
		pawn.setup_virtual_cs();
		#pawn.combat_stats.virtual = true;
	
	for sd in sd_list:
		if sd.skill && sd.target is SpeedDice: add_skirmish(sd);
	
	for sk in skirmishes: calculate_skirmish(sk);
	
	return skirmishes;

func add_skirmish(sd:SpeedDice):
	#Check if dice is already involved in a skirmish AND find proper spot
	
	var index_range:Array[int] = [0,0];
	for s in skirmishes:
		if sd == s.a.sd_ref || sd == s.t.sd_ref: return; #dice is already in a skirmish
		if s.speed > sd.value: 
			index_range[0] += 1;
			index_range[1] += 1;
		elif s.speed == sd.value: index_range[1] += 1;
	
	add_counter_dice(sd);
	
	var data = {
		"speed": sd.value,
		"phase": 0, #0-approach, 1-attack, 2-pause
		"onesided": false,
		"playback": false,
		"clash_count": 0,
		"a": {
			"sd_ref": sd,
			"stats": sd.pawn.stats.virtual_stats,
			"dice_chain": sd.get_skill_dice(),
			"skill": sd.skill,
			"counter": false,
			"dice": 0,
			"cur_dice": null,
			"val": 0,
			"clashwinner": false,
			"rolls": [],
			"current_roll": 0,
			"roll_sum": 0,
			"final_damage": 0
		},
		"t": {
			"sd_ref": sd.target,
			"stats": sd.target.pawn.stats.virtual_stats,
			"dice_chain": sd.target.get_skill_dice(),
			"skill": sd.target.skill,
			"counter": false,
			"dice": 0,
			"cur_dice": null,
			"val": 0,
			"clashwinner": false,
			"rolls": [],
			"current_roll": 0,
			"roll_sum": 0,
			"final_damage": 0
		}
	}
	
	skirmishes.insert(randi_range(index_range[0], index_range[1]), data);

func order_sd_list(sd_list:Array[SpeedDice]) -> Array[SpeedDice]:
	var new_list:Array[SpeedDice] = [];
	for sd in sd_list:
		if new_list.is_empty(): 
			new_list.push_back(sd);
			continue;
		var inserted = false;
		for i in new_list.size():
			if sd.value >= new_list[i].value: 
				new_list.insert(i, sd);
				inserted = true;
				break;
		if inserted == false: new_list.insert(new_list.size(), sd);
	return new_list;

func calculate_skirmish(sk):
	if !sk.playback: print("\nSKIRMISH START");
	sk.onesided = false;
	
	var a = sk.a;
	var t = sk.t;
	
	for x in [a, t]: prepare_skirmish(x, sk.playback);
	
	if sk.playback:
		var ci = _CM.clash_info_res.instantiate();
		_CM.clash_list.add_child(ci);
		ci.setup(a.stats.pawn, t.stats.pawn);
		sk.clash_info = ci;
		
		ci.toggle_dice(true, true);
		ci.toggle_dice(false, true);
	
	if a.dice_chain.is_empty() and t.dice_chain.is_empty(): return;
	
	while not sk.onesided: 
		calc_clash(sk);
		if sk.playback: await _CM.get_tree().create_timer(1.0).timeout;
	
	if a.dice_chain.is_empty() and t.dice_chain.is_empty(): return;
	
	if sk.onesided: for x in [[a,t], [t,a]]:
		if not x[0].clashwinner or x[0].dice_chain.is_empty() or x[0].counter: continue;
		x[0].dice = 0;
		if sk.playback:
			sk.clash_info.toggle_dice(true, x[0] == a);
			sk.clash_info.toggle_dice(false, x[0] == t);
			while x[0].current_roll < x[0].rolls.size(): 
				calc_onesided(sk, x[0], x[1]);
				if sk.playback: await _CM.get_tree().create_timer(1.0).timeout;
		else:
			while x[0].dice < x[0].dice_chain.size(): 
				calc_onesided(sk, x[0], x[1]);
				if sk.playback: await _CM.get_tree().create_timer(1.0).timeout;
	
	for x in [[a,t], [t,a]]:
		if not x[0].counter or x[0].stats.staggered: continue;
		for d in x[0].stats.counter_dice: x[0].dice_chain.push_back(d.deep_copy());
		x[0].dice = 0;
		if sk.playback:
			sk.clash_info.toggle_dice(true, x[0] == a);
			sk.clash_info.toggle_dice(false, x[0] == t);
			while x[0].current_roll < x[0].rolls.size(): 
				calc_onesided(sk, x[0], x[1]);
				if sk.playback: await _CM.get_tree().create_timer(1.0).timeout;
		else:
			while x[0].dice < x[0].dice_chain.size(): 
				calc_onesided(sk, x[0], x[1]);
				if sk.playback: await _CM.get_tree().create_timer(1.0).timeout;
	
	if sk.playback:
		await _CM.get_tree().create_timer(1.0).timeout;
		sk.clash_info.free();
		_CM.combat_script.pop_at(_CM.combat_script.find(sk));
		_CM.combat_phase();

func calc_clash(sk):
	var a = sk.a; var t = sk.t;
	
	for x in [[a,t],[t,a]]:
		if not x[1].dice_chain.is_empty() and not x[1].stats.is_staggered(): continue;
		x[1].dice_chain = [];
		sk.onesided = true;
		transfer_defensive_dice(x[0]);
		x[0].clashwinner = true;
		if sk.clash_count <= 0: return;
		event_call("on_clash_win", x[0].stats, {
			"source": x[0].stats, 
			"target": x[1].stats, 
			"clash_count": sk.clash_count
		});
		event_call("on_clash_lose", x[1].stats, {
			"source": x[1].stats, 
			"target": x[0].stats, 
			"clash_count": sk.clash_count
		});
		x[0].stats.heal_sp(int(10+(sk.clash_count*1.2)));
		x[1].stats.dmg_sp(int(sk.clash_count*3));
		return;
	
	for x in [a,t]: #SIMULATE THE SIMULATION WITH PRE-EXISTING ROLLS
		roll_dice(x, sk.playback);
	if !sk.playback: sk.clash_count += 1;
	
	if sk.playback: sk.clash_info.set_clash(a.cur_dice, a.val, t.cur_dice, t.val);
	else: print(a.cur_dice.get_type_string(), " ", a.val, " // ", t.cur_dice.get_type_string(), " ", t.val);
	dice_interaction(a, t);
	a.pawn.update_nameplate();
	t.pawn.update_nameplate();

func calc_onesided(sk, winner, loser):
	var di = DamageInstance.new(0);
	di.source_type = DamageInstance.SOURCES.SKILL;
	di.source = winner.stats;
	
	roll_dice(winner, sk.playback);
	
	di.multiplier *= (1+sk.clash_count*0.03); #clash count bonus
	di.apply_types(winner.cur_dice.skill);
	di.apply_resistances(loser.stats);
	di.apply_modifiers(winner.cur_dice.skill, winner.stats, loser.stats);
	#BUG: STAGGER ISN't GETTING RESET AFTER SIMULATION
	winner.roll_sum += winner.val;
	
	di.value = winner.roll_sum;
	var total = loser.stats.apply_damage(di);
	loser.stats.dmg_sp(int(total*0.1)+1);
	event_call("on_hit", winner.cur_dice, {"target":loser.stats, "source":winner.stats});

	if !sk.playback:
		winner.final_damage += total;
		print(winner.stats.pawn.char_sheet.display_name, " dealt ", total, "(", winner.final_damage,") damage! ", loser.stats.hp, "(+", loser.stats.shield,")//", loser.stats.sr);
	else:
		sk.clash_info.set_clash(sk.a.cur_dice, sk.a.val, sk.t.cur_dice, sk.t.val);
	
	remove_current_dice(winner);
	winner.stats.pawn.update_nameplate();
	loser.stats.pawn.update_nameplate();

func dice_interaction(a, t, calculating:bool = true):
	if a.val == t.val: #tie
		dice_tie(a, t);
		return;
	
	var winner = a;
	var loser = t;
	if t.val > a.val: winner = t; loser = a;
	var W = winner.cur_dice; var L = loser.cur_dice;
	
	if L.is_offensive():
		if W.is_offensive() and not W.is_counter(): next_dice(winner);
		elif W.is_guard(): 
			winner.stats.give_shield(winner.val); #winner gains shield
			remove_current_dice(winner);
	elif L.is_guard():
		loser.stats.give_shield(loser.val); #loser gains shield regardless
		if W.is_offensive(): 
			loser.stats.dmg_sr(winner.val-loser.val); #deal stagger = difference
			next_dice(winner);
		elif W.is_guard(): 
			winner.stats.give_shield(winner.val); #winner gains shield
			loser.stats.dmg_sr(winner.val); #deal stagger = winner roll
		elif W.is_evade(): winner.stats.heal_sr(winner.val); #heal winner stagger
	elif L.is_evade():
		if W.is_offensive() and not W.is_counter(): 
			loser.stats.dmg_sr(winner.val*2); #deal double stagger damage
			next_dice(winner);
		elif W.is_guard():
			winner.stats.give_shield(winner.val); #give shield. 
			loser.stats.dmg_sr(winner.val); #deal stagger damage = winner roll
	
	if calculating:
		if W.is_defensive() && L.is_defensive(): remove_current_dice(winner);
		remove_current_dice(loser);
	else:
		pass;

func dice_tie(a, t) -> void:
	if a.cur_dice.is_offensive() && t.cur_dice.is_offensive(): 
		if not a.cur_dice.is_counter(): next_dice(a);
		if not t.cur_dice.is_counter(): next_dice(t);
	elif a.cur_dice.is_defensive() || t.cur_dice.is_defensive():
		for x in [a,t]:
			if x.cur_dice.is_guard(): x.stats.give_shield(x.val);
			remove_current_dice(x);

func current_dice(x) -> Dice:
	if x.dice >= x.dice_chain.size(): x.dice = 0;
	return x.dice_chain[x.dice];

func next_dice(x:Dictionary) -> void:
	x.dice += 1;
	if x.dice >= x.dice_chain.size(): x.dice = 0;

func remove_current_dice(x:Dictionary) -> void:
	x.dice_chain.pop_at(x.dice);
	if x.dice >= x.dice_chain.size(): x.dice = 0;

func transfer_defensive_dice(x):
	var d = 0;
	while d < x.dice_chain.size():
		if x.dice_chain[d].is_defensive(): 
			x.stats.reserve_dice.push_back(x.dice_chain[d].deep_copy());
			x.dice_chain.pop_at(d);
		d += 1;

func prepare_skirmish(x:Dictionary, playback:=false):
	if not playback:
		x.dice = 0;
		x.counter = false;
		#x.dice_chain = x.skill.deep_copy_dice();
		if x.dice_chain.is_empty() and not x.stats.staggered:
			x.dice_chain = x.stats.reserve_dice;
			x.counter = true;
	else:
		#x.stats.pawn.get_cs().virtual = false;
		#x.stats = x.stats.pawn.get_cs();
		x.dice_chain = x.sd_ref.get_skill_dice();
		x.roll_sum = 0;
		add_counter_dice(x.sd_ref);

func add_counter_dice(dice:SpeedDice):
	if !dice.skill: return;
	dice.skill.seperate_counter_dice();
	dice.pawn.get_cs().counter_dice.append_array(dice.skill.counter_dice);

func roll_dice(x:Dictionary, playback:bool):
	if !playback:
		x.cur_dice = current_dice(x);
		var adv:int = int(x.stats.sp/40);
		if randi_range(0,39) < x.stats.sp%40: adv += 1;
		x.val = x.cur_dice.roll(adv, x.stats);
		x.rolls.push_back(x.val);
		event_call("on_dice_rolled", x.stats);
	else:
		x.cur_dice = current_dice(x);
		x.val = x.rolls[x.current_roll];
		x.current_roll += 1;
		event_call("on_dice_rolled", x.stats);

func event_call(_signal:String, source:Variant, data:Dictionary = {}):
	if source is Dice: source.event_triggered(_signal, source, data);
	for p in _CM.pawns: p.get_cs().event_triggered(_signal, source, data);
