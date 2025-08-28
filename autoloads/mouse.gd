extends Node

var old_container: PanelContainer
var new_container: PanelContainer
var item: Item
var on_ui: bool
var player: Player
var drop_id: String = ""
var drop_id_first: int = 0
var drop_id_second: int = 0

func get_drop_id():
	drop_id_first += 1
	if drop_id_first > 100000:
		drop_id_second+=1
	drop_id = str(drop_id_first) + str(player.player_id) + str(drop_id_second)
	return drop_id
