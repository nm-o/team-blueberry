extends RigidBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area_2d: Area2D = $Area2D
@onready var item_name_label: Label = $ItemName

var item: Item

func _ready() -> void:
	item_name_label.visible = false

func update_item_drop():
	if item:
		sprite_2d.texture = item.texture
		item_name_label.text = item.name

func interact():
	Mouse.player.selected_areas.erase(self)
	Mouse.player.inventory.add_item(item)
	Mouse.player.manage_destroy_item_drop(item.drop_id)

func _on_area_2d_area_entered(area: Area2D) -> void:
	pass

func _on_area_2d_area_exited(area: Area2D) -> void:
	pass
