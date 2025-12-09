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

func activate(type: String, damage: int):
	if tween and tween.is_valid() or cooldown_timer.time_left != 0:
		return
	
	# Ahora manejamos el tipo de arma para configurar la animación y el daño
	var anim_speed: float = 1.0
	if type=="spear":
		anim_speed = 0.6
	elif type=="sword":
		anim_speed = 1.0
	elif type=="axe":
		anim_speed = 1.4

	hitbox.damage = damage
	do_attack_anim(anim_speed)

func do_attack_anim(speed_factor: float = 1.0):
	tween = create_tween()
	tween.tween_property(
		double_pivot, "rotation",
		double_pivot.rotation - deg_to_rad(35),
		attack_starting_cooldown * speed_factor
	)
	await tween.finished

	weapon_collision.disabled = false

	tween = create_tween()
	tween.tween_property(
		double_pivot, "rotation",
		double_pivot.rotation + deg_to_rad(50),
		0.07 * speed_factor
	)
	await tween.finished

	weapon_collision.disabled = true

	tween = create_tween()
	tween.tween_property(
		double_pivot, "rotation",
		double_pivot.rotation - deg_to_rad(15),
		0.2 * speed_factor
	)
	await tween.finished

	cooldown_timer.start(attack_cooldown * speed_factor)

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
	sprite_2d.rotation_degrees = 45
