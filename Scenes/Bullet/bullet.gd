extends Node2D
class_name Bullet

var damage: int
var speed: float = 600.0
var tick: int
var lifetime: int = 10
var direction: Vector2 = Vector2.ZERO

@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	Gamecontrol.tick.connect(_tick)
	
	area_2d.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Demon:
		body.take_damage(damage)
		_destroy()
	

func _tick() -> void:
	tick += 1
	if tick >= lifetime:
		_destroy()

func _process(delta: float) -> void:
	global_position += direction * speed * delta

func fire() -> void:
	var mouse_pos := get_global_mouse_position()
	direction = (mouse_pos - global_position).normalized()

func _destroy() -> void:
	queue_free()
