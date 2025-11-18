# res://scenes/combat/Hitbox.gd
extends Area2D
class_name Hitbox

@export var damage: int = 10
@export var team: StringName = &"player" # o "enemy"
@export var active_time: float = 0.5
@export var owner_id: int = -1

func get_attacker_id() -> int:
	return owner_id

func attack(target):
	if owner.has_method("after_attack"):
		owner.after_attack(target)
