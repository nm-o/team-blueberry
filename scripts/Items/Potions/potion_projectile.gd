extends Node2D

var effect: Global.States
var effect_time: int
var impact_radius: float = 50.0
var exploded := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var effect_area: Area2D = $EffectArea
@onready var effect_collision: CollisionShape2D = $EffectArea/CollisionShape2D

var current_radius := 0.0
var max_radius := 50.0
var circle_color := Color(1, 0.5, 0, 0.35)

func _ready():
	max_radius = impact_radius
	_set_collision_shape()
	_set_color_from_effect()
	_start_circle_animation()
	AudioController.play_potion_glass_breaking()
	await get_tree().create_timer(0.5).timeout
	_explode()

func _set_collision_shape():
	var shape := CircleShape2D.new()
	shape.radius = impact_radius
	effect_collision.shape = shape

func _set_color_from_effect():
	match effect:
		Global.States.FROZEN:
			circle_color = Color(0.3, 0.7, 1, 0.35)
		Global.States.POISONED:
			circle_color = Color(0.5, 1, 0.3, 0.35)
		Global.States.HEALING:
			circle_color = Color(1, 1, 0.3, 0.35)
		Global.States.HEALING_2:
			circle_color = Color(1, 0.6, 0.9, 0.4)
		_:
			circle_color = Color(1, 0.5, 0, 0.35)

func _start_circle_animation():
	current_radius = 0.0
	modulate.a = 1.0
	
	var tween := create_tween()
	# Importante: ir redibujando cada frame
	tween.tween_property(self, "current_radius", max_radius, 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
	
	# Forzar redibujado durante la animación
	tween.tween_callback(func(): queue_redraw())
	tween.set_loops() # hace que el callback se llame en cada paso

func _process(_delta):
	# Garantiza que se redibuje aunque el tween no dispare
	queue_redraw()

func _draw():
	if current_radius <= 0.0:
		return
	# El círculo se dibuja en el origen local del nodo
	draw_circle(Vector2.ZERO, current_radius, circle_color)

func _explode():
	exploded = true
	sprite.modulate = Color(1, 1, 1, 0.3)
	var tween := create_tween()
	tween.tween_property(sprite, "scale", Vector2(3, 3), 0.2)
	tween.parallel().tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.2)
	_apply_effect_to_area()
	await tween.finished
	queue_free()

func _apply_effect_to_area():
	var bodies = effect_area.get_overlapping_bodies()
	var small = true
	print("POCION: cuerpos en el área:", bodies)  # debug

	for body in bodies:
		print(" - body:", body, " type:", body.get_class(), " effect:", effect) # debug
		if body is Boss and effect == Global.States.POISONED:
			print("Aplicando multi-hit veneno al boss")  # debug
			_poison_multi_hit_boss(body, small)
		elif body is Boss and effect == Global.States.POISONED_2:
			print("Aplicando multi-hit veneno al boss") 
			small = false
			_poison_multi_hit_boss(body, small)
		elif body.has_method("apply_status_effect"):
			print("Aplicando estado normal a:", body)   # debug
			body.apply_status_effect(effect, effect_time)


func _poison_multi_hit_boss(boss: Boss, small: bool) -> void:
	var hits := 1
	
	var dmg_per_hit: int

	if small:
		dmg_per_hit = 40
	else:
		dmg_per_hit = 60

	for i in hits:
		if not is_instance_valid(boss):
			return
		boss.get_attacked(dmg_per_hit)
		await get_tree().create_timer(0.3).timeout  # intervalo entre golpes
