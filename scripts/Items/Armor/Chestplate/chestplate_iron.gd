class_name ChestplateIron
extends Chestplate

# Function that acivates once the game starts
func _init() -> void:
	description = "Chestplate: protect yourself"
	texture = "res://assets/OriginalAssets/item_placeholders/chestplate_test.png"
	max_number = 3
	name = "Iron Chestplate"
	armor_modifier = 0.4*0.5
