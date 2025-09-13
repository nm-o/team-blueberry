# res://scenes/combat/Hurtbox.gd
extends Area2D
class_name Hurtbox

@export var health: HealthComponent
@export var team: StringName = &"player" # o "enemy"

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		var hb := area as Hitbox
# 		fuego aliado
#		if hb.team == team:
#			return
		if health:
			health.apply_damage(hb.damage)
