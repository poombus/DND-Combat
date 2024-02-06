extends AnimationPlayer

@onready var pawn = get_parent();

func play_death(type:int = 0):
	#Retreat Anim
	var direction = Vector2(2000,0) if pawn.sprite.flip_h else Vector2(-2000, 0);
	var tween = create_tween();
	tween.tween_property(pawn, "position", pawn.position+direction, 0.3);
