extends Node2D
class_name ResourceNode

@export var item_script: Script          # Script del Item/Potion/etc.
@export var amount: int = 1             # Cuantas unidades da
@export var respawn_time: float = 0.0   # 0 = no respawnea

@onready var interaction_area: Area2D = $InteractionArea
@onready var interaction_name_label: Label = $InteractionName

var current_amount: int

func _ready() -> void:
	current_amount = amount
	interaction_name_label.visible = false
	# Para que entre en el sistema de interacción del Player
	interaction_area.owner = self

func interact():
	if current_amount <= 0:
		return
	if not item_script:
		return

	var item: Item = item_script.new()

	item.drop_id = Mouse.get_drop_id()

	for i in current_amount:
		Mouse.player.inventory.add_item(item)

	current_amount = 0

	queue_free()
