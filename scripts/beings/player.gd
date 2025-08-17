extends Being
class_name Player

# Represents a Player in the Game

# Variables to set the labels that depict the players name and chosen rol
@export var label_name: Label
@export var label_role: Label

# Variables for setting up the movement of a player
@export var max_speed: int = 300
@export var acceleration: int = 1000

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		var move_input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
		velocity = velocity.move_toward(move_input_vector*max_speed, acceleration*delta)
		move_and_slide()
		send_pos.rpc(position)

func setup(player_data: Statics.PlayerData):
	# Setting up the labels and authority of this player
	label_name.text = player_data.name
	label_role.text = "role: " + str(player_data.role)
	set_multiplayer_authority(player_data.id, false)
	
@rpc("authority", "call_remote", "unreliable_ordered")
func send_pos(pos):
	position = pos
