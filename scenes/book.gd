extends Node2D

@export var interaction_name_label: Label
@export var book_interface: CanvasLayer

var is_in_area: bool = false

func _ready() -> void:
	book_interface.visible = false
	interaction_name_label.visible = false

func _input(event: InputEvent) -> void:
	if is_in_area and event.is_action_pressed("interact"):
		Mouse.is_tutorial_open = !Mouse.is_tutorial_open
		if is_multiplayer_authority():
			book_interface.visible = !book_interface.visible

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		is_in_area = true
		interaction_name_label.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		is_in_area = false
		interaction_name_label.visible = false
