class_name PotionFreeze2
extends Potion

# Function that acivates once the game starts
func _init() -> void:
	description = "Advanced Freeze Potion"
	texture = "res://assets/Items/Craftables/potion_frost_big.png"
	max_number = 10
	name = "Advanced Freeze Potion"
	time = 10
	effect = Global.States.FROZEN_2
