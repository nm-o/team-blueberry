extends Node2D

var target: Player
var speed = 1.7

@onready var laser_hitbox: Hitbox = $LaserHitbox
@onready var laser: Sprite2D = $Laser

func _physics_process(delta: float) -> void:
	if not laser.visible:
		target = owner.player_target
	if target:
		var direction = global_position.direction_to(target.global_position)
		var distance = global_position.distance_to(target.global_position)
		global_position += direction * speed * delta * distance
		
func after_attack(_target_2):
	laser_hitbox.monitoring = false
	laser_hitbox.monitorable = false
	await get_tree().process_frame
	laser_hitbox.monitoring = true
	laser_hitbox.monitorable = true
