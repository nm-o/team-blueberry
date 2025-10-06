extends Being
class_name Player

# Camera
@export var personal_camera_2d: Camera2D

# Hurt/Hit boxes
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hitbox: Hitbox = $SelectedObjectMarker/Hitbox

# Selected object marker
@onready var selected_object_marker: Marker2D = $SelectedObjectMarker
@onready var selected_item_sprite: Sprite2D = $SelectedObjectMarker/Sprite2D

# Inventario e interacción
var is_inventory_open: bool = false
var selected_areas: Array = []
@onready var inventory: CanvasLayer = $Inventory
@onready var interaction_area: Area2D = $InteractionArea
@export var item_drop_scene: PackedScene
@onready var mouse_sprite: Sprite2D = $MouseSprite
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var sprite_2d: Sprite2D = $Sprite2D

# Labels
@export var label_name: Label
@export var label_role: Label
@export var player_id: int = -1
# Movimiento
@export var max_speed: int = 300
@export var acceleration: int = 20000
var target_position: Vector2

# Configuración de clase
@export var class_config: PlayerClassConfig

# Hotbar
@export var max_hotbar_containers = 3
var selected_container_number: int

var is_dead: bool = false

var rolling: bool = false
@onready var roll_cooldown: Timer = $RollCooldown

@export var hp = 100 
func get_attacked(damage: int):
	hp -= damage
	inventory.health_bar.value = hp
	if hp <= 0:
		is_dead = true

func _ready() -> void:
	selected_container_number = 0
	mouse_sprite.top_level = true
	if item_drop_scene:
		multiplayer_spawner.add_spawnable_scene(item_drop_scene.resource_path)
	_apply_visuals_from_config()
	_load_starting_items() 
	
	if hurtbox:
		hurtbox.health = health_component
	if health_component:
		health_component.damaged.connect(_on_damaged)
		health_component.died.connect(_on_died)

func attack_primary() -> void:
	#print("[PL] attack by id:", player_id)
	if is_multiplayer_authority() and hitbox:
		activate_hitbox.rpc()

func _on_damaged(_amount: int) -> void:
	sprite_2d.modulate = Color(1, 0.6, 0.6)
	await get_tree().create_timer(0.08).timeout
	sprite_2d.modulate = Color(1, 1, 1)

func _on_died() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if is_multiplayer_authority():
		mouse_sprite.global_position = get_global_mouse_position()
		if Input.is_action_just_pressed("interact") and not selected_areas.is_empty():
			selected_areas.back().interact()
		if Input.is_action_just_pressed("inventory") and inventory:
			inventory.change_visibility()
		if not is_inventory_open:
			# Selected object marker rotation
			rotate_selected_obj.rpc(get_global_mouse_position())

			# Movement
			var move_input_vector := Input.get_vector("move_left","move_right","move_up","move_down").normalized()
			if move_input_vector.length() > 1.0:
				move_input_vector = move_input_vector.normalized()
			if Input.is_action_just_pressed("roll") and roll_cooldown.time_left == 0:
				rolling = true
				velocity = velocity.move_toward(move_input_vector * max_speed * 2, acceleration * 10 * delta)
				hurtbox.monitoring = false
				await get_tree().create_timer(0.2).timeout
				roll_cooldown.start()
				hurtbox.monitoring = true
				rolling = false
			elif not rolling:
				velocity = velocity.move_toward(move_input_vector * max_speed, acceleration * delta)
			move_and_slide()
			send_pos.rpc(position)

	elif not is_inventory_open:
		position = position.lerp(target_position, delta * 10.0)

	if is_multiplayer_authority() and Input.is_action_just_pressed("attack") and not is_inventory_open and not Mouse.on_ui and selected_item_sprite.texture!=null:
		print(selected_item_sprite)
		attack_primary()

func setup(player_data: Statics.PlayerData) -> void:
	player_id = player_data.id
	selected_object_marker.name = "marker_" + str(player_id)
	#print("[PL] setup id:", player_id, " peer:", multiplayer.get_unique_id())
	if hitbox:
		hitbox.owner_id = player_id
	#print("[PL] hitbox.owner_id =", hitbox.owner_id)
	await get_tree().process_frame


	# Labels y autoridad
	label_name.text = player_data.name
	label_role.text = class_config.label_role_text if class_config else "role: Unknown"
	set_multiplayer_authority(player_data.id, false)
	multiplayer_spawner.set_multiplayer_authority(player_data.id, false)
	
	if class_config and health_component:
		health_component.max_hp = class_config.hp
		health_component.hp = health_component.max_hp

	# Conexiones y cámara para autoridad
	if is_multiplayer_authority() and inventory:
		Mouse.player = self
		if interaction_area:
			interaction_area.area_entered.connect(_interaction_area_entered)
			interaction_area.area_exited.connect(_interaction_area_exited)
		inventory.inventory_containers.visible = false
		inventory.backpack_containers.visible = false
		inventory.hotbar_containers.visible = true
		inventory.health_bar.visible = true
		inventory.health_bar.max_value = hp
		self.personal_camera_2d = Camera2D.new()
		self.add_child(personal_camera_2d)
		personal_camera_2d.zoom = Vector2(1.7, 1.7)
		self.personal_camera_2d.make_current()

