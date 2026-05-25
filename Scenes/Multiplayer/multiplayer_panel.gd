extends PanelContainer

@onready var status_label: Label = %StatusLabel
@onready var adv_settings_check: CheckBox = %AdvSettingsButton
@onready var advanced_container: VBoxContainer = %AdvancedContainer
@onready var server_url_input: LineEdit = %ServerUrlInput
@onready var turn_url_input: LineEdit = %TurnUrlInput
@onready var turn_user_input: LineEdit = %TurnUserInput
@onready var turn_pass_input: LineEdit = %TurnPassInput
@onready var secret_key_input: LineEdit = %SecretKeyInput
@onready var lobby_list: ItemList = %LobbyList
@onready var connect_button: Button = %ConnectButton

func _ready() -> void:
	adv_settings_check.toggled.connect(_on_adv_settings_toggled)
	connect_button.pressed.connect(_on_connect_pressed)

	server_url_input.text = Signaling.server_url
	secret_key_input.text = Signaling.server_secret_key

	turn_url_input.text_changed.connect(_on_turn_config_changed)
	turn_user_input.text_changed.connect(_on_turn_config_changed)
	turn_pass_input.text_changed.connect(_on_turn_config_changed)
	secret_key_input.text_changed.connect(_on_secret_key_changed)

	Signaling.connected_to_server.connect(_on_connected)
	Signaling.peers_updated.connect(_on_peers_updated)
	NetworkManager.state_changed.connect(_on_network_state_changed)

	_sync_status()

func _on_connect_pressed() -> void:
	_apply_network_settings()
	NetworkManager.start_network(server_url_input.text.strip_edges())

func _apply_network_settings() -> void:
	Signaling.server_secret_key = secret_key_input.text.strip_edges()

	var turn_url := turn_url_input.text.strip_edges()
	if turn_url.is_empty():
		NetworkManager.set_ice_configuration("")
	else:
		NetworkManager.set_ice_configuration(
			turn_url,
			turn_user_input.text.strip_edges(),
			turn_pass_input.text.strip_edges()
		)

func _on_secret_key_changed(new_key: String) -> void:
	Signaling.server_secret_key = new_key.strip_edges()

func _on_turn_config_changed(_text: String) -> void:
	_apply_network_settings()

func _on_adv_settings_toggled(toggled_on: bool) -> void:
	advanced_container.visible = toggled_on

func _on_network_state_changed(state: NetworkManager.NetworkState) -> void:
	match state:
		NetworkManager.NetworkState.DISCONNECTED:
			status_label.text = "DISCONNECTED"
			status_label.modulate = Color.RED
		NetworkManager.NetworkState.SIGNALING:
			status_label.text = "CONNECTING..."
			status_label.modulate = Color.YELLOW
		NetworkManager.NetworkState.PEERING:
			status_label.text = "PEERING..."
			status_label.modulate = Color.CYAN
		NetworkManager.NetworkState.CONNECTED:
			status_label.text = "CONNECTED"
			status_label.modulate = Color.GREEN

func _on_connected(my_id: int) -> void:
	status_label.text = "ONLINE (ID: %d)" % my_id
	status_label.modulate = Color.GREEN
	_sync_status()

func _on_peers_updated(peers_data: Variant) -> void:
	lobby_list.clear()

	var peers: Array = []
	if peers_data is Array:
		peers = peers_data
	elif peers_data is Dictionary:
		peers = peers_data.keys()

	for peer_id in peers:
		lobby_list.add_item("Peer %s" % str(peer_id))

	_sync_status()

func _sync_status() -> void:
	if Signaling.my_id != 0:
		status_label.text = "ONLINE (ID: %d)" % Signaling.my_id
		status_label.modulate = Color.GREEN
	elif NetworkManager.current_state == NetworkManager.NetworkState.SIGNALING:
		status_label.text = "CONNECTING..."
		status_label.modulate = Color.YELLOW
	else:
		status_label.text = "OFFLINE"
		status_label.modulate = Color.WHITE
