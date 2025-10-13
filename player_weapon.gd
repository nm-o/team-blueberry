extends Node2D

@onready var sprite_2d: Sprite2D = $DoublePivot/Sprite2D
@onready var hitbox: Hitbox = $DoublePivot/Hitbox
@onready var weapon_collision: CollisionShape2D = $DoublePivot/Hitbox/CollisionShape2D
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var double_pivot: Node2D = $DoublePivot

var item_sprite: Texture2D
var attack_cooldown: float = 0.2
var attack_starting_cooldown: float = 0.2
var tween: Tween

func activate():
	if tween and tween.is_valid() or cooldown_timer.time_left != 0:
		return
	tween = create_tween()
	tween.tween_property(double_pivot, "rotation", double_pivot.rotation - deg_to_rad(35), attack_starting_cooldown)
	await tween.finished
	weapon_collision.disabled = false
	tween = create_tween()
	tween.tween_property(double_pivot, "rotation", double_pivot.rotation + deg_to_rad(50), 0.07)
	await tween.finished
	weapon_collision.disabled = true
	tween = create_tween()
	tween.tween_property(double_pivot, "rotation", double_pivot.rotation - deg_to_rad(15), 0.2)
	await tween.finished
	cooldown_timer.start(attack_cooldown)

@rpc("authority", "call_local", "reliable")
func update_item_sprite_server(sprite_path: String):
	update_item_sprite.rpc(sprite_path)
@rpc("any_peer", "call_local", "reliable")
func update_item_sprite(sprite_path: String):
	if sprite_path == "":
		sprite_2d.texture = null
		return
	sprite_2d.texture = load(sprite_path)
	sprite_2d.position.x = (sprite_2d.texture.get_size().y / 2) + 15
	weapon_collision.shape.size = Vector2(sprite_2d.texture.get_size().x + 2 ,sprite_2d.texture.get_size().y + 2)
	hitbox.position.x = sprite_2d.position.x
