extends VBoxContainer

@onready var text_edit = $LineEdit;
@onready var msg_box = $Messages;

func _on_line_edit_text_submitted(new_text):
	if !(MultiplayerManager.display_name is String) || MultiplayerManager.display_name == "": 
		MultiplayerManager.display_name = "User";
	rpc("send_msg", MultiplayerManager.display_name, new_text);
	text_edit.text = "";

@rpc("call_local", "unreliable", "any_peer", 1)
func send_msg(sender:String, text:String, name_color:String = "#ffffff"):
	msg_box.text += str("[left][color=", name_color, "]", sender, ": ", text, "\n");

func system_msg(text): rpc("send_system_msg", text);

@rpc("call_local", "unreliable", "any_peer", 1)
func send_system_msg(text):
	msg_box.text += str("[left][color=#ff00ff] (System) [color=#ffffff]", text, "\n");
