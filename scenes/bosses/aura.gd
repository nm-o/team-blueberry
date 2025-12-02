extends Node2D

@onready var hitbox: Hitbox = $Hitbox

func _ready() -> void:
	retrigger()

func retrigger():
	hitbox.monitoring = false
	hitbox.monitorable = false
	await get_tree().create_timer(0.2).timeout
	hitbox.monitoring = true
	hitbox.monitorable = true
	retrigger()
