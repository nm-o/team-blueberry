class_name ChestplateLegendary
extends Chestplate

# Function that acivates once the game starts
func _init() -> void:
	description = "Legendary Chestplate"
	texture = "res://assets/Items/Craftables/chest_legendary.png"
	max_number = 3
	name = "Legendary Chestplate"
	armor_modifier = 0.7*0.5
