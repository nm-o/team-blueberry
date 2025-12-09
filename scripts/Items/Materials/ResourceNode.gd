extends Node2D
class_name ResourceNode

@export var item_script: Script      # p.ej. WoodItem.gd
@export var amount: int = 1
@export var item_drop_scene: PackedScene   # misma escena que usa el Player

@onready var interaction_area: Area2D = $InteractionArea
@onready var interaction_name_label: Label = $InteractionName

var current_amount: int

func _ready() -> void:
	current_amount = amount
	interaction_name_label.visible = false
	interaction_area.owner = self

func interact():
	if current_amount <= 0:
		return
	if not item_script or not item_drop_scene:
		return

	for i in current_amount:
		_spawn_item_drop()

	current_amount = 0
	queue_free()  # el recurso desaparece

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
