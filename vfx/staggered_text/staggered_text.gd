extends Node3D
class_name VFX

@onready var anim = $AnimationPlayer;

func _ready():
	if anim.has_animation("Effect"): anim.play("Effect");

func remove_self(): self.queue_free();
