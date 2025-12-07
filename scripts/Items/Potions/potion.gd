class_name Potion
extends Craftable

var effect: Global.States
var time: int

func use(player: Player) -> void:
	player.throw_potion(self)
