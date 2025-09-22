extends Marker2D
@onready var sprite_2d: Sprite2D = $Sprite2D

func change_selected_object(newText: Texture) -> void:
	sprite_2d.texture = newText
