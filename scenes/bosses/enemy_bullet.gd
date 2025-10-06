extends Node2D

@export var max_speed = 100
@export var lifetime = 2

@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	position += max_speed * transform.x * delta
