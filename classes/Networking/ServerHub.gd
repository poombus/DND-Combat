extends Node

signal data_received(data:Variant, req_id:String);

#functions go inside
var listener:Dictionary = {};

@rpc("any_peer")
func req(req_id:String, args:Array = []) -> void: #targets all clients
	if multiplayer.get_remote_sender_id() == 0: return rpc("req", req_id, args);
	if multiplayer.get_remote_sender_id() == multiplayer.get_unique_id(): return;
	
	var data = listener[req_id].callv(args);
	rpc_id(multiplayer.get_remote_sender_id(), "_emit_data", data, req_id);

@rpc("any_peer")
func req_to(target:int, req_id:String, args:Array = []) -> void: #targets specific client
	if multiplayer.get_remote_sender_id() == 0: return rpc_id(target, "req_to", target, req_id, args);
	
	var data = listener[req_id].callv(args);
	rpc_id(multiplayer.get_remote_sender_id(), "_emit_data", data, req_id);

@rpc("any_peer")
func _emit_data(data:Variant,  req_id:String = "") -> void: data_received.emit(data, req_id);

func on(listen_id:String, function:Callable) -> void:
	listener[listen_id] = function;
