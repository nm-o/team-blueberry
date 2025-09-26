extends StaticBody2D

@onready var failed_interaction: Label = $FailedInteraction
@onready var interaction_name_label: Label = $InteractionName
@onready var interface: CanvasLayer = $interface

func _ready() -> void:
	interaction_name_label.visible = false
	failed_interaction.visible = false

func interact():
	for role in interface.get_child(0).accepted_player_roles:
		if Mouse.player.label_role.text == role:
			interface.get_child(0).visible = true
			Mouse.player.inventory.change_visibility()
			return

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		interface.get_child(0).visible = false
		
