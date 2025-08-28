extends DefaultContainer

# Function to add an item to a legs container, the item must be legs or it returns false
func add_item(item_to_add: Item) -> bool:
	if item_to_add is Legs and not item:
		item = item_to_add
		container.number_of_items+=1
		update_container()
		return true
	return false 
