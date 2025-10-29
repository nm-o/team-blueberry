extends CharacterBody2D
class_name Being

# Sistema de estados
var current_state: Global.States = Global.States.NORMAL
var state_timer: Timer = null

func _ready() -> void:
	_setup_state_system()

func _setup_state_system() -> void:
	state_timer = Timer.new()
	state_timer.one_shot = true
	state_timer.timeout.connect(_on_state_timeout)
	add_child(state_timer)

func apply_state(new_state: Global.States, duration: float) -> void:
	# No aplicar si ya está muerto
	if current_state == Global.States.DEAD:
		return
	
	# Cambiar al nuevo estado
	current_state = new_state
	
	# Reiniciar el timer
	if state_timer:
		state_timer.stop()
		state_timer.wait_time = duration
		state_timer.start()
	
	_on_state_changed(new_state)

func _on_state_timeout() -> void:
	var previous_state = current_state
	current_state = Global.States.NORMAL
	_on_state_changed(Global.States.NORMAL)
	_on_state_ended(previous_state)

func _on_state_changed(new_state: Global.States) -> void:
	# Override en clases hijas para efectos visuales
	pass

func _on_state_ended(ended_state: Global.States) -> void:
	# Override en clases hijas para cleanup
	pass

func is_frozen() -> bool:
	return current_state == Global.States.FROZEN

func is_poisoned() -> bool:
	return current_state == Global.States.POISONED

func can_move() -> bool:
	return current_state not in [Global.States.FROZEN, Global.States.DEAD]
