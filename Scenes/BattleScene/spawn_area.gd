extends Area2D

const DEMON = preload("uid://d0drbov7qjn3h")
@onready var area_shape: CollisionShape2D = %area_shape
@onready var battle_scene: Node2D = $".."

var tick: int = 0
var spawn_time = clamp(10, 0, 100)

func _ready() -> void:
	Gamecontrol.tick.connect(_tick)

func _tick() -> void:
	tick += 1
	
	if tick >= spawn_time:
		spawn_time = 101 - battle_scene.threat_level
		var spawn_count := int(battle_scene.threat_level / 2) + 1
		
		for i in range(spawn_count):
			instantiate_demon()
		
		tick = 0

func instantiate_demon() -> void:
	var demon_instance: Node2D = DEMON.instantiate()
	add_child(demon_instance)
	
	demon_instance.wait_time = 20 - battle_scene.threat_level

	var shape: RectangleShape2D = area_shape.shape
	var extents: Vector2 = shape.extents

	var local_pos := Vector2(
		randf_range(-extents.x, extents.x),
		randf_range(-extents.y, extents.y)
	)

	var global_pos := area_shape.global_position + local_pos
	
	demon_instance.global_position = global_pos
