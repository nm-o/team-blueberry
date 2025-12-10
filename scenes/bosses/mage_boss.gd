extends Boss

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pivot: Node2D = $Pivot
@onready var sprite_2d: Sprite2D = $Pivot/Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $Pivot/Hurtbox/CollisionShape2D
@onready var super_laser_pivot: Node2D = $SuperLaserPivot

func _ready() -> void:
	collision_shape_2d.disabled = false
	sprite_2d.modulate = Color(1,1,1,1)
	attacks = {
		"star_lasers": [0, 4],
		"teleport": [0, 0],
		"multi_teleport": [0, 4],
		"super_attack": [8, 8],
		"hands_attack": [0, 6]
	}
	max_speed = 20
	acceleration = 10000
	await get_tree().create_timer(0.1).timeout
	bullet_spawner.add_spawnable_scene(dot_scene.resource_path)
	await super_ready()
	attack_workflow()

func after_attack(target_2):
	super_laser_pivot.after_attack(target_2)

func spawn_boss():
	AudioController.play_boss_appear("final")
	block_movement = true
	animation_player.play("spawn_animation")
	await animation_player.animation_finished
	block_movement = false

func play_death():
	animation_player.play("death_animation")
	await animation_player.animation_finished
	queue_free()

func hands_attack():
	var trigger_amount = 10
	var time_between_triggers = 0.5
	var bullet_amount = 8.0
	var bullet_speed = 500
	var end_delay = 0.5
	var bullet_distance = 40
	
	block_movement = true
	await teleport()
	for trigger in trigger_amount:
		var current_angle = 0
		var rot =  global_position.direction_to(target).angle()
		for bullet in bullet_amount:
			var where = Vector2(cos(deg_to_rad(current_angle)), sin(deg_to_rad(current_angle))) * bullet_distance
			spawn_timed(global_position + where,rot, bullet_speed)
			current_angle += 360 / bullet_amount
		await get_tree().create_timer(time_between_triggers).timeout
		await teleport()
	block_movement = false
	await get_tree().create_timer(end_delay).timeout

func super_attack():
	var laser_charge_time = 1.0
	var bullet_amount = 8.0
	var trigger_amount = 10
	var trigger_separation = 50
	var laser_duration = 15.0
	var trigger_separation_time = 0.05
	var end_delay = 1.0
	
	block_movement = true
	animation_player.play("teleport_entry")
	await animation_player.animation_finished
	global_position = Vector2(8622, 135)
	animation_player.play("teleport_exit")
	await animation_player.animation_finished
	await get_tree().create_timer(laser_charge_time).timeout
	animation_player.play("aura_enter")
	await animation_player.animation_finished
	var current_distance = 0
	var current_angle = 0
	var current_time = 0
	var current_trigger_angle = 0
	for trigger in trigger_amount:
		current_distance += trigger_separation
		current_angle = current_trigger_angle
		current_trigger_angle += 10
		for bullet in bullet_amount:
			var where = Vector2(cos(deg_to_rad(current_angle)), sin(deg_to_rad(current_angle))) * current_distance
			current_angle += 360.0 / bullet_amount
			spawn_dot(global_position + where, laser_duration - current_time)
			current_time += trigger_separation_time
			await get_tree().create_timer(trigger_separation_time).timeout
	animation_player.play("super_laser")
	await animation_player.animation_finished
	animation_player.play("aura_exit")
	await animation_player.animation_finished
	block_movement = false
	await get_tree().create_timer(end_delay).timeout

func star_lasers():
	#vars
	var trigger_amount = 3
	var end_delay = 0.5
	
	for trigger in trigger_amount:
		animation_player.play("laser_star")
		await animation_player.animation_finished
	await get_tree().create_timer(end_delay).timeout


func teleport():
	# vars
	var teleport_distance = 400
	var end_delay = 0.1
	
	block_movement = true
	animation_player.play("teleport_entry")
	await animation_player.animation_finished
	var old_position = global_position
	var not_broken = true
	var i = 0
	while not_broken:
		global_position += Vector2(randf_range(-teleport_distance, teleport_distance), randf_range(-teleport_distance, teleport_distance))
		for player in Game.players:
			if global_position.distance_to(player.scene.global_position) < 200:
				not_broken = false
		if not_broken:
			global_position = old_position
		if i == 10:
			not_broken = false
		i += 1
	animation_player.play("teleport_exit")
	await animation_player.animation_finished
	block_movement = false
	await get_tree().create_timer(end_delay).timeout

func multi_teleport():
	var trigger_amount = 8
	var end_delay = 1.0
	
	block_movement = true
	for trigger in trigger_amount:
		await teleport()
	block_movement = false
	await get_tree().create_timer(end_delay).timeout
