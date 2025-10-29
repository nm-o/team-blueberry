extends Potion

func _init() -> void:
	description = "Basic Healing Potion"
	texture = "res://assets/Items/Craftables/potion_heal_small.png"
	max_number = 10
	name = "Basic Healing Potion"
	time = 0 
	effect = Global.States.HEALING
	heal_amount = 50
