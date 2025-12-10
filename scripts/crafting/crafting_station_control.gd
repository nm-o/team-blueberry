extends Control
class_name CraftingControl

var current_items: Array[String] = []
var recipes

func super_ready() -> void:
	var i = 0
	for child in get_children():
		if child.get_class() != "Button" and child.get_class() != "MarginContainer":
			child.slot_number = i
			i += 1
	for j in range(i):
		current_items.append("")


func _on_craft_button_pressed() -> void:
	if recipes.has(current_items):
		AudioController.play_button_pressed()
		var winning_item = recipes[current_items]
		var added = false
		for child in get_children():
			if child.get_class() != "Button" and child.get_class() != "MarginContainer":
				if child.item:
					child.remove_item()
				if not added:
					added = child.add_item(winning_item.new())
		if not added:
			Mouse.player.inventory.add_item(winning_item.new())
