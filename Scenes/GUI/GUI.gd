# --- GUI ---
extends CanvasLayer

var main_scene: Node
var tank: Node
@onready var lifes_label: Label = %lifes_label
@onready var exp_bar: TextureProgressBar = %exp_bar
@onready var level: Label = %level
@onready var threat_level: Label = %threat_level
@onready var threat_bar: TextureProgressBar = %threat_bar

@onready var ammo_bar: TextureProgressBar = %ammo_bar
@onready var fire_rate_bar: TextureProgressBar = %fire_rate_bar
@onready var reload_bar: TextureProgressBar = %reload_bar

func _ready() -> void:
	reload_bar.value = 0
	tank = main_scene.battle_scene.tank

func _process(_delta: float) -> void:
	threat_level.text = str(main_scene.battle_scene.threat_level)
	threat_bar.value = main_scene.battle_scene.tick
	threat_bar.max_value = main_scene.battle_scene.threat_time
	lifes_label.text = "Lives: " + str(Player.lifes)
	exp_bar.value = Player.current_exp
	exp_bar.max_value = Player.max_exp
	
	ammo_bar.value = Player.current_ammo
	ammo_bar.max_value = Player.max_ammo
	
	fire_rate_bar.value = fire_rate_bar.max_value - tank.get_firerate_progress()
	fire_rate_bar.max_value = Player.fire_rate
	
	reload_bar.value = reload_bar.max_value - tank.get_reload_progress()
	reload_bar.max_value = Player.reload_speed
	
	level.text = str(Player.level)
