extends Node

#HAVE UNUSED DEFENSE DICE BE ADDED TO COUNTER QUEUE

var sk_num:int = 0;
var skirmishes:Array[Dictionary] = [];

var active_skirmishes:Array[Dictionary] = [];

func create_skirmishes(sd_list:Array[SpeedDice]):
	sd_list = order_sd_list(sd_list);
	skirmishes = [];
	
	for sd in sd_list:
		if !sd.skill_chain.is_empty() && sd.target is SpeedDice: add_skirmish(sd);
	
	start_skirmishes();

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

func add_skirmish(sd:SpeedDice):
	#Check if dice is already involved in a skirmish AND find proper spot
	
	var index_range:Array[int] = [0,0];
	for s in skirmishes:
		if sd == s.a.sd_ref || sd == s.t.sd_ref: return; #dice is already in a skirmish
		if s.speed > sd.value: 
			index_range[0] += 1;
			index_range[1] += 1;
		elif s.speed == sd.value: index_range[1] += 1;
	
	var data = {
		"speed": sd.value,
		"phase": 0, #0-approach, 1-attack, 2-pause
		"onesided": false,
		"a": {
			"sd_ref": sd,
			"pawn": sd.pawn,
			"stats": sd.pawn.combat_stats,
			"skill_chain": sd.convert_skill_chain(),
			"counter": false,
			"dice": 0,
			"clashwinner": false
		},
		"t": {
			"sd_ref": sd.target,
			"pawn": sd.target.pawn,
			"stats": sd.target.pawn.combat_stats,
			"skill_chain": sd.target.convert_skill_chain(),
			"counter": false,
			"dice": 0,
			"clashwinner": false
		}
	}
	
	if data.t.skill_chain.is_empty(): 
		data.t.skill_chain = data.t.stats.counter_dice;
		data.t.counter = true;
	
	skirmishes.insert(randi_range(index_range[0], index_range[1]), data);

func start_skirmishes():
	sk_num = 0;
#	var finished = false;
#	while !finished:
#		finished = await activate_skirmish();
	activate_skirmish();

func activate_skirmish() -> bool:
	if sk_num == skirmishes.size(): return true;
	var sk = skirmishes[sk_num];
	active_skirmishes.append(sk);
	sk_num += 1;
	
	var a = sk.a; #attacker
	var t = sk.t; #target
	
	for x in [a, t]:
		x.dice = 0;
		print(x.stats.msc);
		if x.stats.staggered: x.skill_chain = [];
		x.stats.msc.generate_dice(x.skill_chain);
		x.stats.msc.visible = !x.skill_chain.is_empty();
		x.stats.msc.update_display(0);
	
	if a.skill_chain.is_empty() || t.skill_chain.is_empty():
		sk.onesided = true;
		a.clashwinner = !a.skill_chain.is_empty();
		t.clashwinner = !t.skill_chain.is_empty();
	
	next_phase(0);
	return false;

func next_phase(ind:int):
	var sk = active_skirmishes[ind];
	var a = sk.a;
	var t = sk.t;
	if sk.phase == 0: approach_phase(a, t, sk, ind);
	elif sk.phase == 1: reach_phase(a, t, sk, ind);
	elif sk.phase == 2: roll_phase(sk, ind);

func approach_phase(a:Dictionary, t:Dictionary, sk:Dictionary, ind:int):
	sk.phase = 1;
	if sk.onesided:
		for x in [[sk.a, sk.t],[sk.t,sk.a]]:
			if !x[0].clashwinner: continue;
			if x[0].skill_chain.is_empty(): end_skirmish(ind); return;
			x[0].pawn.anim.approach_target(x[1].pawn);
			x[0].pawn.anim.sk_ref = ind;
		return;
	a.pawn.anim.approach_target(t.pawn);
	a.pawn.anim.sk_ref = ind;
	t.pawn.anim.approach_target(a.pawn);
	t.pawn.anim.sk_ref = -1;

func reach_phase(a:Dictionary, t:Dictionary, sk:Dictionary, ind:int):
	if !a.pawn.anim.can_reach_target(t.pawn): return;
	sk.phase = 2;
	next_phase(ind);

func roll_phase(sk:Dictionary, ind:int):
	if !sk.onesided: 
		sk.onesided = await calc_clash(sk.a,sk.t);
		sk.phase = 0;
		
		next_phase(ind);
	else: 
		if !sk.a.clashwinner && !sk.t.clashwinner: end_skirmish(ind); return;
		
		for x in [[sk.a, sk.t], [sk.t, sk.a]]:
			if !x[0].clashwinner: continue;
			if x[0].skill_chain.is_empty(): end_skirmish(ind); return;
			x[1].stats.msc.visible = false;
			if !await calc_one_sided(x[0], x[1]):
				sk.phase = 0;
				next_phase(ind);

func end_skirmish(ind:int = 0):
	active_skirmishes.remove_at(ind);
	if active_skirmishes.is_empty(): activate_skirmish();

