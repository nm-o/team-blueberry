extends Being
class_name Enemy

@export var detection_range: float = 200.0
@export var attack_range: float = 80.0  
@export var attack_cooldown: float = 2.0
@export var move_speed: float = 50.0

var target_player: Player = null
var can_attack: bool = true

func _ready():
	# Solo el servidor controla enemigos
	if multiplayer.is_server():
		set_physics_process(true)
	else:
		set_physics_process(false)

func _physics_process(delta):
	if not multiplayer.is_server():
		return
		
	find_closest_player()
	
	if target_player and target_player.isAlive:
		move_towards_target(delta)
		try_attack()

func find_closest_player():
	var closest_distance = detection_range
	target_player = null
	
	for child in get_parent().get_children():
		if child is Player and child.isAlive:
			var distance = global_position.distance_to(child.global_position)
			if distance < closest_distance:
				closest_distance = distance
				target_player = child

func move_towards_target(delta):
	var direction = (target_player.global_position - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()
	
	# Sincronizar posición a clientes
	sync_position.rpc(global_position)

@rpc("authority", "call_remote", "unreliable_ordered")
func sync_position(pos: Vector2):
	global_position = pos

func try_attack():
	if not can_attack or not target_player:
		return
		
	var distance = global_position.distance_to(target_player.global_position)
	if distance <= attack_range:
		perform_attack()

func perform_attack():
	can_attack = false
	
	# Aplicar daño al jugador objetivo
	if target_player and target_player.isAlive:
		apply_damage_to_target.rpc_id(target_player.get_multiplayer_authority(), attack)
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

@rpc("any_peer", "call_local", "reliable") 
func apply_damage_to_target(damage: int):
	# Este se ejecuta en el cliente del jugador
	if target_player:
		target_player.take_damage(damage)
		target_player.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		target_player.modulate = Color.WHITE
