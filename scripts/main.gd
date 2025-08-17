extends Node2D

# Scenes of the possible roles that can be chosen by the players
@export var alquimist_scene: PackedScene
@export var armor_master_scene: PackedScene
@export var weapon_master_scene: PackedScene

func _ready() -> void:
	# Instantiating the players according to their chosen rol
	for player_data in Game.players:
		if player_data.role == Statics.Role.ROLE_A:
			var alquimist_inst = alquimist_scene.instantiate()
			add_child(alquimist_inst)
			alquimist_inst.setup(player_data)
		elif player_data.role == Statics.Role.ROLE_B:
			var armor_master_inst = armor_master_scene.instantiate()
			add_child(armor_master_inst)
			armor_master_inst.setup(player_data)
		elif player_data.role == Statics.Role.ROLE_C:
			var weapon_master_inst = weapon_master_scene.instantiate()
			add_child(weapon_master_inst)
			weapon_master_inst.setup(player_data)
			
