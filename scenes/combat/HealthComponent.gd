# res://scenes/combat/HealthComponent.gd
extends Node
class_name HealthComponent

signal damaged(amount: int) # la señal no causa Variant si el uso tipado es consistente [1]
signal died

@export var max_hp: int = 100
var hp: int = 100

func _ready() -> void:
	hp = clamp(hp, 0, max_hp)

func apply_damage(amount: int) -> void:
	var dmg: int = max(0, amount)
	if dmg <= 0:
		return
	hp = max(0, hp - dmg)
	damaged.emit(dmg)
	if hp == 0:
		died.emit()