func calc_clash(a,t) -> bool:
	for x in [a,t]:
		x.cur_dice = current_dice(x);
		x.val = x.cur_dice.roll();
		x.stats.msc.change_dice_value(x.dice, x.val);
	
	await get_tree().create_timer(0.5).timeout;
	if a.val > t.val: win_logic(a,t);
	elif a.val < t.val: win_logic(t,a);
	elif a.val == t.val: tie_logic(a,t);
	await get_tree().create_timer(1).timeout;
	
	for x in [a,t]:
		if x.stats.staggered: x.skill_chain = [];
	
	if a.skill_chain.is_empty() || t.skill_chain.is_empty(): 
		a.clashwinner = !a.skill_chain.is_empty();
		t.clashwinner = !t.skill_chain.is_empty();
		a.dice = 0;
		t.dice = 0;
		return true;
	return false;

func calc_one_sided(a, t) -> bool: #this is where you do the cool animations
	if a.skill_chain.is_empty(): 
		a.clashwinner = false;
		return true;
	a.cur_dice = current_dice(a);
	
	if a.cur_dice.is_offensive(): 
		a.val = a.cur_dice.roll();
		a.stats.msc.change_dice_value(a.dice, a.val);
		await get_tree().create_timer(0.5).timeout;
		
		t.stats.dmg_hp(a.val);
		t.stats.dmg_sr(a.val);
		animation_logic(a,t);
		t.pawn.apply_knockback(a.pawn.global_position,8);
		await get_tree().create_timer(1).timeout;
	remove_current_dice(a);
	
	return false;

func defensive_dice_to_clash(x):
	var d = 0;
	while d <= x.skill_chain.size():
		if x.skill_chain[d].is_defensive(): 
			x.stats.counter_dice.push_back(x.skill_chain[d].deep_copy());
			x.skill_chain.pop_at(d);
			d += -1;

func current_dice(x) -> Dice:
	if x.dice >= x.skill_chain.size(): x.dice = 0;
	return x.skill_chain[x.dice];

func next_dice(x:Dictionary) -> void:
	x.dice += 1;
	if x.dice >= x.skill_chain.size(): x.dice = 0;
	x.stats.msc.update_display(x.dice);

func remove_current_dice(x:Dictionary) -> void:
	x.skill_chain.pop_at(x.dice);
	x.stats.msc.remove_dice(x.dice);
	if x.dice >= x.skill_chain.size(): x.dice = 0;
	x.stats.msc.update_display(x.dice);

func win_logic(W, L):
	animation_logic(W,L);
	L.pawn.apply_knockback(W.pawn.global_position,5);
	if L.cur_dice.is_offensive(): #offensive loss
		if W.cur_dice.is_offensive():
			L.stats.dmg_hp(W.val-L.val);
			if W.cur_dice.is_counter(): L.stats.dmg_sr(W.val-L.val);
			if !W.cur_dice.is_counter(): next_dice(W);
		elif W.cur_dice.is_guard():
			L.stats.dmg_sr(W.val-L.val);
			if !W.cur_dice.is_counter(): remove_current_dice(W);
		elif W.cur_dice.is_evade():
			W.stats.dmg_sr(-W.val);
		
	elif L.cur_dice.is_guard(): #guard loss
		if W.cur_dice.is_offensive():
			L.stats.dmg_sr(W.val-L.val);
		elif W.cur_dice.is_guard():
			L.stats.dmg_sr(W.val);
		elif W.cur_dice.is_evade():
			W.stats.dmg_sr(-W.val);
		
		if !W.cur_dice.is_counter() || W.cur_dice.is_defensive(): remove_current_dice(W);
		
	elif L.cur_dice.is_evade(): #evade loss
		if W.cur_dice.is_offensive():
			L.stats.dmg_hp(W.val);
			if !W.cur_dice.is_counter(): next_dice(W);
		elif W.cur_dice.is_guard():
			L.stats.dmg_sr(-W.val);
			remove_current_dice(W);
		elif W.cur_dice.is_evade():
			remove_current_dice(W);
	
	remove_current_dice(L);

func tie_logic(x,y):
	animation_logic(x,y, true);
	if x.cur_dice.is_offensive() && y.cur_dice.is_offensive():
		if !x.cur_dice.is_counter(): next_dice(x);
		if !y.cur_dice.is_counter(): next_dice(y);
		x.pawn.apply_knockback(y.pawn.global_position,5);
		y.pawn.apply_knockback(x.pawn.global_position,5);
	elif x.cur_dice.is_defensive() || y.cur_dice.is_defensive():
		remove_current_dice(x);
		remove_current_dice(y);

func animation_logic(x, y, is_tie:bool = false):
	if is_tie: for t in [[x,y],[y,x]]:
		t[0].pawn.anim.process_action("ATTACK", {"dice" = t[0].cur_dice, "target" = t[1].pawn});
	elif x.cur_dice.is_offensive(): 
		x.pawn.anim.process_action("ATTACK", {"dice" = x.cur_dice, "target" = y.pawn});
		y.pawn.anim.process_action("HURT");
