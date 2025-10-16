extends CharacterBody2D

var player_is_dead: bool = false
@export var max_speed = 400
@export var acceleration = 1000
@onready var ghost_sprite: AnimatedSprite2D = $Node2D/GhostSprite

func _ready() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	var move_input_vector := Input.get_vector("move_left","move_right","move_up","move_down").normalized()
	if move_input_vector.length() > 1.0:
		move_input_vector = move_input_vector.normalized()
	if move_input_vector.x != 0:
		ghost_sprite.scale.x = move_input_vector.x / abs(move_input_vector.x)
	velocity = velocity.move_toward(move_input_vector * max_speed, acceleration * delta)
	move_and_slide()

func set_spawn_position(position):
	global_position = position
