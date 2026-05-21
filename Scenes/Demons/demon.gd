extends CharacterBody2D
class_name Demon

var health: int = 10

var tick: int
var wait_time: int = clamp(5, 0, 40)
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	Gamecontrol.tick.connect(_tick)

func _tick() -> void:
	if not Gamecontrol.in_game:
		return
	
	tick += 1
	
	if tick >= wait_time:
		global_position.y += 40
		tick = 0

func take_damage(value: int) -> void:
	health -= value
	if health <= 0:
		Player.gain_exp(200)
		die()
		

func die() -> void:
	queue_free()
