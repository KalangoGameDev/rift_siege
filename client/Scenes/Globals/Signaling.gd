extends Node

signal message_received(type: String, data: Variant, sender_id: int)
signal connected_to_server(my_id: int)
signal peers_updated(peers: Variant)

var socket: WebSocketPeer = WebSocketPeer.new()
var is_connected_to_server := false
var my_id: int = 0
var peers_cache: Variant = []

var server_url := "ws://localhost:8080/ws"
var server_secret_key := "secret123"
var reconnect_timer: Timer

func _ready() -> void:
	reconnect_timer = Timer.new()
	reconnect_timer.wait_time = 3.0
	reconnect_timer.one_shot = true
	reconnect_timer.timeout.connect(_on_reconnect_timer_timeout)
	add_child(reconnect_timer)

	call_deferred("connect_to_url", server_url)

func connect_to_url(url: String) -> void:
	server_url = url.strip_edges()
	if server_url.is_empty():
		return

	var final_url: String = server_url
	if not server_secret_key.is_empty():
		if "?" in final_url:
			final_url += "&key=" + server_secret_key.uri_encode()
		else:
			final_url += "?key=" + server_secret_key.uri_encode()

	print("Signaling: Connecting to ", final_url)
	socket.connect_to_url(final_url)

func _on_reconnect_timer_timeout() -> void:
	print("Signaling: Attempting to reconnect...")
	connect_to_url(server_url)

func _process(_delta: float) -> void:
	socket.poll()
	var state: int = socket.get_ready_state()

	if state == WebSocketPeer.STATE_OPEN:
		if not is_connected_to_server:
			is_connected_to_server = true
			print("Connected to Signaling Server")
			reconnect_timer.stop()

		while socket.get_available_packet_count() > 0:
			var packet: PackedByteArray = socket.get_packet()
			var data_str: String = packet.get_string_from_utf8()
			if data_str.is_empty():
				continue
			var parsed: Variant = JSON.parse_string(data_str)
			if parsed is Dictionary:
				_handle_message(parsed)

	elif state == WebSocketPeer.STATE_CLOSED:
		if is_connected_to_server:
			is_connected_to_server = false
			print("Disconnected from Signaling Server")
			if reconnect_timer.is_stopped():
				reconnect_timer.start()
		elif reconnect_timer.is_stopped():
			reconnect_timer.start()

func send(type: String, data: Variant, target_id: int = 0) -> void:
	if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return

	var msg: Dictionary = {
		"type": type,
		"data": data,
		"target": target_id
	}
	socket.send_text(JSON.stringify(msg))

func _handle_message(msg: Dictionary) -> void:
	if not msg.has("type"):
		return

	var type: String = str(msg["type"])
	var data: Variant = msg.get("data")
	var sender := int(msg.get("sender", 0))

	match type:
		"id":
			my_id = int(data)
			connected_to_server.emit(my_id)
			print("My ID is: ", my_id)
		"peers":
			peers_cache = data
			peers_updated.emit(data)
		_:
			message_received.emit(type, data, sender)