func _apply_visuals_from_config() -> void:
	if class_config:
		if class_config.sprite_texture and sprite_2d:
			sprite_2d.texture = class_config.sprite_texture
		if class_config.mouse_sprite_texture and mouse_sprite:
			mouse_sprite.texture = class_config.mouse_sprite_texture

func _load_starting_items() -> void:
	if not (inventory and class_config):
		push_warning("Inventory or class_config not ready")
		return
	for path in class_config.starting_items:
		if path == null:
			continue
		var s: String = str(path).strip_edges()
		if s.is_empty():
			continue
		var res: Script = load(s) as Script
		if res == null:
			push_warning("Invalid item route: %s" % s)
			continue
		var item: Object = res.new() as Object
		if item == null:
			push_warning("Couldn't instantiate item: %s" % s)
			continue
		inventory.add_item(item)

func _apply_death_state() -> void:
	#print("[PL] death on peer:", multiplayer.get_unique_id(), " id:", player_id)
	is_dead = true
	if hitbox:
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)
	if hurtbox:
		hurtbox.set_deferred("monitoring", false)
		hurtbox.set_deferred("monitorable", false)
	set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)

func _refresh_hp_ui() -> void:
	if not health_component:
		return
	#print("[PL] UI sees HP:", health_component.hp, "/", health_component.max_hp,
	#	  " for id:", player_id, " peer:", multiplayer.get_unique_id()) 
	if $HPBar:
		$HPBar.max_value = health_component.max_hp
		$HPBar.value = health_component.hp
	if $HPLabel:
		$HPLabel.text = "%d / %d" % [health_component.hp, health_component.max_hp]

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
				

# manages the hotbar selection
func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event is InputEventMouseButton and event.pressed and max_hotbar_containers:  # Just when it gets pressed
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				selected_container_number -= 1
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				selected_container_number += 1
			if selected_container_number > max_hotbar_containers - 1:
				selected_container_number = 0
			if selected_container_number < 0:
				selected_container_number = max_hotbar_containers - 1
			inventory.select_container(selected_container_number)

func manage_hotbar_item(texture: String):
	if is_multiplayer_authority():
		hotbar_item_server.rpc_id(1, texture, player_id)

@rpc("authority", "call_local", "reliable")
func hotbar_item_server(texture: String, player_idx: int):
	hotbar_item_else.rpc(texture, player_idx)

@rpc("any_peer", "call_local", "reliable")
func hotbar_item_else(texture: String, player_idx: int):
	var players = get_node("/root/Main/Players").get_children()
	for player in players:
		if player.player_id == player_idx:
			player.selected_object_marker.change_selected_object(texture)

# Drops items to all the players
func manage_drop(item_to_drop, drop_id):
	if is_multiplayer_authority():
		drop_item_server.rpc_id(1, global_position, item_to_drop, drop_id)

@rpc("authority", "call_local", "reliable")
func drop_item_server(pos, item_to_drop, drop_id):
	drop_item.rpc(pos, item_to_drop, drop_id)

@rpc("any_peer", "call_local", "reliable")
func drop_item(_pos, item_to_drop, drop_id):
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

# Cliente -> servidor
@rpc("any_peer","reliable","call_local")
func request_pos(id: int, pos: Vector2, vel: Vector2) -> void:
	if not multiplayer.is_server():
		return
	_server_apply_pos(id, pos, vel)


func _server_apply_pos(id: int, pos: Vector2, vel: Vector2) -> void:
	var path: NodePath = Combat.actors.get(id, NodePath())
	var node: Node2D = get_node_or_null(path) as Node2D
	if node:
		node.global_position = pos
		apply_pos.rpc(id, pos, vel)  # broadcast a todos


@rpc("authority","reliable","call_local")
func apply_pos(id: int, pos: Vector2, _vel: Vector2) -> void:
	var path: NodePath = Combat.actors.get(id, NodePath())
	var node: Node2D = get_node_or_null(path) as Node2D
	if node:
		node.global_position = pos




@rpc("any_peer","reliable","call_local")
func _notify_damage(_attacker_id: int, victim_id: int, _damage: int) -> void:
	var victim_node := get_tree().get_root().get_node_or_null("Main/Players/Player_%d" % victim_id)
	if victim_node:
		var hc := victim_node.get_node_or_null("HealthComponent") as HealthComponent
		if hc:
			pass

func _damage_authoritative(attacker_id: int, victim_id: int, damage: int) -> void:

	var victim_node := get_tree().get_root().get_node_or_null("Main/Players/Player_%d" % victim_id)
	if victim_node == null:
		return
	var hc := victim_node.get_node_or_null("HealthComponent") as HealthComponent
	if hc == null:
		return
	hc.apply_damage(damage)

	_notify_damage.rpc(attacker_id, victim_id, damage)

@rpc("authority","reliable","call_local")
func _request_damage(attacker_id: int, victim_id: int, damage: int) -> void:
	# Solo corre en el servidor (authority)
	_damage_authoritative(attacker_id, victim_id, damage)


# RPC for selected object rotation
@rpc("authority", "call_local", "reliable")
func rotate_selected_obj(mouse_pos):
	selected_object_marker.look_at(mouse_pos)

@rpc("authority", "call_local", "reliable")
func activate_hitbox():
	selected_object_marker.activate()
