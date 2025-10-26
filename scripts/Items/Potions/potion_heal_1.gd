class_name PotionHeal1
extends Potion

# Function that acivates once the game starts
func _init() -> void:
	description = "Basic Heal Potion"
	texture = "res://assets/Items/Craftables/potion_heal_small.png"
	max_number = 10
	name = "Basic Heal Potion"
	time = 5
	effect = Global.States.HEALING
