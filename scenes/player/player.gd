extends Being
class_name Player

# Camera
@export var personal_camera_2d: Camera2D

# Hurt/Hit boxes
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var collision_shape_2d: CollisionShape2D = $Hurtbox/CollisionShape2D

# Inventario e interacción
var is_inventory_open: bool = false
var selected_areas: Array = []
@onready var inventory: CanvasLayer = $Inventory
@onready var interaction_area: Area2D = $InteractionArea
@export var item_drop_scene: PackedScene
@onready var mouse_sprite: Sprite2D = $MouseSprite
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var sprite_2d: Sprite2D = $PlayerSpritePivot/Sprite2D

# Instakill hitbox
@onready var instakill: Hitbox = $Instakill

# Labels
@export var label_name: Label
@export var label_role: Label
@export var player_id: int = -1

# Movimiento
@export var max_speed: int = 200
@export var acceleration: int = 20000
var target_position: Vector2
var sprite_rotation: int = 1

# Configuración de clase
@export var class_config: PlayerClassConfig

# Hotbar
@export var max_hotbar_containers = 3
var selected_container_number: int

var is_dead: bool = false

var rolling: bool = false
@onready var roll_cooldown: Timer = $RollCooldown

@export var potion_max_range: float = 300.0
@export var max_hp = 100
@export var hp = 100
@export var invulneravility_time: float = 0.1
@export var potion_projectile_scene: PackedScene

@onready var invulnerability_timer: Timer = $InvulnerabilityTimer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree.get("parameters/playback")
@onready var player_sprite_pivot: Node2D = $PlayerSpritePivot
@onready var player_weapon: Node2D = $PlayerWeapon

var selected_item: Item = null
#@onready var hc: CollisionShape2D = $Pivot/Hurtbox/CollisionShape2D
@onready var spectator_ghost: CharacterBody2D = $SpectatorGhost

var old_direction: Vector2 = Vector2(1,0)

var current_state: Global.States = Global.States.NORMAL
var state_timer: Timer

func _init_state_system():
	state_timer = Timer.new()
	add_child(state_timer)
	state_timer.timeout.connect(_on_state_timeout)
	state_timer.one_shot = true

func apply_status_effect(state: Global.States, duration: int):
	if current_state != Global.States.NORMAL:
		return
	
	current_state = state
	if inventory:
		inventory.change_status(state)
	
	if duration > 0:
		state_timer.start(duration)
	
	match state:
		Global.States.HEALING:
			hp = min(hp + 50, max_hp)
			if inventory:
				inventory.health_bar.value = hp

		Global.States.HEALING_2:
			hp = min(hp + 100, max_hp) 
			if inventory:
				inventory.health_bar.value = hp

		Global.States.FROZEN:
			max_speed = 0

		Global.States.POISONED:
			_apply_poison_damage(duration, 5)

		Global.States.POISONED_2:
			_apply_poison_damage(duration, 10)


func _apply_poison_damage(duration: int, dmg_per_tick: int):
	for i in duration:
		if current_state != Global.States.POISONED and current_state != Global.States.POISONED_2:
			break
		manage_do_damage(dmg_per_tick)
		await get_tree().create_timer(1.0).timeout


func _on_state_timeout():
	current_state = Global.States.NORMAL
	if inventory:
		inventory.change_status(Global.States.NORMAL)
	if max_speed == 0:
		max_speed = 200


func get_attacked(damage: int):
	if invulnerability_timer.time_left != 0:
		return
	manage_do_damage(damage)
	invulnerability_timer.start(invulneravility_time)

func manage_do_damage(damage: int):
	if is_multiplayer_authority():
		do_damage_server.rpc_id(1, damage)

@rpc("authority", "call_local", "reliable")
func do_damage_server(damage: int):
	do_damage.rpc(damage)

@rpc("any_peer", "call_local", "reliable")
func do_damage(damage: int):
	hp -= damage
	inventory.health_bar.value = hp
	if hp <= 0 and not is_dead:
		is_dead = true
		if is_multiplayer_authority():
			ghost_enabled(true)
			Mouse.set_player_is_dead.rpc(true, player_id)

func ghost_enabled(is_enabled: bool):
	spectator_ghost.visible = is_enabled
	spectator_ghost.top_level = is_enabled
	spectator_ghost.set_physics_process(is_enabled)
	spectator_ghost.set_spawn_position(global_position)

