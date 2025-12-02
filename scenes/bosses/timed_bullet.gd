extends Node2D

@export var max_speed = 100
@export var lifetime = 5

@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var active = 0

func _ready() -> void:
	animation_player.play("be_born")
	await animation_player.animation_finished
	active = 1
	await get_tree().create_timer(0.2).timeout
	active = 2
	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	if active == 2:
		position += max_speed * transform.x * delta
	elif active == 1:
		position -= max_speed * transform.x * delta / 5
	
