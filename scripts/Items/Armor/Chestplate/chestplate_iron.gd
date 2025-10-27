class_name ChestplateIron
extends Chestplate

# Function that acivates once the game starts
func _init() -> void:
	description = "Iron Chestplate"
	texture = "res://assets/Items/Craftables/chest_iron.png"
	max_number = 3
	name = "Iron Chestplate"
	armor_modifier = 0.4*0.5
