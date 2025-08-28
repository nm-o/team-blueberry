extends DefaultContainer

# Function to add an item to a chestplate container, the item must be a chestplate or it returns false
func add_item(item_to_add: Item) -> bool:
	if item_to_add is Chestplate and not item:
		container.number_of_items+=1
		item = item_to_add
		update_container()
		return true
	return false 
