extends Being
class_name Player

var player_id: int

# Camera
@export var personal_camera_2d: Camera2D

# Variables to manage the inventory
var is_inventory_open: bool = false
var selected_item: Item
var selected_areas: Array = [] # array of selected objects in the area of interaction
@onready var inventory: CanvasLayer =  $Inventory
@onready var interaction_area: Area2D = $InteractionArea
@export var item_drop_scene: PackedScene
@onready var mouse_sprite: Sprite2D = $MouseSprite

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner

# Variables to set the labels that depict the players name and chosen rol
@export var label_name: Label
@export var label_role: Label

# Variables for setting up the movement of a player
@export var max_speed: int = 300
@export var acceleration: int = 1000
var target_position: Vector2

# Variables de combate
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 1.0
var can_attack: bool = true
@onready var weapon_hitbox: Area2D = $WeaponHitbox

func _on_weapon_hit(body: Node2D):
	if not is_multiplayer_authority():
		return
		
	if body is Being and body != self and body.isAlive:
		var distance = global_position.distance_to(body.global_position)
		if distance <= attack_range:
			apply_damage_to_target.rpc_id(body.get_multiplayer_authority(), attack)

func _ready() -> void:
	mouse_sprite.top_level = true
	if item_drop_scene:
		multiplayer_spawner.add_spawnable_scene(item_drop_scene.resource_path)
	if weapon_hitbox:
		weapon_hitbox.body_entered.connect(_on_weapon_hit)
		weapon_hitbox.monitoring = false

func _physics_process(delta: float) -> void:
	# DEBUG: Solo cada 2 segundos
	if Engine.get_process_frames() % 120 == 0:
		print("Player ", name, " - My peer ID: ", multiplayer.get_unique_id(), " - Authority: ", get_multiplayer_authority(), " - Am I authority? ", is_multiplayer_authority())
	
	if is_multiplayer_authority():
		mouse_sprite.global_position = get_global_mouse_position()
		
		# DEBUG: Verificar input
		var move_input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
		if move_input_vector.length() > 0:
			print("Player ", name, " moving: ", move_input_vector)
		
		# Ataque melee
		if Input.is_action_just_pressed("attack") and can_attack and not is_inventory_open:
			perform_attack.rpc()
		
		# Manages interaction with an area
		if Input.is_action_just_pressed("interact") and not selected_areas.is_empty():
			selected_areas.back().interact()
		# Inventory closing and opening
		if Input.is_action_just_pressed("inventory") and inventory:
			inventory.change_visibility()
			
		if not is_inventory_open:
			# Movement
			if move_input_vector.length() > 1.0: # diagonal move normalized
				move_input_vector = move_input_vector.normalized()
			velocity = velocity.move_toward(move_input_vector*max_speed, acceleration*delta)
			move_and_slide()
			
			send_pos.rpc(position)
			
	elif not is_inventory_open:
		position = position.lerp(target_position, delta * 10.0)

func setup(player_data: Statics.PlayerData):
	print("=== PLAYER SETUP DEBUG ===")
	print("Setting up player: ", player_data.name, " ID: ", player_data.id)
	print("My multiplayer ID: ", multiplayer.get_unique_id())
	print("Is this my player? ", player_data.id == multiplayer.get_unique_id())
	
	# Setting up the labels and authority of this player
	if label_name:
		label_name.text = player_data.name
	if label_role:
		label_role.text = "role: " + str(player_data.role)
	
	set_multiplayer_authority(player_data.id, false)
	print("Authority set to: ", get_multiplayer_authority())
	print("Am I authority? ", is_multiplayer_authority())
	multiplayer_spawner.set_multiplayer_authority(player_data.id, false)
	match player_data.role:
		Statics.Role.ROLE_A:
			hp = 100
			movement_speed = 100.0
			attack = 8
			defense = 5
		Statics.Role.ROLE_B:
			hp = 120
			movement_speed = 90.0
			attack = 15
			defense = 8
		Statics.Role.ROLE_C:
			hp = 150
			movement_speed = 80.0
			attack = 10
			defense = 12
	if is_multiplayer_authority() and inventory:
		Mouse.player = self
		if interaction_area:
			interaction_area.area_entered.connect(_interaction_area_entered)
			interaction_area.area_exited.connect(_interaction_area_exited)
		inventory.inventory_containers.visible = false
		inventory.backpack_containers.visible = false
		inventory.hotbar_containers.visible = true
		
		# Setting up the personal camera for this player
		self.personal_camera_2d = Camera2D.new()
		self.add_child(personal_camera_2d)
		self.personal_camera_2d.make_current()

@rpc("any_peer", "call_remote", "unreliable_ordered") 
func send_pos(pos):
	# Solo actualizar si el nodo existe y no soy yo
	if is_inside_tree() and not is_multiplayer_authority():
		target_position = pos

# FUNCIONES DE COMBATE
@rpc("any_peer", "call_local", "reliable")
func perform_attack():
	if not can_attack or state == Global.States.DEAD:
		return
	
	can_attack = false
	weapon_hitbox.monitoring = true
	
	# Desactivar hitbox después de 0.2 segundos
	await get_tree().create_timer(0.2).timeout
	weapon_hitbox.monitoring = false
	
	# Cooldown
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

@rpc("any_peer", "call_local", "reliable") 
func apply_damage_to_target(damage: int):
	take_damage(damage)
	# Efecto visual de daño
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
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
		selected_areas.back().interaction_name_label.visible = false
	selected_areas.append(area.owner)
	selected_areas.back().interaction_name_label.visible = true
	
func _interaction_area_exited(area: Area2D):
	if area.owner:
		area.owner.interaction_name_label.visible = false
	selected_areas.erase(area.owner)
	if not selected_areas.is_empty():
		selected_areas.back().interaction_name_label.visible = true
