# res://autoloads/Combat.gd
extends Node

var actors: Dictionary[int, NodePath] = {}

func register_actor(id: int, path: NodePath) -> void:
	actors[id] = path
	print("Registered actor:", id, "->", path)

func unregister_actor(id: int) -> void:
	if actors.has(id):
		actors.erase(id)

@rpc("any_peer","reliable","call_local")
func request_damage(attacker_id: int, victim_id: int, damage: int) -> void:
	print("[CB] RPC request_damage from:", multiplayer.get_remote_sender_id(),
		  " data:", attacker_id, victim_id, damage)
	if not multiplayer.is_server():
		print("[CB] ignored on client; only server applies") 
		return
	_damage_authoritative(attacker_id, victim_id, damage)

func _damage_authoritative(attacker_id: int, victim_id: int, damage: int) -> void:
	print("[CB] AUTH damage:", attacker_id, "->", victim_id, " dmg:", damage) 
	var path: NodePath = actors.get(victim_id, NodePath(""))
	if path == NodePath(""):
		print("[CB] no path for id:", victim_id)
		return
	var victim_node: Node = get_node_or_null(path)
	if victim_node == null:
		print("[CB] node missing at:", path)
		return
	var hc: HealthComponent = victim_node.get_node_or_null("HealthComponent") as HealthComponent
	if hc == null:
		print("[CB] HealthComponent missing on node:", victim_node.name)
		return

	var before: int = hc.hp
	hc.apply_damage(damage)
	print("[CB] HP server:", before, "->", hc.hp, "/", hc.max_hp) 

	apply_hp_remote.rpc(victim_id, hc.hp, hc.max_hp) 

	if before > 0 and hc.hp == 0:
		print("[CB] death broadcast for id:", victim_id) 
		death_broadcast.rpc(victim_id)

@rpc("any_peer","reliable","call_local")
func apply_hp_remote(victim_id: int, hp: int, max_hp: int) -> void:
	var path: NodePath = actors.get(victim_id, NodePath(""))
	if path == NodePath(""):
		print("[CB] apply_hp_remote: no path for", victim_id)
		return
	var victim_node: Node = get_node_or_null(path)
	if victim_node == null:
		print("[CB] apply_hp_remote: node not found at", path) 
		return
	var hc: HealthComponent = victim_node.get_node_or_null("HealthComponent") as HealthComponent
	if hc:
		var before: int = hc.hp
		hc.hp = clamp(hp, 0, max_hp)
		print("[CB] client applied HP:", before, "->", hc.hp, "/", hc.max_hp,
			  " on peer:", multiplayer.get_unique_id())

@rpc("any_peer","reliable","call_local")
func death_broadcast(victim_id: int) -> void:
	var path: NodePath = actors.get(victim_id, NodePath(""))
	if path == NodePath(""):
		print("[CB] death_broadcast: no path for", victim_id) 
		return
	var victim_node: Node = get_node_or_null(path)
	if victim_node and victim_node.has_method("_apply_death_state"):
		print("[CB] death apply on peer:", multiplayer.get_unique_id(), " id:", victim_id)
		victim_node._apply_death_state()
