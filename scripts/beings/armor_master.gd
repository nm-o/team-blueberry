extends Player
class_name ArmorMaster

# Represents the rol of the Armor Master

func _ready() -> void:
	inventory.add_item(Helmet.new())
	inventory.add_item(Legs.new())
	inventory.add_item(Chestplate.new())
	inventory.add_item(Legs.new())
