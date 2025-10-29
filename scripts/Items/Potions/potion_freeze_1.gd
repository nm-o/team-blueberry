extends Potion

# Function that acivates once the game starts
func _init() -> void:
	description = "Basic Freeze Potion"
	texture = "res://assets/Items/Craftables/potion_frost_small.png"
	max_number = 10
	name = "Basic Freeze Potion"
	time = 5
	effect = Global.States.FROZEN
