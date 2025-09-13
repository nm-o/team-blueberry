extends Being
class_name Player

# Camera
@export var personal_camera_2d: Camera2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hitbox: Hitbox = $Hitbox


# Inventario e interacción
var is_inventory_open: bool = false
var selected_item: Item
var selected_areas: Array = [] # objetos en el área de interacción
@onready var inventory: CanvasLayer = $Inventory
@onready var interaction_area: Area2D = $InteractionArea
@export var item_drop_scene: PackedScene
@onready var mouse_sprite: Sprite2D = $MouseSprite
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner

# Labels
@export var label_name: Label
@export var label_role: Label
@export var player_id: int = -1
# Movimiento
@export var max_speed: int = 300
@export var acceleration: int = 1000
var target_position: Vector2

# Configuración de clase
@export var class_config: PlayerClassConfig

func _ready() -> void:
	mouse_sprite.top_level = true
	if item_drop_scene:
		multiplayer_spawner.add_spawnable_scene(item_drop_scene.resource_path)
	_apply_visuals_from_config()
	
	if hurtbox:
		hurtbox.health = health_component
	if health_component:
		health_component.damaged.connect(_on_damaged)
		health_component.died.connect(_on_died)

func attack_primary() -> void:
	if hitbox:
		hitbox.activate()

func _on_damaged(amount: int) -> void:
	# feedback: parpadeo, sonido, knockback
	$Sprite2D.modulate = Color(1, 0.6, 0.6)
	await get_tree().create_timer(0.08).timeout
	$Sprite2D.modulate = Color(1, 1, 1)

func _on_died() -> void:
	# deshabilitar control y notificar si usas multiplayer
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		mouse_sprite.global_position = get_global_mouse_position()
		if Input.is_action_just_pressed("interact") and not selected_areas.is_empty():
			selected_areas.back().interact()
		if Input.is_action_just_pressed("inventory") and inventory:
			inventory.change_visibility()
		if not is_inventory_open:
			var move_input_vector := Input.get_vector("move_left","move_right","move_up","move_down").normalized()
			if move_input_vector.length() > 1.0:
				move_input_vector = move_input_vector.normalized()
			velocity = velocity.move_toward(move_input_vector * max_speed, acceleration * delta)
			move_and_slide()
			send_pos.rpc(position)
	elif not is_inventory_open:
		position = position.lerp(target_position, delta * 10.0)
	if is_multiplayer_authority() and Input.is_action_just_pressed("attack"):
		attack_primary()
func setup(player_data: Statics.PlayerData):
	# Labels y autoridad
	label_name.text = player_data.name
	label_role.text = class_config.label_role_text if class_config else "role: Unknown"
	set_multiplayer_authority(player_data.id, false)
	multiplayer_spawner.set_multiplayer_authority(player_data.id, false)

	# Aplicar stats desde la config y cargar inventario inicial
	if class_config:
		hp = class_config.hp
		movement_speed = class_config.movement_speed
		attack = class_config.attack
		defense = class_config.defense
		max_speed = int(class_config.movement_speed)
		_apply_visuals_from_config()
		_load_starting_items()

	# Conexiones y cámara para autoridad
	if is_multiplayer_authority() and inventory:
		Mouse.player = self
		if interaction_area:
			interaction_area.area_entered.connect(_interaction_area_entered)
			interaction_area.area_exited.connect(_interaction_area_exited)
		inventory.inventory_containers.visible = false
		inventory.backpack_containers.visible = false
		inventory.hotbar_containers.visible = true
		self.personal_camera_2d = Camera2D.new()
		self.add_child(personal_camera_2d)
		self.personal_camera_2d.make_current()

func _apply_visuals_from_config() -> void:
	if class_config:
		if class_config.sprite_texture and $Sprite2D:
			$Sprite2D.texture = class_config.sprite_texture
		if class_config.mouse_sprite_texture and mouse_sprite:
			mouse_sprite.texture = class_config.mouse_sprite_texture

func _load_starting_items() -> void:
	if not (inventory and class_config):
		return
	for path in class_config.starting_items:

		if path == null:
			continue
		var s := str(path).strip_edges()
		if s.is_empty():
			continue

		var res := load(s)
		if res == null:
			push_warning("No se pudo cargar Item Resource en ruta: %s" % s)
			continue

		var item = res.new()
		if item == null:
			push_warning("No se pudo instanciar script de ítem en: %s" % s)
			continue

		inventory.add_item(item)


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
		selected_areas.back().interaction_name_label.visible = false
	selected_areas.append(area.owner)
	selected_areas.back().interaction_name_label.visible = true

func _interaction_area_exited(area: Area2D):
	if area.owner:
		area.owner.interaction_name_label.visible = false
	selected_areas.erase(area.owner)
	if not selected_areas.is_empty():
		selected_areas.back().interaction_name_label.visible = true
