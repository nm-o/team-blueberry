extends Node2D

@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var damage_circle: Sprite2D = $DamageCircle

@export var mortar_area = 3

func _ready() -> void:
	collision_shape_2d.shape.radius = 6 * mortar_area 
	damage_circle.scale = damage_circle.scale * mortar_area
	animation_player.play("spawn_bomb")
	await animation_player.animation_finished
	queue_free()
