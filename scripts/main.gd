# res://scenes/main.gd
extends Node2D

@export var player_scene: PackedScene
@export var boss_1_scene: PackedScene
@export var boss_2_scene: PackedScene
@export var boss_3_scene: PackedScene
@export var menu_scene: PackedScene

@onready var boss_spawn_marker: Marker2D = $BossSpawnMarker
@onready var collision_shape_2d: CollisionShape2D = $ColiseoToBase/CollisionShape2D

var current_boss = 1
var bosses


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

func _spawn_boss(to_coliseum):
	if not to_coliseum:
		return
	await get_tree().create_timer(7.0).timeout
	var boss = bosses[current_boss].instantiate()
	current_boss += 1
	Mouse.boss_number = current_boss
	add_child(boss)
	boss.global_position = boss_spawn_marker.global_position

func _victory():
	await get_tree().create_timer(6.0).timeout
	collision_shape_2d.disabled = false
	await get_tree().create_timer(3.5).timeout
	for player in Game.players:
		player.is_dead = false
	for player in get_tree().get_nodes_in_group("Players"):
		player.is_dead = false
		player.hp = player.max_hp
		player.ghost_enabled(false)
		player.inventory.health_bar.value = player.hp
	await get_tree().create_timer(5.0).timeout
	collision_shape_2d.disabled = true

func _defeat():
	await get_tree().create_timer(5.0).timeout
	get_tree().change_scene_to_packed(menu_scene)

func _super_victory():
	await get_tree().create_timer(7.0).timeout
	get_tree().change_scene_to_packed(menu_scene)

func _ready() -> void:
	Mouse.defeat_ui.connect(_defeat)
	Mouse.boss_dead.connect(_victory)
	Mouse.super_victory.connect(_super_victory)
	Mouse.teleport_started.connect(_spawn_boss)
	# Establecemos spawn point para jugadores
	if player_scene == null:
		player_scene = load("res://scenes/player/Player.tscn") as PackedScene
	assert(player_scene != null, "Player scene not assigned")

	if multiplayer.is_server():
		if "SERVER_ID" in Game:
			Game.SERVER_ID = multiplayer.get_unique_id()

	var players_root := _ensure_players_root()
	bosses = {
		1: boss_1_scene,
		2: boss_2_scene,
		3: boss_3_scene
	}
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
