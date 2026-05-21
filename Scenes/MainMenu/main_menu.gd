extends CanvasLayer

@onready var main_scene: Node

@onready var high_score: Label = %high_score
@onready var play_button: Button = %play_button
@onready var how_to_play__button: Button = %how_to_play__button
@onready var options_button: Button = %options_button
@onready var exit_button: Button = %exit_button

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)

func _on_play_pressed() -> void:
	await get_tree().create_timer(0.1).timeout
	main_scene.instantiate_gui_scene()
	Gamecontrol.clock.start()
	Gamecontrol.in_game = true
	queue_free()