func _ready() -> void:
	_init_state_system()
	add_to_group("players")
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
	if is_multiplayer_authority():
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
			inventory.select_container(selected_container_number)
		if Input.is_action_just_pressed("inventory") and inventory:
			inventory.change_visibility()
		if not is_inventory_open:
			# Selected object marker rotation
			rotate_selected_obj.rpc(get_global_mouse_position())

			# Movement
			var move_input_vector := Input.get_vector("move_left","move_right","move_up","move_down").normalized()
			if move_input_vector != Vector2.ZERO:
				old_direction = move_input_vector
			if move_input_vector.length() > 1.0:
				move_input_vector = move_input_vector.normalized()
			if move_input_vector.x != 0:
				player_sprite_pivot.scale.x = move_input_vector.x / abs(move_input_vector.x)
			if move_input_vector == Vector2(0,0):
				manage_animation("idle_animation")
			else:
				manage_animation("running_animation")
			if Input.is_action_just_pressed("instakill"):
				activate_instakill_area()
			if Input.is_action_just_pressed("roll") and roll_cooldown.time_left == 0:
				rolling = true
				velocity = velocity.move_toward(old_direction * max_speed * 1.5, acceleration * 10 * delta)
				collision_shape_2d.disabled = true
				await get_tree().create_timer(0.2).timeout
				roll_cooldown.start()
				collision_shape_2d.disabled = false
				rolling = false
			elif not rolling:
				velocity = velocity.move_toward(move_input_vector * max_speed, acceleration * delta)
			move_and_slide()
			send_pos.rpc(position)
			if move_input_vector.x != 0:
				send_rot.rpc(move_input_vector.x / abs(move_input_vector.x))

	elif not is_inventory_open:
		position = position.lerp(target_position, delta * 10.0)
		player_sprite_pivot.scale.x = sprite_rotation

	if is_multiplayer_authority() and Input.is_action_just_pressed("attack") and not is_inventory_open and not Mouse.on_ui:
		if selected_item is Weapon:
			attack_primary()
		elif selected_item is Potion:
			selected_item.use(self)
			if inventory:
				inventory.consume_hotbar_slot(selected_container_number)
				inventory.select_container(selected_container_number)



func activate_instakill_area():
	instakill.monitoring = true
	instakill.monitorable = true
	await get_tree().create_timer(0.2).timeout
	instakill.monitoring = false
	instakill.monitorable = false

func setup(player_data: Statics.PlayerData) -> void:
	player_id = player_data.id
	await get_tree().process_frame
	# Labels y autoridad
	label_name.text = player_data.name
	label_role.text = class_config.label_role_text if class_config else "role: Unknown"
	set_multiplayer_authority(player_data.id, false)
	multiplayer_spawner.set_multiplayer_authority(player_data.id, false)
	player_weapon.set_multiplayer_authority(player_data.id, false)
	
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
		inventory.protect_bar.visible = true
		inventory.current_status.visible = true
		personal_camera_2d = Camera2D.new()
		personal_camera_2d.zoom = Vector2(2.5, 2.5)
		personal_camera_2d.position = Vector2(0, 0)
		spectator_ghost.add_child(personal_camera_2d)
		personal_camera_2d.make_current()
		inventory.select_container(0)

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
@rpc("authority", "call_remote", "unreliable_ordered")
func send_rot(rot):
	sprite_rotation = rot

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

# Animation manager
func manage_animation(animation_name: String):
	if is_multiplayer_authority():
		manage_animation_server.rpc_id(1, animation_name)
@rpc("authority", "call_local", "reliable")
func manage_animation_server(animation_name: String):
	do_the_animation.rpc(animation_name)
@rpc("any_peer", "call_local", "reliable")
func do_the_animation(animation_name: String):
	playback.travel(animation_name)

# Drops items to all the players
func manage_drop(item_to_drop, drop_id):
	if is_multiplayer_authority():
		drop_item_server.rpc_id(1, global_position, item_to_drop, drop_id)
		inventory.select_container(selected_container_number)

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
		if selected_areas.back() != null:
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
	player_weapon.look_at(mouse_pos)

@rpc("authority", "call_local", "reliable")
func activate_hitbox():
	player_weapon.activate()

func manage_update_item_sprite(sprite_path: String):
	if is_multiplayer_authority():
		player_weapon.update_item_sprite_server.rpc_id(1, sprite_path)

func throw_potion(potion: Potion):
	if not potion_projectile_scene:
		return
	
	var target_pos = get_global_mouse_position()
	var distance = global_position.distance_to(target_pos)
	
	
	if distance > potion_max_range:
		var direction = global_position.direction_to(target_pos)
		target_pos = global_position + direction * potion_max_range
	
	manage_throw_potion.rpc_id(1, potion.effect, potion.time, target_pos)

@rpc("any_peer", "call_local", "reliable")
func manage_throw_potion(effect: Global.States, time: int, target_pos: Vector2):
	spawn_potion.rpc(effect, time, target_pos)

@rpc("authority", "call_local", "reliable")
func spawn_potion(effect: Global.States, time: int, target_pos: Vector2):
	var projectile = potion_projectile_scene.instantiate()
	get_tree().root.add_child(projectile)
	projectile.global_position = target_pos
	projectile.effect = effect
	projectile.effect_time = time
	projectile.sprite.texture = load("res://assets/Items/Craftables/potion_frost_small.png")
