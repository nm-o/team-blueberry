extends Boss

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pivot: Node2D = $Pivot
@onready var sprite_2d: Sprite2D = $Pivot/Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $Pivot/Hurtbox/CollisionShape2D
@onready var laser_pivot: Node2D = $LaserPivot

func after_attack(target_2):
	laser_pivot.after_attack(target_2)

func _ready() -> void:
	collision_shape_2d.disabled = false
	sprite_2d.modulate = Color(1,1,1,1)
	attacks = {
		"mortar_machine_gun": [0, 3],
		"bullet_hell_1": [0, 4],
		"bullet_hell_2": [0, 4],
		"laser": [0, 5],
		"move": [0, 2]
	}
	max_speed = 10
	acceleration = 10000
	await get_tree().create_timer(0.1).timeout
	bullet_spawner.add_spawnable_scene(bullet_scene.resource_path)
	await super_ready()
	attack_workflow()

func spawn_boss():
	block_movement = true
	animation_player.play("spawn_animation")
	await animation_player.animation_finished
	await get_tree().create_timer(2).timeout
	block_movement = false

func move():
	max_speed = 30
	await get_tree().create_timer(3.0).timeout
	max_speed = 10
	
func play_death():
	animation_player.play("death_animation")
	await animation_player.animation_finished
	queue_free()

func mortar_machine_gun():
	#vars
	var gun_target = player_target
	var bullet_speed = 600
	var end_delay = 2.0
	var bullet_cooldown = 0.1
	var mortar_cooldown = 3 # every 3 bullets
	var mortar_area = 10
	var attack_duration = 5.0
	
	block_movement = true
	animation_player.play("show_pointer")
	await animation_player.animation_finished
	var attack_timer = get_tree().create_timer(attack_duration)
	var timer_running = true
	while timer_running:
		for i in mortar_cooldown:
			var direction = global_position.direction_to(gun_target.global_position)
			if direction == Vector2(0,0):
				direction = Vector2.RIGHT
			spawn_bullet(sprite_2d.global_position, direction.angle(), bullet_speed)
			await get_tree().create_timer(bullet_cooldown).timeout
		var mortar_target = Game.players[randi() % Game.players.size()].scene.global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
		spawn_mortar(mortar_target, mortar_area)
		if attack_timer.time_left == 0:
			timer_running = false
	block_movement = false
	await get_tree().create_timer(end_delay).timeout


func bullet_hell_1():
	var bullet_speed = 170
	var bullet_amount = 24
	var trigger_amount = 16
	var trigger_cooldown = 0.4
	var end_delay = 2.0
	block_movement = true
	for trigger in trigger_amount:
		var extra_angle = (trigger % 2) * 7.5
		for bullet in bullet_amount:
			var rot = deg_to_rad(((360.0/bullet_amount) * bullet) + extra_angle)
			spawn_bullet(global_position, rot, bullet_speed)
		await get_tree().create_timer(trigger_cooldown).timeout
	block_movement = false
	await get_tree().create_timer(end_delay).timeout
		

func bullet_hell_2():
	var bullet_speed = 150
	var bullet_amount = 36
	var trigger_amount = 16
	var trigger_cooldown = 0.5
	var end_delay = 2.0
	block_movement = true
	for trigger in trigger_amount:
		for bullet in bullet_amount:
			var rot = deg_to_rad(((360.0/(bullet_amount - 6))) * bullet) + deg_to_rad(randi_range(0, 360))
			spawn_bullet(global_position, rot, bullet_speed)
		await get_tree().create_timer(trigger_cooldown).timeout
	block_movement = false
	await get_tree().create_timer(end_delay).timeout
	
func laser():
	var bullet_spread = 40.0
	var bullet_amount = 5
	var bullet_speed = 200
	var trigger_cooldown = 0.4
	var laser_start_duration = 3.0
	var laser_duration = 7.0
	var end_delay = 3.0
	block_movement = true
	await get_tree().create_timer(2.0).timeout
	animation_player.play("activate_laser")
	await get_tree().create_timer(laser_start_duration).timeout
	var attack_timer = get_tree().create_timer(laser_duration)
	var timer_running = true
	while timer_running:
		var shotgun_target = Game.players[randi() % Game.players.size()].scene.global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
		var direction = global_position.direction_to(shotgun_target)
		if direction == Vector2(0,0):
			direction = Vector2.RIGHT
		var current_spread = - bullet_spread / 2
		for bullet in bullet_amount:
			spawn_bullet(sprite_2d.global_position, direction.angle() + deg_to_rad(current_spread), bullet_speed)
			current_spread += bullet_spread / bullet_amount
		await get_tree().create_timer(trigger_cooldown).timeout
		if attack_timer.time_left == 0:
			timer_running = false
	block_movement = false
	await get_tree().create_timer(end_delay).timeout
	
	
	
