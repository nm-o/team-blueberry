extends Node2D

@export var radius: float = 100.0
@export var color: Color = Color("3c3c3c19")
@export var width: float = 1.5
@export var resolution: int = 64

func _draw():
	draw_arc(Vector2.ZERO, radius, 0, TAU, resolution, color, width)

func set_radius(r):
	radius = r
	queue_redraw()

func set_visible_ring(is_visible: bool):
	visible = is_visible
	queue_redraw()
