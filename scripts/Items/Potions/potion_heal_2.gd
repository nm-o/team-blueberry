class_name PotionHeal2
extends Potion

# Function that acivates once the game starts
func _init() -> void:
	description = "Advanced Heal Potion"
	texture = "res://assets/Items/Craftables/potion_heal_big.png"
	max_number = 10
	name = "Advanced Heal Potion"
	time = 10
	effect = Global.States.HEALING_2
