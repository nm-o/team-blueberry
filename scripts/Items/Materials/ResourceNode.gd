extends Node2D
class_name ResourceNode

@export var item_script: Script
@export var amount: int = 1
@export var item_drop_scene: PackedScene
@export var max_clicks: int = 3

@onready var interaction_area: Area2D = $InteractionArea
@onready var interaction_name_label: Label = $InteractionName

var clicks_left: int
@export var harvest_range: float = 80.0  # distancia máxima para talar

func _ready() -> void:
	clicks_left = max_clicks
	interaction_name_label.visible = false
	interaction_area.owner = self
	interaction_area.input_event.connect(_on_interaction_area_input_event)

func _on_interaction_area_input_event(viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed:
		_on_left_click()

func _on_left_click() -> void:
	# Comprobar distancia al jugador
	if not Mouse.player:
		return
	var dist = global_position.distance_to(Mouse.player.global_position)
	if dist > harvest_range:
		return  # demasiado lejos, no cuenta el click

	clicks_left -= 1
	if clicks_left <= 0:
		_break_and_drop()


func _break_and_drop() -> void:
	if not item_script or not item_drop_scene or amount <= 0:
		queue_free()
		return

	for i in amount:
		_spawn_item_drop()

	queue_free()

func _spawn_item_drop():
	var item_res: Item = item_script.new()
	item_res.drop_id = Mouse.get_drop_id()

	var drop := item_drop_scene.instantiate()
	drop.item = item_res
	get_tree().root.add_child(drop)
	drop.global_position = global_position + Vector2(
		randf_range(-8, 8),
		randf_range(-8, 8)
	)
	drop.update_item_drop()
