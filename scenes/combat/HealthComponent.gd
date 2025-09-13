# res://scenes/combat/HealthComponent.gd
extends Node
class_name HealthComponent

signal damaged(amount: int)
signal died

@export var max_hp: int = 100
var hp: int

func _ready() -> void:
	hp = max_hp

func apply_damage(amount: int) -> void:
	var dmg := max(0, amount)
	if dmg <= 0:
		return
	hp = max(0, hp - dmg)
	damaged.emit(dmg)
	if hp == 0:
		died.emit()
