extends DefaultContainer

# Function to add an item to a helmet container, the item must be a helmet or it returns false
func add_item(item_to_add: Item) -> bool:
	if item_to_add is Helmet and not item:
		container.number_of_items+=1
		item = item_to_add
		update_container()
		
		# Manejamos la actualizacion del defense_modifier
		print("add helmet")
		Mouse.update_modifier(0, item.armor_modifier)
		
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
	print("remove helmet")
	Mouse.update_modifier(0, 0)
