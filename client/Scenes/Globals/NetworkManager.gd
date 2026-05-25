extends Node

enum NetworkState {
	DISCONNECTED,
	SIGNALING,
	PEERING,
	CONNECTED
}

signal state_changed(new_state: NetworkState)
signal connection_established(id: int)
signal player_state_received(peer_id: int, position: Vector2, cannon_rotation: float)
signal player_shot_received(peer_id: int, origin: Vector2, direction: Vector2, damage: int)

var rtc_mp: WebRTCMultiplayerPeer
var peers: Dictionary = {}
var current_state: NetworkState = NetworkState.DISCONNECTED

var ice_config: Array = [
	{
		"urls": ["turn:173.212.207.80:3478"],
		"username": "nilbyte",
		"credential": "secret123"
	}
]

func _ready() -> void:
	Signaling.message_received.connect(_on_signaling_message)
	Signaling.connected_to_server.connect(_on_connected_to_signaling)
	Signaling.peers_updated.connect(_on_peers_updated)

func is_online() -> bool:
	return current_state >= NetworkState.SIGNALING

func is_host() -> bool:
	return Signaling.my_id == 1

func change_state(new_state: NetworkState) -> void:
	current_state = new_state
	state_changed.emit(current_state)
	print("NetworkManager: State Changed to ", NetworkState.keys()[current_state])

func start_network(server_url: String) -> void:
	print("NetworkManager: Starting network at ", server_url)
	change_state(NetworkState.SIGNALING)
	Signaling.connect_to_url(server_url)

func set_ice_configuration(urls: String, username: String = "", credential: String = "") -> void:
	ice_config.clear()
	if not urls.is_empty():
		var server: Dictionary = {"urls": [urls]}
		if not username.is_empty():
			server["username"] = username
		if not credential.is_empty():
			server["credential"] = credential
		ice_config.append(server)
	print("NetworkManager: Updated ICE config: ", ice_config)

func _on_peers_updated(peers_data: Variant) -> void:
	var active_peers: Array = []
	if peers_data is Array:
		active_peers = peers_data
	elif peers_data is Dictionary:
		active_peers = peers_data.keys()

	var my_id: int = Signaling.my_id
	if my_id == 0:
		return

	print("NetworkManager: Active peers updated: ", active_peers)

	for peer_id_var in active_peers:
		var peer_id: int = int(peer_id_var)
		if peer_id == my_id:
			continue
		if peers.has(peer_id):
			continue
		if my_id < peer_id:
			print("NetworkManager: Auto-connecting to ", peer_id)
			connect_to_peer(peer_id)

func _on_connected_to_signaling(my_id: int) -> void:
	rtc_mp = WebRTCMultiplayerPeer.new()
	var error: Error = rtc_mp.create_mesh(my_id)
	if error != OK:
		push_error("NetworkManager: Failed to create mesh: %s" % error)
		return

	multiplayer.multiplayer_peer = rtc_mp
	print("NetworkManager: Mesh initialized with ID: ", my_id)

	change_state(NetworkState.PEERING)
	connection_established.emit(my_id)

func connect_to_peer(target_id: int) -> void:
	if peers.has(target_id):
		return

	print("NetworkManager: Initiating connection to ", target_id)
	var peer: WebRTCPeerConnection = _create_peer_connection(target_id)
	peer.create_offer()

func _create_peer_connection(id: int) -> WebRTCPeerConnection:
	var peer: WebRTCPeerConnection = WebRTCPeerConnection.new()
	peer.initialize({
		"iceServers": ice_config
	})

	peer.session_description_created.connect(_on_session_description_created.bind(id))
	peer.ice_candidate_created.connect(_on_ice_candidate_created.bind(id))

	peers[id] = peer
	if rtc_mp:
		rtc_mp.add_peer(peer, id)

	return peer

func broadcast_player_state(peer_id: int, position: Vector2, cannon_rotation: float) -> void:
	if multiplayer.multiplayer_peer == null:
		return
	receive_player_state.rpc(peer_id, position, cannon_rotation)

func broadcast_player_shot(peer_id: int, origin: Vector2, direction: Vector2, damage: int) -> void:
	if multiplayer.multiplayer_peer == null:
		return
	receive_player_shot.rpc(peer_id, origin, direction, damage)

@rpc("any_peer", "unreliable")
func receive_player_state(peer_id: int, position: Vector2, cannon_rotation: float) -> void:
	player_state_received.emit(peer_id, position, cannon_rotation)

@rpc("any_peer", "reliable")
func receive_player_shot(peer_id: int, origin: Vector2, direction: Vector2, damage: int) -> void:
	player_shot_received.emit(peer_id, origin, direction, damage)

func _on_signaling_message(type: String, data: Variant, sender_id: int) -> void:
	match type:
		"offer":
			print("NetworkManager: Received offer from ", sender_id)
			var peer: WebRTCPeerConnection
			if peers.has(sender_id):
				peer = peers[sender_id]
			else:
				peer = _create_peer_connection(sender_id)
			peer.set_remote_description("offer", data)

		"answer":
			print("NetworkManager: Received answer from ", sender_id)
			if peers.has(sender_id):
				peers[sender_id].set_remote_description("answer", data)

		"candidate":
			if peers.has(sender_id):
				var parts: PackedStringArray = str(data).split(":", true, 2)
				if parts.size() == 3:
					peers[sender_id].add_ice_candidate(parts[0], int(parts[1]), parts[2])

func _on_session_description_created(type: String, sdp: String, id: int) -> void:
	peers[id].set_local_description(type, sdp)
	Signaling.send(type, sdp, id)

func _on_ice_candidate_created(mid: String, index: int, sdp: String, id: int) -> void:
	Signaling.send("candidate", "%s:%d:%s" % [mid, index, sdp], id)
