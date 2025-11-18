extends Sprite2D

func _physics_process(delta: float) -> void:
	var direction = owner.global_position.direction_to(owner.player_target.global_position)
	rotation = direction.angle()
