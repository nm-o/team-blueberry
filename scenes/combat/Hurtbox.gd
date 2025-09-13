# res://scenes/combat/Hurtbox.gd
extends Area2D
class_name Hurtbox

@export var health: HealthComponent
@export var team: StringName = &"player" # o "enemy"

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area: Area2D) -> void:
	if not (area is Hitbox):
		return
	var hb: Hitbox = area
	print("Hurtbox overlap PVP. hb.team=", hb.team, " vs team=", team, " dmg=", hb.damage)

	# Obtener IDs de víctima y atacante
	var victim := owner
	var victim_id: int = -1
	if victim is Player:
		var p: Player = victim
		victim_id = p.player_id

	var attacker_id: int = hb.get_attacker_id()

	# Evitar golpearse a sí mismo
	if attacker_id == victim_id and attacker_id != -1:
		return

	print("PVP Damage req -> attacker:", attacker_id, " victim:", victim_id)

	# Enviar al servidor autoritativo
	if multiplayer.is_server():
		Combat._damage_authoritative(attacker_id, victim_id, hb.damage)  # aplica en host [11]
	else:
		Combat.request_damage.rpc_id(Game.SERVER_ID, attacker_id, victim_id, hb.damage)  # PVP/PVE [12]
