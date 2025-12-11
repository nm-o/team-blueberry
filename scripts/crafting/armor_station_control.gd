extends CraftingControl

# Must initiate this and recipes
var accepted_player_roles = ["Armor Master"]

func _ready() -> void:
	recipes = {
		# Level 1
		["Iron", "Iron", "", "Iron", ""]: HelmetIron,
		["", "Iron", "Iron", "Iron", "Iron"]: ChestplateIron,
		["", "Iron", "", "Iron", ""]: LegsIron,
		# Level 2
		["Legendary Mineral", "Legendary Mineral", "", "Legendary Mineral", ""]: HelmetLegendary,
		["", "Legendary Mineral", "Legendary Mineral", "Legendary Mineral", "Legendary Mineral"]: ChestplateLegendary,
		["", "Legendary Mineral", "", "Legendary Mineral", ""]: LegsLegendary,
	}
	super_ready()
