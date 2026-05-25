extends Parallax2D
@onready var _1: Sprite2D = $"1"
@onready var _2: Sprite2D = $"2"
@onready var _3: Sprite2D = $"3"

func _ready() -> void:
	_1.motion_scale = Vector2(0.2, 0.2)
	_2.motion_scale = Vector2(0.5, 0.5)
	_3.motion_scale = Vector2(0.9, 0.9)
