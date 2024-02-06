extends Node

#TURN THIS INTO SOMETHING LIKE SOCKET.IO
#CREATE FUNCS THAT WILL BE USED FREQUENTLY. THESE FUNCS WILL EMIT SINGALS AS A RESPONSE
#IN CLIENT SCRIPTS, CONNECT TO THESE SIGNALS

#FIND OUT IF YOU CAN TURN HOST INTO A SERVER, AND ALL CLIENTS INTERACT WITH THE SERVER AS A MEDIUM (like nodejs)

signal res_player(player:Player);

func req_player(target:int) -> void: rpc_id(target, "req1_player", multiplayer.get_unique_id());

@rpc("any_peer")
func req1_player(sender:int) -> void:
	rpc_id(sender, "req2_player", MultiplayerManager.get_player());

@rpc("any_peer")
func req2_player(p:Player) -> void:
	print(p);
	res_player.emit(p);
