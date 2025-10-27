extends CraftingControl

# Must initiate this and recipes
var accepted_player_roles = ["Alchemist"]

func _ready() -> void:
	recipes = {}
	super_ready()
