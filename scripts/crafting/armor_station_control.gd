extends CraftingControl

# Must initiate this and recipes
var accepted_player_roles = ["Alchemist"]

func _ready() -> void:
	recipes = {
		["Wood", "Wood", "Wood", ""]: SwordWood,
	}
	super_ready()
