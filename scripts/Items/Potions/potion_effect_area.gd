extends Area2D
class_name PotionEffectArea

var potion: Potion
var radius: float = 150.0
var duration: float = 0.5 

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual_effect: Node2D = $VisualEffect
@onready var duration_timer: Timer = $DurationTimer

func _ready() -> void:
	# Configurar el radio del área
	var shape = CircleShape2D.new()
	shape.radius = radius
	collision_shape.shape = shape
	
	var circle = Line2D.new()
	add_child(circle) 
	circle.width = 3
	circle.default_color = Color(0, 1, 1, 0.8)
	
	var points = []
	for i in range(33):
		var angle = (i / 32.0) * TAU
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	circle.points = PackedVector2Array(points)
	
	var tween = create_tween()
	tween.tween_property(circle, "modulate:a", 0.0, duration)
	
	# Aplicar efecto a todos los Beings en el área
	body_entered.connect(_on_body_entered)
	
	# También aplicar a los que ya están dentro
	await get_tree().process_frame
	_apply_to_existing_bodies()
	
	# Destruir el área después de un tiempo
	duration_timer.wait_time = duration
	duration_timer.timeout.connect(queue_free)
	duration_timer.start()

func _apply_to_existing_bodies() -> void:
	for body in get_overlapping_bodies():
		_apply_effect_to_body(body)

func _on_body_entered(body: Node2D) -> void:
	_apply_effect_to_body(body)

func _apply_effect_to_body(body: Node2D) -> void:
	if body is Being:
		if potion.effect == Global.States.HEALING:
			if body.has_method("heal"):
				body.heal(potion.heal_amount)
		else:
			if multiplayer.is_server():
				body.apply_state(potion.effect, potion.time)
