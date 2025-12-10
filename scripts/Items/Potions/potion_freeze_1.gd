class_name PotionFreeze1
extends Potion

# Function that acivates once the game starts
func _init() -> void:
	description = "Basic Speed Up Potion"
	texture = "res://assets/Items/Craftables/potion_frost_small.png"
	max_number = 10
	name = "Basic Speed Up Potion"
	time = 5
	effect = Global.States.FROZEN
