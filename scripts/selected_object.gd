extends Node2D

# Variables to control selected object and the animation
@export var radius: int = 200
@export var active: bool = true

@onready var rotating_marker: Marker2D = $RotatingMarker
@onready var attack_area: Sprite2D = $RotatingMarker/AttackArea
@onready var animation_player: AnimationPlayer = $RotatingMarker/AnimationPlayer
@onready var object: Sprite2D = $RotatingMarker/Object

func _ready() -> void:
	attack_area.visible = false
	rotating_marker.position.x = radius

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority() and active:
		look_at(get_global_mouse_position())

func change_object(new_item_selected: Item):
	object.texture = new_item_selected.texture

func attack_animation(animName: String = "attackGreen"):
	if animation_player.has_animation(animName):
		animation_player.play(animName)
	
