class_name PotionPoison2
extends Potion

# Function that acivates once the game starts
func _init() -> void:
	description = "Advanced Poison Potion"
	texture = "res://assets/Items/Craftables/potion_poison_big.png"
	max_number = 10
	name = "Advanced Poison Potion"
	time = 10
	effect = Global.States.POISONED_2
