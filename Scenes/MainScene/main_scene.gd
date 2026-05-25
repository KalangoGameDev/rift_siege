extends Node

const MAIN_MENU = preload("uid://77vays8evmd6")
const OPTIONS = preload("uid://dyn6137r0meut")
const UPGRADE = preload("uid://bkdq0eef5ogt2")
const GUI = preload("uid://6q8b0yd4w3fg")
const BULLET_SCENE = preload("res://Scenes/Bullet/bullet.tscn")
const TANK_SCENE = preload("res://Scenes/BattleScene/tank.tscn")

@onready var battle_scene: Node2D = %battle_scene
@onready var canvas: Node = %canvas

var remote_players: Dictionary = {}
var last_peers_data: Variant = []

func _ready() -> void:
	instantiate_main_menu()
	Player.main_scene = self
	battle_scene.main_scene = self

	Signaling.connected_to_server.connect(_on_connected_to_server)
	Signaling.peers_updated.connect(_on_peers_updated)
	NetworkManager.player_state_received.connect(_on_player_state_received)
	NetworkManager.player_shot_received.connect(_on_player_shot_received)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	call_deferred("_refresh_network_players")


var main_menu_scene: Node = null
func instantiate_main_menu() -> void:
	main_menu_scene = MAIN_MENU.instantiate()
	main_menu_scene.main_scene = self
	canvas.add_child(main_menu_scene)

var gui_scene: Node = null
func instantiate_gui_scene() -> void:
	gui_scene = GUI.instantiate()
	gui_scene.main_scene = self
	canvas.add_child(gui_scene)

var upgrade_scene: Node = null
func instantiate_upgrade_window() -> void:
	upgrade_scene = UPGRADE.instantiate()
	canvas.add_child(upgrade_scene)

func _refresh_network_players() -> void:
	if Signaling.my_id != 0:
		_configure_local_player(Signaling.my_id)
	if last_peers_data == [] and Signaling.peers_cache != []:
		last_peers_data = Signaling.peers_cache
	_spawn_known_peers()

func _on_connected_to_server(my_id: int) -> void:
	_configure_local_player(my_id)
	_spawn_known_peers()

func _on_peers_updated(peers_data: Variant) -> void:
	last_peers_data = peers_data
	_spawn_known_peers()

func _spawn_known_peers() -> void:
	var peer_ids: Array = []
	if last_peers_data is Array:
		peer_ids = last_peers_data
	elif last_peers_data is Dictionary:
		peer_ids = last_peers_data.keys()

	for peer_id_var in peer_ids:
		var peer_id := int(peer_id_var)
		if peer_id == 0 or peer_id == Signaling.my_id:
			continue
		_spawn_remote_player(peer_id)

func _configure_local_player(peer_id: int) -> void:
	if battle_scene and battle_scene.has_node("tank"):
		battle_scene.tank.set_player_mode(true, peer_id)

func _on_peer_connected(id: int) -> void:
	if id == Signaling.my_id:
		return
	_spawn_remote_player(id)

func _on_peer_disconnected(id: int) -> void:
	if remote_players.has(id):
		var player_node: Node = remote_players[id]
		if is_instance_valid(player_node):
			player_node.queue_free()
		remote_players.erase(id)
	elif battle_scene.remote_players.has_node(str(id)):
		battle_scene.remote_players.get_node(str(id)).queue_free()

func _spawn_remote_player(id: int) -> void:
	if battle_scene == null or battle_scene.remote_players == null:
		return
	if id == Signaling.my_id:
		return
	if battle_scene.remote_players.has_node(str(id)):
		return

	var character := TANK_SCENE.instantiate()
	character.name = str(id)
	character.set_player_mode(false, id)
	character.position = battle_scene.tank.position + Vector2(float(id % 4) * 48.0, 0.0)
	battle_scene.remote_players.add_child(character)
	remote_players[id] = character

func _on_player_state_received(peer_id: int, position: Vector2, cannon_rotation: float) -> void:
	if peer_id == Signaling.my_id:
		return

	var player_node := _get_remote_player(peer_id)
	if player_node == null:
		_spawn_remote_player(peer_id)
		player_node = _get_remote_player(peer_id)

	if player_node and player_node.has_method("apply_remote_state"):
		player_node.apply_remote_state(position, cannon_rotation)

func _on_player_shot_received(peer_id: int, origin: Vector2, direction: Vector2, damage: int) -> void:
	if peer_id == Signaling.my_id:
		return

	_spawn_network_bullet(origin, direction, damage, peer_id)

func _get_remote_player(id: int) -> Node:
	if remote_players.has(id):
		var player_node: Node = remote_players[id]
		if is_instance_valid(player_node):
			return player_node

	if battle_scene.remote_players and battle_scene.remote_players.has_node(str(id)):
		var node := battle_scene.remote_players.get_node(str(id))
		remote_players[id] = node
		return node

	return null

func _spawn_network_bullet(origin: Vector2, direction: Vector2, damage: int, owner_id: int) -> void:
	var bullet: Node = BULLET_SCENE.instantiate()
	bullet.damage = damage
	bullet.owner_id = owner_id
	get_tree().root.add_child(bullet)
	bullet.global_position = origin
	bullet.fire_direction(direction)
