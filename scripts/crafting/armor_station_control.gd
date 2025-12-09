extends CraftingControl

# Must initiate this and recipes
var accepted_player_roles = ["Alchemist"]

func _ready() -> void:
	recipes = {
		# Level 1
		["Water", "Poisonous flower", ""]: PotionPoison1,
		["Water", "", "Poisonous flower"]: PotionPoison1,
		["Water", "Healing flower", ""]: PotionHeal1,
		["Water", "", "Healing flower"]: PotionHeal1,
		["Water", "Frost flower", ""]: PotionFreeze1,
		["Water", "", "Frost flower"]: PotionFreeze1,
		# Level 2
		["Water", "Poisonous flower", "Magic Crystal"]: PotionPoison2,
		["Water", "Magic Crystal", "Poisonous flower"]: PotionPoison2,
		["Water", "Healing flower", "Magic Crystal"]: PotionHeal2,
		["Water", "Magic Crystal",  "Healing flower"]: PotionHeal2,
		["Water", "Frost flower", "Magic Crystal"]: PotionFreeze2,
		["Water", "Magic Crystal", "Frost flower"]: PotionFreeze2,
	}
	super_ready()
