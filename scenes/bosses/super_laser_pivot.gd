extends Node2D

var target: Player
var speed = 1

@onready var laser: Sprite2D = $SuperLaserSprite
@onready var laser_hitbox: Hitbox = $Hitbox

func _physics_process(delta: float) -> void:
	if not laser.visible:
		target = owner.player_target
	if target:
		var direction = global_position.direction_to(target.global_position)
		var target_angle = direction.angle() + deg_to_rad(90)
		var angle_diff = abs(angle_difference(rotation, target_angle))
		rotation = rotate_toward(rotation, target_angle, speed * delta * angle_diff)
		
func after_attack(_target_2):
	laser_hitbox.monitoring = false
	laser_hitbox.monitorable = false
	await get_tree().process_frame
	laser_hitbox.monitoring = true
	laser_hitbox.monitorable = true
