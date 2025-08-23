extends CharacterBody2D
class_name Being
# Represents a Being in the game

# ATTRIBUTES
var hp: int
var movement_speed: float
var attack: int
var defense: int
var state: Global.States = Global.States.NORMAL

# isAlive PROPERTY
var isAlive: bool:
	get:
		return hp > 0

# CONSTRUCTOR
func _init(life: int = 100, speed: float = 100.0, att: int = 10, def: int = 5):
	hp = life
	movement_speed = speed
	attack = att
	defense = def

# METHODS
func take_damage(damage: int):
	var final_damage = max(1, damage - defense)  # Minimum 1 damage
	hp = max(0, hp - final_damage)
	
	if not isAlive:
		state = Global.States.DEAD

func heal(amount: int):
	if isAlive:
		hp += amount

# METHOD TO CHANGE STATE (WITH DEAD PROTECTION)
func change_state(new_state: Global.States):
	# If dead, only allow resurrection
	if state == Global.States.DEAD and new_state != Global.States.RESURRECTED:
		print("Cannot change state of a dead being without resurrection")
		return false
	
	state = new_state
	return true

# SPECIAL METHOD FOR RESURRECTION
func resurrect(initial_hp: int = 1):
	if state == Global.States.DEAD:
		hp = initial_hp
		state = Global.States.NORMAL 
		print("Has been resurrected")
		return true
	return false

# METHOD TO APPLY EFFECTS (potions)
func apply_effect(effect_type: Global.States):
	# Normal effects don't affect the dead
	if state == Global.States.DEAD:
		print("Effects have no effect on the dead")
		return false
	
	return change_state(effect_type)
 
