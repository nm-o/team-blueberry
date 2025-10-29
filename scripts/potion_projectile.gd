extends Area2D
class_name PotionProjectile

var potion: Potion
var direction: Vector2
var speed: float = 400.0
var lifetime: float = 2.0
var explosion_radius: float = 150.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var lifetime_timer: Timer = $LifetimeTimer

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	if potion and potion.texture:
		sprite.texture = load(potion.texture)
	
	lifetime_timer.wait_time = lifetime
	lifetime_timer.timeout.connect(_explode)
	lifetime_timer.start()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(_body: Node2D) -> void:
	_explode()

func _on_area_entered(_area: Area2D) -> void:
	_explode()

func _explode() -> void:
	# Crear el área de efecto
	var effect_area = preload("res://scenes/potion_effect_area.tscn").instantiate()
	effect_area.potion = potion
	effect_area.radius = explosion_radius
	effect_area.global_position = global_position
	get_parent().add_child(effect_area)
	
	queue_free()
