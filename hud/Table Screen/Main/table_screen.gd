extends Control

@onready var mini_window := $"Mini Window";
@onready var tabs := $Tabs;
@onready var chatbox := $"Chat Box";

func _ready():
	tabs.table_screen = self;
	
	Server.on("test", func(text:String):
		Server._emit_data("this is data", "test")
	);
	Server.on("get_player", func():
		return MultiplayerManager.client_player.get_data();
	);
