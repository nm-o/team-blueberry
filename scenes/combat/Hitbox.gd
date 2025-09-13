# res://scenes/combat/Hitbox.gd
extends Area2D
class_name Hitbox

@export var damage: int = 10
@export var team: StringName = &"player" # o "enemy"
@export var active_time: float = 0.12
@export var owner_id: int = -1

func get_attacker_id() -> int:
	return owner_id

func activate() -> void:
	print("Hitbox ON by", owner_id)
	visible = true
	monitoring = true
	set_deferred("monitorable", true)
	await get_tree().create_timer(active_time).timeout
	monitoring = false
	monitorable = false
	visible = false
	print("Hitbox OFF")
