extends PanelContainer

@onready var item_description: RichTextLabel = $"../Description"
@onready var item_container: Control = $".."

var mouse_in: bool = false

func _ready():
	item_description.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	item_description.visible = false

func _on_mouse_entered():
	mouse_in = true
	Mouse.new_container = self
	item_description.visible = true

func _on_mouse_exited():
	mouse_in = false
	Mouse.new_container = null
	item_description.visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click") and item_container.item and mouse_in and not Mouse.item:
		Mouse.item = item_container.item
		Mouse.old_container = self
		item_container.remove_item()
	if Input.is_action_just_released("left_click") and Mouse.item:
		if Mouse.new_container:
			if Mouse.new_container.item_container.item:
				var temp = Mouse.new_container.item_container.item
				Mouse.new_container.item_container.remove_item()
				var added = Mouse.new_container.item_container.add_item(Mouse.item)
				if added:
					var added_2 = Mouse.old_container.item_container.add_item(temp)
					if not added_2:
						Mouse.old_container.item_container.add_item(Mouse.new_container.item_container.item)
						Mouse.new_container.item_container.add_item(temp)
				else:
					Mouse.old_container.item_container.add_item(Mouse.item)
					Mouse.new_container.item_container.add_item(temp)
			else:
				var added = Mouse.new_container.item_container.add_item(Mouse.item)
				if not added:
						Mouse.old_container.item_container.add_item(Mouse.item)
		else:
			Mouse.old_container.item_container.add_item(Mouse.item)
		Mouse.item = null
		Mouse.old_container = null
