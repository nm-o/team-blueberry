extends CharacterBody2D
class_name Being

# Sistema de estados
var current_state: Global.States = Global.States.NORMAL
var state_timer: Timer = null

# Sistema de veneno
var poison_timer: Timer = null
var poison_damage: int = 5
var poison_tick_interval: float = 1.0

func _ready() -> void:
	_setup_state_system()

func _setup_state_system() -> void:
	# Timer para duración de estados
	state_timer = Timer.new()
	state_timer.one_shot = true
	state_timer.timeout.connect(_on_state_timeout)
	add_child(state_timer)
	
	# Timer para daño de veneno
	poison_timer = Timer.new()
	poison_timer.timeout.connect(_on_poison_tick)
	add_child(poison_timer)

func apply_state(new_state: Global.States, duration: float) -> void:
	# No aplicar si ya está muerto
	if current_state == Global.States.DEAD:
		return
	
	# Cambiar al nuevo estado
	current_state = new_state
	
	# Reiniciar el timer de duración
	if state_timer:
		state_timer.stop()
		state_timer.wait_time = duration
		state_timer.start()
	
	# Iniciar daño de veneno si es necesario
	if new_state == Global.States.POISONED:
		_start_poison_damage()
	
	_on_state_changed(new_state)

func _start_poison_damage() -> void:
	if poison_timer:
		poison_timer.stop()
		poison_timer.wait_time = poison_tick_interval
		poison_timer.start()

func _on_poison_tick() -> void:
	# Solo aplicar daño si sigue envenenado
	if current_state == Global.States.POISONED:
		_apply_poison_damage()
		# Reiniciar para el siguiente tick
		if poison_timer:
			poison_timer.start()

func _apply_poison_damage() -> void:
	# Override en Player o Enemy para aplicar daño
	pass

func _on_state_timeout() -> void:
	var previous_state = current_state
	current_state = Global.States.NORMAL
	_on_state_changed(Global.States.NORMAL)
	_on_state_ended(previous_state)

func _on_state_changed(new_state: Global.States) -> void:
	# Override en clases hijas para efectos visuales
	pass

func _on_state_ended(ended_state: Global.States) -> void:
	# Detener veneno cuando termine el efecto
	if ended_state == Global.States.POISONED:
		if poison_timer:
			poison_timer.stop()

func is_frozen() -> bool:
	return current_state == Global.States.FROZEN

func is_poisoned() -> bool:
	return current_state == Global.States.POISONED

func can_move() -> bool:
	return current_state not in [Global.States.FROZEN, Global.States.DEAD]
