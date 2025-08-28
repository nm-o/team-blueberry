extends Being
class_name Player

var player_id: int

# Variables to manage the inventory
var is_inventory_open: bool = false
var selected_item: Item
var selected_areas: Array = [] # array of selected objects in the area of interaction
@onready var inventory: CanvasLayer =  $Inventory
@onready var interaction_area: Area2D = $InteractionArea
@export var item_drop_scene: PackedScene

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner

# Variables to manage selected object
@onready var selected_item_object = $SelectedObject

# Variables to set the labels that depict the players name and chosen rol
@export var label_name: Label
@export var label_role: Label

# Variables for setting up the movement of a player
@export var max_speed: int = 300
@export var acceleration: int = 1000
var target_position: Vector2

func _ready() -> void:
	if item_drop_scene:
		multiplayer_spawner.add_spawnable_scene(item_drop_scene.resource_path)

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		# Manages interaction with an area
		if Input.is_action_just_pressed("interact") and not selected_areas.is_empty():
			selected_areas.back().interact()
		# Inventory closing and opening
		if Input.is_action_just_pressed("inventory") and inventory:
			is_inventory_open = not is_inventory_open
			selected_item_object.active = not selected_item_object.active
			inventory.change_visibility()
			
		if not is_inventory_open:
			# Selected Object 
			if Input.is_action_just_pressed("left_click") and not Mouse.on_ui and selected_item:
				selected_item_object.attack_animation(selected_item.animationName)
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
	if new_item:
		selected_item_object.change_object(new_item)

func setup(player_data: Statics.PlayerData):
	# Setting up the labels and authority of this player
	label_name.text = player_data.name
	label_role.text = "role: " + str(player_data.role)
	set_multiplayer_authority(player_data.id, false)
	multiplayer_spawner.set_multiplayer_authority(player_data.id, false)
	if is_multiplayer_authority() and inventory:
		Mouse.player = self
		if interaction_area:
			interaction_area.area_entered.connect(_interaction_area_entered)
			interaction_area.area_exited.connect(_interaction_area_exited)
		inventory.inventory_containers.visible = false
		inventory.backpack_containers.visible = false
		inventory.hotbar_containers.visible = true
	
@rpc("authority", "call_remote", "unreliable_ordered")
func send_pos(pos):
	target_position = pos
	
# Destroys dropped items on all the players
func manage_destroy_item_drop(drop_id):
	if is_multiplayer_authority():
		destroy_drop_item_server.rpc_id(1, drop_id)
@rpc("authority", "call_local", "reliable")
func destroy_drop_item_server(drop_id):
	destroy_drop_item.rpc(drop_id)
@rpc("any_peer", "call_local", "reliable")
func destroy_drop_item(drop_id):
	var spawners = get_tree().get_nodes_in_group("DropSpawners")
	for spawner in spawners:
		for child in spawner.get_children():
			if child.item.drop_id == drop_id:
				child.queue_free()
	
# Drops items to all the players
func manage_drop(item_to_drop, drop_id):
	if is_multiplayer_authority():
		drop_item_server.rpc_id(1, global_position, item_to_drop, drop_id)
@rpc("authority", "call_local", "reliable")
func drop_item_server(pos, item_to_drop, drop_id):
	drop_item.rpc(pos, item_to_drop, drop_id)
@rpc("any_peer", "call_local", "reliable")
func drop_item(pos, item_to_drop, drop_id):
	if not item_drop_scene:
		return
	var item_drop = item_drop_scene.instantiate()
	var script = load(item_to_drop)
	item_drop.item = script.new()
	item_drop.item.drop_id = drop_id
	multiplayer_spawner.add_child(item_drop)
	item_drop.update_item_drop()
	item_drop.global_position = global_position

func _interaction_area_entered(area: Area2D):
	if not selected_areas.is_empty():
		selected_areas.back().item_name_label.visible = false
	selected_areas.append(area.owner)
	selected_areas.back().item_name_label.visible = true
	
func _interaction_area_exited(area: Area2D):
	if area.owner:
		area.owner.item_name_label.visible = false
	selected_areas.erase(area.owner)
	if not selected_areas.is_empty():
		selected_areas.back().item_name_label.visible = true
