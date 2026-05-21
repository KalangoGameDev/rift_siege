extends Node

const MAIN_MENU = preload("uid://77vays8evmd6")
const OPTIONS = preload("uid://dyn6137r0meut")
const UPGRADE = preload("uid://bkdq0eef5ogt2")
const GUI = preload("uid://6q8b0yd4w3fg")

@onready var battle_scene: Node2D = %battle_scene
@onready var canvas: Node = %canvas

func _ready() -> void:
	instantiate_main_menu()
	Player.main_scene = self
	battle_scene.main_scene = self


var main_menu_scene: Node = null
func instantiate_main_menu() -> void:
	main_menu_scene = MAIN_MENU.instantiate()
	main_menu_scene.main_scene = self
	canvas.add_child(main_menu_scene)

var gui_scene: Node = null
func instantiate_gui_scene() -> void:
	gui_scene = GUI.instantiate()
	gui_scene.main_scene = self
	canvas.add_child(gui_scene)

var upgrade_scene: Node = null
func instantiate_upgrade_window() -> void:
	upgrade_scene = UPGRADE.instantiate()
	canvas.add_child(upgrade_scene)
