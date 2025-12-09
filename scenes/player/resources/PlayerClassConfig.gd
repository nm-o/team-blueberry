extends Resource
class_name PlayerClassConfig

@export var role_name: StringName = ""
@export var hp: int = 100
@export var movement_speed: float = 300.0
@export var attack: int = 10
@export var defense: int = 10

@export var label_role_text: String = ""
@export var starting_items: Array[String] = [] # rutas a scripts de ítems

# visuales por clase
@export var sprite_texture: Texture2D
@export var mouse_sprite_texture: Texture2D
