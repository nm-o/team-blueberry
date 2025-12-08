extends Area2D
class_name Hurtbox

@export var health: HealthComponent
@export var team: StringName = &"player" # o "enemy"
@export var mine: bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:

	if not (area is Hitbox):
		return

	var hb: Hitbox = area

	if mine:
		owner.get_attacked(hb.damage)
		hb.attack(owner)
	else:
		var victim := owner
		var victim_id: int = -1
		if victim is Player:
			victim_id = (victim as Player).player_id
		var attacker_id: int = hb.get_attacker_id()

		if attacker_id == victim_id and attacker_id != -1:
			return

		if multiplayer.is_server():
			Combat._damage_authoritative(attacker_id, victim_id, hb.damage)
		else:
			Combat.request_damage.rpc_id(Game.SERVER_ID, attacker_id, victim_id, hb.damage)
