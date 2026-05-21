extends Node

signal tick
var clock: Timer

var in_game: bool = false

func _ready() -> void:
	clock = Timer.new()
	clock.wait_time = 0.1
	clock.timeout.connect(_tick)
	clock.one_shot = false
	add_child(clock)


func start_tick() -> void:
	clock.start()

func stop_tick() -> void:
	clock.stop()

func _tick() -> void:
	emit_signal("tick")
