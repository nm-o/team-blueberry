extends Node2D

# Scenes of the possible roles that can be chosen by the players
@export var alquimist_scene: PackedScene
@export var armor_master_scene: PackedScene
@export var weapon_master_scene: PackedScene

# Marker to set up the initial positions
@onready var marker_2d: Marker2D = $Marker2D


func _ready() -> void:
	# Going through the players to instatiate them
	for i in len(Game.players):
		var player_data = Game.players[i]
		var player_inst
		
		# Associating the correct scene depending on the selected rol
		if player_data.role == Statics.Role.ROLE_A:
			player_inst = alquimist_scene.instantiate()
		elif player_data.role == Statics.Role.ROLE_B:
			player_inst = armor_master_scene.instantiate()
		elif player_data.role == Statics.Role.ROLE_C:
			player_inst = weapon_master_scene.instantiate()
		
		# Setting the players in the main scene
		add_child(player_inst)
		player_inst.player_id = i
		player_inst.global_position.x = marker_2d.global_position.x*i + 50
		player_inst.global_position.y = marker_2d.global_position.y
		player_inst.setup(player_data)
			
