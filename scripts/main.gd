extends Node2D

@export var player_scene: PackedScene
@onready var marker_2d: Marker2D = $Marker2D

func _ready() -> void:
	if multiplayer.is_server():
		# El servidor espera a que todos se conecten y luego spawnea
		await get_tree().create_timer(0.5).timeout
		spawn_players_for_everyone.rpc()

@rpc("authority", "call_local", "reliable")
func spawn_players_for_everyone():
	print("=== SPAWNING PLAYERS ===")
	print("My peer ID: ", multiplayer.get_unique_id())
	
	for i in len(Game.players):
		var player_data = Game.players[i]
		
		print("Processing player: ", player_data.name, " ID: ", player_data.id)
		
		var player_inst = player_scene.instantiate()
		player_inst.name = "Player_" + str(player_data.id)
		
		add_child(player_inst, true)
		player_inst.player_id = i
		player_inst.global_position.x = marker_2d.global_position.x + (i * 100)
		player_inst.global_position.y = marker_2d.global_position.y
		
		player_inst.set_multiplayer_authority(player_data.id, false)
		
		setup_player_data(player_inst, player_data)
		
		print("Player ", player_data.name, " spawned with authority: ", player_inst.get_multiplayer_authority())
		print("Am I authority for this player? ", player_inst.is_multiplayer_authority())
		
		
@export var enemy_scene: PackedScene

func spawn_enemies():
	if multiplayer.is_server():
		for i in range(3):  # 3 enemigos
			var enemy = enemy_scene.instantiate()
			enemy.name = "Enemy_" + str(i)
			enemy.global_position = Vector2(randf_range(100, 900), randf_range(100, 500))
			enemy.faction = Being.Faction.ENEMY
			add_child(enemy)	
	
func setup_player_data(player_inst, player_data):

	match player_data.role:
		Statics.Role.ROLE_A:
			player_inst.hp = 100
			player_inst.movement_speed = 100.0
			player_inst.attack = 8
			player_inst.defense = 5
		Statics.Role.ROLE_B:
			player_inst.hp = 120
			player_inst.movement_speed = 90.0
			player_inst.attack = 15
			player_inst.defense = 8
		Statics.Role.ROLE_C:
			player_inst.hp = 150
			player_inst.movement_speed = 80.0
			player_inst.attack = 10
			player_inst.defense = 12
	

	
	# Labels
	if player_inst.label_name:
		player_inst.label_name.text = player_data.name
	if player_inst.label_role:
		player_inst.label_role.text = "role: " + str(player_data.role)
	
	# Solo configurar autoridad específica si es MI jugador
	if player_data.id == multiplayer.get_unique_id():
		setup_my_player(player_inst)

	await get_tree().create_timer(0.2).timeout
	player_inst.multiplayer_ready = true
	print("Player ", player_inst.name, " is now multiplayer ready")	

func setup_my_player(player_inst):
	print("Setting up MY player: ", player_inst.name)
	
	if player_inst.inventory:
		Mouse.player = player_inst
		if player_inst.interaction_area:
			player_inst.interaction_area.area_entered.connect(player_inst._interaction_area_entered)
			player_inst.interaction_area.area_exited.connect(player_inst._interaction_area_exited)
		
		player_inst.inventory.inventory_containers.visible = false
		player_inst.inventory.backpack_containers.visible = false
		player_inst.inventory.hotbar_containers.visible = true
		
		# Cámara personal
		player_inst.personal_camera_2d = Camera2D.new()
		player_inst.add_child(player_inst.personal_camera_2d)
		player_inst.personal_camera_2d.make_current()
