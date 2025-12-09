extends CanvasLayer

@onready var inventory_containers: Control = $InventoryContainers
@onready var backpack_containers: Control = $BackpackContainers
@onready var hotbar_containers: Control = $HotbarContainers
@onready var player: Player = $".."
@onready var health_bar: ProgressBar = $HealthBar
@onready var hp_label: Label = $HealthBar/Label
@onready var players_ready: VBoxContainer = $PlayersReady
@onready var teleport_timer_label: Label = $TeleportTimerLabel
@onready var teleport_timer: Timer = $TeleportTimer
@onready var black_screen: ColorRect = $BlackScreen
@onready var victory_label: Label = $VictoryLabel
@onready var defeat_label: Label = $DefeatLabel
@onready var super_victory_label: RichTextLabel = $SuperVictoryLabel
@onready var inventory_back: MarginContainer = $InventoryBack
@onready var current_status: Sprite2D = $CurrentStatus
@onready var protect_bar: ProgressBar = $ProtectBar

@export var max_hotbar_containers: int = 3

var selected_container_number: int = 0
var stop_countdown: bool = false

func _ready() -> void:
	Mouse.on_teleport.connect(_add_label)
	Mouse.exited_teleport.connect(_destroy_label)
	Mouse.teleport_timer_started.connect(_start_countdown)
	Mouse.teleport_timer_stopped.connect(_stop_countdown)
	Mouse.teleport_started.connect(_start_teleport_animation)
	Mouse.boss_dead.connect(_victory_ui)
	Mouse.defeat_ui.connect(_defeat_ui)
	Mouse.super_victory.connect(_super_victory_ui)
	for players in Game.players:
		var label = Label.new()
		label.add_theme_font_size_override("font_size", 26)
		players_ready.add_child(label)
		label.MOUSE_FILTER_IGNORE
	
	protect_bar.max_value = 1
	protect_bar.value = 0

func _physics_process(delta: float) -> void:
	hp_label.text = str(health_bar.value*10)
	protect_bar.value = player.class_config.defense_modifier

func _super_victory_ui():
	var tween: Tween = create_tween()
	tween.tween_property(super_victory_label, "modulate", Color(1,1,1,1), 1).set_ease(Tween.EASE_IN)
	tween.tween_property(super_victory_label, "modulate", Color(1,1,1,1), 4)
	tween.tween_property(super_victory_label, "modulate", Color(1,1,1,0), 1)
	await tween.finished
	defeat_label.modulate = Color(0,0,0,0)
func _defeat_ui():
	var tween: Tween = create_tween()
	tween.tween_property(defeat_label, "modulate", Color(0,0,0,1), 1).set_ease(Tween.EASE_IN)
	tween.tween_property(defeat_label, "modulate", Color(0.753, 0.0, 0.0, 1.0), 1)
	tween.tween_property(defeat_label, "modulate", Color(0.753, 0.0, 0.0, 1.0), 1)
	tween.tween_property(defeat_label, "modulate", Color(0.753, 0.0, 0.0, 0), 1)
	await tween.finished
	defeat_label.modulate = Color(1,1,1,0)
func _victory_ui():
	var tween: Tween = create_tween()
	tween.tween_property(victory_label, "modulate", Color(0,0,0,1), 1).set_ease(Tween.EASE_IN)
	tween.tween_property(victory_label, "modulate", Color(0.955, 0.801, 0.0, 1.0), 1)
	tween.tween_property(victory_label, "modulate", Color(0.955, 0.801, 0.0, 1.0), 2)
	tween.tween_property(victory_label, "modulate", Color(0.955, 0.801, 0.0, 0), 1)
	await tween.finished
	victory_label.modulate = Color(1,1,1,0)

func _start_teleport_animation(_to_coliseum):
	var tween: Tween = create_tween()
	tween.tween_property(black_screen, "modulate", Color(0,0,0,1), 2)
	tween.tween_property(black_screen, "modulate", Color(0,0,0,1), 1)
	tween.tween_property(black_screen, "modulate", Color(0,0,0,0), 1)

func _start_countdown(time):
	stop_countdown = false
	teleport_timer_label.visible = true
	teleport_timer.start(time)
	for i in range(time, 0, -1):
		if stop_countdown:
			break
		teleport_timer_label.text = str(i)
		await get_tree().create_timer(1.0).timeout
func _stop_countdown():
	stop_countdown = true
	teleport_timer_label.visible = false
			
func _destroy_label(player_id):
	var teleporting_player = Game.get_player(player_id)
	for label in players_ready.get_children():
		if label.text == teleporting_player.name + "   READY":
			label.text = ""
			return
func _add_label(player_id):
	var teleporting_player = Game.get_player(player_id)
	for label in players_ready.get_children():
		if label.text == "":
			label.text = teleporting_player.name + "   READY"
			return

# Gets the current selected container in the hotbar
func search_selected_container():
	var containers = hotbar_containers.get_children()
	var i = 0
	for container in containers:
		if container.selected:
			selected_container_number = i
			return
		i+=1

# Selects a container from the hotbar using a number as id
func select_container(num: int):
	var container = hotbar_containers.get_child(num)
	_deselect_containers()
	container.selected = true
	container.selector.visible = true
	selected_container_number = num
	Mouse.player.selected_container_number = num
	if container.item:
		Mouse.player.selected_item = container.item
		Mouse.player.manage_update_item_sprite(container.item.texture)
	else:
		Mouse.player.selected_item = null
		Mouse.player.manage_update_item_sprite("")

# Deselecta all the containers in the hotbar
func _deselect_containers():
	var containers = hotbar_containers.get_children()
	for container in containers:
		container.selected = false
		container.selector.visible = false

# Funcition that changes the visibility of the inventory
func change_visibility():
	inventory_containers.visible = not inventory_containers.visible
	backpack_containers.visible = not backpack_containers.visible
	inventory_back.visible = not inventory_back.visible

	Mouse.player.is_inventory_open = inventory_containers.visible

# Function to add an item into the inventory
func add_item(item: Item):
	var containers = hotbar_containers.get_children()
	for container in containers:
		var is_true = container.add_item(item)
		if is_true:
			return
	var containers_2 = backpack_containers.get_children()
	for container in containers_2:
		var is_true = container.add_item(item)
		if is_true:
			return
	Mouse.player.manage_drop(item.get_script().resource_path, Mouse.get_drop_id())
	

# Function to manage the status effect icon 
func change_status(new_status: Global.States):
	if new_status == Global.States.HEALING:
		current_status.frame = 1
	elif new_status == Global.States.FROZEN:
		current_status.frame = 2
	elif new_status == Global.States.POISONED:
		current_status.frame = 3
	elif new_status == Global.States.HEALING_2:
		current_status.frame = 1
	elif new_status == Global.States.POISONED_2:
		current_status.frame = 2
	else:
		current_status.frame = 0


func consume_hotbar_slot(index: int) -> void:
	var containers = hotbar_containers.get_children()
	if index < 0 or index >= containers.size():
		return

	var slot = containers[index]  # hotbar_container
	if not slot.item:
		return

	var panel: PanelContainer = slot.get_node("Container")
	panel.consume_one()
