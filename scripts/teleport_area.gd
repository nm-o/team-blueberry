class_name Teleporter
extends Area2D

@export var teleport_marker: Marker2D
@export var required_time: float = 5.0
@export var show_labels: bool = true
@export var to_coliseum: bool = true
var players_in_area: Dictionary = {}  # {player_id: true}
var teleport_timer: Timer

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	teleport_timer = Timer.new()
	teleport_timer.one_shot = true
	teleport_timer.timeout.connect(_on_timer_timeout)
	add_child(teleport_timer)

func _on_body_entered(body):
	if body is Player:
		notify_player_entered.rpc(body.player_id)
		if show_labels:
			Mouse.on_teleport.emit(body.player_id)

func _on_body_exited(body):
	if body is Player:
		notify_player_exited.rpc(body.player_id)
		if show_labels:
			Mouse.exited_teleport.emit(body.player_id)
			Mouse.teleport_timer_stopped.emit()

@rpc("any_peer", "call_local", "reliable")
func notify_player_entered(id: int):
	players_in_area[id] = true
	check_teleport()

@rpc("any_peer", "call_local", "reliable")
func notify_player_exited(id: int):
	players_in_area.erase(id)
	teleport_timer.stop()

func check_teleport():
	var total_players = get_tree().get_nodes_in_group("players").size()
	if players_in_area.size() == total_players:
		if teleport_timer.is_stopped():
			teleport_timer.start(required_time)
			if show_labels:
				Mouse.teleport_timer_started.emit(required_time)
	else:
		teleport_timer.stop()
		Mouse.teleport_timer_stopped.emit()

func _on_timer_timeout():
	Mouse.teleport_timer_stopped.emit()
	Mouse.teleport_started.emit(to_coliseum)
	await get_tree().create_timer(2.5).timeout
	teleport_all()

func teleport_all():
	if not teleport_marker:
		push_warning("No teleport marker assigned")
		return
	var i = 0
	for player in get_tree().get_nodes_in_group("players"):
		player.global_position = teleport_marker.global_position + Vector2(i*10, 0)
		i += 1
	players_in_area.clear()
