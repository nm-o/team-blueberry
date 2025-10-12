# res://scenes/main.gd
extends Node2D

@export var player_scene: PackedScene

# Mapeo de rol → ruta del Resource de configuración
const ROLE_CONFIGS := {
	Statics.Role.ROLE_A: "res://scenes/player/resources/Alchemist.tres",
	Statics.Role.ROLE_B: "res://scenes/player/resources/ArmorMaster.tres",
	Statics.Role.ROLE_C: "res://scenes/player/resources/WeaponMaster.tres",
}

@onready var player_spawn: Marker2D = $PlayerSpawn

func _ensure_players_root() -> Node:
	var root := get_node_or_null("Players")
	if root == null:
		root = Node2D.new()
		root.name = "Players"
		add_child(root)
	return root

func _ready() -> void:
	# Establecemos spawn point para jugadores
	if player_scene == null:
		player_scene = load("res://scenes/player/Player.tscn") as PackedScene
	assert(player_scene != null, "Player scene not assigned")

	if multiplayer.is_server():
		if "SERVER_ID" in Game:
			Game.SERVER_ID = multiplayer.get_unique_id()

	var players_root := _ensure_players_root()

	for i in Game.players.size():
		var player_data = Game.players[i]
		var player_inst: Player = player_scene.instantiate()
		player_inst.name = "Player_%d" % player_data.id

		# Seleccionar configuración por rol (.tres)
		var cfg_path: String = ROLE_CONFIGS.get(player_data.role, "res://scenes/player/resources/WeaponMaster.tres")
		var config: PlayerClassConfig = load(cfg_path) as PlayerClassConfig
		player_inst.class_config = config

		players_root.add_child(player_inst)
		player_inst.global_position = player_spawn.global_position + Vector2(10 * i, 0)

		player_inst.setup(player_data)
		player_data.scene = player_inst

		if Engine.has_singleton("Combat") or (typeof(Combat) == TYPE_OBJECT):
			Combat.register_actor(player_data.id, player_inst.get_path())
	await get_tree().create_timer(5).timeout
