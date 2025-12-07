extends Node2D

var velocity: Vector2 = Vector2.ZERO
var effect: Global.States
var effect_time: int
var impact_radius: float = 100.0
var speed: float = 400.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var impact_area: Area2D = $ImpactArea
@onready var effect_area: Area2D = $EffectArea
@onready var effect_collision: CollisionShape2D = $EffectArea/CollisionShape2D

func _ready():
	impact_area.body_entered.connect(_on_impact)
	var shape = CircleShape2D.new()
	shape.radius = impact_radius
	effect_collision.shape = shape

func _physics_process(delta):
	global_position += velocity * delta

func _on_impact(_body):
	_apply_effect_to_area()
	queue_free()

func _apply_effect_to_area():
	var bodies = effect_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("apply_status_effect"):
			body.apply_status_effect(effect, effect_time)
