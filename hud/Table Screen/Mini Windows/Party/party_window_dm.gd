extends MiniWindow

var list_item = load("res://hud/Table Screen/Mini Windows/Party/list_item.tscn");

@onready var player_list := $"Player List";
@onready var player_sheet_list := $"Player-Sheet List";

func _ready():
	Server.connect("data_received", process_data);
	peers_to_plist();

func set_char_sheet(id):
	print("setting ", id);

func view_char_sheet(id):
	print("viewing ", id);

func new_plist_item(player:Player):
	if player.id <= 0: return;
	var i = list_item.instantiate();
	player_list.add_child(i);
	i.setup(player.username, player.id);

func peers_to_plist():
	if multiplayer.get_unique_id() != 1: new_plist_item(MultiplayerManager.get_player());
	Server.req("get_player");

func process_data(data:Variant, req_id:String) -> void:
	match req_id:
		"get_player": var p = Player.new().import_data(data); new_plist_item(p);
