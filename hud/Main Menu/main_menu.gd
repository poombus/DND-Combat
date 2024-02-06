extends Control

@onready var display_name = $"VBoxContainer/Display Name";

func _on_host_pressed():
	if display_name.text != "": MultiplayerManager.display_name = display_name.text;
	MultiplayerManager.host_server();

func _on_join_pressed():
	if display_name.text != "": MultiplayerManager.display_name = display_name.text;
	MultiplayerManager.join_server();
