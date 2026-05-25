extends Area2D

const DEMON = preload("uid://d0drbov7qjn3h")
@onready var area_shape: CollisionShape2D = %area_shape
@onready var battle_scene: Node2D = $".."

var tick: int = 0
var spawn_time = clamp(10, 0, 100)

func _ready() -> void:
	Gamecontrol.tick.connect(_tick)

func _tick() -> void:
	if NetworkManager.is_online() and not NetworkManager.is_host():
		return

	tick += 1
	
	if tick >= spawn_time:
		spawn_time = max(10, 101 - battle_scene.threat_level)
		var spawn_count := int(battle_scene.threat_level / 2) + 1
		
		for i in range(spawn_count):
			instantiate_demon()
		
		tick = 0

func instantiate_demon() -> void:
	var shape: RectangleShape2D = area_shape.shape
	var extents: Vector2 = shape.extents

	var local_pos := Vector2(
		randf_range(-extents.x, extents.x),
		randf_range(-extents.y, extents.y)
	)

	var global_pos := area_shape.global_position + local_pos
	var wait_time := max(1, 20 - battle_scene.threat_level)

	if multiplayer.has_multiplayer_peer():
		network_spawn_demon.rpc(global_pos, wait_time)
	else:
		_spawn_demon(global_pos, wait_time)

@rpc("any_peer", "call_local", "reliable")
func network_spawn_demon(global_pos: Vector2, wait_time: int) -> void:
	_spawn_demon(global_pos, wait_time)

func _spawn_demon(global_pos: Vector2, wait_time: int) -> void:
	var demon_instance: Node2D = DEMON.instantiate()
	add_child(demon_instance)
	demon_instance.wait_time = wait_time
	demon_instance.global_position = global_pos
