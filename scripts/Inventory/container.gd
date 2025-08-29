extends PanelContainer

@onready var item_description: RichTextLabel = $"../Description"
@onready var item_container: Control = $".."
@onready var number_label: Label = $"../Number"

var number_of_items: int = 0
var mouse_in: bool = false

func _ready():
	self.mouse_filter = Control.MOUSE_FILTER_PASS
	item_description.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	item_description.visible = false

func _on_mouse_entered():
	mouse_in = true
	Mouse.on_ui = true
	if number_of_items > 1:
		Mouse.to_stack = true
	else:
		Mouse.to_stack = false
	Mouse.new_container = self
	item_description.visible = true

func _on_mouse_exited():
	mouse_in = false
	Mouse.on_ui = false
	Mouse.new_container = null
	item_description.visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click") and item_container.item and mouse_in and not Mouse.item:
		if item_container.get_script().resource_path.get_file().get_basename() == "hotbar_container":
			item_container.owner.select_container(item_container.get_index())
		Mouse.item = item_container.item
		if number_of_items > 1:
			Mouse.from_stack = true
		else:
			Mouse.from_stack = false
		Mouse.player.mouse_sprite.texture = Mouse.item.texture
		Mouse.old_container = self
		item_container.remove_item()
	if Input.is_action_just_released("left_click") and Mouse.item:
		if Mouse.new_container:
			if Mouse.new_container.item_container.item and not Mouse.from_stack:
				var temp = Mouse.new_container.item_container.item
				Mouse.new_container.item_container.remove_item()
				var added = Mouse.new_container.item_container.add_item(Mouse.item)
				if added and Mouse.item.get_script().resource_path.get_file().get_basename() != temp.get_script().resource_path.get_file().get_basename():
					var added_2 = Mouse.old_container.item_container.add_item(temp)
					if not added_2:
						Mouse.old_container.item_container.add_item(Mouse.new_container.item_container.item)
						Mouse.new_container.item_container.add_item(temp)
				elif Mouse.item.get_script().resource_path.get_file().get_basename() == temp.get_script().resource_path.get_file().get_basename():
					var added_equal = Mouse.new_container.item_container.add_item(temp)
					if not added_equal:
						Mouse.old_container.item_container.add_item(Mouse.item)
				else:
					Mouse.old_container.item_container.add_item(Mouse.item)
					Mouse.new_container.item_container.add_item(temp)
			else:
				var added = Mouse.new_container.item_container.add_item(Mouse.item)
				if not added:
						Mouse.old_container.item_container.add_item(Mouse.item)
		else:
			Mouse.player.manage_drop(Mouse.item.get_script().resource_path, Mouse.get_drop_id())
		Mouse.player.mouse_sprite.texture = null
		Mouse.item = null
		Mouse.old_container = null
