# res://scenes/combat/Hurtbox.gd
extends Area2D
class_name Hurtbox

@export var health: HealthComponent
@export var team: StringName = &"player" # o "enemy"
@export var mine: bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if mine:
		var hitbox = area as Hitbox
		await owner.get_attacked(hitbox.damage)
	else:
		if not (area is Hitbox):
			return
		var hb: Hitbox = area
		var victim := owner
		var victim_id: int = -1
		if victim is Player:
			victim_id = (victim as Player).player_id
		var attacker_id: int = hb.get_attacker_id()

		#print("\n[HB] overlap PVP hb.team=", hb.team, " vs team=", team, " dmg=", hb.damage) 
		#print("[HB] req -> attacker:", attacker_id, " victim:", victim_id) 

		if attacker_id == victim_id and attacker_id != -1:
			#print("[HB] self-hit blocked attacker==victim:", attacker_id) 
			return

		if multiplayer.is_server():
			#print("[HB] server applying directly") 
			Combat._damage_authoritative(attacker_id, victim_id, hb.damage)
		else:
			#print("[HB] client sending RPC to server:", Game.SERVER_ID)
			Combat.request_damage.rpc_id(Game.SERVER_ID, attacker_id, victim_id, hb.damage)
