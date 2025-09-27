extends Marker2D
@onready var sprite_2d: Sprite2D = $Sprite2D

func change_selected_object(newText: String) -> void:
	if newText == "":
		sprite_2d.texture = null
	else:
		sprite_2d.texture = load(newText)
