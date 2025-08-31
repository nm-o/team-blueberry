extends DefaultContainer

var slot_number: int

# Function to add an item to a crafting table container
func add_item(item_to_add: Item) -> bool:
	if item:
		if item.get_script().resource_path.get_file().get_basename() == item_to_add.get_script().resource_path.get_file().get_basename():
			if container.number_of_items < item.max_number:
				container.number_of_items += 1
				update_container()
				return true
			else:
				return false
		else:
			return false
	get_parent().current_items[slot_number] = item_to_add.name
	Debug.log(get_parent().current_items)
	item = item_to_add
	container.number_of_items += 1
	update_container()
	return true

# Removes an item from the container
func remove_item():
	if container.number_of_items > 1:
		container.number_of_items -=1
		update_container()
		return
	get_parent().current_items[slot_number] = ""
	Debug.log(get_parent().current_items)
	container.number_of_items -= 1
	update_container()
	item = null
	description.text = ""
	texture.texture = null
	
