extends StaticBody2D

@onready var interaction_name_label: Label = $InteractionName

func _ready() -> void:
	interaction_name_label.visible = false

func interact():
	Mouse.player.inventory.open_crafting_table()
