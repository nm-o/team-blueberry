extends CraftingControl

# Must initiate this and recipes
var accepted_player_roles = ["Armor Master"]

func _ready() -> void:
	recipes = {
		["Iron", "Iron", ""]: Helmet
	}
	super_ready()
