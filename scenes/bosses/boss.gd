class_name Boss
extends CharacterBody2D

@export var bullet_scene: PackedScene
@export var max_speed = 200
@export var acceleration = 10000

@onready var bullet_spawner: MultiplayerSpawner = $BulletSpawner
@onready var health_bar: ProgressBar = $CanvasLayer/HealthBar

var target_position: Vector2
var attacks
var real_attack: String
var doable_attacks: Array[String]
var target
var dashing = false
var block_movement = false

var hp: int = 100
var is_dead: bool = false

func super_ready():
	Mouse.players_lost.connect(_defeat)
func _defeat():
	await call("defeat")

func get_attacked(damage: int):
	manage_do_damage(damage)
		
func manage_do_damage(damage: int):
	if is_multiplayer_authority():
		do_damage_server.rpc_id(1, damage)

@rpc("authority", "call_local", "reliable")
func do_damage_server(damage: int):
	do_damage.rpc(damage)

@rpc("any_peer", "call_local", "reliable")
func do_damage(damage: int):
	hp -= damage
	health_bar.value = hp
	if hp <= 0:
		is_dead = true
		Mouse.boss_dead.emit()

func update_target():
	var closest_target = null
	var closest_distance = INF
	var players = get_node("/root/Main/Players").get_children()
	for player in players:
		if not player is Player:
			continue
		var player_distance = global_position.distance_to(player.global_position)
		if player_distance < closest_distance and not player.is_dead:
			closest_target = player.global_position
			closest_distance = player_distance
	if closest_target:
		target = closest_target
		
func spawn_bullet(pos: Vector2, rot: float, vel: float):
	if not bullet_scene:
		return null
	var bullet_inst = bullet_scene.instantiate()
	bullet_inst.global_position = pos
	bullet_inst.global_rotation = rot
	bullet_inst.max_speed = vel
	bullet_spawner.add_child(bullet_inst)
	
func _physics_process(delta: float) -> void:
	if is_dead:
		return
	update_target()
	if target and not block_movement and not dashing:
		var target_distance = global_position.distance_to(target)
		if target_distance > 4:
			var target_direction = global_position.direction_to(target)
			velocity = velocity.move_toward(target_direction * max_speed, acceleration * delta)
		else:
			velocity = Vector2(0,0)
	elif not dashing:
		velocity = Vector2(0,0)
	move_and_slide()
	if position.distance_to(target_position) > 100:
		if target_position != Vector2(0,0):
			position = target_position
		manage_send_pos()

func manage_send_pos():
	if is_multiplayer_authority():
		send_pos_server.rpc_id(1)
@rpc("authority", "call_local", "unreliable_ordered")
func send_pos_server():
	var pos = position
	send_pos.rpc(pos)
@rpc("any_peer", "call_remote", "unreliable_ordered")
func send_pos(pos):
	target_position = pos
	
func attack_workflow():
	doable_attacks = []
	for key in attacks.keys():
		if attacks[key][0] == 0:
			doable_attacks.append(key)
	manage_get_attack()
		
func manage_get_attack():
	if is_multiplayer_authority():
		get_attack_server.rpc_id(1)

@rpc("authority", "call_local", "reliable")
func get_attack_server():
	var attack = doable_attacks.pick_random()
	get_attack.rpc(attack)

@rpc("any_peer", "call_local", "reliable")
func get_attack(attack: String):
	do_attack(attack)

func do_attack(attack: String):
	if is_dead:
		await call("play_death")
	if attack:
		await call(attack)
		attacks[attack][0]=attacks[attack][1]
		for key in attacks.keys():
			if attacks[key][0] > 0:
				attacks[key][0] -= 1
		attack_workflow()
	else: 
		for key in attacks.keys():
			if attacks[key][0] > 0:
				attacks[key][0] -= 1
		await get_tree().create_timer(3).timeout
		attack_workflow()
			
			
