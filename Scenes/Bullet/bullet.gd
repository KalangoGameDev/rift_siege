extends Node2D
class_name Bullet

var damage: int
var owner_id: int = 0
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
		body.take_damage(damage, owner_id)
		_destroy()
	

func _tick() -> void:
	tick += 1
	if tick >= lifetime:
		_destroy()

func _process(delta: float) -> void:
	global_position += direction * speed * delta

func fire() -> void:
	fire_direction((get_global_mouse_position() - global_position).normalized())

func fire_direction(new_direction: Vector2) -> void:
	if new_direction == Vector2.ZERO:
		new_direction = Vector2.RIGHT
	direction = new_direction.normalized()

func _destroy() -> void:
	queue_free()
