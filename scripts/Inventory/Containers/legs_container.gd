extends DefaultContainer

# Function to add an item to a legs container, the item must be legs or it returns false
func add_item(item_to_add: Item) -> bool:
	if item_to_add is Legs and not item:
		item = item_to_add
		container.number_of_items+=1
		update_container()

		# Manejamos la actualizacion del defense_modifier
		print("add legs")
		Mouse.update_modifier(2, item.armor_modifier)

		return true
	return false 

func remove_item():
	if container.number_of_items > 1:
		container.number_of_items -=1
		update_container()
		return
	container.number_of_items -= 1
	update_container()
	item = null
	description.text = ""
	texture.texture = null
	
	# Manejamos la actualizacion del defense_modifier
	print("remove legs")
	Mouse.update_modifier(2, 0)
