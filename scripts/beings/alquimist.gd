extends Player
class_name Alquimist

# Represents the rol of the Alquimist

func _ready() -> void:
	inventory.add_item(Helmet.new())
	inventory.add_item(Legs.new())
	inventory.add_item(Chestplate.new())
	inventory.add_item(Legs.new())
