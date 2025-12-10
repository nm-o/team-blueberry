extends RigidBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area_2d: Area2D = $Area2D
@onready var interaction_name_label: Label = $InteractionName

var item: Item

func _ready() -> void:
	interaction_name_label.visible = false

func update_item_drop():
	if not item:
		return
	if not sprite_2d:
		sprite_2d = $Sprite2D
	if not sprite_2d:
		return
	sprite_2d.texture = load(item.texture)


func interact():
	Mouse.player.selected_areas.erase(self)
	Mouse.player.inventory.add_item(item)
	Mouse.player.manage_destroy_item_drop(item.drop_id)
	queue_free()
