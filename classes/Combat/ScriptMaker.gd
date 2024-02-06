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
	
	for sd in sd_list:
		if sd.skill && sd.target is SpeedDice: add_skirmish(sd);
	
	for pawn in _CM.pawns: pawn.setup_virtual_cs();
	
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
			"pawn": sd.pawn,
			"stats": sd.pawn.get_cs(),
			"dice_chain": sd.get_skill_dice(),
			"skill": sd.skill,
			"counter": false,
			"dice": 0,
			"clashwinner": false,
			"rolls": [],
			"current_roll": 0,
			"roll_sum": 0,
			"final_damage": 0
		},
		"t": {
			"sd_ref": sd.target,
			"pawn": sd.target.pawn,
			"stats": sd.target.pawn.get_cs(),
			"dice_chain": sd.target.get_skill_dice(),
			"skill": sd.target.skill,
			"counter": false,
			"dice": 0,
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
	print("\nSKIRMISH START");
	sk.onesided = false;
	
	var a = sk.a;
	var t = sk.t;
	
	for x in [a, t]:
		x.dice = 0;
		x.counter = false;
		if x.dice_chain.is_empty():
			x.dice_chain = x.stats.reserve_dice;
			x.counter = true;
		if x.stats.staggered: x.dice_chain = [];
	
	while not sk.onesided: calc_clash(sk);
	if sk.onesided: for x in [[a,t], [t,a]]:
		if not x[0].clashwinner or x[0].dice_chain.is_empty() or x[0].counter: continue;
		x[0].dice = 0;
		while not x[0].dice_chain.is_empty(): calc_onesided(sk, x[0], x[1]);
	
	for x in [[a,t], [t,a]]:
		if not x[0].counter or x[0].stats.staggered: continue;
		x[0].dice_chain = x[0].stats.counter_dice;
		x[0].dice = 0;
		while not x[0].dice_chain.is_empty(): calc_onesided(sk, x[0], x[1]);

func calc_clash(sk):
	var a = sk.a; var t = sk.t;
	
	if a.dice_chain.is_empty() || t.dice_chain.is_empty():
		sk.onesided = true;
		for x in [a, t]:
			transfer_defensive_dice(x);
			x.clashwinner = !x.dice_chain.is_empty();
			if sk.clash_count > 0:
				if x.clashwinner: event_call("on_clash_win", x.stats, {"source": x.stats, "target": t.stats if x == a else a.stats});
				else: event_call("on_clash_lose", x.stats, {"source": x.stats, "target": a.stats if x == a else t.stats});
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
	di.source = winner.pawn;
	
	roll_dice(winner, sk.playback);
	
	di.multiplier *= (1+sk.clash_count*0.03); #clash count bonus
	di.apply_types(winner.cur_dice.skill);
	di.apply_resistances(loser.pawn);
	di.apply_modifiers(winner.cur_dice.skill, winner.pawn, loser.pawn);
	
	winner.roll_sum += winner.val;
	
	di.value = winner.roll_sum;
	var total = loser.stats.apply_damage(di);
	event_call("on_hit", winner.cur_dice, {"target":loser.stats, "source":winner.stats});

	if !sk.playback:
		winner.final_damage += total;
		print("Winner dealt ", total, "(", winner.final_damage,") damage! ", loser.stats.hp, "(+", loser.stats.shield,")//", loser.stats.sr);
	else:
		sk.clash_info.set_clash(sk.a.cur_dice, sk.a.val, sk.t.cur_dice, sk.t.val);
	
	remove_current_dice(winner);
	winner.pawn.update_nameplate();
	loser.pawn.update_nameplate();

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
			loser.stats.deal_stagger(winner.val-loser.val); #deal stagger = difference
			next_dice(winner);
		elif W.is_guard(): 
			winner.stats.give_shield(winner.val); #winner gains shield
			loser.stats.deal_stagger(winner.val); #deal stagger = winner roll
		elif W.is_evade(): winner.stats.heal_sr(winner.val); #heal winner stagger
	elif L.is_evade():
		if W.is_offensive() and not W.is_counter(): 
			loser.stats.deal_stagger(winner.val*2); #deal double stagger damage
			next_dice(winner);
		elif W.is_guard():
			winner.stats.give_shield(winner.val); #give shield. 
			loser.stats.deal_stagger(winner.val); #deal stagger damage = winner roll
	
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

func add_counter_dice(dice:SpeedDice):
	var pawn = dice.pawn;
	var skill = dice.skill;
	if !skill: return;
	if not dice.counter_dice.is_empty():
		for d in dice.counter_dice: pawn.get_cs().counter_dice.push_back(d.deep_copy());
		return;
	for i in range(skill.dice.size()-1, -1, -1):
		if skill.dice[i].dice_type != _Enums.DICE_TYPES.COUNTER: continue;
		dice.counter_dice.push_back(skill.dice[i].deep_copy());
		skill.dice.remove_at(i);
	for d in dice.counter_dice: pawn.get_cs().counter_dice.push_back(d.deep_copy());
	if skill.dice.is_empty(): dice.skill = null;

func roll_dice(x:Dictionary, playback:bool):
	if !playback:
		x.cur_dice = current_dice(x);
		x.val = x.cur_dice.roll();
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
