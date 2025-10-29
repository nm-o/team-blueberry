extends Potion

# Function that acivates once the game starts
func _init() -> void:
	description = "Basic Poison Potion"
	texture = "res://assets/Items/Craftables/potion_poison_small.png"
	max_number = 10
	name = "Basic Poison Potion"
	time = 5
	effect = Global.States.POISONED
