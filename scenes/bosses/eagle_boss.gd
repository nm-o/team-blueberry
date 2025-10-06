extends Boss

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pivot: Node2D = $Pivot
@onready var sprite_2d: Sprite2D = $Pivot/Sprite2D

func _ready() -> void:
	attacks = {
		"quick_dash": [0, 2],
		"quick_feathers": [0, 2],
		"fly": [0, 4],
		"circle_attack": [0, 4]
	}
	max_speed = 100
	acceleration = 10000
	await get_tree().create_timer(0.1).timeout
	bullet_spawner.add_spawnable_scene(bullet_scene.resource_path)
	attack_workflow()
	
func circle_attack():
	#vars
	var fire_rate = 23
	var bullet_speed = 500
	
	block_movement = true
	animation_player.play("prepare_circle")
	await animation_player.animation_finished
	animation_player.play("circle")
	while animation_player.is_playing():
		spawn_bullet(sprite_2d.global_position, pivot.global_rotation, bullet_speed)
		await get_tree().create_timer(1.0 / fire_rate).timeout
	animation_player.play("end_circle")
	block_movement = false
	await animation_player.animation_finished


func quick_dash():
	# vars
	var dash_duration = 0.3
	
	block_movement = true
	var direction = global_position.direction_to(target)
	if direction == Vector2(0,0):
		direction = Vector2.RIGHT
	global_rotation = direction.angle()
	var old_speed = max_speed
	max_speed = 800 / dash_duration
	dashing = true
	velocity = Vector2(0, 0)
	animation_player.play("quick_dash_animation")
	await animation_player.animation_finished
	velocity = direction * max_speed
	await get_tree().create_timer(dash_duration).timeout
	max_speed = old_speed
	velocity = Vector2(0,0)
	dashing = false
	await get_tree().create_timer(0.5).timeout
	global_rotation = 0
	block_movement = false
	

func appear_on_top(time: float):
	await get_tree().create_timer(time).timeout
	global_position = target

func fly():
	#vars
	var bullet_speed = 500
	var fire_rate = 3
	var amount_of_triggers = 3
	var bullet_amount = 16
	
	max_speed += 100
	animation_player.play("prapare_to_fly_animation")
	block_movement = true
	await get_tree().create_timer(0.3).timeout
	await animation_player.animation_finished
	block_movement = false
	animation_player.play("fly_animation")
	appear_on_top(0.8)
	await get_tree().create_timer(3.4).timeout
	max_speed -= 100
	for trigger in amount_of_triggers:
		var rot = deg_to_rad(randf_range(-90, 90))
		for bullet in bullet_amount:
			var pos = global_position
			rot += deg_to_rad(360.0 / bullet_amount)
			spawn_bullet(pos, rot, bullet_speed)
		await get_tree().create_timer(1.0/fire_rate).timeout

func quick_feathers():
	#vars
	var spread = 60.0
	var bullet_speed = 700
	var fire_rate = 6
	var amount_of_triggers = 3
	var bullet_amount = 5
	
	block_movement = true
	for trigger in amount_of_triggers:
		var direction = global_position.direction_to(target)
		var current_spread =  - spread / 2
		var direction_angle = direction.angle() + deg_to_rad(randf_range(- spread / 3, spread / 3))
		for bullet in bullet_amount:
			var rot = direction_angle + deg_to_rad(current_spread)
			current_spread += spread/bullet_amount
			var pos = global_position
			spawn_bullet(pos, rot, bullet_speed)
		await get_tree().create_timer(1.0/fire_rate).timeout
	block_movement = false
