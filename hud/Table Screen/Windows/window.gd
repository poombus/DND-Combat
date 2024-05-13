extends Panel
class_name CustomWindow

func _on_close_button_pressed(): self.queue_free();
