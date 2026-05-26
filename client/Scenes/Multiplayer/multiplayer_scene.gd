extends CanvasLayer

@onready var main_scene: Node

@onready var join_button: Button = %join_button
@onready var back_button: Button = %back_button

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)

func _on_join_pressed() -> void:
	pass

func _on_back_pressed() -> void:
	main_scene.instantiate_main_menu()
	queue_free()
