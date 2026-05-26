extends CanvasLayer

@onready var main_scene: Node
@onready var start_button: Button = %start_button
@onready var back_button: Button = %back_button


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_start_pressed() -> void:
	main_scene.instantiate_gui_scene()
	Gamecontrol.clock.start()
	Gamecontrol.in_game = true
	await get_tree().create_timer(0.1).timeout
	queue_free()

func _on_back_pressed() -> void:
	main_scene.instantiate_main_menu()
	queue_free()
