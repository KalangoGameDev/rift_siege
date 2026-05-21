extends CharacterBody2D

var move_speed: float

@onready var balttle_scene: Node2D = owner
@onready var muzzle: Node2D = $cannon/muzzle
const BULLET = preload("uid://bknpcmye04u3x")
@onready var cannon: Sprite2D = $cannon

@onready var main_scene

func _ready() -> void:
	fire_rate_timer = Timer.new()
	fire_rate_timer.one_shot = true
	fire_rate_timer.timeout.connect(on_firerate_timeout)
	add_child(fire_rate_timer)
	
	reload_timer = Timer.new()
	reload_timer.one_shot = true
	reload_timer.timeout.connect(on_reload_timeout)
	add_child(reload_timer)
	
	Player.movement_speed_updated_signal.connect(_update_ms)

func _update_ms() -> void:
	move_speed = Player.movement_speed

func _input(event: InputEvent) -> void:
	if not Gamecontrol.in_game:
		return
	
	if event.is_action_pressed("shoot"):
		shoot()

func _physics_process(_delta: float) -> void:
	if not Gamecontrol.in_game:
		return
	
	var direction := Input.get_axis("move_left", "move_right")
	move_speed = Player.movement_speed
	velocity.x = direction * move_speed
	velocity.y = 0
	
	move_and_slide()
	
	var mouse_pos := get_global_mouse_position()
	var dir := mouse_pos - cannon.global_position
	cannon.rotation = dir.angle()
	
	if global_position.y != 585:
		global_position.y = 585

func shoot() -> void:
	if not attack_ready or reloading:
		return
	
	Player.current_ammo -= 1
	firerate_cooldown()
	
	if Player.current_ammo <= 0:
		reload()
	
	var bullet: Node = BULLET.instantiate()
	var damage: int = Player.damage
	
	bullet.damage = damage
	get_tree().root.add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.fire()



var fire_rate_timer: Timer
var attack_ready: bool = true

func firerate_cooldown() -> void:
	update_firerate_cooldown()
	attack_ready = false
	fire_rate_timer.start()

func on_firerate_timeout() -> void:
	attack_ready = true

func update_firerate_cooldown() -> void:
	var fire_rate: float = Player.fire_rate
	fire_rate_timer.wait_time = fire_rate

func get_firerate_progress() -> float:
	var firerate_progress: float = fire_rate_timer.time_left
	return firerate_progress


var reload_timer: Timer
var reloading: bool = false

func reload() -> void:
	reloading = true
	update_reload_cooldown()
	reload_timer.start()

func on_reload_timeout() -> void:
	Player.update_max_ammo()
	reloading = false
	

func update_reload_cooldown() -> void:
	var reload_cooldown: float = Player.reload_speed
	reload_timer.wait_time = reload_cooldown

func get_reload_progress() -> float:
	var reload_progress: float = reload_timer.time_left
	return reload_progress
