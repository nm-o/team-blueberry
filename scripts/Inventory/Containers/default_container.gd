class_name DefaultContainer
extends Control

@onready var container: PanelContainer = $Container
@onready var texture: TextureRect = $Container/Texture
@onready var description: RichTextLabel = $Description
@onready var number: Label = $Number

var item: Item

# Function to change the description and texture of the container
func update_container():
	texture.texture = load(item.texture)
	description.text = item.description
	if container.number_of_items > 1:
		number.text = str(container.number_of_items)
	else:
		number.text = ""

# Function to add an item to a default container
func add_item(item_to_add: Item) -> bool:
	if item:
		if item.get_script().resource_path.get_file().get_basename() == item_to_add.get_script().resource_path.get_file().get_basename():
			if container.number_of_items < item.max_number:
				container.number_of_items += 1
				update_container()
				return true
			else:
				return false
		else:
			return false
	item = item_to_add
	container.number_of_items += 1
	update_container()
	return true

# Removes an item from the container
func remove_item():
	if container.number_of_items > 1:
		container.number_of_items -=1
		update_container()
		return
	container.number_of_items -= 1
	update_container()
	item = null
	description.text = ""
	texture.texture = null
