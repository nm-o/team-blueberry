extends CanvasLayer

@onready var inventory_containers: Control = $InventoryContainers
@onready var backpack_containers: Control = $BackpackContainers
@onready var hotbar_containers: Control = $HotbarContainers
@onready var player: Player = $".."

@export var max_hotbar_containers: int = 3

var selected_container_number: int = 0

# Gets the current selected container in the hotbar
func search_selected_container():
	var containers = hotbar_containers.get_children()
	var i = 0
	for container in containers:
		if container.selected:
			selected_container_number = i
			return
		i+=1

# Selects a container from the hotbar using a number as id
func select_container(num: int):
	var container = hotbar_containers.get_child(num)
	_deselect_containers()
	container.selected = true
	container.selector.visible = true
	selected_container_number = num
	Mouse.player.selected_container_number = num
	if container.item:
		Mouse.player.manage_hotbar_item(container.item.texture)
	else:
		Mouse.player.manage_hotbar_item("")

# Deselecta all the containers in the hotbar
func _deselect_containers():
	var containers = hotbar_containers.get_children()
	for container in containers:
		container.selected = false
		container.selector.visible = false

# Funcition that changes the visibility of the inventory
func change_visibility():
	inventory_containers.visible = not inventory_containers.visible
	backpack_containers.visible = not backpack_containers.visible
	Mouse.player.is_inventory_open = inventory_containers.visible

# Function to add an item into the inventory
func add_item(item: Item):
	var containers = hotbar_containers.get_children()
	for container in containers:
		var is_true = container.add_item(item)
		if is_true:
			return
	var containers_2 = backpack_containers.get_children()
	for container in containers_2:
		var is_true = container.add_item(item)
		if is_true:
			return
	Mouse.player.manage_drop(item.get_script().resource_path, Mouse.get_drop_id())
