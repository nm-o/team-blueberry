class_name DefaultContainer
extends Control

@onready var container: PanelContainer = $Container
@onready var texture: TextureRect = $Container/Texture
@onready var description: RichTextLabel = $Description

var item: Item

# Function to change the description and texture of the container
func update_container():
	texture.texture = item.texture
	description.text = item.description

# Function to add an item to a default container
func add_item(item_to_add: Item) -> bool:
	if item:
		return false
	item = item_to_add
	update_container()
	return true

func remove_item():
	item = null
	description.text = ""
	texture.texture = null
