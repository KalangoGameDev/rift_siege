extends CharacterBody2D

@export var is_local_player: bool = true

var network_peer_id: int = 1
var move_speed: float

@onready var muzzle: Node2D = $cannon/muzzle
const BULLET = preload("uid://bknpcmye04u3x")
@onready var cannon: Sprite2D = $cannon
@onready var camera: Camera2D = $Camera2D

var fire_rate_timer: Timer
var attack_ready: bool = true
var reload_timer: Timer
var reloading: bool = false

func _ready() -> void:
	set_player_mode(is_local_player)

	if is_local_player:
		fire_rate_timer = Timer.new()
		fire_rate_timer.one_shot = true
		fire_rate_timer.timeout.connect(on_firerate_timeout)
		add_child(fire_rate_timer)

		reload_timer = Timer.new()
		reload_timer.one_shot = true
		reload_timer.timeout.connect(on_reload_timeout)
		add_child(reload_timer)

		Player.movement_speed_updated_signal.connect(_update_ms)
		_update_ms()
	else:
		move_speed = 0.0

func set_player_mode(local_player: bool, peer_id: int = 0) -> void:
	is_local_player = local_player
	if peer_id > 0:
		network_peer_id = peer_id
	elif network_peer_id <= 0:
		network_peer_id = multiplayer.get_unique_id() if multiplayer.has_multiplayer_peer() else 1

		set_multiplayer_authority(network_peer_id)
		if is_local_player:
			if is_node_ready() and camera:
				camera.make_current()
		elif is_node_ready() and camera and camera.is_current():
			camera.clear_current()

func _get_current_peer_id() -> int:
	if Signaling.my_id != 0:
		return Signaling.my_id
	return network_peer_id

func _update_ms() -> void:
	move_speed = Player.movement_speed

func _input(event: InputEvent) -> void:
	if not is_local_player or not Gamecontrol.in_game:
		return

	if event.is_action_pressed("shoot"):
		shoot()

func _physics_process(_delta: float) -> void:
	if not is_local_player or not Gamecontrol.in_game:
		return

	var direction := Input.get_axis("move_left", "move_right")
	move_speed = Player.movement_speed
	velocity.x = direction * move_speed
	velocity.y = 0
	
	move_and_slide()
	
	var mouse_pos := get_global_mouse_position()
	var dir := mouse_pos - cannon.global_position
	cannon.rotation = dir.angle()

	if global_position.y != 585:
		global_position.y = 585

	if multiplayer.has_multiplayer_peer():
		NetworkManager.broadcast_player_state(_get_current_peer_id(), global_position, cannon.rotation)

func shoot() -> void:
	if not attack_ready or reloading:
		return

	Player.current_ammo -= 1
	firerate_cooldown()

	if Player.current_ammo <= 0:
		reload()

	var owner_id := _get_current_peer_id()
	if owner_id <= 0:
		owner_id = multiplayer.get_unique_id() if multiplayer.has_multiplayer_peer() else 1

	var damage: int = Player.damage

	var shot_direction := (get_global_mouse_position() - muzzle.global_position).normalized()
	_spawn_bullet(muzzle.global_position, shot_direction, damage, owner_id)

	if multiplayer.has_multiplayer_peer():
		NetworkManager.broadcast_player_shot(owner_id, muzzle.global_position, shot_direction, damage)

func firerate_cooldown() -> void:
	update_firerate_cooldown()
	attack_ready = false
	fire_rate_timer.start()

func on_firerate_timeout() -> void:
	attack_ready = true

func update_firerate_cooldown() -> void:
	var fire_rate: float = Player.fire_rate
	fire_rate_timer.wait_time = fire_rate

func get_firerate_progress() -> float:
	var firerate_progress: float = fire_rate_timer.time_left
	return firerate_progress


func reload() -> void:
	reloading = true
	update_reload_cooldown()
	reload_timer.start()

func on_reload_timeout() -> void:
	Player.update_max_ammo()
	reloading = false
	

func update_reload_cooldown() -> void:
	var reload_cooldown: float = Player.reload_speed
	reload_timer.wait_time = reload_cooldown

func get_reload_progress() -> float:
	var reload_progress: float = reload_timer.time_left
	return reload_progress

func apply_remote_state(new_position: Vector2, new_cannon_rotation: float) -> void:
	if is_local_player:
		return

	global_position = new_position
	cannon.rotation = new_cannon_rotation

func _spawn_bullet(origin: Vector2, direction: Vector2, damage: int, owner_id: int) -> void:
	var bullet: Node = BULLET.instantiate()
	bullet.damage = damage
	bullet.owner_id = owner_id
	get_tree().root.add_child(bullet)
	bullet.global_position = origin
	bullet.fire_direction(direction)
