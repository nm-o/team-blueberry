# res://scenes/combat/Hitbox.gd
extends Area2D
class_name Hitbox

@export var damage: int = 10
@export var team: StringName = &"player" # o "enemy"
@export var active_time: float = 0.12

func activate() -> void:
	visible = true
	monitoring = true
	set_deferred("monitorable", true)
	await get_tree().create_timer(active_time).timeout
	monitoring = false
	monitorable = false
	visible = false
