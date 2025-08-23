extends Being
class_name Player

# Variables to manage the inventory
var is_inventory_open: bool = false
var selected_item: Item
@onready var inventory: CanvasLayer =  $Inventory

# Variables to manage selected object
@onready var selected_object = $SelectedObject

# Variables to set the labels that depict the players name and chosen rol
@export var label_name: Label
@export var label_role: Label

# Variables for setting up the movement of a player
@export var max_speed: int = 300
@export var acceleration: int = 1000
var target_position: Vector2

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		# Inventory closing and opening
		if Input.is_action_just_pressed("inventory") and inventory:
			is_inventory_open = not is_inventory_open
			selected_object.active = not selected_object.active
			inventory.change_visibility()
			
		if not is_inventory_open and selected_object:
			# Selected Object 
			if Input.is_action_just_pressed("left_click"):
				selected_object.attack_animation(selected_item.animationName)
				
			# Movement
			var move_input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
			if move_input_vector.length() > 1.0: # diagonal move normalized
				move_input_vector = move_input_vector.normalized()
			velocity = velocity.move_toward(move_input_vector*max_speed, acceleration*delta)
			move_and_slide()
			send_pos.rpc(position)
			
	elif not is_inventory_open:
		position = position.lerp(target_position, delta * 10.0)

func change_selected_item(new_item: Item):
	selected_item = new_item
	print("selected_item_is: " + str(selected_item))
	if new_item:
		selected_object.change_object(new_item)

func setup(player_data: Statics.PlayerData):
	# Setting up the labels and authority of this player
	label_name.text = player_data.name
	label_role.text = "role: " + str(player_data.role)
	
	set_multiplayer_authority(player_data.id, false)
	if is_multiplayer_authority() and inventory:
		inventory.inventory_containers.visible = false
		inventory.backpack_containers.visible = false
		inventory.hotbar_containers.visible = true
	
@rpc("authority", "call_remote", "unreliable_ordered")
func send_pos(pos):
	target_position = pos
