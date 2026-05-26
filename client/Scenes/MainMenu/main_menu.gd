extends CanvasLayer

@onready var main_scene: Node

@onready var play_button: Button = %play_button
@onready var multiplayer_button: Button = %multiplayer_button
@onready var how_to_play__button: Button = %how_to_play__button
@onready var options_button: Button = %options_button
@onready var exit_button: Button = %exit_button

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	multiplayer_button.pressed.connect(_on_multiplayer_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_play_pressed() -> void:
	main_scene.instantiate_solo_play()
	queue_free()

func _on_multiplayer_pressed() -> void:
	main_scene.instantiate_multiplayer_scene()
	queue_free()

func _on_exit_pressed() -> void:
	queue_free()
