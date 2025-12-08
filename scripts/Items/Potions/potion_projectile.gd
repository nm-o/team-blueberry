# potion_projectile.gd
extends Node2D

var effect: Global.States
var effect_time: int
var impact_radius: float = 50.0
var exploded: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var effect_area: Area2D = $EffectArea
@onready var effect_collision: CollisionShape2D = $EffectArea/CollisionShape2D

func _ready():
	var shape = CircleShape2D.new()
	shape.radius = impact_radius
	effect_collision.shape = shape
	
	# Mostrar círculo inmediatamente
	_show_effect_circle()
	
	# Esperar 0.5s y explotar
	await get_tree().create_timer(0.5).timeout
	_explode()

func _explode():
	exploded = true
	
	# Animación
	sprite.modulate = Color(1, 1, 1, 0.3)
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(3, 3), 0.2)
	tween.parallel().tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.2)
	
	_apply_effect_to_area()
	
	await tween.finished
	queue_free()
	
func _show_effect_circle():
	var circle = Sprite2D.new()
	add_child(circle)
	circle.z_index = 1  # Cambiar a positivo para que sea visible encima
	
	# Crear textura con tamaño mínimo decente
	var size = max(512, int(impact_radius * 8))
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	# Determinar color según efecto (asegurar que effect esté inicializado)
	var color = Color(1, 0.5, 0, 0.5)  # Por defecto naranja
	if effect == Global.States.FROZEN:
		color = Color(0.3, 0.7, 1, 0.5)
	elif effect == Global.States.POISONED:
		color = Color(0.5, 1, 0.3, 0.5)
	elif effect == Global.States.HEALING:
		color = Color(1, 1, 0.3, 0.5)
	
	var center = size / 2.0
	var radius_pixels = (impact_radius / (impact_radius * 2)) * size
	var radius_squared = radius_pixels * radius_pixels
	
	# Dibujar círculo relleno
	for x in range(size):
		for y in range(size):
			var dx = x - center
			var dy = y - center
			if dx*dx + dy*dy <= radius_squared:
				img.set_pixel(x, y, color)
	
	circle.texture = ImageTexture.create_from_image(img)
	circle.centered = true
	# Escalar para que el tamaño visual coincida con impact_radius
	circle.scale = Vector2.ONE * (impact_radius * 2) / size



func _apply_effect_to_area():
	var bodies = effect_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("apply_status_effect"):
			body.apply_status_effect(effect, effect_time)
