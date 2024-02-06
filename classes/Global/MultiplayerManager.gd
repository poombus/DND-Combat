extends Node

#object.set_multiplayer_authority will associated the object with the id of the peer that called it
#when is_multiplayer_authority is called by that peer, it will return true, otherwise false

var multiplayer_peer:ENetMultiplayerPeer = ENetMultiplayerPeer.new();

var client_player:Player = Player.new();
#multiplayer.multiplayer_peer.get_peers()

const PORT = 9999;
const ADDRESS = "localhost";

var display_name = "Username";

func host_server():
	GlobalSignals.connect("req_player", send_player_data);
	
	multiplayer_peer.create_server(PORT);
	multiplayer.multiplayer_peer = multiplayer_peer;
	#str(multiplayer.get_unique_id())
	
	multiplayer.peer_connected.connect(func(peer_id): 
		rpc("add_peer", peer_id);
		rpc_id(peer_id, "client_setup", peer_id);
	);
	
	get_tree().change_scene_to_file("res://hud/Table Screen/Main/table_screen.tscn");
	if display_name == "Username": display_name = "DM";

func join_server():
	GlobalSignals.connect("req_player", send_player_data);
	
	multiplayer_peer.create_client(ADDRESS, PORT);
	multiplayer.multiplayer_peer = multiplayer_peer;
	get_tree().change_scene_to_file("res://hud/Table Screen/Main/table_screen.tscn");

@rpc
func add_peer(p_id) -> void:
	print(p_id, " Joined");

@rpc
func client_setup(p_id) -> void:
	if display_name == "Username": display_name = "Client "+str(multiplayer.get_unique_id());
	client_player.init(p_id, display_name);

func send_player_data(target_id:int, requester:int): 
	print(multiplayer.get_unique_id(), ": ", target_id, " requested by ", requester);
	if target_id != multiplayer.get_unique_id(): return;
	GlobalSignals.emit_signal("res_player", client_player, requester);

func get_player() -> Player: return client_player;
