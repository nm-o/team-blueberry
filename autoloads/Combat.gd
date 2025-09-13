# res://autoloads/Combat.gd
extends Node

var actors: Dictionary[int, NodePath] = {}

func register_actor(id: int, path: NodePath) -> void:
	actors[id] = path
	print("Registered actor:", id, "->", path)  # confirma registro local [3]

func unregister_actor(id: int) -> void:
	if actors.has(id):
		actors.erase(id)



@rpc("any_peer","reliable","call_local")
func request_damage(attacker_id: int, victim_id: int, damage: int) -> void:
	print("RPC request_damage from:", multiplayer.get_remote_sender_id(), " data:", attacker_id, victim_id, damage)
	if not multiplayer.is_server():
		return
	_damage_authoritative(attacker_id, victim_id, damage)

func _damage_authoritative(attacker_id: int, victim_id: int, damage: int) -> void:
	print("AUTH damage:", attacker_id, "->", victim_id, " dmg:", damage)
	var path: NodePath = actors.get(victim_id, NodePath(""))
	if path == NodePath(""):
		print("No actor path for id:", victim_id); return
	var victim_node: Node = get_node_or_null(path)
	if victim_node == null:
		print("Victim node not found at:", path); return
	var hc: HealthComponent = victim_node.get_node_or_null("HealthComponent") as HealthComponent
	if hc == null:
		print("HealthComponent not found on victim"); return
	hc.apply_damage(damage)
	print("Victim HP now:", hc.hp, "/", hc.max_hp)
	_update_hp.rpc(victim_id, hc.hp, hc.max_hp)

@rpc("any_peer", "reliable", "call_local")
func _update_hp(victim_id: int, hp: int, max_hp: int) -> void:
	var path: NodePath = actors.get(victim_id, NodePath(""))  # tipado explícito [web:130]
	if path == NodePath(""):
		return
	var victim_node: Node = get_node_or_null(path)
	if victim_node == null:
		return
	var hc: HealthComponent = victim_node.get_node_or_null("HealthComponent") as HealthComponent
	if hc:
		hc.hp = clamp(hp, 0, max_hp)  # tipado de parámetros evita Variant [web:130]
