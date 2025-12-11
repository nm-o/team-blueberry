extends CraftingControl

# Must initiate this and recipes
var accepted_player_roles = ["Weapon Master"]

func _ready() -> void:
	recipes = {
		["Wood", "Wood", "Wood", ""]: SwordWood,
		["Wood", "Iron", "Iron", ""]: SwordIron,
		["Wood", "Legendary Mineral", "Legendary Mineral", ""]: SwordLegendary,
		["Wood", "Wood", "Iron", ""]: SpearIron,
		["Wood", "Wood", "Legendary Mineral", ""]: SpearLegendary,
		["Wood", "Wood", "Iron", "Iron"]: AxeIron,
		["Wood", "Wood", "Legendary Mineral", "Legendary Mineral"]: AxeLegendary,
	}
	super_ready()
