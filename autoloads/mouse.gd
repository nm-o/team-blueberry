extends Node

var old_container: PanelContainer
var from_stack: bool = false
var new_container: PanelContainer
var to_stack: bool = false
var item: Item
var on_ui: bool
var player: Player
var drop_id: String = ""
var drop_id_first: int = 0
var drop_id_second: int = 0
var boss_number: int = 1

signal players_lost
signal boss_dead
signal on_teleport(id)
signal exited_teleport(id)
signal teleport_timer_started(time)
signal teleport_timer_stopped()
signal teleport_started(to_coliseum)
signal defeat_ui()
signal super_victory

func update_modifier(index: int, modifier: float):
	if index in [0,1,2]:
		player.class_config.defense_modifier_array[index] = modifier
		var updated_full_modifier: float = player.class_config.defense_modifier_array.reduce(func(acc, num): return acc+num)
		player.class_config.defense_modifier = updated_full_modifier
		print("updated_modifier ", player.class_config.defense_modifier)
		
func get_drop_id():
	drop_id_first += 1
	if drop_id_first > 100000:
		drop_id_second += 1
		drop_id_first = 1
	drop_id = str(drop_id_first) + str(player.player_id) + str(drop_id_second)
	return drop_id

@rpc("any_peer", "reliable", "call_local")
func set_player_is_dead(is_dead: bool, id: int):
	var current_player = Game.get_player(id)
	if not current_player:
		return
	current_player.is_dead = is_dead
	var all_dead: bool = true
	for player_0 in Game.players:
		all_dead = all_dead and player_0.is_dead
	if all_dead:
		players_lost.emit()
