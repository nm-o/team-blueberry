extends Area2D

@export var teleport_marker: Marker2D
@export var required_time: float = 5.0
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

func _on_body_exited(body):
	if body is Player:
		notify_player_exited.rpc(body.player_id)

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
	else:
		teleport_timer.stop()

func _on_timer_timeout():
	teleport_all()

func teleport_all():
	if not teleport_marker:
		push_warning("No teleport marker assigned")
		return
	
	for player in get_tree().get_nodes_in_group("players"):
		player.global_position = teleport_marker.global_position
	players_in_area.clear()
