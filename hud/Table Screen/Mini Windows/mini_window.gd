extends Panel
class_name MiniWindow

var table_screen:Control;

func _on_button_pressed(): self.queue_free();
