extends Node2D

@export var max_speed = 100
@export var lifetime = 300

@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var hitbox: Hitbox = $Hitbox
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("be_born")
	await get_tree().create_timer(lifetime).timeout
	animation_player.play("be_dead")
	await animation_player.animation_finished
	queue_free()
	
func after_attack(_target_2):
	hitbox.monitoring = false
	hitbox.monitorable = false
	await get_tree().process_frame
	hitbox.monitoring = true
	hitbox.monitorable = true
