# res://scenes/combat/Hitbox.gd
extends Area2D
class_name Hitbox

@export var damage: int = 10
@export var team: StringName = &"player" # o "enemy"
@export var active_time: float = 0.5
@export var owner_id: int = -1

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

func _ready() -> void:
	monitoring = false
	monitorable = false
	visible = false

func get_attacker_id() -> int:
	return owner_id

func activate() -> void:
	print("Hitbox ON by", owner_id)
	animation_player.play("sketch_anim")
	print("Hitbox OFF")
