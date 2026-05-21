extends Node

@onready var main_scene: Node

func _ready() -> void:
	starting_life()
	update_damage()
	update_movement_speed()
	update_fire_rate()
	update_reload_speed()
	
	update_max_ammo()


var upgrade_cards: int = 3
func gain_upgrade_cards(value:int) -> void:
	upgrade_cards += value

#region --- Life ---

var starting_lifes: int = 3
var lifes: int = 0

func gain_life(value:int) -> void:
	lifes += value

func lose_life(value:int) -> void:
	lifes -= value
	if lifes <= 0:
		_die()

func _die() -> void:
	pass

func starting_life() -> void:
	lifes = starting_lifes

#endregion


#region --- EXP ---
var luck: int = 10
signal level_up_signal
var current_exp: int = 0
var exp_modifier: float = 0.0
var max_exp: int = 400
var level: int = 0

func gain_luck(value: int) -> void:
	luck += value

func gain_exp(_exp: int) -> void:
	var final_exp: int = _exp * int(1 + exp_modifier)
	current_exp += final_exp
	if current_exp >= max_exp:
		level += 1
		gain_luck(2)
		emit_signal("level_up_signal")
		main_scene.instantiate_upgrade_window()
		current_exp = 0
		max_exp = max_exp + level * 200

func gain_exp_modifier(value: float) -> void:
	exp_modifier += value

func reset_exp() -> void:
	current_exp = 0
	max_exp = 1000
	level = 0

#endregion


#region --- Movement Speed ---

signal movement_speed_updated_signal
var base_movement_speed: float = 120.0
var movement_speed_modifier: float = 0.0
var movement_speed: float

func update_movement_speed() -> void:
	movement_speed = base_movement_speed * (1 + movement_speed_modifier)
	emit_signal("movement_speed_updated_signal")

func gain_movement_speed(value: float) -> void:
	movement_speed_modifier += value
	update_movement_speed()

func reset_movement_speed() -> void:
	movement_speed_modifier = 0.00
	update_movement_speed()
	
#endregion


#region --- Weapon ---

var base_damage: int = 10
var bonus_damage: int = 0
var damage: int

func update_damage() -> void:
	damage = base_damage + bonus_damage

func gain_bonus_damage(value: int) -> void:
	bonus_damage += value
	update_damage()

func reset_damage() -> void:
	bonus_damage = 0
	update_damage()

var current_ammo: int = clamp(0, 10, max_ammo)
var base_ammo: int = 10
var bonus_ammo: float = 0.0
var max_ammo: int = clamp(0, 10, 999)

func update_max_ammo() -> void:
	max_ammo = int(base_ammo * 1 + bonus_ammo)
	current_ammo = max_ammo

func gain_bonus_ammo(value: float) -> void:
	bonus_ammo += value
	update_max_ammo()

var base_reload_speed: float = 10.0
var bonus_reload_speed: float = 0.0
var reload_speed: float



var base_fire_rate: float = 1.0
var bonus_fire_rate: float = 0.0
var fire_rate: float

func update_fire_rate() -> void:
	fire_rate = base_fire_rate * 1 - bonus_fire_rate

func gain_fire_rate_bonus(value: float) -> void:
	bonus_fire_rate += value
	update_fire_rate()

func update_reload_speed() -> void:
	reload_speed = base_reload_speed# * 1 - base_reload_speed

func gain_reload_speed(value: float) -> void:
	reload_speed += value
	update_reload_speed()

#endregion
